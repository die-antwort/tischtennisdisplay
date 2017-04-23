require "pi_piper"
require "concurrent-edge"

class ButtonInput
  DOUBLE_CLICK_DELAY = 0.2
  DEBOUNCE_DELAY = 0.1

  def initialize(left_button_pin, right_button_pin)
    system "echo #{left_button_pin} > /sys/class/gpio/unexport 2>/dev/null"
    system "echo #{right_button_pin} > /sys/class/gpio/unexport 2>/dev/null"
    @inputs = Concurrent::Channel.new(capacity: 1000)
    connect(left_button_pin){ |action| handle_symbol(action, 'l') }
    connect(right_button_pin){ |action| handle_symbol(action, 'r') }
  end

  def get
    @inputs.take
  end

  private

  def handle_symbol(action, side)
    if action == :click
      @inputs.put(side)
    else
      @inputs.put('u')
    end
  end

  def connect(button_pin_nr)
    t = nil
    PiPiper.after pin: button_pin_nr, goes: :down, pull: :up do
      sleep(DEBOUNCE_DELAY) # debounce button (min click time-'distance')
      if t.nil? || !t.alive?
        t = Thread.new{
          sleep DOUBLE_CLICK_DELAY
          yield :click
        }
      else
        t.kill
        yield :double_click
      end
    end
  end
end
