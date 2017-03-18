class GameState
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
    self.set = 0
    input.each do |c|
      update_state c
    end
  end

  def update_state(c)
    handle_input(c) unless game_finished?
    if set_finished?
      self.p1_set_score += p1_score > p2_score ? 1 : 0
      self.p2_set_score += p2_score > p1_score ? 1 : 0
      self.p1_score = self.p2_score = 0
    end
  end

  def winner
    return unless game_finished? 
    p1_set_score > p2_set_score ? 1 : 2
  end

  def set_finished?
    (p1_score - p2_score).abs >= MIN_DIFFERENCE && [p1_score, p2_score].max >= WINNING_SCORE
  end

  def game_finished?
    (p1_set_score - p2_set_score).abs >= MIN_SET_DIFFERENCE && [p1_set_score, p2_set_score].max >= WINNING_SET_SCORE
  end

  def handle_input(c)
    case c
    when '1'
      self.p1_score += 1
    when '2'
      self.p2_score += 1 
    else
      $stderr.puts "Unknown command '#{c}'"
    end
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
