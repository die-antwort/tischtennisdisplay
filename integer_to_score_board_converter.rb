class IntegerToScoreBoardBitConverter
  def self.convert(int)
    bits = self.convert_digit(int%10)
    if int/10 > 0 
      bits = bits + 0x80
    end
    return bits;
  end
  private

  def self.convert_digit(int)
    case int
    when 0
      return 0x3f
    when 1
      return 0x06
    when 2
      return 0x5b
    when 3
      return 0x4f
    when 4
      return 0x66
    when 5
      return 0x6d
    when 6
      return 0x7d
    when 7
      return 0x07
    when 8
      return 0x7f
    when 9
      return 0x6f
    end
  end
end
