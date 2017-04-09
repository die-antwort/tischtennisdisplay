require_relative "score"

class Game
  attr_reader :score
  %i(p1_score p2_score p1_set_score p2_set_score set winner game_finished?).each do |method|
    define_method method do
      score.public_send(method)
    end
  end

  def initialize
    @history = []
  end

  def handle_input(c)
    @history.push(c)
    @score = Score.new(@history)
  end

  def undo
    @history.pop
    @score = Score.new(@history)
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
end
