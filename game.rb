class Game
  WINNING_SCORE = 11
  MIN_DIFFERENCE = 2

  def initialize(p1_score, p2_score)
    @finished_handlers = []
    @p1_score = p1_score
    @p2_score = p2_score
    subscribe_to_score_changes
  end

  def subscribe_to_score_changes
    @p1_score.on_change{ scores_changed }
    @p2_score.on_change{ scores_changed }
  end

  def scores_changed
    call_all_finished_handlers unless in_progress?
  end

  def in_progress?
    p1_points = @p1_score.points
    p2_points = @p2_score.points
    (p1_points - p2_points).abs < MIN_DIFFERENCE || [p1_points, p2_points].max < WINNING_SCORE
  end

  def leading_player
    @p1_score.points > @p2_score.points ? :p1 : :p2
  end

  def winner
    leading_player unless in_progress?
  end

  def game_state
    {
      p1_points: @p1_score.points,
      p2_points: @p2_score.points,
      in_progress: in_progress?,
      winner: winner,
    }
  end

  def call_all_finished_handlers
    @finished_handlers.each(&:call)
  end

  def on_finished(&handler)
    @finished_handlers.push(handler)
  end
end
