class PlayerScoreIncrementCommand
  def initialize(player_score, on_undo: lambda{})
    @player_score = player_score
    @on_undo = on_undo
  end

  def call
    @player_score.increment
  end

  def undo
    @player_score.decrement
    @on_undo.call
    true
  end
end
