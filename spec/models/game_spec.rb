require "spec_helper"
require_relative "../../game"
require "support/input_event_helpers"

RSpec.describe Game do
  include InputEventHelpers

  def game_with_input_sequence(input)
    game = Game.new
    input.each do |c|
      game.handle_input(c)
    end
    game
  end

  it "calculates scores" do
    game = game_with_input_sequence([l, l, r, r, l, l])
    expect(game.score_for_side(:left)).to eq(4)
    expect(game.score_for_side(:right)).to eq(2)
    expect(game.current_set_nr).to eq(1)
  end

  it "can undo" do
    game = game_with_input_sequence([l, l, r, r, l])
    expect(game.score_for_side(:left)).to eq(3)
    expect(game.score_for_side(:right)).to eq(2)

    game.undo
    expect(game.score_for_side(:left)).to eq(2)
    expect(game.score_for_side(:right)).to eq(2)

    game.undo
    expect(game.score_for_side(:left)).to eq(2)
    expect(game.score_for_side(:right)).to eq(1)

    game.handle_input(l)
    expect(game.score_for_side(:left)).to eq(3)
    expect(game.score_for_side(:right)).to eq(1)
  end

  it "can undo across sets" do
    game = game_with_input_sequence([l] * 11)
    expect(game.score_for_side(:left)).to eq(11)
    expect(game.score_for_side(:right)).to eq(0)
    expect(game.current_set_nr).to eq(1)
    expect(game.p1_set_score).to eq(1)
    expect(game.p2_set_score).to eq(0)

    game.handle_input(l) # acknowledge first set, start second set
    expect(game.score_for_side(:left)).to eq(0)
    expect(game.score_for_side(:right)).to eq(0)
    expect(game.current_set_nr).to eq(2)
    expect(game.p1_set_score).to eq(1)
    expect(game.p2_set_score).to eq(0)

    game.undo
    expect(game.score_for_side(:left)).to eq(11)
    expect(game.score_for_side(:right)).to eq(0)
    expect(game.current_set_nr).to eq(1)
    expect(game.p1_set_score).to eq(1)
    expect(game.p2_set_score).to eq(0)

    game.undo
    expect(game.score_for_side(:left)).to eq(10)
    expect(game.score_for_side(:right)).to eq(0)
    expect(game.current_set_nr).to eq(1)
    expect(game.p1_set_score).to eq(0)
    expect(game.p2_set_score).to eq(0)
  end

  it 'has a valid score even if the input is empty' do
    game = Game.new
    expect(game.score_for_side(:left)).to eq(0)
    expect(game.score_for_side(:right)).to eq(0)
    expect(game.current_set_nr).to eq(1)
    expect(game.p1_set_score).to eq(0)
    expect(game.p2_set_score).to eq(0)
  end
end
