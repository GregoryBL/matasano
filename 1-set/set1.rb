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

def hex_to_base_64(hex_string)
  raw_to_base_64(hex_to_raw(hex_string))
end

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