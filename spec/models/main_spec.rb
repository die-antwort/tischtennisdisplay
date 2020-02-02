require "spec_helper"
require_relative "../../console_input"
require_relative "../../main"

RSpec.describe Main do
  class TestInput < ConsoleInput
    def initialize
      @inputs = []
    end

    def get(block: true)
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

  it 'asks for the player ids (undo is possible!), if the match should be “best of 3” or “best of 5”, and for the side serving first' do
    enter('l') # wake up
    expect(@score_board.state).to eq [["PLAYER ", :scroll], ["PLAYER ", :scroll]]
    enter('l') # start player selection

    sleep(BEFORE_PLAYER_SELECTION_DELAY) # wait for player selection to start actually
    enter('l') # select player 0 for left side
    sleep(PLAYER_SELECTION_DELAY + 0.1) # now it should display "1" on the right side
    enter('r') # select player 1 for right side
    expect(@score_board.state).to eq [[0, :blink], [1, :blink]] # confirmation
    enter('L') # undo

    sleep(BEFORE_PLAYER_SELECTION_DELAY) # wait for player selection to start actually
    expect(@score_board.state).to eq [[0, nil], [0, nil]]
    enter('r') # select player 0 for right side
    sleep(PLAYER_SELECTION_DELAY + 0.1) # now it should display "1" on the left side
    expect(@score_board.state).to eq [[1, nil], [0, nil]]
    enter('l') # select player 1 for left side
    expect(@score_board.state).to eq [[1, :blink], [0, :blink]] # confirmation
    enter('l') # confirm

    expect(@score_board.state).to eq [[3, :blink], [5, :blink]] # selection of winning sets
    enter('l') # best of 3

    expect(@score_board.state).to eq [["SERVICE ", :scroll], ["SERVICE ", :scroll]]
    enter('l') # left side serves first

    expect(@score_board.state).to eq [[0, :flash_twice_after_delay], [0, nil]]
    expect(@main.match.max_game_count).to eq 3
    expect(@main.players).to eq([1, 0])
  end

  it 'processes inputs as expected' do
    enter('l') # wake up
    enter('l') # start player selection
    sleep(BEFORE_PLAYER_SELECTION_DELAY) # wait for player selection to start
    enter('l') # right: player 0
    sleep(PLAYER_SELECTION_DELAY + 0.1) # now it should display "2" on the right side
    enter('r') # left: player 1
    enter('l') # confirm player selection
    expect(@main.players).to eq([0, 1])
    enter('l') # “best of 3”
    enter('l') # left side serves first
    enter(%w(l) * 11)
    expect(@score_board.state).to eq [[11, :rotate_cw], [0, nil]]
    expect(@main.match.p1_game_score).to eq 1
    enter('r') # “next game”
    expect(@score_board.state).to eq [[0, :flash_twice_after_delay], [0, nil]]
    enter(%w(L) * 2) # “undo”
    expect(@score_board.state).to eq [[10, nil], [0, :flash_twice_after_delay]]
    enter(%w(r) * 12)
    expect(@score_board.state).to eq [[10, nil], [12, :rotate_cw]]
    expect(@main.match.p1_game_score).to eq 0
    expect(@main.match.p2_game_score).to eq 1
    enter('r') # “next game”
    expect(@score_board.state).to eq [[0, :flash_twice_after_delay], [0, nil]]
    enter(%w(l) * 11)
    expect(@score_board.state).to eq [[11, :rotate_ccw], [nil, nil]]
    expect(@main.match.p1_game_score).to eq 0
    expect(@main.match.p2_game_score).to eq 2
    expect(@main.match.match_finished?).to be true
    enter('l') # continue

    expect(@score_board.state).to eq [["Y", :blink], ["N", :blink]] # ask for rematch
    enter('l')
    expect(@score_board.state).to eq [[0, :flash_twice_after_delay], [0, nil]]
    expect(@main.players).to eq([1, 0])
  end
end
