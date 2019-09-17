require_relative "./integer_to_score_board_converter"
require_relative "./untroubled_pi_piper"

class ScoreBoard
  BLINK_DELAY = 0.500

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
        else
          update(@left_bits, @right_bits)
        end
      end
    }
  end

  #just updating state here
  #thread @t redraws it
  def display(left_score, right_score, effect: nil, side: nil)
    @left_bits = IntegerToScoreBoardBitConverter.convert(left_score)
    @right_bits = IntegerToScoreBoardBitConverter.convert(right_score)
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
