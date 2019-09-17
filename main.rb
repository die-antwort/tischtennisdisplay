#!/usr/bin/env ruby
require "bundler"
require_relative "game"

PINS = {
  left_button_pin: 3,
  right_button_pin: 2,
  clock_pin: 17,
}.freeze

P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze

class Main
  attr_reader :score_board, :game

  def initialize(input, score_board)
    @input = input
    @score_board = score_board
    Thread.abort_on_exception = true
  end

  def run
    max_set_count = ask_for_max_set_count
    puts "Starting a best of #{max_set_count} game."
    @game = Game.new(max_set_count: max_set_count)

    loop do
      update_score_board(@game.score)
      c = @input.get
      break if @game.game_finished?
      if c.undo?
        @game.undo
      else
        @game.handle_input(c)
      end
    end
  end

  private

  def ask_for_max_set_count
    @score_board.display(3, 5, effect: :blink_alternating)
    @input.get.left? ? 3 : 5
  end


  def update_score_board(score)
    options =
      if score.game_finished?
        {effect: :rotate_ccw, side: score.winner_side}
      elsif score.set_finished?
        {effect: :rotate_cw, side: score.set_winner_side}
      elsif score.waiting_for_final_set_change_over?
        {effect: :rotate_bounce}
      else
        {}
      end
    left = score.for_side(:left) unless score.game_finished? && score.winner_side == :right
    right = score.for_side(:right) unless score.game_finished? && score.winner_side == :left
    @score_board.display(left, right, **options)
  end
end

if $0 == __FILE__
  main =
    if ARGV.shift == "pi"
      require_relative "button_input"
      require_relative "score_board"
      Main.new(
        ButtonInput.new(PINS[:left_button_pin], PINS[:right_button_pin]),
        ScoreBoard.new(P1_SHIFT_REGISTER, P2_SHIFT_REGISTER, PINS[:clock_pin])
      )
    else
      require_relative "console_input"
      require_relative "console_score_board"
      Main.new(ConsoleInput.new, ConsoleScoreBoard.new)
    end

  main.run
end
