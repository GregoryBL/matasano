require_relative '../utilities/text'
require_relative '../utilities/scorer'

# Solve challenge 3
def decode_single_xor(text)
  byte_scores = {}
  (0..255).each do |byte|
    xored = text.single_xor(byte)
    byte_scores[byte] = Scorer.score(xored)
  end
  score_byte_hash = invert_hash(byte_scores)
  max_bytes_array = score_byte_hash[score_byte_hash.keys.min]

  # If there are multiple, choose the one with fewer lower case letters
  answer_byte = max_bytes_array.max_by do |byte|
    chr_arr = text.single_xor(byte).string_value.split("")
    chr_arr.count { |c| c.upcase != c }
  end

  {
    score: score_byte_hash.keys.min,
    byte: answer_byte,
    result: text.single_xor(answer_byte).string_value
  }
end

# Solve challenge 4
def find_the_single_xor(filename)
  lines = File.open(filename, 'rb').readlines.map { |l| Text.new(hex: l.chomp) }
  line_scores = {}
  best_score = 26*26*26

  lines.each_with_index do |line, ind|
    print "."
    line_scores[line] = decode_single_xor(line).merge({ line: line })
    score = line_scores[line][:score]
    if score < best_score
      best_score = score
    end
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

  Text.new(bytes: xored).hex_value
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
  puts repeating_key_xor(Text.new(string: "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"), "ICE")
  # puts repeating_key_xor(Text.new(string: "I go crazy when I hear a cymbal"), "ICE")
end

main