require "spec_helper"
require_relative "../../game"

RSpec.describe Game  do
  it "handles a valid input sequence" do
    input = %w(1 1 2 2 1 1 x)
    game = Game.new(input)
    game.run
    expect(game.p1_score).to eq(4)
    expect(game.p2_score).to eq(2)
    expect(game.set).to eq(0)
  end

  it "can be rerun" do
    input = %w(1 1 2 2 1 1 x)
    game = Game.new(input)
    game.run
    expect(game.p1_score).to eq(4)
    expect(game.p2_score).to eq(2)
    expect(game.set).to eq(0)
    input.concat(%w(1 2 x))
    game.run
    expect(game.p1_score).to eq(5)
    expect(game.p2_score).to eq(3)
  end

  it "knows who won" do
    input = %w(1) * (3*11-1)
    input.push('x')
    game = Game.new(input)
    game.run
    expect(game.winner).to be_nil
    input.push("1")
    game.run
    expect(game.winner).to eq(1)
  end

  it "is aware of minimum difference" do
    #input = %w(1) * (3*11-1)
  end


end


