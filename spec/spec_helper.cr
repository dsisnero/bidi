require "spec"
require "../src/bidi"

# Add spec helpers here

module SpecHelpers
  # Convert a string to UTF-16 array for testing
  def self.to_utf16(s : String) : Array(UInt16)
    result = [] of UInt16
    s.each_char do |c|
      if c.ord < 0x10000
        result << c.ord.to_u16
      else
        # Encode as surrogate pair
        code = c.ord - 0x10000
        high = (code >> 10) + 0xD800
        low = (code & 0x3FF) + 0xDC00
        result << high.to_u16
        result << low.to_u16
      end
    end
    result
  end

  # Create UTF-16 array with invalid sequences for testing
  def self.invalid_utf16 : Array(UInt16)
    # Lone high surrogate, lone low surrogate, reversed pair
    [0xD801_u16, 0x20_u16, 0xDC01_u16, 0x20_u16, 0xDC00_u16, 0xD800_u16]
  end
end
