require_relative "./string_to_score_board_converter"
require_relative "./untroubled_pi_piper"

class ScoreBoard
  BLINK_DELAY = 0.500
  FLASH_TWICE_DELAY = [1.000, 0.150] # first value is delay before flashing
  ROTATE_DELAY = 0.100
  SCROLL_DELAY = 0.500

  def initialize(p1_shift_register, p2_shift_register, clock_pin)
    @p1_shift_register = p1_shift_register
    @p2_shift_register = p2_shift_register
    @left_str = nil
    @right_str = nil
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
        left_bits = @left_str ? StringToScoreBoardBitConverter.convert(@effect == :scroll ? @left_str.next : @left_str) : nil
        right_bits = @right_str ? StringToScoreBoardBitConverter.convert(@effect == :scroll ? @right_str.next : @right_str) : nil

        case @effect
        when :blink
          update(left_bits, right_bits)
          sleep(BLINK_DELAY)
          update((left_bits if @side == :right), (right_bits if @side == :left))
          sleep(BLINK_DELAY)
        when :blink_alternating
          update(left_bits, nil)
          sleep(BLINK_DELAY)
          update(nil, right_bits)
          sleep(BLINK_DELAY)
        when :flash_twice_after_delay
          update(left_bits, right_bits)
          sleep(FLASH_TWICE_DELAY[0])
          @effect = :flash_twice_after_delay_continue
        when :flash_twice_after_delay_continue
          update(left_bits, right_bits)
          sleep(FLASH_TWICE_DELAY[1])
          update((left_bits if @side == :right), (right_bits if @side == :left))
          sleep(FLASH_TWICE_DELAY[1])
          if (flash_twice_count += 1) == 2
            flash_twice_count = 0
            @effect = nil
          end
        when :rotate_cw
          bit_sequence = StringToScoreBoardBitConverter.rotation_sequence_cw.cycle
          @effect = :rotate_continue
        when :rotate_ccw
          bit_sequence = StringToScoreBoardBitConverter.rotation_sequence_ccw.cycle
          @effect = :rotate_continue
        when :rotate_bounce
          bit_sequence = StringToScoreBoardBitConverter.rotation_sequence_bounce.cycle
          @effect = :rotate_continue
        when :rotate_continue
          rotation_bits = bit_sequence.next
          update(@side != :right ? rotation_bits : left_bits, @side != :left ? rotation_bits : right_bits)
          sleep(ROTATE_DELAY)
        when :scroll
          update(left_bits, right_bits)
          sleep(SCROLL_DELAY)
        else
          update(left_bits, right_bits)
        end
      end
    }
  end

  #just updating state here
  #thread @t redraws it
  def display(left, right, effect: nil, side: nil)
    @effect = effect
    @side = side
    @left_str = left.to_s
    @right_str = right.to_s
    @left_str = @left_str.split(//).cycle if @left_str && effect == :scroll && side != :right
    @right_str = @right_str.split(//).cycle if @right_str && effect == :scroll && side != :left
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
