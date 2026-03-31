# 3.3.4 - 3.3.6. Resolve implicit levels and types.
#
# <http://www.unicode.org/reports/tr9/#Resolving_Implicit_Levels>

# 3.3.4 Resolving Weak Types
#
# <http://www.unicode.org/reports/tr9/#Resolving_Weak_Types>
def Bidi.resolve_weak(
  text : String,
  sequence : IsolatingRunSequence,
  processing_classes : Array(BidiClass),
  start : Int32 = 0,
) : Nil
  # Note: The spec treats these steps as individual passes that are applied one after the other
  # on the entire IsolatingRunSequence at once. We instead collapse it into a single iteration,
  # which is straightforward for rules that are based on the state of the current character, but not
  # for rules that care about surrounding characters. To deal with them, we retain additional state
  # about previous character classes that may have since been changed by later rules.

  # The previous class for the purposes of rule W4/W6, not tracking changes made after or during W4.
  prev_class_before_w4 = sequence.sos
  # The previous class for the purposes of rule W5.
  prev_class_before_w5 = sequence.sos
  # The previous class for the purposes of rule W1, not tracking changes from any other rules.
  prev_class_before_w1 = sequence.sos
  last_strong_is_al = false
  et_run_indices = [] of Int32 # for W5
  bn_run_indices = [] of Int32 # for W5 + <https://www.unicode.org/reports/tr9/#Retaining_Explicit_Formatting_Characters>

  sequence.runs.each_with_index do |level_run, _run_index|
    # puts "resolve_weak: processing run #{run_index}: #{level_run} (processing_classes size: #{processing_classes.size})"
    level_run.each do |i|
      # Skip BN characters (they're not real for processing)
      if processing_classes[i] == BidiClass::BN
        # Keep track of bn runs for W5 in case we see an ET
        bn_run_indices << i
        # BNs aren't real, skip over them
        next
      end

      # Store the processing class of all rules before W2/W1
      # Used to keep track of the last strong character for W2
      w2_processing_class = processing_classes[i]

      # W1: NSM handling
      if processing_classes[i] == BidiClass::NSM
        processing_classes[i] = case prev_class_before_w1
                                when BidiClass::RLI, BidiClass::LRI, BidiClass::FSI, BidiClass::PDI
                                  BidiClass::ON
                                else
                                  prev_class_before_w1
                                end
        # W1 occurs before W2, update this.
        w2_processing_class = processing_classes[i]
      end

      prev_class_before_w1 = processing_classes[i]

      # W2 and W3
      #
      # <http://www.unicode.org/reports/tr9/#W2>
      # <http://www.unicode.org/reports/tr9/#W3>
      case processing_classes[i]
      when BidiClass::EN
        if last_strong_is_al
          # W2. If previous strong char was AL, change EN to AN.
          processing_classes[i] = BidiClass::AN
        end
      when BidiClass::AL
        # W3. Change AL to R.
        if (i >= 11 && i <= 12) || (i >= 24 && i <= 25)
        end
        processing_classes[i] = BidiClass::R
      end

      # update last_strong_is_al.
      case w2_processing_class
      when BidiClass::L, BidiClass::R
        last_strong_is_al = w2_processing_class == BidiClass::AL
      end

      # W4: A single European separator between two European numbers changes to a European number.
      # W5: A sequence of European terminators adjacent to European numbers changes to all European numbers.
      # W6: Otherwise, separators and terminators change to Other Neutral.
      #
      # <http://www.unicode.org/reports/tr9/#W4>
      # <http://www.unicode.org/reports/tr9/#W5>
      # <http://www.unicode.org/reports/tr9/#W6>
      class_before_w456 = processing_classes[i]

      # W4.
      if processing_classes[i] == BidiClass::ES
        if prev_class_before_w4 == BidiClass::EN && sequence.eos == BidiClass::EN
          processing_classes[i] = BidiClass::EN
        end
      end

      # W5.
      if processing_classes[i] == BidiClass::ET
        if prev_class_before_w5 == BidiClass::EN
          processing_classes[i] = BidiClass::EN
        else
          # Keep track of ET runs for W6
          et_run_indices << i
          # Also apply to any preceding BN runs
          bn_run_indices.each do |j|
            processing_classes[j] = BidiClass::EN
          end
          bn_run_indices.clear
        end
      elsif processing_classes[i] == BidiClass::EN
        # Convert any preceding ET runs to EN
        et_run_indices.each do |j|
          processing_classes[j] = BidiClass::EN
        end
        et_run_indices.clear
        # Also apply to any preceding BN runs
        bn_run_indices.each do |j|
          processing_classes[j] = BidiClass::EN
        end
        bn_run_indices.clear
      end

      # W6 (separators only)
      if processing_classes[i] == BidiClass::CS
        if prev_class_before_w4 == BidiClass::EN && sequence.eos == BidiClass::EN
          processing_classes[i] = BidiClass::EN
        elsif prev_class_before_w4 == BidiClass::AN && sequence.eos == BidiClass::AN
          processing_classes[i] = BidiClass::AN
        end
      end

      # <https://www.unicode.org/reports/tr9/#Retaining_Explicit_Formatting_Characters>
      # BN runs would have already continued the loop, clear them before we get to the next one.
      bn_run_indices.clear

      # W6 above only deals with separators, so it doesn't change anything W5 cares about,
      # so we still can update this after running that part of W6.
      prev_class_before_w5 = processing_classes[i]

      # W6 (terminators only)
      if prev_class_before_w5 != BidiClass::ET
        # W6: If we didn't find an adjacent EN, turn any ETs into ON instead
        et_run_indices.each do |j|
          processing_classes[j] = BidiClass::ON
        end
        et_run_indices.clear
      end

      # Update prev_class_before_w4
      prev_class_before_w4 = class_before_w456
    end
  end

  # Final W6 check in case we ended with a sequence of BNs
  et_run_indices.each do |j|
    processing_classes[j] = BidiClass::ON
  end
  et_run_indices.clear

  # W7: If the previous strong char was L, change EN to L
  last_strong_is_l = sequence.sos == BidiClass::L
  sequence.runs.each do |level_run|
    level_run.each do |i|
      case processing_classes[i]
      when BidiClass::EN
        if last_strong_is_l
          processing_classes[i] = BidiClass::L
        end
      when BidiClass::L
        last_strong_is_l = true
      when BidiClass::R, BidiClass::AL
        last_strong_is_l = false
      end
    end
  end
