module Scorer
  ENGLISH_LETTER_FREQUENCY = {
    a: 0.08167, b: 0.01492, c: 0.02782, d: 0.04253, e: 0.12702, f: 0.02228, g: 0.02015, h: 0.06094,
    i: 0.06966, j: 0.00153, k: 0.00772, l: 0.04025, m: 0.02406, n: 0.06749, o: 0.07507, p: 0.01929,
    q: 0.00095, r: 0.05987, s: 0.06327, t: 0.09056, u: 0.02758, v: 0.00978, w: 0.02360, x: 0.00150,
    y: 0.01974, z: 0.00074
  }

  ENGLISH_LETTERS = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q" "r", "s", "t", "u", "v", "w", "x", "y", "z"]

  COMMON_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 \"\'-.,:;".split('')

  def self.score(text)
    score_sorted_array(sort_freq_hash(to_freq_hash(text)))
  end

  def self.portion_common_letters(text)
    text.raw_value.select { |c| COMMON_CHARS.include?(c.chr) }.length / text.length.to_f
  end

  def self.to_freq_hash(text)
    chr_array = text.string_value.split("").map {|c| c.downcase}
    letter_array = chr_array.select do |chr|
      ENGLISH_LETTERS.include?(chr)
    end
    make_frequency_hash(letter_array)
  end

  def self.score_sorted_array(array)
    english_sorted = sort_freq_hash(ENGLISH_LETTER_FREQUENCY).map {|s| s.to_s}
    compare_sorted_array_orders(array.reverse, english_sorted.reverse)
  end

  def self.compare_sorted_array_orders(array1, array2)
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

  def self.sort_freq_hash(freq_hash)
    freq_hash.sort_by { |let, freq| freq }.map { |lf_hash| lf_hash[0] }
  end

  def self.make_frequency_hash(byte_array)
    freq_hash = {}
    byte_array.each do |b|
      freq_hash[b] = freq_hash[b] ? freq_hash[b] + 1 : 1
    end
    freq_hash
  end
end