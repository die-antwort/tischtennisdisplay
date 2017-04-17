require "pi_piper"
require "concurrent/atomic/semaphore"

class ButtonInput
  DOUBLE_CLICK_DELAY = 0.2
  DEBOUNCE_DELAY = 0.1

  def initialize(left_button_pin, right_button_pin)
    @inputs = []
    @semaphore = Concurrent::Semaphore.new(0)
    connect(left_button_pin, ->(action) { handle_symbol(action, 'l') })
    connect(right_button_pin, ->(action) { handle_symbol(action, 'r') })
  end

  def get_next
    @semaphore.acquire if @inputs.empty?
    @inputs.shift
  end

  private

  def handle_symbol(action, side)
    if action == :click
      @inputs.push(side)
    else
      @inputs.push('u')
    end
    @semaphore.release
  end

  def connect(button_pin_nr, handler)
    t = nil
    PiPiper.after pin: button_pin_nr, goes: :down, pull: :up do
      sleep(DEBOUNCE_DELAY) # debounce button (min click time-'distance')
      if t.nil? || !t.alive?
        t = Thread.new{
          sleep DOUBLE_CLICK_DELAY
          handler.call(:click)
        }
      else
        t.kill
        handler.call(:double_click)
      end
    end
  end
end
