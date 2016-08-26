require "pi_piper"
include PiPiper

#Pin.new(pin: 14, direction: :in, pull: :up)
after pin: 14, goes: :down, pull: :up do
  puts "Button pressed"
end

wait
