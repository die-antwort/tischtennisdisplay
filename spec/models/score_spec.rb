require "spec_helper"
require_relative "../../score"

RSpec.describe Score do
  def score(input)
    # this is in a method because we will probably want to set WINNING_SET_SCORE here in the future
    Score.new(input)
  end

  it "handles a valid input sequence" do
    score = score(%w(l l r r l l))
    expect(score.p1_score).to eq(4)
    expect(score.p2_score).to eq(2)
    expect(score.set).to eq(1)
  end


  it "handles changeover" do
    input = %w(l) * 13
    score = score(input)
    expect(score.p1_score).to eq(0)
    expect(score.p2_score).to eq(1)
    expect(score.p1_set_score).to eq(1)
    expect(score.set).to eq(2)
  end

  it "knows who won" do
    # after 3*1b -r we are at 10-0 in set 3
    input = %w(l) * 12 + %w(r) * 12 + %w(l) * 10
    score = score(input)
    expect(score.winner).to be_nil
    score = score(input + ['l'])
    expect(score.winner).to eq(1)
  end

  # it "is aware of minimum difference" do
  #  #input = %w(1) * (3*11-1)
  # end


  it "ignores further input after game is finished" do
    input = %w(l) * 12 + %w(r) * 12 + %w(l) * 11
    score = score(input)
    expect(score.game_finished?).to eq(true)
    expect(score.set).to eq(3)
    expect(score.p1_score).to eq(11)
    score = score(input + ['l'])
    expect(score.game_finished?).to eq(true)
    expect(score.set).to eq(3)
    expect(score.p1_score).to eq(11)
  end

  it "handles changeover in the third set" do
    input = %w(l) * 12 * 4 + %w(l) * 7
    score = score(input)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l'])
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l', 'l'])
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(1)
  end
end
