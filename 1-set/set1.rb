require_relative '../utilities/text'
require_relative '../utilities/scorer'

# Solve challenge 3
def decode_single_xor(text)
  byte_scores = {}
  (0..255).each do |byte|
    xored = text.single_xor(byte)
    next if Scorer.portion_common_letters(xored) < 0.9
    byte_scores[byte] = Scorer.score(xored)
  end
  score_byte_hash = invert_hash(byte_scores)
  max_bytes_array = score_byte_hash[score_byte_hash.keys.min]

  # max_bytes_array is nil if none are even close, so return highest possible score
  if max_bytes_array != nil
    # If there are multiple, choose the one with more lower case letters
    answer_byte = max_bytes_array.max_by do |byte|
      chr_arr = text.single_xor(byte).string_value.split("")
      chr_arr.count { |c| c.upcase != c }
    end
    {
      score: score_byte_hash.keys.min,
      byte: answer_byte,
      result: text.single_xor(answer_byte).string_value
    }
  else
    { score: 26*26*26 }
  end
end

# Solve challenge 4
def find_the_single_xor(filename)
  lines = File.open(filename, 'rb').readlines.map { |l| Text.new(hex: l.chomp) }
  line_scores = {}

  lines.each_with_index do |line, ind|
    print "."
    result = decode_single_xor(line).merge({ line: line })
    line_scores[line] = result if result[:score] < 26*26*26
  end
  puts ""

  max_result = line_scores.max_by do |line, result|
    result[:result].split('').count { |c| c.upcase != c }
  end

  puts "Byte: #{max_result[1][:byte]}"
  puts "Score: #{max_result[1][:score]}"
  puts "Original Line: #{max_result[0].hex_value}"
  puts "Decoded: #{max_result[1][:result]}"
end

# Solve challenge 5

def repeating_key_xor(text, key)
  key_length = key.length

  xored = text.raw_value.map.with_index do |byte, index|
    key[index % key_length].ord ^ byte
  end

  Text.new(bytes: xored)
end

# Solve challenge 6
def decrypt_repeating_xor(text)
  bytes = text.raw_value
  p keysize = find_key_size(text)
  sorted = bytes.group_by.with_index { |_, ind| ind % keysize }.map { |a| Text.new(bytes: a[1]) }
  p sorted.map { |t| t.string_value }
  p key = sorted.map { |txt| p decode_single_xor(txt)[:byte].chr }.join('')
  repeating_key_xor(text, key)
end

##### Helper methods #####

def invert_hash(hash)
  inverted = {}
  hash.each do |key, value|
    prev = inverted[value]
    inverted[value] = prev != nil ? prev << key : [key]
  end
  inverted
end

## 6

def hamming_distance(txt1, txt2)
  xored = txt1 ^ txt2

  xored.raw_value.inject(0) do |total, byte|
    total + byte.to_s(2).count("1")
  end
end

def find_key_size(text)
  (2..40).min_by do |size|
    c1 = text[0..size]
    c2 = text[size..2*size]
    c3 = text[2*size..3*size]
    c4 = text[3*size..4*size]
    p (hamming_distance(c1, c2) + hamming_distance(c1, c3) + hamming_distance(c1, c4) + hamming_distance(c2, c3) + hamming_distance(c2, c4) + hamming_distance(c3, c4)).to_f / size
  end
end

### runner

def main
  puts "Solution P1"
  puts Text.new(hex: "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d").base64_value

  puts "Solution P2"
  xor_txt = Text.new(hex: "1c0111001f010100061a024b53535009181c") ^ Text.new(hex: "686974207468652062756c6c277320657965")
  puts xor_txt.hex_value

  puts "Solution P3"
  puts decode_single_xor(Text.new(hex: "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"))

  puts "solution P4"
  find_the_single_xor("4_detect.txt")

  puts "Solution P5"
  puts repeating_key_xor(Text.new(string: "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"), "ICE").hex_value
  # puts repeating_key_xor(Text.new(string: "I go crazy when I hear a cymbal"), "ICE")
end

def test_p_6
  p ct = repeating_key_xor(Text.new(string: "This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR (Vigenere) statistically is obviously an academic exercise, a Crypto 101 thing. But more people know how to break it than can actually break it, and a similar technique breaks something much more important."), "hiya").base64_value
  p decrypt_repeating_xor(Text.new(base64: ct)).string_value
end

test_p_6