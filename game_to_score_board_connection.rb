class GameToScoreBoardConnection
  def initialize(game)
    @game = game
  end

  def score_board_state
    # puts "The score board state should be derived from the game state"
    # puts "game state = "
    puts @game.game_state.inspect
  end
end
