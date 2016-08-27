class GameToScoreBoardConnection
  def initialize(game)
    @game = game
  end
  def getScoreBoardState()
    puts "The score board state should be derived from the game state"
    puts "game state = "  
    puts @game.getGameState.inspect
  end
end
