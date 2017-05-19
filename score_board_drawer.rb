require_relative "./integer_to_score_board_converter"
require_relative "./untroubled_pi_piper"

class ScoreBoardDrawer
  BLINKING_DELAY = 0.5
  def initialize(p1_shift_register, p2_shift_register, clock_pin)
    @p1_shift_register = p1_shift_register
    @p2_shift_register = p2_shift_register
    @left_bits = 0
    @right_bits = 0
    @blink = false
    init_clock_pin(clock_pin)
    @t = start_thread
  end

  def start_thread
    Thread.new{
      loop do
        sleep(BLINKING_DELAY)
        File.write(@p1_shift_register, 0.chr) if @blink == :left || @blink == :both
        File.write(@p2_shift_register, 0.chr) if @blink == :right || @blink == :both
        clock
        sleep(BLINKING_DELAY)
        File.write(@p1_shift_register, @left_bits.chr)
        File.write(@p2_shift_register, @right_bits.chr)
        clock
      end
    }
  end

  #just updating state here
  #thread @t redraws it 
  def display(left_score, right_score, blink: false)
    @left_bits = IntegerToScoreBoardBitConverter.convert(left_score)
    @right_bits = IntegerToScoreBoardBitConverter.convert(right_score)
    @blink = blink
  end

  def init_clock_pin(clock_pin)
    @clock_pin = UntroubledPiPiper::Pin.new(pin: clock_pin, direction: :out)
    @clock_pin.on
  end

  def clock
    @clock_pin.off
    @clock_pin.on
    @clock_pin.off
  end
end
