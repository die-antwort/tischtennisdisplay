#!/usr/bin/env ruby
require "bundler"
require_relative "button_input"
require_relative "console_input"
require_relative "console_score_board"
require_relative "game"


PINS = {
  left_button_pin: 3,
  right_button_pin: 2,
  clock_pin: 17,
}.freeze

P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze

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


Thread.abort_on_exception = true

if ARGV.shift == "pi"
  PINS.values.each do |pin|
    system "echo #{pin} > /sys/class/gpio/unexport 2>/dev/null";
  end
  @input = ButtonInput.new(PINS[:left_button_pin], PINS[:right_button_pin])
  @score_board = ConsoleScoreBoard.new # FIXME
else
  @input = ConsoleInput.new
  @score_board = ConsoleScoreBoard.new
end

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

