require "./src/bidi"

puts "Testing BidiInfo.new with LRE and different base levels..."
lre_string = Bidi::FormatChars::LRE.to_s

test_cases = [
  {name: "nil (auto)", level: nil},
  {name: "LTR", level: Bidi::Level.ltr},
  {name: "RTL", level: Bidi::Level.rtl},
]

test_cases.each do |tc|
  puts "\nTest: #{tc[:name]}"
  start = Time.instant
  begin
    info = Bidi::BidiInfo.new(lre_string, tc[:level])
    elapsed = Time.instant - start
    puts "  Success! in #{elapsed.total_milliseconds} ms"
    puts "  Paragraphs: #{info.paragraphs.size}"
    if info.paragraphs.size > 0
      puts "  Paragraph level: #{info.paragraphs[0].level}"
    end
  rescue ex
    elapsed = Time.instant - start
    puts "  Exception after #{elapsed.total_milliseconds} ms: #{ex}"
  end
end

puts "\nDone."
