#!/usr/bin/env ruby
require "bundler"

PINS = {
  p1_button_pin: 3,
  p2_button_pin: 2,
  clock_pin: 17,
}.freeze

P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze


PINS.values.each do |pin|
  #system "echo #{pin} > /sys/class/gpio/unexport 2>/dev/null";
end

#require "pi_piper"
#include PiPiper
Thread.abort_on_exception = true

require_relative "game";
require_relative "console_score_board";

def update_score_board(score)
  options = 
    if score.game_finished?
      { blink: score.winner_side }
    elsif score.set_finished?       
      { blink: :both }
    elsif score.final_set_at_changeover_score? 
      { blink: :both }
    else 
      { }
    end
  @score_board.display(score.for_side(:left), score.for_side(:right), **options)
end

game = Game.new
@score_board = ConsoleScoreBoard.new
loop  do
  gets.chomp.split("").each do |c| 
    if (c == 'u') 
      game.undo
    else 
      game.handle_input(c)
    end
  end
  update_score_board(game.score)
  break if game.game_finished?
end







#Game.new(**PINS, p1_shift_register: P1_SHIFT_REGISTER, p2_shift_register: P2_SHIFT_REGISTER)

#wait
