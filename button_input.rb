require "concurrent-edge"
require_relative "./input_event"

class ButtonInput
  LONG_PRESS_DURATION = 1
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
    pin = UntroubledPiPiper::Pin.new(pin: button_pin_nr, direction: :in, pull: :up)
    UntroubledPiPiper.after pin: button_pin_nr, goes: :down do
      start_time = Time.now
      event = loop do
        break :long_press if Time.now - start_time >= LONG_PRESS_DURATION
        if pin.read == 1 # button has been released
          break :click
        end
      end
      yield event
    end
  end
end
