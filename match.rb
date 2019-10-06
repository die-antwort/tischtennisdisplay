require_relative "match_state"

class Match
  attr_reader :max_set_count

  %i(current_set_nr p1_set_score p2_set_score set_finished? set_winner_side winner_side match_finished? waiting_for_final_set_switching_of_sides? inspect).each do |method|
    define_method method do
      @match_state.public_send(method)
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
    @match_state = MatchState.new(@history, max_set_count: max_set_count)
  end

  def score_for_side(side)
    @match_state.score_for_side(side)
  end
end