class IntegerToScoreBoardBitConverter
  # The bits map to the segments as follows (0 = LSB, 7 = MSB)
  #
  #                1
  #              * * *
  #     *      *       *
  #   0 *    6 *       * 2
  #     *      *   7   *
  #              * * *
  #     *      *       *
  #   0 *    5 *       * 3
  #     *      *       *
  #              * * *
  #                4

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
      0x3f << 1
    when 1
      0x06 << 1
    when 2
      0x5b << 1
    when 3
      0x4f << 1
    when 4
      0x66 << 1
    when 5
      0x6d << 1
    when 6
      0x7d << 1
    when 7
      0x07 << 1
    when 8
      0x7f << 1
    when 9
      0x6f << 1
    end
  end

  def self.rotation_sequence_cw
    [0b0000_0010, 0b0000_0100, 0b0000_1000, 0b0001_0000, 0b0010_0000, 0b0100_0000]
  end

  def self.rotation_sequence_ccw
    rotation_sequence_cw.reverse
  end
end
