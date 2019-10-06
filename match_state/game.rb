class MatchState
  class Game
    MIN_DIFFERENCE = 2

    attr_reader :p1_score, :p2_score

    def initialize(player_having_first_service:, is_final_game: false)
      @player_having_first_service =  player_having_first_service
      @is_final_game = is_final_game
      @final_game_sides_switched = false
      @p1_score = 0
      @p2_score = 0
    end

    def waiting_for_final_game_switching_of_sides?
      @is_final_game && !@final_game_sides_switched && [p1_score, p2_score].max == 5
    end

    def finished?
      (p1_score - p2_score).abs >= MIN_DIFFERENCE && [p1_score, p2_score].max >= WINNING_SCORE
    end

    def deuce?
      p1_score >= WINNING_SCORE - 1 && p2_score >= WINNING_SCORE - 1
    end

    def other_player(player)
      3 - player
    end

    def player_having_service
      if deuce?
        p1_score == p2_score ? @player_having_first_service : other_player(@player_having_first_service)
      else
        ((p1_score + p2_score) / 2).even? ? @player_having_first_service : other_player(@player_having_first_service)
      end
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

    def final_game_switch_sides
      @final_game_sides_switched = true
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
