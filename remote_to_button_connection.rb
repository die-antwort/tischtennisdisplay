require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  DOUBLE_CLICK_DELAY = 0.2
  DEBOUNCE_DELAY = 0.1
  def self.connect(button_pin_nr, remote_controller)
    t = nil
    after pin: button_pin_nr, goes: :down, pull: :up do
      sleep(DEBOUNCE_DELAY) #debounce button (min click time-'distance')
      if t.nil? || !t.alive?
        t = Thread.new{
          sleep DOUBLE_CLICK_DELAY
          puts "click"
          remote_controller.trigger(:click)
        }
      else
        t.kill
        puts "double click"
        remote_controller.trigger(:double_click)
      end
    end
  end
end
