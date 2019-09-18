class MatchState
  class Game
    MIN_DIFFERENCE = 2

    attr_reader :p1_score, :p2_score

    def initialize(is_final_set: false)
      @is_final_set = is_final_set
      @final_set_sides_switched = false
      @p1_score = 0
      @p2_score = 0
    end

    def waiting_for_final_set_switching_of_sides?
      @is_final_set && !@final_set_sides_switched && p1_score + p2_score == 7
    end

    def finished?
      (p1_score - p2_score).abs >= MIN_DIFFERENCE && [p1_score, p2_score].max >= WINNING_SCORE
    end

    def p1_won?
      finished? && p1_score > p2_score
    end

    def p2_won?
      finished? && p2_score > p1_score
    end

    def p1_scored
      @p1_score += 1
    end

    def p2_scored
      @p2_score += 1
    end

    def final_set_switch_sides
      @final_set_sides_switched = true
    end

    def inspect
      {p1_score: p1_score, p2_score: p2_score}.inspect
    end

    def ==(other)
      return false unless other.class == self.class
      other.p1_score == p1_score && other.p2_score == p2_score
    end
  end
end
