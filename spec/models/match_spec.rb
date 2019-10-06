require "spec_helper"
require_relative "../../match"
require "support/input_event_helpers"

RSpec.describe Match do
  include InputEventHelpers

  def match_with_input_sequence(input)
    match = Match.new
    input.each do |c|
      match.handle_input(c)
    end
    match
  end

  it "calculates scores" do
    match = match_with_input_sequence([l, l, r, r, l, l])
    expect(match.score_for_side(:left)).to eq(4)
    expect(match.score_for_side(:right)).to eq(2)
    expect(match.current_game_nr).to eq(1)
  end

  it "can undo" do
    match = match_with_input_sequence([l, l, r, r, l])
    expect(match.score_for_side(:left)).to eq(3)
    expect(match.score_for_side(:right)).to eq(2)

    match.undo
    expect(match.score_for_side(:left)).to eq(2)
    expect(match.score_for_side(:right)).to eq(2)

    match.undo
    expect(match.score_for_side(:left)).to eq(2)
    expect(match.score_for_side(:right)).to eq(1)

    match.handle_input(l)
    expect(match.score_for_side(:left)).to eq(3)
    expect(match.score_for_side(:right)).to eq(1)
  end

  it "can undo across games" do
    match = match_with_input_sequence([l] * 11)
    expect(match.score_for_side(:left)).to eq(11)
    expect(match.score_for_side(:right)).to eq(0)
    expect(match.current_game_nr).to eq(1)
    expect(match.p1_game_score).to eq(1)
    expect(match.p2_game_score).to eq(0)

    match.handle_input(l) # acknowledge first game, start second game
    expect(match.score_for_side(:left)).to eq(0)
    expect(match.score_for_side(:right)).to eq(0)
    expect(match.current_game_nr).to eq(2)
    expect(match.p1_game_score).to eq(1)
    expect(match.p2_game_score).to eq(0)

    match.undo
    expect(match.score_for_side(:left)).to eq(11)
    expect(match.score_for_side(:right)).to eq(0)
    expect(match.current_game_nr).to eq(1)
    expect(match.p1_game_score).to eq(1)
    expect(match.p2_game_score).to eq(0)

    match.undo
    expect(match.score_for_side(:left)).to eq(10)
    expect(match.score_for_side(:right)).to eq(0)
    expect(match.current_game_nr).to eq(1)
    expect(match.p1_game_score).to eq(0)
    expect(match.p2_game_score).to eq(0)
  end

  it 'has a valid score even if the input is empty' do
    match = Match.new
    expect(match.score_for_side(:left)).to eq(0)
    expect(match.score_for_side(:right)).to eq(0)
    expect(match.current_game_nr).to eq(1)
    expect(match.p1_game_score).to eq(0)
    expect(match.p2_game_score).to eq(0)
  end
end
