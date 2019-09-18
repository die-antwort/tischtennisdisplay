require_relative "match_state/set"

class MatchState
  attr_reader :sets, :winning_set_score

  WINNING_SCORE = 11

  MIN_SET_DIFFERENCE = 1

  def initialize(input, max_set_count: 3)
    @sets = [Set.new]
    @winning_set_score = winning_set_score_for_max_set_count(max_set_count)
    @player_on = {left: 1, right: 2}
    input.each do |c|
      update_state c
    end
  end

  def update_state(c)
    return if match_finished?
    if set_finished?
      change_over
      start_new_set
    elsif waiting_for_final_set_change_over?
      change_over
      current_set.do_final_set_change_over
    else
      handle_input(c)
    end
  end

  def winner
    return unless match_finished?
    p1_set_score > p2_set_score ? 1 : 2
  end

  def winner_side
    @player_on.invert[winner]
  end

  def set_winner
    return unless set_finished?
    current_set.p1_won? ? 1 : 2
  end

  def set_winner_side
    @player_on.invert[set_winner]
  end

  def score_for_side(side)
    if @player_on[side] == 1
      current_set.p1_score
    else
      current_set.p2_score
    end
  end

  def p1_set_score
    sets.select(&:p1_won?).size
  end

  def p2_set_score
    sets.select(&:p2_won?).size
  end

  def current_set
    sets.last
  end

  def current_set_nr
    sets.size
  end

  def set_finished?
    current_set.finished?
  end

  def match_finished?
    (p1_set_score - p2_set_score).abs >= MIN_SET_DIFFERENCE && [p1_set_score, p2_set_score].max >= winning_set_score
  end

  def waiting_for_final_set_change_over?
    current_set.need_change_over?
  end

  def handle_input(c)
    case c.type
    when :normal
      if @player_on[c.side] == 1
        current_set.p1_scored
      else
        current_set.p2_scored
      end
    else
      $stderr.puts "Unknown command '#{c}'"
    end
  end

  def change_over
    tmp = @player_on[:left]
    @player_on[:left] = @player_on[:right]
    @player_on[:right] = tmp
  end

  def start_new_set
    sets << Set.new(is_final_set: sets.size == winning_set_score * 2 - 2)
  end

  def winning_set_score_for_max_set_count(max_set_count)
    raise ArgumentError, "max_set_count must be an odd number greater than 0" if max_set_count < 1 || max_set_count.even?
    (max_set_count / 2.0).ceil
  end

  def inspect
    {sets: sets.inspect, p1_set_score: p1_set_score, p2_set_score: p2_set_score}.inspect
  end

  def ==(other)
    return false unless other.class == self.class
    other.sets == sets &&
      other.p1_set_score == p1_set_score &&
      other.p2_set_score == p2_set_score
  end
end