end

# 3.3.5 Resolving Neutral and Isolate Formatting Types
#
# <http://www.unicode.org/reports/tr9/#Resolving_Neutral_and_Isolate_Formatting_Types>
# Bracket pair identified by `identify_bracket_pairs`
struct Bidi::BracketPair
  # The text-relative index of the opening bracket
  getter start : Int32
  # The text-relative index of the closing bracket
  getter end : Int32
  # The index of the run (in the run sequence) that the opening bracket is in
  getter start_run : Int32
  # The index of the run (in the run sequence) that the closing bracket is in
  getter end_run : Int32

  def initialize(@start : Int32, @end : Int32, @start_run : Int32, @end_run : Int32)
  end
end

# Neutral or Isolate formatting character (B, S, WS, ON, FSI, LRI, RLI, PDI)
#
# <http://www.unicode.org/reports/tr9/#NI>
def Bidi.ni?(bidi_class : BidiClass) : Bool
  case bidi_class
  when BidiClass::B, BidiClass::S, BidiClass::WS, BidiClass::ON,
       BidiClass::FSI, BidiClass::LRI, BidiClass::RLI, BidiClass::PDI
    true
  else
    false
  end
end

# 3.1.3 Identifying Bracket Pairs
#
# Returns all paired brackets in the source, as indices into the
# text source.
#
# <https://www.unicode.org/reports/tr9/#BD16>
def Bidi.identify_bracket_pairs(
  text : String,
  data_source : BidiDataSource,
  run_sequence : IsolatingRunSequence,
  original_classes : Array(BidiClass),
  bracket_pairs : Array(BracketPair),
) : Nil
  stack = [] of Tuple(Char, Int32, Int32) # (opening_char, index, run_index)

  run_sequence.runs.each_with_index do |level_run, run_index|
    # Iterate through byte indices in the level run
    level_run.each do |i|
      # Check bounds
      break if i >= text.bytesize

      # All paren characters are ON.
      # From BidiBrackets.txt:
      # > The Unicode property value stability policy guarantees that characters
      # > which have bpt=o or bpt=c also have bc=ON and Bidi_M=Y
      if original_classes[i] != BidiClass::ON
        next
      end

      # Get character at byte index i
      # Note: This assumes i is a valid byte index for a character boundary
      # In a proper implementation, we should use char_indices to handle multi-byte characters
      ch = text[i]?
      next unless ch # Skip if out of bounds

      if matched = data_source.bidi_matched_opening_bracket(ch)
        if matched.is_open
          # > If an opening paired bracket is found ...

          # > ... and there is no room in the stack,
          # > stop processing BD16 for the remainder of the isolating run sequence.
          if stack.size >= 63
            return
          end
          # > ... push its Bidi_Paired_Bracket property value and its text position onto the stack
          stack.push({matched.opening, i, run_index})
        else
          # > If a closing paired bracket is found, do the following

          # > Declare a variable that holds a reference to the current stack element
          # > and initialize it with the top element of the stack.
          # AND
          # > Else, if the current stack element is not at the bottom of the stack
          stack_index = stack.size - 1
          while stack_index >= 0
            element = stack[stack_index]
            # > Compare the closing paired bracket being inspected or its canonical
            # > equivalent to the bracket in the current stack element.
            if element[0] == matched.opening
              # > If the values match, meaning the two characters form a bracket pair, then

              # > Append the text position in the current stack element together with the
              # > text position of the closing paired bracket to the list.
              pair = BracketPair.new(
                element[1],
                i,
                element[2],
                run_index
              )
              bracket_pairs.push(pair)

              # > Pop the stack through the current stack element inclusively.
              stack = stack[0...stack_index]
              break
            end
            stack_index -= 1
          end
        end
      end
    end
  end

  # > Sort the list of pairs of text positions in ascending order based on
  # > the text position of the opening paired bracket.
  bracket_pairs.sort_by!(&.start)
