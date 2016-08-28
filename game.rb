class Game
  @@winning_score = 11
  @@min_difference = 2

  def initialize(p1_score, p2_score)
    @p1_score = p1_score
    @p2_score = p2_score
  end

  def in_progress?
    p1_points = @p1_score.points
    p2_points = @p2_score.points
    dif = (p1_points - p2_points).abs
    dif < @@min_difference ||
      [p1_points, p2_points].max < @@winning_score
  end

  def leading_player
    @p1_score.points > @p2_score.points ? :p1 : :p2
  end

  def winner
    unless in_progress?
      return leading_player
    end
    nil
  end

  def game_state
    {
      p1_points: @p1_score.points,
      p2_points: @p2_score.points,
      in_progress: in_progress?,
      winner: winner,
    }
  end
end
