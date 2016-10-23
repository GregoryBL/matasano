require_relative 'set1'
require_relative 'text'
# Solve 6
def decrypt_repeating_xor(string)
  bytes = base64_to_raw(string)
  p keysize = find_key_size(bytes)
  p sorted = bytes.group_by.with_index { |_, ind| ind % keysize }.map { |a| a[1] }
  p key = sorted.map { |bts| decode_single_xor(raw_to_hex(bts))[:byte].chr }.join('')
  repeating_key_xor(base64_to_raw(string).map{|a| a.chr}, key)
end

## Helpers
def hamming_distance(str1, str2)
  if str1.length > str2.length
    longer = str1
    shorter = str2
  else
    longer = str2
    shorter = str1
  end

  bytes1 = longer.split("").map { |c| c.ord }
  bytes2 = shorter.split("").map { |c| c.ord }

  xored = bytes2.map.with_index do |byte, ind|
    byte ^ bytes1[ind]
  end

  xored.inject(0) do |total, byte|
    total + byte.to_s(2).count("1")
  end
end

def find_key_size(bytes)
  (2..40).min_by do |size|
    c1 = bytes[0..size].map { |n| n.chr }.join('')
    c2 = bytes[size..2*size].map { |n| n.chr }.join('')
    c3 = bytes[2*size..3*size].map { |n| n.chr }.join('')
    c4 = bytes[3*size..4*size].map { |n| n.chr }.join('')
    p (hamming_distance(c1, c2) + hamming_distance(c1, c3) + hamming_distance(c1, c4)) / size.to_f
  end
end

def base64_to_raw(base64string)
  base64string.split('').group_by.with_index { |_, ind| ind / 4 }.inject([]) do |memo, g|
    memo + base64_4_to_raw(g[1])
  end
end

def base64_4_to_raw(base64_array)
  value = base64_array.each.with_index.inject(0) do |memo, b64_char|
    memo + (BASE_64_CHARS.index(b64_char[0]) << (4 - b64_char[1] - 1) * 6)
  end
  v1 = value >> 16
  v2 = value - v1 * 2 ** 16 >> 8
  v3 = value - v1 * 2 ** 16 - v2 * 2 ** 8
  [v1, v2, v3]
end

p ct = hex_to_base_64(repeating_key_xor("This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR (Vigenere) statistically is obviously an academic exercise, a Crypto 101 thing. But more people know how to break it than can actually break it, and a similar technique breaks something much more important.", "his"))
p decrypt_repeating_xor(ct)
