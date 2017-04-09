require "spec_helper"
require_relative "../../game"

RSpec.describe Game do
  def game_with_input_sequence(input)
    game = Game.new
    input.each do |c|
      game.handle_input(c)
    end
    game
  end

  it "can delegate input to score" do
    score = game_with_input_sequence(%w(l l r r l l)).score
    expect(score.p1_score).to eq(4)
    expect(score.p2_score).to eq(2)
    expect(score.set).to eq(1)
  end

  it "can undo" do
    game = game_with_input_sequence(%w(l l r r l))
    original_score = game.score
    game.handle_input('r')
    expect(game.score).to_not eq(original_score)
    game.undo
    expect(game.score).to eq(original_score)
  end

  it "can undo across sets" do
    game = game_with_input_sequence(%w(l) * 10)
    original_score = game.score
    game.handle_input('l')
    game.handle_input('l')
    expect(game.score).to_not eq(original_score)
    # needs to also undo the confirmation click that is needed to get to the next set
    game.undo
    game.undo
    expect(game.score).to eq(original_score)
  end
end
