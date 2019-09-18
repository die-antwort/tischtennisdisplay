class GameState
  class Set
    MIN_DIFFERENCE = 2

    attr_reader :p1_score, :p2_score

    def initialize(is_final_set: false)
      @is_final_set = is_final_set
      @p1_score = 0
      @p2_score = 0
    end

    def need_change_over?
      @is_final_set && p1_score + p2_score == 7
    end

    def finished?
      (p1_score - p2_score).abs >= MIN_DIFFERENCE && [p1_score, p2_score].max >= WINNING_SCORE
    end

    def p1_won?
      p1_score > p2_score
    end

    def p2_won?
      p2_score > p1_score
    end

    def p1_scored
      @p1_score += 1
    end

    def p2_scored
      @p2_score += 1
    end

    def ==(other)
      return false unless other.class == self.class
      other.p1_score == p1_score && other.p2_score == p2_score
    end
  end
end
