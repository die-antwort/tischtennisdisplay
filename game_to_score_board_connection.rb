class GameToScoreBoardConnection
  def initialize(game)
    @game = game
  end

  def score_board_state
    state = @game.state
    {
      p1_bits: IntegerToScoreBoardBitConverter.convert(state[:p1_points]),
      p2_bits: IntegerToScoreBoardBitConverter.convert(state[:p2_points]),
      blinking: !state[:in_progress],
    }
  end
end
