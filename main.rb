require "pi_piper"
include PiPiper
require "./GameFacade.rb"

gameFacade = GameFacade.new
gameFacade.initGame()

wait
