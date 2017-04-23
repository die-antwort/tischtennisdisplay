#!/usr/bin/env ruby
require "bundler"
require_relative "console_input"
require_relative "console_score_board"
require_relative "game"

class Main
  PINS = {
    left_button_pin: 3,
    right_button_pin: 2,
    clock_pin: 17,
  }.freeze

  P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
  P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze

  def initialize(input, score_board)
    @input = input
    @score_board = score_board
    Thread.abort_on_exception = true
  end

  def run
    @score_board.display("3", "5", blink: :both)
    max_set_count = @input.get_next == 'l' ? 3 : 5
    puts "Starting a best of #{max_set_count} game."
    game = Game.new(max_set_count: max_set_count)

    loop do
      c = @input.get_next
      if c == 'u'
        game.undo
      else
        game.handle_input(c)
      end
      update_score_board(game.score)
      break if game.game_finished?
    end
  end

  private

  def update_score_board(score)
    options =
      if score.game_finished?
        {blink: score.winner_side}
      elsif score.set_finished?
        {blink: :both}
      elsif score.waiting_for_final_set_change_over?
        {blink: :both}
      else
        {}
      end
    @score_board.display(score.for_side(:left), score.for_side(:right), **options)
  end
end


main = if ARGV.shift == "pi"
  require_relative "button_input"
  Main.new(ButtonInput.new(PINS[:left_button_pin], PINS[:right_button_pin]), ConsoleScoreBoard.new)
else
  Main.new(ConsoleInput.new, ConsoleScoreBoard.new)
end

main.run

