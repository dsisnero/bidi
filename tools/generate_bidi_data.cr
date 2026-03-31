#!/usr/bin/env crystal

# Port of vendor/unicode-bidi/tools/generate.py to Crystal
# Generates Bidi data tables from Unicode data files

require "file_utils"
require "http/client"
require "uri"

DATA_DIR = "data/ucd"
TESTS_DATA_DIR = "tests/data"
README_NAME = "ReadMe.txt"
UNICODE_DATA_NAME = "UnicodeData.txt"
BIDI_BRACKETS_NAME = "BidiBrackets.txt"
DERIVED_BIDI_CLASS_NAME = "extracted/DerivedBidiClass.txt"
UNIDATA_SOURCE = "https://www.unicode.org/Public/16.0.0/ucd"  # Unicode 16.0.0 (matches Rust)
TABLES_PATH = "src/bidi/char_data/tables_data.cr"

# Surrogate codepoints, which are not valid characters
SURROGATE_RANGE = 0xD800..0xDFFF

def fetch(name : String, dst : String)
  unless File.exists?(dst)
    puts "Downloading #{name} to #{dst}"
    url = "#{UNIDATA_SOURCE}/#{name}"

    begin
      HTTP::Client.get(url) do |response|
        if response.status.success?
          File.write(dst, response.body_io.gets_to_end)
        else
          STDERR.puts "Failed to fetch #{url}: #{response.status}"
          exit(1)
        end
      end
    rescue ex
      STDERR.puts "Error fetching #{url}: #{ex.message}"
      exit(1)
    end
  end
end

def fetch_data(name : String)
  dst = File.join(DATA_DIR, File.basename(name))
  fetch(name, dst)
end

def fetch_test_data(name : String)
  dst = File.join(TESTS_DATA_DIR, File.basename(name))
  fetch(name, dst)
end

def load_unicode_data
  puts "Loading Unicode data..."

  udict = {} of Int32 => Array(String)
  on_decomps = {} of Int32 => String

  path = File.join(DATA_DIR, UNICODE_DATA_NAME)
  unless File.exists?(path)
    STDERR.puts "Missing #{path}"
    exit(1)
  end

  range_start = nil

  File.each_line(path) do |line|
    next if line.empty? || line.starts_with?('#')

    data = line.split(';')
    cp = data[0].to_i(16)

    # Skip surrogate codepoints
    next if SURROGATE_RANGE.includes?(cp)

    if data[1].ends_with?(", First>")
      range_start = cp
      next
    elsif data[1].ends_with?(", Last>") && range_start
      # Handle range
      (range_start..cp).each do |range_cp|
        next if SURROGATE_RANGE.includes?(range_cp)
        udict[range_cp] = data.clone
        udict[range_cp][1] = data[1].gsub(", Last>", ">")
      end
      range_start = nil
    else
      udict[cp] = data
    end
  end

  # Mapping of code point to Bidi_Class property
  bidi_class = {} of String => Array(Int32)

  udict.each do |code, data|
    bidi = data[4]  # Bidi_Class field

    bidi_class[bidi] ||= [] of Int32
    bidi_class[bidi] << code

    decomp = data[5]  # Decomposition field
    if !decomp.empty? && !decomp.includes?(' ')
      on_decomps[code] = decomp
    end
  end

  # Default Bidi_Class for unassigned codepoints.
  # From http://www.unicode.org/Public/UNIDATA/extracted/DerivedBidiClass.txt
  default_ranges = [
    {0x0600, 0x07BF, "AL"}, {0x08A0, 0x08FF, "AL"},
    {0xFB50, 0xFDCF, "AL"}, {0xFDF0, 0xFDFF, "AL"},
    {0xFE70, 0xFEFF, "AL"}, {0x1EE00, 0x1EEFF, "AL"},

    {0x0590, 0x05FF, "R"}, {0x07C0, 0x089F, "R"},
    {0xFB1D, 0xFB4F, "R"}, {0x10800, 0x10FFF, "R"},
    {0x1E800, 0x1EDFF, "R"}, {0x1EF00, 0x1EFFF, "R"},

    {0x20A0, 0x20CF, "ET"},
  ]

  default_ranges.each do |start, end_, default|
    (start..end_).each do |code|
      unless udict.has_key?(code) || SURROGATE_RANGE.includes?(code)
        bidi_class[default] ||= [] of Int32
        bidi_class[default] << code
      end
    end
  end

  {group_categories(bidi_class), on_decomps}
end

def group_categories(cats : Hash(String, Array(Int32)))
  cats_out = [] of Tuple(Int32, Int32, String)

  cats.each do |cat, codes|
    group_cat(codes).each do |start, end_|
      cats_out << {start, end_, cat}
    end
  end

  cats_out.sort_by! { |start, end_, cat| start }
  cats_out
end

