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
  

  it "handles a valid input sequence" do
    input = %w(1 1 2 2 1 1)
    game = game_with_input_sequence(input)
    expect(game.p1_score).to eq(4)
    expect(game.p2_score).to eq(2)
    expect(game.set).to eq(0)
  end

  it "can be rerun" do
    input = %w(1 1 2 2 1 1)
    game = game_with_input_sequence(input)
    expect(game.p1_score).to eq(4)
    expect(game.p2_score).to eq(2)
    expect(game.set).to eq(0)
    %w(1 2).each do |c| 
      game.handle_input(c)
    end
    expect(game.p1_score).to eq(5)
    expect(game.p2_score).to eq(3)
  end

  it "knows who won" do
    input = %w(1) * (3*11-1)
    game = game_with_input_sequence(input)
    expect(game.winner).to be_nil
    game.handle_input('1')
    expect(game.winner).to eq(1)
  end

  it "is aware of minimum difference" do
    #input = %w(1) * (3*11-1)
  end

  it "can undo" do 
    game = game_with_input_sequence(%w(1 1 2 2 1))
    expect(game.p1_score).to eq(3)
    game.undo
    expect(game.p1_score).to eq(2)
  end
  
  it "can undo across sets" do
    game = game_with_input_sequence(%w(1) * 11)
    expect(game.p1_set_score).to eq(1)
    game.undo
    expect(game.p1_set_score).to eq(0)
  end


end


