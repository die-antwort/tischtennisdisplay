class PlayerScoreIncrementCommand
  def initialize(player_score)
    @player_score = player_score
  end

  def call
    @player_score.increment
  end

  def undo
    @player_score.decrement
  end
end
