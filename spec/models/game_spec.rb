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
    input = %w(l l r r l l)
    game = game_with_input_sequence(input)
    expect(game.p1_score).to eq(4)
    expect(game.p2_score).to eq(2)
    expect(game.set).to eq(1)
  end

  it "can be rerun" do
    input = %w(l l r r l l)
    game = game_with_input_sequence(input)
    expect(game.p1_score).to eq(4)
    expect(game.p2_score).to eq(2)
    expect(game.set).to eq(1)
    %w(l r).each do |c| 
      game.handle_input(c)
    end
    expect(game.p1_score).to eq(5)
    expect(game.p2_score).to eq(3)
  end

  it "handles changeover" do
    input = %w(l) * 13
    game = game_with_input_sequence(input)
    expect(game.p1_score).to eq(0)
    expect(game.p2_score).to eq(1)
    expect(game.p1_set_score).to eq(1)
    expect(game.set).to eq(2)

  end

  it "knows who won" do
    #after 3*1b -r we are at 10-0 in set 3
    input = %w(l)*12 + %w(r)*12 + %w(l)*10
    game = game_with_input_sequence(input)
    expect(game.winner).to be_nil
    game.handle_input('l')
    expect(game.winner).to eq(1)
  end

  it "is aware of minimum difference" do
    #input = %w(1) * (3*11-1)
  end

  it "can undo" do 
    game = game_with_input_sequence(%w(l l r r l))
    expect(game.p1_score).to eq(3)
    game.undo
    expect(game.p1_score).to eq(2)
  end
  
  it "can undo across sets" do
    game = game_with_input_sequence(%w(l) * 12)
    expect(game.p1_set_score).to eq(1)
    #needs to also undo the confirmation click that is needed to get to the next set
    game.undo
    game.undo 
    expect(game.p1_set_score).to eq(0)
  end

  it "ignores further input after game is finished" do
    game = game_with_input_sequence(%w(l)*12 + %w(r)*12 + %w(l)*11)
    expect(game.game_finished?).to eq(true)
    expect(game.set).to eq(3)
    expect(game.p1_score).to eq(11)
    game.handle_input('l')
    expect(game.game_finished?).to eq(true)
    expect(game.set).to eq(3)
    expect(game.p1_score).to eq(11)
  end

  it "handles chageover in the third set" do
    game = game_with_input_sequence(%w(l)*12*4 + %w(l)*7)
    expect(game.p1_score).to eq(7)
    expect(game.p2_score).to eq(0)
    game.handle_input('l')
    expect(game.p1_score).to eq(7)
    expect(game.p2_score).to eq(0)
    game.handle_input('l')
    expect(game.p1_score).to eq(7)
    expect(game.p2_score).to eq(1)
  end

end


