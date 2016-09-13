require './player_score_increment_command.rb'
class PlayerScoreResetCommand
  def initialize(p1_score, p2_score, on_call: lambda{})
    @p1_score = p1_score
    @p2_score = p2_score
    @on_call = on_call
  end

  def call
    @p1_score.reset
    @p2_score.reset
    @on_call.call
  end

  def undo
    false
  end
end
