class GameState
  class Set
    MIN_DIFFERENCE = 2

    attr_reader :p1_score, :p2_score

    def initialize
      @p1_score = 0
      @p2_score = 0
    end

    def finished?
      (p1_score - p2_score).abs >= MIN_DIFFERENCE && [p1_score, p2_score].max >= WINNING_SCORE
    end

    def p1_scored
      @p1_score += 1
    end

    def p2_scored
      @p2_score += 1
    end
  end
end
