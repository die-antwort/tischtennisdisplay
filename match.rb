require_relative "match_state"

class Match
  attr_reader :max_game_count

  %i[
    current_game_nr
    game_finished?
    game_winner_side
    games
    inspect
    match_finished?
    p1_game_score
    p2_game_score
    side_having_service
    waiting_for_final_game_switching_of_sides?
    winner
    winner_side
  ].each do |method|
    define_method method do
      @match_state.public_send(method)
    end
  end

  def initialize(side_having_first_service:, max_game_count: 3)
    @side_having_first_service = side_having_first_service
    @max_game_count = max_game_count
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
    @match_state = MatchState.new(
      @history,
      side_having_first_service: @side_having_first_service,
      max_game_count: max_game_count
    )
  end

  def score_for_side(side)
    @match_state.score_for_side(side)
  end
end
