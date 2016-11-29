require_relative 'set1'
require_relative 'text'



# def base64_to_raw(base64string)
#   base64string.split('').group_by.with_index { |_, ind| ind / 4 }.inject([]) do |memo, g|
#     memo + base64_4_to_raw(g[1])
#   end
# end

# def base64_4_to_raw(base64_array)
#   value = base64_array.each.with_index.inject(0) do |memo, b64_char|
#     memo + (BASE_64_CHARS.index(b64_char[0]) << (4 - b64_char[1] - 1) * 6)
#   end
#   v1 = value >> 16
#   v2 = value - v1 * 2 ** 16 >> 8
#   v3 = value - v1 * 2 ** 16 - v2 * 2 ** 8
#   [v1, v2, v3]
# end

p ct = repeating_key_xor(Text.new(string: "This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR (Vigenere) statistically is obviously an academic exercise, a Crypto 101 thing. But more people know how to break it than can actually break it, and a similar technique breaks something much more important."), "his").base64_value
p decrypt_repeating_xor(Text.new(base64: ct))
