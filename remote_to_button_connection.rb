require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  @@double_click_delay = 0.5
  def self.connect(button_pin_nr, remote_controller)
    # pin = Pin.new(:pin => button_pin_nr)
    # pin.release
    t = nil
    after pin: button_pin_nr, goes: :down, pull: :up do
      puts "low level click"
      if t.nil?
        t = Thread.new{
          sleep @@double_click_delay
          puts "click detected"
          remote_controller.on_action(:click)
          t = nil
        }
      else
        t.kill
        t = nil
        puts "doubleClick"
        remote_controller.on_action(:doubleClick)
      end
    end
  end
end
