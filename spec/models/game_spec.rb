require "spec_helper"
require_relative "../../game"

RSpec.describe Game  do

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
    expect(game.score.p1_score).to eq(3)
    game.undo
    expect(game.score.p1_score).to eq(2)
  end
  
  it "can undo across sets" do
    game = game_with_input_sequence(%w(l) * 12)
    expect(game.score.p1_set_score).to eq(1)
    #needs to also undo the confirmation click that is needed to get to the next set
    game.undo
    game.undo 
    expect(game.score.p1_set_score).to eq(0)
  end

end


