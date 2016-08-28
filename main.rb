#!/usr/bin/env ruby

require "pi_piper"
include PiPiper
require "./game_facade.rb"
Thread.abort_on_exception = true

GameFacade.new

wait
