class StringToScoreBoardBitConverter
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

  CHARACTERS = {
    " " => 0b0000_0000,
    "0" => 0b0111_1110,
    "1" => 0b0000_1100,
    "2" => 0b1011_0110,
    "3" => 0b1001_1110,
    "4" => 0b1100_1100,
    "5" => 0b1101_1010,
    "6" => 0b1111_1010,
    "7" => 0b0000_1110,
    "8" => 0b1111_1110,
    "9" => 0b1101_1110,
    "C" => 0b0111_0010,
    "E" => 0b1111_0010,
    "I" => 0b0110_0000,
    "R" => 0b1010_0000,
    "P" => 0b1110_0110,
    "S" => 0b1101_1010,
    "V" => 0b0011_1000,
  }.freeze

  def self.convert(string_or_int)
    string = string_or_int.to_s
    return 0b0000_0000 if string == ""

    raise ArgumentError, "Can not convert '#{string_or_int}'." unless string =~ /\A1?[#{CHARACTERS.keys}]\z/

    if string.length == 2
      CHARACTERS.fetch(string[1]) | 0b0000_0001
    else
      CHARACTERS.fetch(string[0])
    end
  end

  def self.rotation_sequence_cw
    [0b0000_0010, 0b0000_0100, 0b0000_1000, 0b0001_0000, 0b0010_0000, 0b0100_0000]
  end

  def self.rotation_sequence_ccw
    rotation_sequence_cw.reverse
  end

  def self.rotation_sequence_bounce
    bit_sequence = rotation_sequence_cw * 4
    bit_sequence.pop
    bit_sequence += rotation_sequence_ccw * 4
    bit_sequence.pop
    bit_sequence
  end

  def self.switch_over_sequence_ltr
    single_ltr = [0b0000_0001, 0b0110_0000, 0b0000_1100]
    single_ltr + single_ltr[1..-1].reverse
  end

  def self.switch_over_sequence_rtl
    single_rtl = [0b0000_0001, 0b0110_0000, 0b0000_1100].reverse
    single_rtl + single_rtl[1..-1].reverse
  end
end
