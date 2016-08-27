require "pi_piper"
include PiPiper
require "./GameFacade.rb"
Thread.abort_on_exception = true

gameFacade = GameFacade.new
gameFacade.initGame()

wait
