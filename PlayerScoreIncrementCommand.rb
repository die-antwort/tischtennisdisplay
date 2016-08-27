class PlayerScoreIncrementCommand
  def initialize(playerScore)
    @playerScore = playerScore
  end

  def execute
    @playerScore.increment
  end

  def undo
    @playerScore.decrement
  end
end
