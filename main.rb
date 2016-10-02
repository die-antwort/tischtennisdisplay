#!/usr/bin/env ruby

PINS = {
  p1_button_pin: 3,
  p2_button_pin: 2,
  clock_pin: 25,
}.freeze

P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze


PINS.values.each do |pin|
  system "echo #{pin} > /sys/class/gpio/unexport 2>/dev/null";
end

require "pi_piper"
include PiPiper
require "./game_facade.rb"
Thread.abort_on_exception = true

GameFacade.new(**PINS, p1_shift_register: P1_SHIFT_REGISTER, p2_shift_register: P2_SHIFT_REGISTER)

wait
