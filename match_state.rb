require_relative "match_state/game"

class MatchState
  attr_reader :games, :winning_game_score

  WINNING_SCORE = 11

  MIN_GAME_DIFFERENCE = 1

  def initialize(input, max_game_count: 3)
    @games = [Game.new]
    @winning_game_score = winning_game_score_for_max_game_count(max_game_count)
    @player_on = {left: 1, right: 2}
    input.each do |c|
      update_state c
    end
  end

  def update_state(c)
    return if match_finished?
    if game_finished?
      switch_sides
      start_new_game
    elsif waiting_for_final_game_switching_of_sides?
      switch_sides
      current_game.final_game_switch_sides
    else
      handle_input(c)
    end
  end

  def winner
    return unless match_finished?
    p1_game_score > p2_game_score ? 1 : 2
  end

  def winner_side
    @player_on.invert[winner]
  end

  def game_winner
    return unless game_finished?
    current_game.p1_won? ? 1 : 2
  end

  def game_winner_side
    @player_on.invert[game_winner]
  end

  def score_for_side(side)
    if @player_on[side] == 1
      current_game.p1_score
    else
      current_game.p2_score
    end
  end

  def p1_game_score
    games.select(&:p1_won?).size
  end

  def p2_game_score
    games.select(&:p2_won?).size
  end

  def current_game
    games.last
  end

  def current_game_nr
    games.size
  end

  def game_finished?
    current_game.finished?
  end

  def match_finished?
    (p1_game_score - p2_game_score).abs >= MIN_GAME_DIFFERENCE && [p1_game_score, p2_game_score].max >= winning_game_score
  end

  def waiting_for_final_game_switching_of_sides?
    current_game.waiting_for_final_game_switching_of_sides?
  end

  def handle_input(c)
    case c.type
    when :normal
      if @player_on[c.side] == 1
        current_game.p1_scored
      else
        current_game.p2_scored
      end
    else
      $stderr.puts "Unknown command '#{c}'"
    end
  end

  def switch_sides
    tmp = @player_on[:left]
    @player_on[:left] = @player_on[:right]
    @player_on[:right] = tmp
  end

  def start_new_game
    games << Game.new(is_final_game: games.size == winning_game_score * 2 - 2)
  end

  def winning_game_score_for_max_game_count(max_game_count)
    raise ArgumentError, "max_game_count must be an odd number greater than 0" if max_game_count < 1 || max_game_count.even?
    (max_game_count / 2.0).ceil
  end

  def inspect
    {games: games.inspect, p1_game_score: p1_game_score, p2_game_score: p2_game_score}.inspect
  end

  def ==(other)
    return false unless other.class == self.class
    other.games == games &&
      other.p1_game_score == p1_game_score &&
      other.p2_game_score == p2_game_score
  end
end
