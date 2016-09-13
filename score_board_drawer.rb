require "pi_piper"
include PiPiper
require "./integer_to_score_board_converter"

class ScoreBoardDrawer
  BLINKING_DELAY = 0.5
  def initialize(game_board_connection, p1_shift_register, p2_shift_register)
    @p1_shift_register = p1_shift_register
    @p2_shift_register = p2_shift_register
    @game_board_connection = game_board_connection
    init_clock_pin
    @t = false
  end

  def redraw
    score_board_state = @game_board_connection.score_board_state
    puts("redrawing");
    if (!score_board_state[:blinking]) 
      if @t && @t.status 
        puts("killing thread")
        Thread.kill(@t)
        redraw
      end
    end
    File.write(@p1_shift_register, score_board_state[:p1_bits].chr)
    File.write(@p2_shift_register, score_board_state[:p2_bits].chr)
    clock
    if (score_board_state[:blinking]) 
      @t = Thread.new{
        puts 1;
        sleep(BLINKING_DELAY)
        puts 2;
        File.write(@p1_shift_register, 0.chr)
        File.write(@p2_shift_register, 0.chr)
        puts 3;
        clock
        puts 4;
        sleep(BLINKING_DELAY)
        puts 5;
        redraw
        puts 6;
      }
    end

  end

  def init_clock_pin
    @clock_pin = PiPiper::Pin.new(pin: 25, direction: :out)
    @clock_pin.on
  end

  def clock
    @clock_pin.off
    @clock_pin.on
    @clock_pin.off
  end
end
