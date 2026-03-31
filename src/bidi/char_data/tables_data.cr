# Simplified bidi_class_table for initial implementation
# Contains only the ranges needed for basic tests

module Bidi
  module CharData
    BIDI_CLASS_TABLE = [
      # Basic ASCII ranges from Rust table
      {'\u{0}', '\u{8}', BidiClass::BN},
      {'\u{9}', '\u{9}', BidiClass::S},
      {'\u{a}', '\u{a}', BidiClass::B},
      {'\u{b}', '\u{b}', BidiClass::S},
      {'\u{c}', '\u{c}', BidiClass::WS},
      {'\u{d}', '\u{d}', BidiClass::B},
      {'\u{e}', '\u{1b}', BidiClass::BN},
      {'\u{1c}', '\u{1e}', BidiClass::B},
      {'\u{1f}', '\u{1f}', BidiClass::S},
      {'\u{20}', '\u{20}', BidiClass::WS},
      {'\u{21}', '\u{22}', BidiClass::ON},
      {'\u{23}', '\u{25}', BidiClass::ET},
      {'\u{26}', '\u{2a}', BidiClass::ON},
      {'\u{2b}', '\u{2b}', BidiClass::ES},
      {'\u{2c}', '\u{2c}', BidiClass::CS},
      {'\u{2d}', '\u{2d}', BidiClass::ES},
      {'\u{2e}', '\u{2f}', BidiClass::CS},
      {'\u{30}', '\u{39}', BidiClass::EN},
      {'\u{3a}', '\u{3a}', BidiClass::CS},
      {'\u{3b}', '\u{40}', BidiClass::ON},
      {'\u{41}', '\u{5a}', BidiClass::L},
      {'\u{5b}', '\u{60}', BidiClass::ON},
      {'\u{61}', '\u{7a}', BidiClass::L},
      {'\u{7b}', '\u{7e}', BidiClass::ON},
      {'\u{7f}', '\u{84}', BidiClass::BN},
      {'\u{85}', '\u{85}', BidiClass::B},
      {'\u{86}', '\u{9f}', BidiClass::BN},

      # Hebrew (R)
      {'\u{590}', '\u{5ff}', BidiClass::R},

      # Arabic (AN, AL, etc.)
      {'\u{600}', '\u{605}', BidiClass::AN},
      {'\u{608}', '\u{608}', BidiClass::AL},
      {'\u{61b}', '\u{64a}', BidiClass::AL}, # Includes \u{0627}

      # Paragraph separator (B) - must come before embedding controls
      {'\u{2029}', '\u{2029}', BidiClass::B}, # PARAGRAPH SEPARATOR

      # Embedding and override controls (X2-X9)
      {'\u{202a}', '\u{202a}', BidiClass::LRE}, # LEFT-TO-RIGHT EMBEDDING
      {'\u{202b}', '\u{202b}', BidiClass::RLE}, # RIGHT-TO-LEFT EMBEDDING
      {'\u{202c}', '\u{202c}', BidiClass::PDF}, # POP DIRECTIONAL FORMATTING
      {'\u{202d}', '\u{202d}', BidiClass::LRO}, # LEFT-TO-RIGHT OVERRIDE
      {'\u{202e}', '\u{202e}', BidiClass::RLO}, # RIGHT-TO-LEFT OVERRIDE

      # Isolate controls (X5a-X5c)
      {'\u{2066}', '\u{2066}', BidiClass::LRI}, # LEFT-TO-RIGHT ISOLATE
      {'\u{2067}', '\u{2067}', BidiClass::RLI}, # RIGHT-TO-LEFT ISOLATE
      {'\u{2068}', '\u{2068}', BidiClass::FSI}, # FIRST STRONG ISOLATE
      {'\u{2069}', '\u{2069}', BidiClass::PDI}, # POP DIRECTIONAL ISOLATE

      # Default ET range
      {'\u{20a0}', '\u{20cf}', BidiClass::ET},

      # Noncharacters (L)
      {'\u{fdd0}', '\u{fdef}', BidiClass::L},
      {'\u{fffe}', '\u{ffff}', BidiClass::L},

      # Supplementary Multilingual Plane (SMP) ranges
      {'\u{10800}', '\u{10fff}', BidiClass::R},
      {'\u{1e800}', '\u{1edff}', BidiClass::R},
      {'\u{1ee00}', '\u{1eeff}', BidiClass::AL},
      {'\u{1ef00}', '\u{1efff}', BidiClass::R},
    ]

    # Bracket pairs table from BidiBrackets.txt
    # Format: (opening_bracket, closing_bracket, normalized_opening_bracket_or_nil)
    BIDI_PAIRS_TABLE = [
      {'\u{28}', '\u{29}', nil}, # ( )
      {'\u{5b}', '\u{5d}', nil}, # [ ]
      {'\u{7b}', '\u{7d}', nil}, # { }
      {'\u{f3a}', '\u{f3b}', nil},
      {'\u{f3c}', '\u{f3d}', nil},
      {'\u{169b}', '\u{169c}', nil},
      {'\u{2045}', '\u{2046}', nil},
      {'\u{207d}', '\u{207e}', nil},
      {'\u{208d}', '\u{208e}', nil},
      {'\u{2308}', '\u{2309}', nil},
      {'\u{230a}', '\u{230b}', nil},
      {'\u{2329}', '\u{232a}', '\u{3008}'},
      {'\u{2768}', '\u{2769}', nil},
      {'\u{276a}', '\u{276b}', nil},
      {'\u{276c}', '\u{276d}', nil},
      {'\u{276e}', '\u{276f}', nil},
      {'\u{2770}', '\u{2771}', nil},
      {'\u{2772}', '\u{2773}', nil},
      {'\u{2774}', '\u{2775}', nil},
      {'\u{27c5}', '\u{27c6}', nil},
      {'\u{27e6}', '\u{27e7}', nil},
      {'\u{27e8}', '\u{27e9}', nil},
      {'\u{27ea}', '\u{27eb}', nil},
      {'\u{27ec}', '\u{27ed}', nil},
      {'\u{27ee}', '\u{27ef}', nil},
      {'\u{2983}', '\u{2984}', nil},
      {'\u{2985}', '\u{2986}', nil},
      {'\u{2987}', '\u{2988}', nil},
      {'\u{2989}', '\u{298a}', nil},
      {'\u{298b}', '\u{298c}', nil},
      {'\u{298d}', '\u{2990}', nil},
      {'\u{298f}', '\u{298e}', nil},
      {'\u{2991}', '\u{2992}', nil},
      {'\u{2993}', '\u{2994}', nil},
      {'\u{2995}', '\u{2996}', nil},
      {'\u{2997}', '\u{2998}', nil},
      {'\u{29d8}', '\u{29d9}', nil},
      {'\u{29da}', '\u{29db}', nil},
      {'\u{29fc}', '\u{29fd}', nil},
      {'\u{2e22}', '\u{2e23}', nil},
      {'\u{2e24}', '\u{2e25}', nil},
      {'\u{2e26}', '\u{2e27}', nil},
      {'\u{2e28}', '\u{2e29}', nil},
      {'\u{2e55}', '\u{2e56}', nil},
      {'\u{2e57}', '\u{2e58}', nil},
      {'\u{2e59}', '\u{2e5a}', nil},
      {'\u{2e5b}', '\u{2e5c}', nil},
      {'\u{3008}', '\u{3009}', nil},
      {'\u{300a}', '\u{300b}', nil},
      {'\u{300c}', '\u{300d}', nil},
      {'\u{300e}', '\u{300f}', nil},
      {'\u{3010}', '\u{3011}', nil},
      {'\u{3014}', '\u{3015}', nil},
      {'\u{3016}', '\u{3017}', nil},
      {'\u{3018}', '\u{3019}', nil},
      {'\u{301a}', '\u{301b}', nil},
      {'\u{fe59}', '\u{fe5a}', nil},
      {'\u{fe5b}', '\u{fe5c}', nil},
      {'\u{fe5d}', '\u{fe5e}', nil},
      {'\u{ff08}', '\u{ff09}', nil},
      {'\u{ff3b}', '\u{ff3d}', nil},
      {'\u{ff5b}', '\u{ff5d}', nil},
      {'\u{ff5f}', '\u{ff60}', nil},
      {'\u{ff62}', '\u{ff63}', nil},
    ]
  end
end
