class Score
  attr_accessor :p1_score, :p2_score, :p1_set_score, :p2_set_score, :set

  WINNING_SCORE = 11
  MIN_DIFFERENCE = 2

  WINNING_SET_SCORE = 3
  MIN_SET_DIFFERENCE = 1

  def initialize(input)
    self.p1_score = 0
    self.p2_score = 0
    self.p1_set_score = 0
    self.p2_set_score = 0
    self.set = 1
    @changed_over_in_final_set = false
    @player_on = { left: 1, right: 2 }
    input.each do |c|
      update_state c
    end
  end

  def update_state(c)
    return if game_finished?
    if set_finished?
      change_over
      start_new_set
    elsif final_set_at_changeover_score? && !@changed_over_in_final_set
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
    (p1_set_score - p2_set_score).abs >= MIN_SET_DIFFERENCE && [p1_set_score, p2_set_score].max >= WINNING_SET_SCORE
  end

  def final_set_at_changeover_score?
    return set == WINNING_SET_SCORE*2 - 1 && p1_score+p2_score == 7
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
      self.p1_set_score += p1_score > p2_score ? 1 : 0
      self.p2_set_score += p2_score > p1_score ? 1 : 0
    end
  end

  def change_over
    tmp = @player_on[:left]
    @player_on[:left] = @player_on[:right]
    @player_on[:right] = tmp
  end

  def start_new_set 
    self.p1_score = self.p2_score = 0
    self.set += 1
  end

  def inspect
    return <<~EOF
    {
      p1_score: #{p1_score}
      p2_score: #{p2_score}
      set: #{set}
      p1_set_score: #{p1_set_score}
      p2_set_score: #{p2_set_score}
    }
    EOF
  end

end
