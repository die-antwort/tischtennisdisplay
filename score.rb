class Score
  attr_reader :p1_score, :p2_score, :p1_set_score, :p2_set_score, :set, :winning_set_score

  WINNING_SCORE = 11
  MIN_DIFFERENCE = 2

  MIN_SET_DIFFERENCE = 1

  def initialize(input, max_set_count: 3)
    @p1_score = 0
    @p2_score = 0
    @p1_set_score = 0
    @p2_set_score = 0
    @set = 1
    @winning_set_score = winning_set_score_for_max_set_count(max_set_count)
    @changed_over_in_final_set = false
    @player_on = {left: 1, right: 2}
    input.each do |c|
      update_state c
    end
  end

  def update_state(c)
    return if game_finished?
    if set_finished?
      change_over
      start_new_set
    elsif waiting_for_final_set_change_over?
      change_over
      @changed_over_in_final_set = true
    else
      handle_input(c)
    end
  end

  def winner
    return unless game_finished?
    p1_set_score > p2_set_score ? 1 : 2
  end

  def winner_side
    @player_on.invert[winner]
  end

  def for_side(side)
    if @player_on[side] == 1
      @p1_score
    else
      @p2_score
    end
  end

  def set_finished?
    (p1_score - p2_score).abs >= MIN_DIFFERENCE && [p1_score, p2_score].max >= WINNING_SCORE
  end

  def game_finished?
    (p1_set_score - p2_set_score).abs >= MIN_SET_DIFFERENCE && [p1_set_score, p2_set_score].max >= winning_set_score
  end

  def waiting_for_final_set_change_over?
    set == winning_set_score * 2 - 1 && p1_score + p2_score == 7 &&
      !@changed_over_in_final_set
  end

  def handle_input(c)
    case c
    when 'l', 'r'
      side = c == 'l' ? :left : :right
      if @player_on[side] == 1
        @p1_score += 1
      else
        @p2_score += 1
      end
    else
      $stderr.puts "Unknown command '#{c}'"
    end
    if set_finished?
      @p1_set_score += p1_score > p2_score ? 1 : 0
      @p2_set_score += p2_score > p1_score ? 1 : 0
    end
  end

  def change_over
    tmp = @player_on[:left]
    @player_on[:left] = @player_on[:right]
    @player_on[:right] = tmp
  end

  def start_new_set
    @p1_score = @p2_score = 0
    @set += 1
  end

  def winning_set_score_for_max_set_count(max_set_count)
    raise ArgumentError, "max_set_count must be an odd number greater than 0" if max_set_count < 1 || max_set_count.even?
    (max_set_count / 2.0).ceil
  end

  def inspect
    <<~EOF
    {
      p1_score: #{p1_score}
      p2_score: #{p2_score}
      set: #{set}
      p1_set_score: #{p1_set_score}
      p2_set_score: #{p2_set_score}
    }
    EOF
  end

  def ==(other)
    return false unless other.class == self.class
    other.p1_score == p1_score &&
      other.p2_score == p2_score &&
      other.set == set &&
      other.p1_set_score == p1_set_score &&
      other.p2_set_score == p2_set_score
  end
end
