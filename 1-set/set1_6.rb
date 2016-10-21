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