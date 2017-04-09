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

  it "handles changeover in last set and knows when it is waiting for changeover" do
    input = %w(l) * 12 * 4 + %w(l) * 6
    score = score(input)
    expect(score.waiting_for_final_set_change_over?).to eq(false)
    expect(score.p1_score).to eq(6)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l'])
    expect(score.waiting_for_final_set_change_over?).to eq(true)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l', 'l'])
    expect(score.waiting_for_final_set_change_over?).to eq(false)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l', 'l', 'l'])
    expect(score.waiting_for_final_set_change_over?).to eq(false)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(1)
  end

  it "knows who won and on which side (left) they are" do
    input = %w(l) * 12 * 2 + %w(r) * 12 + %w(l) * 10
    score = score(input)
    expect(score.winner).to be_nil
    expect(score.winner_side).to be_nil
    score = score(input + ['l'])
    expect(score.winner).to eq(2)
    expect(score.winner_side).to eq(:left)
  end

  it "knows who won and on which side (right) they are" do
    input = %w(l) * 12 * 2 + %w(l) * 12 + %w(r) * 10
    score = score(input)
    expect(score.winner).to be_nil
    expect(score.winner_side).to be_nil
    score = score(input + ['r'])
    expect(score.winner).to eq(1)
    expect(score.winner_side).to eq(:right)
  end

  it "knows when set is finished" do
    input = %w(l) * 10
    score = score(input)
    expect(score.set_finished?).to eq(false)
    score = score(input + ['l'])
    expect(score.set_finished?).to eq(true)
    score = score(input + ['l', 'l'])
    expect(score.set_finished?).to eq(false)
  end




  # it "is aware of minimum difference" do
  #  #input = %w(1) * (3*11-1)
  # end


  it "knows when game is finished and ignores input after that" do
    input = %w(l) * 12 + %w(r) * 12 + %w(l) * 10
    score = score(input)
    expect(score.game_finished?).to eq(false)
    score = score(input + ['l'])
    expect(score.game_finished?).to eq(true)
    expect(score.set).to eq(3)
    expect(score.p1_score).to eq(11)
    score = score(input + ['l'])
    expect(score.game_finished?).to eq(true)
    expect(score.set).to eq(3)
    expect(score.p1_score).to eq(11)
  end
end
