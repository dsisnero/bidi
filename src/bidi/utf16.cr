# UTF-16 text support for the Unicode Bidirectional Algorithm

require "./level"
require "./info"
require "./prepare"
require "./char_data"
require "./data_source"

module Bidi
  module UTF16
    # Initial bidi information of the text (UTF-16 version).
    struct InitialInfo
      property text : Array(UInt16)
      property original_classes : Array(BidiClass)
      property paragraphs : Array(ParagraphInfo)

      def initialize(@text : Array(UInt16), @original_classes : Array(BidiClass), @paragraphs : Array(ParagraphInfo))
      end
    end

    private struct ParagraphInfoFlags
      property is_pure_ltr : Bool
      property has_isolate_controls : Bool

      def initialize(@is_pure_ltr : Bool, @has_isolate_controls : Bool)
      end
    end

    struct InitialInfoExt
      property original_classes : Array(BidiClass)
      property paragraphs : Array(ParagraphInfo)
      property flags : Array(ParagraphInfoFlags)

      def initialize(@original_classes : Array(BidiClass), @paragraphs : Array(ParagraphInfo), @flags : Array(ParagraphInfoFlags))
      end

      def self.new_with_data_source(data_source : BidiDataSource, text : Array(UInt16), default_para_level : Level?) : InitialInfoExt
        original_classes = [] of BidiClass
        paragraphs = [] of ParagraphInfo
        flags = [] of ParagraphInfoFlags

        isolate_stack = [] of Int32
        para_start = 0
        para_level = default_para_level
        is_pure_ltr = true
        has_isolate_controls = false

        i = 0
        text_each_char(text) do |c|
          bidi_class = data_source.bidi_class(c)
          char_len = c.unsafe_to_utf16_slice.size rescue 1

          char_len.times { original_classes << bidi_class }

          case bidi_class
          when BidiClass::B
            para_end = i + char_len
            paragraphs << ParagraphInfo.new(para_start...para_end, para_level || Level.ltr)
            flags << ParagraphInfoFlags.new(is_pure_ltr, has_isolate_controls)

            para_start = para_end
            para_level = default_para_level
            is_pure_ltr = true
            has_isolate_controls = false
            isolate_stack.clear
          when BidiClass::L, BidiClass::R, BidiClass::AL
            if bidi_class != BidiClass::L
              is_pure_ltr = false
            end
            if !isolate_stack.empty?
              start = isolate_stack.last
              if original_classes[start] == BidiClass::FSI
                fsi_len = 1
                fsi_len.times do |j|
                  original_classes[start + j] = bidi_class == BidiClass::L ? BidiClass::LRI : BidiClass::RLI
                end
              end
            elsif para_level.nil?
              para_level = bidi_class == BidiClass::L ? Level.ltr : Level.rtl
            end
          when BidiClass::AN, BidiClass::LRE, BidiClass::RLE, BidiClass::LRO, BidiClass::RLO
            is_pure_ltr = false
          when BidiClass::RLI, BidiClass::LRI, BidiClass::FSI
            is_pure_ltr = false
            has_isolate_controls = true
            isolate_stack << i
          when BidiClass::PDI
            isolate_stack.pop if !isolate_stack.empty?
          end

          i += char_len
        end

        if para_start < text.size
          paragraphs << ParagraphInfo.new(para_start...text.size, para_level || Level.ltr)
          flags << ParagraphInfoFlags.new(is_pure_ltr, has_isolate_controls)
        end

        InitialInfoExt.new(original_classes, paragraphs, flags)
      end
    end

    private def self.text_each_char(text : Array(UInt16), &block : Char ->)
      i = 0
      while i < text.size
        if text[i] < 0xD800 || text[i] > 0xDBFF
          if text[i] < 0xDC00 || text[i] > 0xDFFF
            yield text[i].chr rescue '\uFFFD'
            i += 1
          else
            yield '\uFFFD'
            i += 1
          end
        elsif i + 1 < text.size && text[i + 1] >= 0xDC00 && text[i + 1] <= 0xDFFF
          code = ((text[i] - 0xD800) << 10) + (text[i + 1] - 0xDC00) + 0x10000
          yield Char.new(code)
          i += 2
        else
          yield '\uFFFD'
          i += 1
        end
      end
    end

    # Bidi information of the text (UTF-16 version).
    struct BidiInfo
      property text : Array(UInt16)
      property original_classes : Array(BidiClass)
      property levels : Array(Level)
      property paragraphs : Array(ParagraphInfo)

      def initialize(@text : Array(UInt16), @original_classes : Array(BidiClass), @levels : Array(Level), @paragraphs : Array(ParagraphInfo))
      end

      def self.new(text : Array(UInt16), default_para_level : Level? = nil) : BidiInfo
        new_with_data_source(HardcodedBidiData.new, text, default_para_level)
      end

      def self.new_with_data_source(data_source : BidiDataSource, text : Array(UInt16), default_para_level : Level? = nil) : BidiInfo
        initial_info = InitialInfoExt.new_with_data_source(data_source, text, default_para_level)

        text_size = text.size
        levels = Array(Level).new(text_size, Level.ltr)
        processing_classes = initial_info.original_classes.dup

        initial_info.paragraphs.each_with_index do |para, idx|
          flags = initial_info.flags[idx]
          compute_bidi_info_for_para_utf16(data_source, para, flags.is_pure_ltr, flags.has_isolate_controls, text, initial_info.original_classes, processing_classes, levels)
        end

        BidiInfo.new(text, initial_info.original_classes, levels, initial_info.paragraphs)
      end

      private def self.compute_bidi_info_for_para_utf16(data_source : BidiDataSource, para : ParagraphInfo, is_pure_ltr : Bool, has_isolate_controls : Bool, text : Array(UInt16), original_classes : Array(BidiClass), processing_classes : Array(BidiClass), levels : Array(Level)) : Nil
        para.range.each do |i|
          levels[i] = para.level
        end

        return if para.level.ltr? && is_pure_ltr
      end

      def reordered_levels(line : Range(Int32, Int32)) : Array(Level)
        @levels[line]
      end

      def has_rtl? : Bool
        @levels.any?(&.rtl?)
      end

      def reorder_line(line : Range(Int32, Int32)) : String
        return "" unless line.begin < line.end
        return text_as_string(@text, line) unless has_rtl?
        levels = reordered_levels(line)
        _, runs = visual_runs(line)
        do_reorder_line(text_as_string(@text, line), line, levels, runs)
      end

      def self.reorder_visual(levels : Array(Level)) : Array(Int32)
        BidiInfo.reorder_visual(levels)
      end

      def visual_runs(line : Range(Int32, Int32)) : Tuple(Array(Level), Array(Range(Int32, Int32)))
        levels = reordered_levels(line)
        compute_visual_runs(levels, line)
      end

      private def self.compute_visual_runs(levels : Array(Level), line : Range(Int32, Int32)) : Tuple(Array(Level), Array(Range(Int32, Int32)))
        runs = [] of Range(Int32, Int32)
        start = line.begin
        return {levels, runs} if start >= levels.size || start >= line.end

        run_level = levels[start]
        min_level = run_level
        max_level = run_level

        ((start + 1)...line_end).each do |i|
          new_level = levels[i]
          if new_level != run_level
            runs << (start...i)
            start = i
            run_level = new_level
            min_level = Level.new(levels[i].value < min_level.value ? levels[i].value : min_level.value)
            max_level = Level.new(levels[i].value > max_level.value ? levels[i].value : max_level.value)
          end
        end
        runs << (start...line_end)

        {levels, runs}
      end

      private def self.do_reorder_line(text : String, line : Range(Int32, Int32), levels : Array(Level), runs : Array(Range(Int32, Int32))) : String
        parts = [] of String
        runs.each do |run|
          if l = levels[run.begin]?
            if l.rtl?
              parts << text[run].chars.reverse!.join
            else
              parts << text[run]
            end
          else
            parts << text[run]
          end
        end
        parts.join
      end

      private def text_as_string(text : Array(UInt16), line : Range(Int32, Int32)) : String
        String.build do |s|
          line.begin.upto(line.end - 1) do |i|
            s << text[i].chr rescue '\uFFFD'
          end
        end
      end

      private def line_end : Int32
        @levels.size
      end
    end

    struct Paragraph
      property info : BidiInfo
      property para : ParagraphInfo

      def initialize(@info : BidiInfo, @para : ParagraphInfo)
      end

      def direction : Direction
        ltr = false
        rtl = false
        @info.levels[@para.range].each do |level|
          if level.ltr?
            ltr = true
            return Direction::Mixed if rtl
          end
          if level.rtl?
            rtl = true
            return Direction::Mixed if ltr
          end
        end
        return Direction::Ltr if ltr
        Direction::Rtl
      end

      def level_at(pos : Int32) : Level
        @info.levels[@para.range.begin + pos]
      end
    end

    struct ParagraphBidiInfo
      property text : Array(UInt16)
      property original_classes : Array(BidiClass)
      property levels : Array(Level)
      property paragraph_level : Level
      property is_pure_ltr : Bool

      def initialize(@text : Array(UInt16), @original_classes : Array(BidiClass), @levels : Array(Level), @paragraph_level : Level, @is_pure_ltr : Bool)
      end

      def self.new(text : Array(UInt16), default_para_level : Level? = nil) : ParagraphBidiInfo
        new_with_data_source(HardcodedBidiData.new, text, default_para_level)
      end

      def self.new_with_data_source(data_source : BidiDataSource, text : Array(UInt16), default_para_level : Level? = nil) : ParagraphBidiInfo
        original_classes = [] of BidiClass
        para_level = default_para_level
        is_pure_ltr = true
        has_isolate_controls = false

        text_each_char(text) do |c|
          bidi_class = data_source.bidi_class(c)

          case bidi_class
          when BidiClass::L, BidiClass::R, BidiClass::AL
            if bidi_class != BidiClass::L
              is_pure_ltr = false
            end
            para_level = bidi_class == BidiClass::L ? Level.ltr : Level.rtl if para_level.nil?
          when BidiClass::AN, BidiClass::LRE, BidiClass::RLE, BidiClass::LRO, BidiClass::RLO
            is_pure_ltr = false
          when BidiClass::RLI, BidiClass::LRI, BidiClass::FSI
            is_pure_ltr = false
            has_isolate_controls = true
          end
        end

        paragraph_level = para_level || Level.ltr
        levels = Array(Level).new(text.size, paragraph_level)

        if paragraph_level.ltr? && is_pure_ltr
          return ParagraphBidiInfo.new(text, original_classes, levels, paragraph_level, is_pure_ltr)
        end

        ParagraphBidiInfo.new(text, original_classes, levels, paragraph_level, is_pure_ltr)
      end

      def reordered_levels(line : Range(Int32, Int32)) : Array(Level)
        @levels[line]
      end

      def reorder_line(line : Range(Int32, Int32)) : String
        return "" unless has_rtl?
        "TODO"
      end

      def self.reorder_visual(levels : Array(Level)) : Array(Int32)
        BidiInfo.reorder_visual(levels)
      end

      def visual_runs(line : Range(Int32, Int32)) : Tuple(Array(Level), Array(Range(Int32, Int32)))
        BidiInfo.visual_runs_for_line(@levels, line)
      end

      def has_rtl? : Bool
        !@is_pure_ltr
      end

      def direction : Direction
        return Direction::Ltr if @is_pure_ltr
        ltr = false
        rtl = false
        @levels.each do |level|
          if level.ltr?
            ltr = true
            return Direction::Mixed if rtl
          end
          if level.rtl?
            rtl = true
            return Direction::Mixed if ltr
          end
        end
        return Direction::Ltr if ltr
        Direction::Rtl
      end
    end
  end
end
