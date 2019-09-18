require_relative "game_state"

class Game
  attr_reader :max_set_count

  %i(p1_set_score p2_set_score sets set_finished? set_winner_side winner winner_side game_finished? waiting_for_final_set_change_over? inspect).each do |method|
    define_method method do
      @game_state.public_send(method)
    end
  end

  def initialize(max_set_count: 3)
    @max_set_count = max_set_count
    @history = []
    set_game_state
  end

  def handle_input(c)
    @history.push(c)
    set_game_state
  end

  def undo
    @history.pop
    set_game_state
  end

  def set_game_state
    @game_state = GameState.new(@history, max_set_count: max_set_count)
  end

  def score_for_side(side)
    @game_state.score_for_side(side)
  end
end
