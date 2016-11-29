class Text
  BASE_64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  HEX_TO_RAW = {'0' => 0,'1' => 1,'2' => 2,'3' => 3,'4' => 4,'5' => 5,'6' => 6,'7' => 7,'8' => 8,'9' => 9,'a' => 10,'b' => 11,'c' => 12,'d' => 13,'e' => 14,'f' => 15}
  HEX_CHARS = "0123456789abcdef"

  def initialize(init_hash = {})
    if init_hash[:bytes]
      @bytes = init_hash[:bytes]
    elsif init_hash[:hex]
      @bytes = hex_to_raw(init_hash[:hex])
    elsif init_hash[:string]
      @bytes = init_hash[:string].split("").map {|c| c.ord }
    elsif init_hash[:base64]
      @bytes = base64_to_raw(init_hash[:base64])
    else
      puts "Text object not initialized"
    end
  end

  def [](*args)
    Text.new(bytes: @bytes[*args])
  end

  def []=(index, byte)
    @bytes[index] = byte
  end

  def base64_value
    ((3 - (length % 3)) % 3).times { @bytes << 0 }
    groups = @bytes.group_by.with_index { |_, ind| ind / 3 }.map { |g| g[1] }
    groups.inject("") do |memo, group|
      c1 = BASE_64_CHARS[group[0] >> 2]
      c2 = BASE_64_CHARS[(group[0] % 4) * 16 + (group[1] >> 4)]
      c3 = BASE_64_CHARS[(group[1] % 16) * 4 + (group[2] >> 6)]
      c4 = BASE_64_CHARS[group[2] % 64]
      memo + c1 + c2 + c3 + c4
    end
  end

  def hex_value
    @bytes.inject("") do |memo, byte|
      memo + HEX_CHARS[byte >> 4] + HEX_CHARS[byte % 16]
    end
  end

  def string_value
    @bytes.inject("") do |memo, byte|
      memo + byte.chr
    end
  end

  def raw_value
    @bytes.dup
  end

  def frequencies
    freq_hash = {}
    @bytes.each do |b|
      freq_hash[b] = freq_hash[b] ? freq_hash[b] + 1 : 1
    end
    freq_hash
  end

  def base64_value=(new_base64)
    @bytes = base64_to_raw(new_base64)
    self
  end

  def hex_value=(new_hex)
    @bytes = hex_to_raw(new_hex)
    self
  end

  def string_value=(new_string)
    @bytes = new_string.map {|c| c.ord }
    self
  end

  def raw_value=(new_raw)
    @bytes = new_raw
    self
  end

  def +(other_text)
    Text.new(bytes: @bytes + other_text.raw_value)
  end

  def ^(other_text)
    return nil if length != other_text.length
    Text.new(bytes: (@bytes.zip(other_text.raw_value).map { |a| a[0] ^ a[1] }))
  end

  def single_xor(byte)
    Text.new(bytes: @bytes.map { |b| b ^ byte })
  end

  def length
    @bytes.length
  end

  private

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

  def hex_to_raw(hex_string)
    nibble_array = hex_string.downcase.split('').map { |c| HEX_TO_RAW[c] }
    byte_array = nibble_array.each_slice(2).map { |b| b[1] | b[0] << 4 }
  end
end