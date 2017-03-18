require_relative "game_state"

class Game
  attr_accessor :input
  attr_reader :game_state
  %i(p1_score p2_score p1_set_score p2_set_score set winner).each do |method|
    define_method method do
      game_state.public_send(method)
    end
  end

  def initialize(input)
    self.input = input
    @history = []
  end

  def run 
    loop do 
      while input.empty?
      end
      c = input.shift
      break if c == 'x'
      @history.push(c)
      @game_state = GameState.new(@history)
      break if @game_state.game_finished?
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
