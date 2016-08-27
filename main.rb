require "pi_piper"
include PiPiper
require "./RemoteController.rb"

remote = RemoteController.new
after pin: 14, goes: :down, pull: :up do
  puts "button pressed"
  remote.works?
end

wait