def group_cat(codes : Array(Int32))
  return [] of Tuple(Int32, Int32) if codes.empty?

  # Filter out surrogate codepoints
  filtered = codes.select { |code| !SURROGATE_RANGE.includes?(code) }
  return [] of Tuple(Int32, Int32) if filtered.empty?

  sorted = filtered.sort.uniq
  result = [] of Tuple(Int32, Int32)

  cur_start = sorted.first
  cur_end = cur_start

  sorted[1..].each do |code|
    # Check if we're crossing surrogate boundary
    if code == cur_end + 1 && !(cur_end == 0xD7FF && code == 0xD800) # Not crossing D800 boundary
      cur_end = code
    else
      result << {cur_start, cur_end}
      cur_start = cur_end = code
    end
  end

  result << {cur_start, cur_end}
  result
end

def escape_char(c : Int32) : String
  "\\u{#{c.to_s(16)}}"
end

def emit_bidi_class_table(file : File, table_data : Array(Tuple(Int32, Int32, String)))
  file.puts "    BIDI_CLASS_TABLE = ["

  table_data.each_with_index do |(start, end_, cat), i|
    crystal_cat = "BidiClass::#{cat}"
    entry = "      {'#{escape_char(start)}', '#{escape_char(end_)}', #{crystal_cat}}"
    entry += "," unless i == table_data.size - 1
    file.puts entry
  end

  file.puts "    ]"
end

def load_bidi_brackets
  puts "Loading Bidi brackets data..."

  pairs = [] of Tuple(Int32, Int32, Int32?)  # (opening, closing, normalized)

  path = File.join(DATA_DIR, BIDI_BRACKETS_NAME)
  unless File.exists?(path)
    STDERR.puts "Missing #{path}"
    return pairs
  end

  File.each_line(path) do |line|
    next if line.empty? || line.starts_with?('#')

    # Format: 0028; 0029; o # LEFT PARENTHESIS; RIGHT PARENTHESIS
    parts = line.split(';').map(&.strip)
    next if parts.size < 3

    opening = parts[0].to_i(16)
    closing = parts[1].to_i(16)
    bpt = parts[2]  # Bidi_Paired_Bracket_Type: o (open), c (close), or n (none)

    next if bpt == "n"

    # Get normalized form if present (4th field)
    normalized = parts.size > 3 ? parts[3].to_i?(16) : nil

    pairs << {opening, closing, normalized}
  end

  pairs
end

def emit_bidi_pairs_table(file : File, pairs_data : Array(Tuple(Int32, Int32, Int32?)))
  file.puts "    BIDI_PAIRS_TABLE = ["

  pairs_data.each_with_index do |(opening, closing, normalized), i|
    norm_str = normalized ? "'#{escape_char(normalized)}'" : "nil"
    entry = "      {'#{escape_char(opening)}', '#{escape_char(closing)}', #{norm_str}}"
    entry += "," unless i == pairs_data.size - 1
    file.puts entry
  end

  file.puts "    ]"
end

def main
  puts "Generating Bidi data tables for Crystal..."

  # Create directories
  FileUtils.mkdir_p(DATA_DIR)
  FileUtils.mkdir_p(TESTS_DATA_DIR)
  FileUtils.mkdir_p(File.dirname(TABLES_PATH))

  # Fetch data files
  fetch_data(UNICODE_DATA_NAME)
  fetch_data(BIDI_BRACKETS_NAME)
  fetch_data(DERIVED_BIDI_CLASS_NAME)

  # Fetch test data
  fetch_test_data("BidiTest.txt")
  fetch_test_data("BidiCharacterTest.txt")

  # Load and process data
  bidi_table_data, on_decomps = load_unicode_data
  bidi_pairs_data = load_bidi_brackets

  puts "Generating #{bidi_table_data.size} Bidi class ranges..."
  puts "Generating #{bidi_pairs_data.size} Bidi bracket pairs..."

  # Generate Crystal file
  File.open(TABLES_PATH, "w") do |file|
    file.puts "# NOTE:"
    file.puts "# The following code was generated by \"tools/generate_bidi_data.cr\" from"
    file.puts "# Unicode data files (Unicode #{UNIDATA_SOURCE.split('/')[-2]})."
    file.puts "# Do not edit directly."
    file.puts
    file.puts "module Bidi"
    file.puts "  module CharData"

    emit_bidi_class_table(file, bidi_table_data)
    file.puts
    emit_bidi_pairs_table(file, bidi_pairs_data)

    file.puts "  end"
    file.puts "end"
  end

  puts "Successfully generated #{TABLES_PATH}"

  # Also copy test data to spec directory
  puts "Copying test data to spec directory..."
  test_files = ["BidiTest.txt", "BidiCharacterTest.txt"]
  test_files.each do |test_file|
    src = File.join(TESTS_DATA_DIR, test_file)
    dst = File.join("spec", "data", test_file)
    if File.exists?(src)
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
      puts "  Copied #{test_file}"
    end
  end
end

# Run main
main