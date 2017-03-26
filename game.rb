require_relative "game_state"

class Game
  attr_reader :game_state
  %i(p1_score p2_score p1_set_score p2_set_score set winner).each do |method|
    define_method method do
      game_state.public_send(method)
    end
  end

  def initialize
    @history = []
  end

  def handle_input(c)
    @history.push(c)
    @game_state = GameState.new(@history)
  end

  def undo
    @history.pop()
    @game_state = GameState.new(@history)
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
