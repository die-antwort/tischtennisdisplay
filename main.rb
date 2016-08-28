require "pi_piper"
include PiPiper
require "./game_facade.rb"
Thread.abort_on_exception = true

game_facade = GameFacade.new
game_facade.init_game

wait
