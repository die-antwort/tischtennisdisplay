class PlayerScoreIncrementCommand
  def initialize(playerScore)
    @playerScore = playerScore
  end

  def call
    @playerScore.increment
  end

  def undo
    @playerScore.decrement
  end
end
