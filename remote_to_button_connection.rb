require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  DOUBLE_CLICK_DELAY = 0.2
  def self.connect(button_pin_nr, remote_controller)
    # pin = Pin.new(:pin => button_pin_nr)
    # pin.release
    t = nil
    after pin: button_pin_nr, goes: :down, pull: :up do
      puts "low level click"
      if t.nil?
        t = Thread.new{
          sleep DOUBLE_CLICK_DELAY
          puts "click detected"
          remote_controller.trigger(:click)
          t = nil
        }
      else
        t.kill
        t = nil
        puts ":double_click"
        remote_controller.trigger(:double_click)
      end
    end
  end
end
