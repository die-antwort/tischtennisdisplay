require "pi_piper"
include PiPiper
require "./integer_to_score_board_converter"

class ScoreBoardDrawer
  def initialize(game_board_connection, p1_shift_register, p2_shift_register)
    @p1_shift_register = p1_shift_register
    @p2_shift_register = p2_shift_register
    @game_board_connection = game_board_connection
    init_clock_pin
  end

  def redraw
    score_board_state = @game_board_connection.score_board_state
    File.write(@p1_shift_register, score_board_state[:p1_bits].chr)
    File.write(@p2_shift_register, score_board_state[:p2_bits].chr)
    clock
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
