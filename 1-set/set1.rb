BASE_64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
HEX_TO_RAW = {
  '0' => 0,
  '1' => 1,
  '2' => 2,
  '3' => 3,
  '4' => 4,
  '5' => 5,
  '6' => 6,
  '7' => 7,
  '8' => 8,
  '9' => 9,
  'a' => 10,
  'b' => 11,
  'c' => 12,
  'd' => 13,
  'e' => 14,
  'f' => 15
}

HEX_CHARS = "0123456789abcdef"

ENGLISH_LETTER_FREQUENCY = {
  a: 0.08167,
  b: 0.01492,
  c: 0.02782,
  d: 0.04253,
  e: 0.12702,
  f: 0.02228,
  g: 0.02015,
  h: 0.06094,
  i: 0.06966,
  j: 0.00153,
  k: 0.00772,
  l: 0.04025,
  m: 0.02406,
  n: 0.06749,
  o: 0.07507,
  p: 0.01929,
  q: 0.00095,
  r: 0.05987,
  s: 0.06327,
  t: 0.09056,
  u: 0.02758,
  v: 0.00978,
  w: 0.02360,
  x: 0.00150,
  y: 0.01974,
  z: 0.00074
}

ENGLISH_LETTERS = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q" "r", "s", "t", "u", "v", "w", "x", "y", "z"]

# Solve challenge 1
def hex_to_base_64(hex_string)
  raw_to_base_64(hex_to_raw(hex_string))
end

# Solve challenge 2
def fixed_xor(hex_string1, hex_string2)
  xor_raw = hex_to_raw(hex_string1).zip(hex_to_raw(hex_string2)).map do |arr|
    arr[0] ^ arr[1]
  end
  raw_to_hex(xor_raw)
end

# Solve challenge 3
def decode_single_xor(hex_string)
  byte_scores = {}
  (0..255).each do |byte|
    xor_byte_array = xor_single_char(hex_string, byte.chr)
    byte_scores[byte] = score_byte_array(xor_byte_array)
  end
  score_byte_hash = invert_hash(byte_scores)
  max_bytes_array = score_byte_hash[score_byte_hash.keys.min]

  # If there are multiple, choose the one with fewer lower case letters
  answer_byte = max_bytes_array.max_by do |byte|
    chr_arr = byte_array_to_char_array(xor_single_char(hex_string, byte.chr))
    chr_arr.count { |c| c.upcase != c }
  end

  # puts answer_byte
  # puts xor_single_char(hex_string, answer_byte).map {|byte| byte.chr}.join('')
  {
    score: score_byte_hash.keys.min,
    byte: answer_byte,
    result: xor_single_char(hex_string, answer_byte).map {|byte| byte.chr}.join('')
  }
end

# Solve challenge 4
def find_the_single_xor(filename)
  lines = File.open(filename, 'rb').readlines.map { |l| l.chomp }
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

  # max_score = best_score * 1.3
  # low_enough_hash = line_scores.select { |_, report| report[:score] < max_score }

  max_result = line_scores.max_by do |line, result|
    result[:result].split('').count { |c| c.upcase != c }
  end

  puts max_result[1][:byte]
  puts max_result[1][:score]
  puts max_result[0]
  puts max_result[1][:result]
end

# Solve challenge 5

def repeating_key_xor(plaintext, key)
  key_length = key.length
  pt_bytes = pt_to_byte_array(plaintext)

  xored = pt_bytes.map.with_index do |byte, index|
    key[index % key_length].ord ^ byte
  end

  raw_to_hex(xored)
end
##### Helper methods #####

## For P1
def raw_to_base_64(byte_array)
  return "" if byte_array == []
  ((3 - (byte_array.length % 3)) % 3).times { byte_array << 0 }
  c1 = BASE_64_CHARS[byte_array[0] >> 2]
  c2 = BASE_64_CHARS[(byte_array[0] % 4) * 16 + (byte_array[1] >> 4)]
  c3 = BASE_64_CHARS[(byte_array[1] % 16) * 4 + (byte_array[2] >> 6)]
  c4 = BASE_64_CHARS[byte_array[2] % 64]
  c1 + c2 + c3 + c4 + raw_to_base_64(byte_array[3..-1])
end

def hex_to_raw(hex_string)
  nibble_array = hex_string.downcase.split('').map { |c| HEX_TO_RAW[c] }
  byte_array = nibble_array.each_slice(2).map { |b| b[1] | b[0] << 4 }
end

## For P2
def raw_to_hex(byte_array)
  byte_array.inject("") do |memo, byte|
    memo + HEX_CHARS[byte >> 4] + HEX_CHARS[byte % 16]
  end
end

## For P3
def xor_single_char(hex_string, char)
  byte_array = hex_to_raw(hex_string)
  raw_char = char.ord
  xor_byte_array = byte_array.map { |byte| byte ^ raw_char }
end

def byte_array_to_char_array(byte_array)
  byte_array.map do |byte|
    byte.chr
  end
end

def byte_array_to_freq_hash(byte_array)
  chr_array = byte_array_to_char_array(byte_array).map {|c| c.downcase}
  letter_array = chr_array.select do |chr|
    ENGLISH_LETTERS.include?(chr)
  end
  make_frequency_hash(letter_array)
end

def invert_hash(hash)
  inverted = {}
  hash.each do |key, value|
    prev = inverted[value]
    inverted[value] = prev != nil ? prev << key : [key]
  end
  inverted
end

def score_byte_array(byte_array)
  score_sorted_array(sort_freq_hash(byte_array_to_freq_hash(byte_array)))
end

def score_sorted_array(array)
  english_sorted = sort_freq_hash(ENGLISH_LETTER_FREQUENCY).map {|s| s.to_s}
  compare_sorted_array_orders(array.reverse, english_sorted.reverse)
end

def compare_sorted_array_orders(array1, array2)
  score = 0
  len = array2.length
  array2.each_with_index do |letter, ind|
    ind_in_other_array = array1.index(letter)
    if ind_in_other_array
      score += (ind ** 2 - ind_in_other_array ** 2).abs / len
    else
      score += len * (len - ind)
    end
  end
  score
end

def sort_freq_hash(freq_hash)
  freq_hash.sort_by { |let, freq| freq }.map { |lf_hash| lf_hash[0] }
end

def make_frequency_hash(byte_array)
  freq_hash = {}
  byte_array.each do |b|
    freq_hash[b] = freq_hash[b] ? freq_hash[b] + 1 : 1
  end
  freq_hash
end

## For P5

def pt_to_byte_array(pt)
  pt.split("").map {|c| c.ord }
end