end

def Bidi.resolve_neutral(
  data_source : BidiDataSource,
  text : String,
  sequence : IsolatingRunSequence,
  levels : Array(Level),
  original_classes : Array(BidiClass),
  processing_classes : Array(BidiClass),
) : Nil
  # e = embedding direction
  e = levels[sequence.runs[0].begin].bidi_class
  not_e = e == BidiClass::L ? BidiClass::R : BidiClass::L

  # N0. Process bracket pairs.

  # > Identify the bracket pairs in the current isolating run sequence according to BD16.
  # We use processing_classes, not original_classes, due to BD14/BD15
  bracket_pairs = [] of BracketPair
  identify_bracket_pairs(text, data_source, sequence, processing_classes, bracket_pairs)

  # > For each bracket-pair element in the list of pairs of text positions
  bracket_pairs.each do |pair|
    found_e = false
    found_not_e = false
    class_to_set = nil.as(BidiClass?)

    # > Inspect the bidirectional types of the characters enclosed within the bracket pair.
    # Note: We need to iterate through characters between the brackets
    # For simplicity, we'll iterate through indices in the sequence
    sequence.iter_forwards_from(pair.start + 1, pair.start_run).each do |enclosed_i|
      break if enclosed_i >= pair.end
      bidi_class = processing_classes[enclosed_i]
      if bidi_class == e
        found_e = true
      elsif bidi_class == not_e
        found_not_e = true
      elsif bidi_class == BidiClass::EN || bidi_class == BidiClass::AN
        # > Within this scope, bidirectional types EN and AN are treated as R.
        if e == BidiClass::L
          found_not_e = true
        else
          found_e = true
        end
      end

      # If we have found a character with the class of the embedding direction
      # we can bail early.
      break if found_e
    end

    # > If any strong type (either L or R) matching the embedding direction is found
    if found_e
      # > .. set the type for both brackets in the pair to match the embedding direction
      class_to_set = e
      # > Otherwise, if there is a strong type it must be opposite the embedding direction
    elsif found_not_e
      # > Therefore, test for an established context with a preceding strong type by
      # > checking backwards before the opening paired bracket
      # > until the first strong type (L, R, or sos) is found.
      previous_strong = sequence.sos
      sequence.iter_backwards_from(pair.start, pair.start_run).each do |i|
        bidi_class = processing_classes[i]
        if bidi_class == BidiClass::L || bidi_class == BidiClass::R ||
           bidi_class == BidiClass::EN || bidi_class == BidiClass::AN
          previous_strong = bidi_class
          break
        end
      end

      # > Within this scope, bidirectional types EN and AN are treated as R.
      if previous_strong == BidiClass::EN || previous_strong == BidiClass::AN
        previous_strong = BidiClass::R
      end

      # > If the preceding strong type is also opposite the embedding direction,
      # > context is established,
      # > so set the type for both brackets in the pair to that direction.
      # AND
      # > Otherwise set the type for both brackets in the pair to the embedding direction.
      # > Either way it gets set to previous_strong
      #
      # Both branches amount to setting the type to the strong type.
      class_to_set = previous_strong
    end

    if class_to_set
      # Update the processing classes for the brackets
      processing_classes[pair.start] = class_to_set
      processing_classes[pair.end] = class_to_set

      # > Any number of characters that had original bidirectional character type NSM prior to the application of
      # > W1 that immediately follow a paired bracket which changed to L or R under N0 should change to match the type of their preceding bracket.

      # Update NSMs after opening bracket
      (pair.start + 1).upto(pair.end - 1) do |idx|
        # Check if idx is in the sequence
        in_sequence = sequence.runs.any?(&.includes?(idx))
        break unless in_sequence
        if original_classes[idx] == BidiClass::NSM || processing_classes[idx] == BidiClass::BN
          processing_classes[idx] = class_to_set
        else
          break
        end
      end

      # Update NSMs after closing bracket
      (pair.end + 1).upto(text.size - 1) do |idx|
        # Check if idx is in the sequence
        in_sequence = sequence.runs.any?(&.includes?(idx))
        break unless in_sequence
        if original_classes[idx] == BidiClass::NSM || processing_classes[idx] == BidiClass::BN
          processing_classes[idx] = class_to_set
        else
          break
        end
      end
    end
    # > Otherwise, there are no strong types within the bracket pair
    # > Therefore, do not set the type for that bracket pair
  end

  # N1 and N2.
  # Indices of every byte in this isolating run sequence
  indices = sequence.runs.flat_map(&.to_a).each
  prev_class = sequence.sos

  loop do
    i_value = indices.next
    break if i_value.is_a?(Iterator::Stop)
    i = i_value.as(Int32)

    # Process sequences of NI characters.
    ni_run = [] of Int32
    # The BN is for <https://www.unicode.org/reports/tr9/#Retaining_Explicit_Formatting_Characters>
    if ni?(processing_classes[i]) || processing_classes[i] == BidiClass::BN
      # Consume a run of consecutive NI characters.
      ni_run << i
      next_class = nil.as(BidiClass?)

      loop do
        j_value = indices.next
        if j_value.is_a?(Iterator::Stop)
          next_class = sequence.eos
          break
        else
          j_idx = j_value.as(Int32)
          next_class = processing_classes[j_idx]
          # The BN is for <https://www.unicode.org/reports/tr9/#Retaining_Explicit_Formatting_Characters>
          if ni?(next_class) || next_class == BidiClass::BN
            ni_run << j_idx
          else
            break
          end
        end
      end

      # N1-N2.
      #
      # <http://www.unicode.org/reports/tr9/#N1>
      # <http://www.unicode.org/reports/tr9/#N2>
      new_class = case {prev_class, next_class}
                  when {BidiClass::L, BidiClass::L}
                    BidiClass::L
                  when {BidiClass::R, BidiClass::R},
                       {BidiClass::R, BidiClass::AN},
                       {BidiClass::R, BidiClass::EN},
                       {BidiClass::AN, BidiClass::R},
                       {BidiClass::AN, BidiClass::AN},
                       {BidiClass::AN, BidiClass::EN},
                       {BidiClass::EN, BidiClass::R},
                       {BidiClass::EN, BidiClass::AN},
                       {BidiClass::EN, BidiClass::EN}
                    BidiClass::R
                  else
                    e
                  end

      ni_run.each do |idx|
        processing_classes[idx] = new_class
      end
      ni_run.clear
    end
    prev_class = processing_classes[i]
  end
