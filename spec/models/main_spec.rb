require "spec_helper"
require_relative "../../console_input"
require_relative "../../main"

RSpec.describe Main do
  class TestInput < ConsoleInput
    def initialize
      @inputs = []
    end

    def get
      Fiber.yield while @inputs.empty?
      input_event_from_char(@inputs.shift)
    end

    def enter(inputs)
      @inputs.concat(inputs)
    end
  end

  class TestScoreBoard
    attr_reader :state

    def display(left, right, effect: nil, side: nil)
      @state = [
        [left, (effect unless side == :right)],
        [right, (effect unless side == :left)],
      ]
    end
  end

  def enter(inputs)
    @input.enter(Array(inputs))
    @fiber.resume
  end

  before do
    @input = TestInput.new
    @score_board = TestScoreBoard.new
    @main = Main.new(@input, @score_board)
    @fiber = Fiber.new do
      @main.run
    end
    @fiber.resume
  end

  it 'asks if the match should be “best of 3” or “best of 5”' do
    expect(@score_board.state).to eq [[3, :blink_alternating], [5, :blink_alternating]]
    enter('l')
    expect(@main.match.max_set_count).to eq 3
    expect(@score_board.state).to eq [[0, nil], [0, nil]]
  end

  it 'processes inputs as expected' do
    enter('l') # “best of 3”
    enter(%w(l) * 11)
    expect(@score_board.state).to eq [[11, :rotate_cw], [0, nil]]
    expect(@main.match.p1_set_score).to eq 1
    enter('r') # “next game”
    expect(@score_board.state).to eq [[0, nil], [0, nil]]
    enter(%w(L) * 2) # “undo”
    expect(@score_board.state).to eq [[10, nil], [0, nil]]
    enter(%w(r) * 12)
    expect(@score_board.state).to eq [[10, nil], [12, :rotate_cw]]
    expect(@main.match.p1_set_score).to eq 0
    expect(@main.match.p2_set_score).to eq 1
    enter('r') # “next game”
    expect(@score_board.state).to eq [[0, nil], [0, nil]]
    enter(%w(l) * 11)
    expect(@score_board.state).to eq [[11, :rotate_ccw], [nil, nil]]
    expect(@main.match.p1_set_score).to eq 0
    expect(@main.match.p2_set_score).to eq 2
    expect(@main.match.match_finished?).to be true
  end
end
