# Test each_char with LRE character
lre_char = '\u{202A}'  # LEFT-TO-RIGHT EMBEDDING
lre_string = lre_char.to_s
puts "LRE string: #{lre_string.inspect}"
puts "LRE ord: 0x#{lre_char.ord.to_s(16).upcase}"

puts "\nTesting each_char:"
count = 0
lre_string.each_char do |c|
  puts "Char: #{c.inspect} (U+0x#{c.ord.to_s(16).upcase})"
  count += 1
  break if count > 5
end
puts "Done"
