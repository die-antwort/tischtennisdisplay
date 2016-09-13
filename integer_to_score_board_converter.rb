class IntegerToScoreBoardBitConverter
  def self.convert(int)
    bits = convert_digit(int % 10)
    if int / 10 > 0
      bits += 0x01
    end
    bits
  end

  def self.convert_digit(int)
    case int
    when 0
      return 0x3f << 1 
    when 1
      return 0x06 << 1
    when 2
      return 0x5b << 1
    when 3
      return 0x4f << 1
    when 4
      return 0x66 << 1
    when 5
      return 0x6d << 1
    when 6
      return 0x7d << 1
    when 7
      return 0x07 << 1
    when 8
      return 0x7f << 1
    when 9
      return 0x6f << 1
    end
  end
end
