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
input = []

Thread.new do 
  loop do
    input.concat(gets.chomp.split(""))
  end
end



Game.new(input).run

#Game.new(**PINS, p1_shift_register: P1_SHIFT_REGISTER, p2_shift_register: P2_SHIFT_REGISTER)

#wait
