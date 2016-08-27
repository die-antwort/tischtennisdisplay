require "pi_piper"
include PiPiper
require "./GameFacade.rb"

gameFacade = GameFacade.new
gameFacade.initGame()
after pin: 14, goes: :down, pull: :up do
  puts "button pressed"
end

wait
