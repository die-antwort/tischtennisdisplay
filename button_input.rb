require "concurrent-edge"
require_relative "./untroubled_pi_piper"

class ButtonInput
  DOUBLE_CLICK_DELAY = 0.2
  DEBOUNCE_DELAY = 0.1

  def initialize(left_button_pin, right_button_pin)
    @inputs = Concurrent::Channel.new(capacity: 1000)
    connect(left_button_pin){ |action| add_input_event(action, :left) }
    connect(right_button_pin){ |action| add_input_event(action, :right) }
  end

  def get
    @inputs.take
  end

  private

  def add_input_event(action, side)
    if action == :click
      @inputs.put(InputEvent.new(side))
    else
      @inputs.put(InputEvent.new(side, :undo))
    end
  end

  def connect(button_pin_nr)
    t = nil
    UntroubledPiPiper.after pin: button_pin_nr, goes: :down, pull: :up do
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
