require_relative "score"

class Game
  attr_reader :max_set_count

  %i(p1_score p2_score p1_set_score p2_set_score set set_finished? set_winner_side winner winner_side game_finished? waiting_for_final_set_change_over?).each do |method|
    define_method method do
      @score.public_send(method)
    end
  end

  def initialize(max_set_count: 3)
    @max_set_count = max_set_count
    @history = []
    set_score
  end

  def handle_input(c)
    @history.push(c)
    set_score
  end

  def undo
    @history.pop
    set_score
  end

  def inspect
    {p1_score: p1_score, p2_score: p2_score, set: set, p1_set_score: p1_set_score, p2_set_score: p2_set_score}.inspect
  end

  def set_score
    @score = Score.new(@history, max_set_count: max_set_count)
  end

  def score_for_side(side)
    @score.for_side(side)
  end
end
