require_relative "./integer_to_score_board_converter"
require_relative "./untroubled_pi_piper"

class ScoreBoard
  BLINK_DELAY = 0.500
  FLASH_TWICE_DELAY = 0.250
  ROTATE_DELAY = 0.100

  def initialize(p1_shift_register, p2_shift_register, clock_pin)
    @p1_shift_register = p1_shift_register
    @p2_shift_register = p2_shift_register
    @left_bits = 0
    @right_bits = 0
    @effect = nil
    @side = nil
    init_clock_pin(clock_pin)
    @t = start_thread
  end

  def start_thread
    Thread.new{
      bit_sequence = nil
      flash_twice_count = 0
      loop do
        case @effect
        when :blink
          update(@left_bits, @right_bits)
          sleep(BLINK_DELAY)
          update((@left_bits if @side == :right), (@right_bits if @side == :left))
          sleep(BLINK_DELAY)
        when :blink_alternating
          update(@left_bits, nil)
          sleep(BLINK_DELAY)
          update(nil, @right_bits)
          sleep(BLINK_DELAY)
        when :flash_twice
          update(@left_bits, @right_bits)
          sleep(FLASH_TWICE_DELAY)
          update((@left_bits if @side == :right), (@right_bits if @side == :left))
          sleep(FLASH_TWICE_DELAY)
          if (flash_twice_count += 1) == 2
            flash_twice_count = 0
            @effect = nil
          end
        when :rotate_cw
          bit_sequence = IntegerToScoreBoardBitConverter.rotation_sequence_cw.cycle
          @effect = :rotate_continue
        when :rotate_ccw
          bit_sequence = IntegerToScoreBoardBitConverter.rotation_sequence_ccw.cycle
          @effect = :rotate_continue
        when :rotate_bounce
          bit_sequence = IntegerToScoreBoardBitConverter.rotation_sequence_bounce.cycle
          @effect = :rotate_continue
        when :rotate_continue
          rotation_bits = bit_sequence.next
          update(@side != :right ? rotation_bits : @left_bits, @side != :left ? rotation_bits : @right_bits)
          sleep(ROTATE_DELAY)
        else
          update(@left_bits, @right_bits)
        end
      end
    }
  end

  #just updating state here
  #thread @t redraws it
  def display(left_score, right_score, effect: nil, side: nil)
    @left_bits = left_score ? IntegerToScoreBoardBitConverter.convert(left_score) : nil
    @right_bits = right_score ? IntegerToScoreBoardBitConverter.convert(right_score) : nil
    @effect = effect
    @side = side
  end

  def init_clock_pin(clock_pin)
    @clock_pin = UntroubledPiPiper::Pin.new(pin: clock_pin, direction: :out)
    @clock_pin.on
  end

  def update(left_bits, right_bits)
    File.write(@p1_shift_register, left_bits ? left_bits.chr : "\x00")
    File.write(@p2_shift_register, right_bits ? right_bits.chr : "\x00")
    clock
  end

  def clock
    @clock_pin.off
    @clock_pin.on
    @clock_pin.off
  end
end
