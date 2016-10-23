require_relative 'set1'
# Solve 6
def decrypt_repeating_xor(string)

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

def find_key_size(string)

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
