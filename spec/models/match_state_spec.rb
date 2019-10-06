require "spec_helper"
require "support/input_event_helpers"
require_relative "../../match_state"


RSpec.describe MatchState do
  include InputEventHelpers

  def match_state(input, max_game_count: 3)
    MatchState.new(input, max_game_count: max_game_count)
  end

  it "handles a valid input sequence" do
    match_state = match_state([l, l, r, r, l, l])
    expect(match_state.score_for_side(:left)).to eq(4)
    expect(match_state.score_for_side(:right)).to eq(2)
    expect(match_state.current_game_nr).to eq(1)
  end

  it "handles switching of sides" do
    input =
      [l] * 12 +   # Game 1: p1 vs. p2, left side = p1 wins
      [l] * 1      # Game 2: p2 vs. p1, current score 1:0
    match_state = match_state(input)
    expect(match_state.score_for_side(:left)).to eq(1)
    expect(match_state.score_for_side(:right)).to eq(0)
    expect(match_state.p1_game_score).to eq(1)
    expect(match_state.p2_game_score).to eq(0)
    expect(match_state.current_game_nr).to eq(2)
  end

  it "handles switching of sides in last game and knows when it is waiting to switch sides" do
    input =
      [l] * 12 +   # Game 1: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Game 2: p2 vs. p1, left side = p2 wins
      [l] * 12 +   # Game 3: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Game 4: p2 vs. p1, left side = p2 wins
      [l] * 4      # Game 5: p1 vs. p2, current score 4:0
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.current_game_nr).to eq(5)
    expect(match_state.p1_game_score).to eq(2)
    expect(match_state.p2_game_score).to eq(2)
    expect(match_state.score_for_side(:left)).to eq(4)
    expect(match_state.score_for_side(:right)).to eq(0)
    expect(match_state.waiting_for_final_game_switching_of_sides?).to eq(false)

    input << l # 7:0, now waiting to switch sides
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.score_for_side(:left)).to eq(5)
    expect(match_state.score_for_side(:right)).to eq(0)
    expect(match_state.waiting_for_final_game_switching_of_sides?).to eq(true)

    input << l << l # first input confirms switching of sides (7:0 -> 0:7), second input changes score to 1:7
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.waiting_for_final_game_switching_of_sides?).to eq(false)
    expect(match_state.score_for_side(:left)).to eq(1)
    expect(match_state.score_for_side(:right)).to eq(5)
  end

  it "knows who won and on which side (left) they are" do
    input =
      [l] * 12 +   # Game 1: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Game 2: p2 vs. p1, left side = p2 wins
      [r] * 12 +   # Game 3: p1 vs. p2, right side = p2 wins
      [l] * 10     # Game 4: p2 vs. p1, current score 10:0
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.winner).to be_nil
    expect(match_state.winner_side).to be_nil

    input << l # current score 11:0, left side = p2 wins
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.winner).to eq(2)
    expect(match_state.winner_side).to eq(:left)
  end

  it "knows who won and on which side (right) they are" do
    input =
      [l] * 12 +   # Game 1: p1 vs. p2, left side = p1 wins
      [l] * 12 +   # Game 2: p2 vs. p1, left side = p2 wins
      [l] * 12 +   # Game 3: p1 vs. p2, left side = p1 wins
      [r] * 10     # Game 4: p2 vs. p1, current score 0:10
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.winner).to be_nil
    expect(match_state.winner_side).to be_nil

    input << r # current score 0:11, right side = p1 wins
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.winner).to eq(1)
    expect(match_state.winner_side).to eq(:right)
  end

  it "knows when game is finished" do
    input = [l] * 10 # current score 10:0
    match_state = match_state(input)
    expect(match_state.game_finished?).to eq(false)

    input << l # current score 11:0
    match_state = match_state(input)
    expect(match_state.game_finished?).to eq(true)
    expect(match_state.current_game_nr).to eq(1)

    input << l # acknowledge first game, start second game
    match_state = match_state(input)
    expect(match_state.game_finished?).to eq(false)
    expect(match_state.current_game_nr).to eq(2)
  end

  it 'respects max_game_count when checking if the match is finished' do
    winning_sequence_for_best_of_3_match = [l] * 12 + [r] * 11
    expect(match_state(winning_sequence_for_best_of_3_match, max_game_count: 3).match_finished?).to be true
    expect(match_state(winning_sequence_for_best_of_3_match, max_game_count: 5).match_finished?).to be false
  end


  # it "is aware of minimum difference" do
  #  #input = { 1 } * (3*11-1)
  # end

  it "knows when match is finished and ignores input after that" do
    input =
      [l] * 12 +   # Game 1: p1 vs. p2, left side = p1 wins
      [r] * 12 +   # Game 2: p2 vs. p1, right side = p1 wins
      [l] * 10     # Game 3: p1 vs. p2, current score 10:0
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.match_finished?).to eq(false)

    input << l # score now 11:0, p1 wins their third game and thus the match
    match_state = match_state(input, max_game_count: 5)
    expect(match_state.match_finished?).to eq(true)
    expect(match_state.current_game_nr).to eq(3)
    expect(match_state.score_for_side(:left)).to eq(11)

    input << l # match is finished, input should be ignored
    new_game_state = match_state(input, max_game_count: 5)
    expect(new_game_state).to eq(match_state)
  end

  it 'calculates winning_game_score from :max_game_count' do
    expect(MatchState.new([], max_game_count: 1).winning_game_score).to eq(1)
    expect(MatchState.new([], max_game_count: 3).winning_game_score).to eq(2)
    expect(MatchState.new([], max_game_count: 5).winning_game_score).to eq(3)
    expect(MatchState.new([], max_game_count: 7).winning_game_score).to eq(4)
  end

  it 'throws an expection if max_game_count is invalid' do
    expect{ MatchState.new([], max_game_count: -1).winning_game_score }.to raise_error(ArgumentError)
    expect{ MatchState.new([], max_game_count: 0).winning_game_score }.to raise_error(ArgumentError)
    expect{ MatchState.new([], max_game_count: 4).winning_game_score }.to raise_error(ArgumentError)
  end
end