end

# 3.3.6 Resolving Implicit Levels
#
# <http://www.unicode.org/reports/tr9/#Resolving_Implicit_Levels>
def Bidi.resolve_levels(
  processing_classes : Array(BidiClass),
  levels : Array(Level),
  start : Int32 = 0,
  size : Int32? = nil,
) : Level
  actual_size = size || processing_classes.size
  max_level = Level.ltr

  actual_size.times do |rel_i|
    i = start + rel_i
    bidi_class = processing_classes[i]
    next unless bidi_class.not_removed_by_x9?

    # DEBUG
    if i == 11 || i == 24 || i == 25
    end

    # I1. For all characters with an even (left-to-right) embedding direction
    # I2. For all characters with an odd (right-to-left) embedding direction
    if levels[i].rtl?
      # Odd level (RTL) - I2
      case bidi_class
      when BidiClass::L, BidiClass::EN, BidiClass::AN
        # I2. L, EN, AN -> raise level by 1 (odd → even for L, odd+1=even for EN/AN)
        level = levels[i]
        level.raise(1_u8)
        levels[i] = level
        # DEBUG
        # puts "  RTL, L/EN/AN -> raise(1), level after=#{levels[i]}"
      when BidiClass::R
        # I2. R -> no change (stays odd)
        # DEBUG
        # puts "  RTL, R -> no change"
      end
    else
      # Even level (LTR) - I1
      case bidi_class
      when BidiClass::R
        # I1. R -> raise level by 1 (even → odd)
        level = levels[i]
        level.raise(1_u8)
        levels[i] = level
        # DEBUG
        if i == 11 || i == 24 || i == 25
        end
      when BidiClass::EN, BidiClass::AN
        # I1. EN, AN -> raise level by 2 (even → even+2 = next even)
        level = levels[i]
        level.raise(2_u8)
        levels[i] = level
        # DEBUG
        # puts "  LTR, EN/AN -> raise(2), level after=#{levels[i]}"
      when BidiClass::L
        # I1. L -> no change
        # DEBUG
        # puts "  LTR, L -> no change"
      end
    end

    max_level = Level.max(max_level, levels[i])
  end

  max_level
end
