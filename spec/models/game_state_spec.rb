require "spec_helper"
require "support/input_event_helpers"
require_relative "../../game_state"


RSpec.describe GameState do
  include InputEventHelpers

  def game_state(input, max_set_count: 3)
    GameState.new(input, max_set_count: max_set_count)
  end

  it "handles a valid input sequence" do
    game_state = game_state([l, l, r, r, l, l])
    expect(game_state.score_for_side(:left)).to eq(4)
    expect(game_state.score_for_side(:right)).to eq(2)
    expect(game_state.current_set_nr).to eq(1)
  end

  it "handles changeover" do
    input =
      [l] * 12 +   # Set 1: p1 vs. p2, left side = p1 wins
      [l] * 1      # Set 2: p2 vs. p1, current score 1:0
    game_state = game_state(input)
    expect(game_state.score_for_side(:left)).to eq(1)
    expect(game_state.score_for_side(:right)).to eq(0)
    expect(game_state.p1_set_score).to eq(1)
    expect(game_state.p2_set_score).to eq(0)
    expect(game_state.current_set_nr).to eq(2)
  end

  it "handles changeover in last set and knows when it is waiting for changeover" do
    input =
      [l] * 12 +   # Set 1: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Set 2: p2 vs. p1, left side = p2 wins
      [l] * 12 +   # Set 3: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Set 4: p2 vs. p1, left side = p2 wins
      [l] * 6      # Set 5: p1 vs. p2, current score 6:0
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.current_set_nr).to eq(5)
    expect(game_state.p1_set_score).to eq(2)
    expect(game_state.p2_set_score).to eq(2)
    expect(game_state.score_for_side(:left)).to eq(6)
    expect(game_state.score_for_side(:right)).to eq(0)
    expect(game_state.waiting_for_final_set_change_over?).to eq(false)

    input << l # 7:0, now waiting for changeover
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.score_for_side(:left)).to eq(7)
    expect(game_state.score_for_side(:right)).to eq(0)
    expect(game_state.waiting_for_final_set_change_over?).to eq(true)

    input << l << l # first input confirms changeover (7:0 -> 0:7), second input changes score to 1:7
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.waiting_for_final_set_change_over?).to eq(false)
    expect(game_state.score_for_side(:left)).to eq(1)
    expect(game_state.score_for_side(:right)).to eq(7)
  end

  it "knows who won and on which side (left) they are" do
    input =
      [l] * 12 +   # Set 1: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Set 2: p2 vs. p1, left side = p2 wins
      [r] * 12 +   # Set 3: p1 vs. p2, right side = p2 wins
      [l] * 10     # Set 4: p2 vs. p1, current score 10:0
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.winner).to be_nil
    expect(game_state.winner_side).to be_nil

    input << l # current score 11:0, left side = p2 wins
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.winner).to eq(2)
    expect(game_state.winner_side).to eq(:left)
  end

  it "knows who won and on which side (right) they are" do
    input =
      [l] * 12 +   # Set 1: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Set 2: p2 vs. p1, left side = p2 wins
      [l] * 12 +   # Set 3: p1 vs. p2, left side = p1 wins
      [r] * 10     # Set 4: p2 vs. p1, current score 0:10
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.winner).to be_nil
    expect(game_state.winner_side).to be_nil

    input << r # current score 0:11, right side = p1 wins
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.winner).to eq(1)
    expect(game_state.winner_side).to eq(:right)
  end

  it "knows when set is finished" do
    input = [l] * 10 # current score 10:0
    game_state = game_state(input)
    expect(game_state.set_finished?).to eq(false)

    input << l # current score 11:0
    game_state = game_state(input)
    expect(game_state.set_finished?).to eq(true)
    expect(game_state.current_set_nr).to eq(1)

    input << l # acknowledge first set, start second set
    game_state = game_state(input)
    expect(game_state.set_finished?).to eq(false)
    expect(game_state.current_set_nr).to eq(2)
  end

  it 'respects max_set_count when checking if the match is finished' do
    winning_sequence_for_best_of_3_match = [l] * 12 + [r] * 11
    expect(game_state(winning_sequence_for_best_of_3_match, max_set_count: 3).match_finished?).to be true
    expect(game_state(winning_sequence_for_best_of_3_match, max_set_count: 5).match_finished?).to be false
  end


  # it "is aware of minimum difference" do
  #  #input = { 1 } * (3*11-1)
  # end

  it "knows when match is finished and ignores input after that" do
    input =
      [l] * 12 +   # Set 1: p1 vs. p2, left side = p1 wins
      [r] * 12 +   # Set 2: p2 vs. p1, right side = p1 wins
      [l] * 10     # Set 3: p1 vs. p2, current score 10:0
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.match_finished?).to eq(false)

    input << l # score now 11:0, p1 wins their third set and thus the match
    game_state = game_state(input, max_set_count: 5)
    expect(game_state.match_finished?).to eq(true)
    expect(game_state.current_set_nr).to eq(3)
    expect(game_state.score_for_side(:left)).to eq(11)

    input << l # match is finished, input should be ignored
    new_game_state = game_state(input, max_set_count: 5)
    expect(new_game_state).to eq(game_state)
  end

  it 'calculates winning_set_score from :max_set_count' do
    expect(GameState.new([], max_set_count: 1).winning_set_score).to eq(1)
    expect(GameState.new([], max_set_count: 3).winning_set_score).to eq(2)
    expect(GameState.new([], max_set_count: 5).winning_set_score).to eq(3)
    expect(GameState.new([], max_set_count: 7).winning_set_score).to eq(4)
  end

  it 'throws an expection if max_set_count is invalid' do
    expect{ GameState.new([], max_set_count: -1).winning_set_score }.to raise_error(ArgumentError)
    expect{ GameState.new([], max_set_count: 0).winning_set_score }.to raise_error(ArgumentError)
    expect{ GameState.new([], max_set_count: 4).winning_set_score }.to raise_error(ArgumentError)
  end
end
