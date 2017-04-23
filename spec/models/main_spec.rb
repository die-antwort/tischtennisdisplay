require "spec_helper"
require_relative "../../main"

RSpec.describe Main do
  class TestInput
    def initialize
      @inputs = []
    end

    def get_next
      Fiber.yield while @inputs.empty?
      @inputs.shift
    end

    def enter(inputs)
      @inputs.concat(inputs)
    end
  end

  class TestScoreBoard
    attr_reader :state

    def display(left, right, blink: false)
      @state = [
        [left, blink == :left || blink == :both ? :blink : :normal],
        [right, blink == :right || blink == :both ? :blink : :normal],
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

  it 'asks if the game should be “best of 3” or “best of 5”' do
    expect(@score_board.state).to eq [[3, :blink], [5, :blink]]
    enter('l')
    expect(@main.game.max_set_count).to eq 3
    expect(@score_board.state).to eq [[0, :normal], [0, :normal]]
  end

  it 'processes inputs as expected' do
    enter('l') # “best of 3”
    enter(%w(l) * 11)
    expect(@score_board.state).to eq [[11, :blink], [0, :blink]]
    expect(@main.game.p1_set_score).to eq 1
    enter('r') # “next set”
    expect(@score_board.state).to eq [[0, :normal], [0, :normal]]
    enter(%w(u) * 2)
    expect(@score_board.state).to eq [[10, :normal], [0, :normal]]
    enter(%w(r) * 12)
    expect(@score_board.state).to eq [[10, :blink], [12, :blink]]
    expect(@main.game.p1_set_score).to eq 0
    expect(@main.game.p2_set_score).to eq 1
    enter('r') # “next set”
    expect(@score_board.state).to eq [[0, :normal], [0, :normal]]
    enter(%w(l) * 11)
    expect(@score_board.state).to eq [[11, :blink], [0, :normal]]
    expect(@main.game.p1_set_score).to eq 0
    expect(@main.game.p2_set_score).to eq 2
    expect(@main.game.game_finished?).to be true
  end
end
