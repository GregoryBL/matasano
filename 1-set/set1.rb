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

def fixed_xor(hex_string1, hex_string2)
  xor_raw = hex_to_raw(hex_string1).zip(hex_to_raw(hex_string2)).map do |arr|
    arr[0] ^ arr[1]
  end
  raw_to_hex(xor_raw)
end

def raw_to_hex(byte_array)
  byte_array.inject("") do |memo, byte|
    memo + HEX_CHARS[byte >> 4] + HEX_CHARS[byte % 16]
  end
end




