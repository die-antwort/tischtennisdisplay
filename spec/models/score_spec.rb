require "spec_helper"
require_relative "../../score"

RSpec.describe Score do
  def score(input, max_set_count: 3)
    Score.new(input, max_set_count: max_set_count)
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
    score = score(input, max_set_count: 5)
    expect(score.waiting_for_final_set_change_over?).to eq(false)
    expect(score.p1_score).to eq(6)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l'], max_set_count: 5)
    expect(score.waiting_for_final_set_change_over?).to eq(true)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l', 'l'], max_set_count: 5)
    expect(score.waiting_for_final_set_change_over?).to eq(false)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(0)
    score = score(input + ['l', 'l', 'l'], max_set_count: 5)
    expect(score.waiting_for_final_set_change_over?).to eq(false)
    expect(score.p1_score).to eq(7)
    expect(score.p2_score).to eq(1)
  end

  it "knows who won and on which side (left) they are" do
    input = %w(l) * 12 * 2 + %w(r) * 12 + %w(l) * 10
    score = score(input, max_set_count: 5)
    expect(score.winner).to be_nil
    expect(score.winner_side).to be_nil
    score = score(input + ['l'], max_set_count: 5)
    expect(score.winner).to eq(2)
    expect(score.winner_side).to eq(:left)
  end

  it "knows who won and on which side (right) they are" do
    input = %w(l) * 12 * 2 + %w(l) * 12 + %w(r) * 10
    score = score(input, max_set_count: 5)
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

  it 'respects max_set_count when checking if the game is finished' do
    winning_sequence_for_best_of_3_match = %w(l) * 12 + %w(r) * 11
    expect(score(winning_sequence_for_best_of_3_match, max_set_count: 3).game_finished?).to be true
    expect(score(winning_sequence_for_best_of_3_match, max_set_count: 5).game_finished?).to be false
  end


  # it "is aware of minimum difference" do
  #  #input = %w(1) * (3*11-1)
  # end


  it "knows when game is finished and ignores input after that" do
    input = %w(l) * 12 + %w(r) * 12 + %w(l) * 10
    score = score(input, max_set_count: 5)
    expect(score.game_finished?).to eq(false)
    score = score(input + ['l'], max_set_count: 5)
    expect(score.game_finished?).to eq(true)
    expect(score.set).to eq(3)
    expect(score.p1_score).to eq(11)
    score = score(input + ['l'], max_set_count: 5)
    expect(score.game_finished?).to eq(true)
    expect(score.set).to eq(3)
    expect(score.p1_score).to eq(11)
  end

  it 'calculates winning_set_score from :max_set_count' do
    expect(Score.new([], max_set_count: 1).winning_set_score).to eq(1)
    expect(Score.new([], max_set_count: 3).winning_set_score).to eq(2)
    expect(Score.new([], max_set_count: 5).winning_set_score).to eq(3)
    expect(Score.new([], max_set_count: 7).winning_set_score).to eq(4)
  end

  it 'throws an expection if max_set_count is invalid' do
    expect{ Score.new([], max_set_count: -1).winning_set_score }.to raise_error(ArgumentError)
    expect{ Score.new([], max_set_count: 0).winning_set_score }.to raise_error(ArgumentError)
    expect{ Score.new([], max_set_count: 4).winning_set_score }.to raise_error(ArgumentError)
  end
end
