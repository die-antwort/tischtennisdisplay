require "pi_piper"
class ButtonInput
  DOUBLE_CLICK_DELAY = 0.2
  DEBOUNCE_DELAY = 0.1

  LEFT_PIN = 1
  RIGHT_PIN = 2

  def initialize
    @inputs = []
    connect(LEFT_PIN, ->  (action) { handle_symbol(action, 'l') })
    connect(RIGHT_PIN, ->  (action) { handle_symbol(action, 'r') })
  end

  def handle_symbol(action, side) 
    if action == :click
      @inputs.push(side)
    else
      @inputs.push('u')
    end
  end

  def get_next
    loop do 
      while @input.empty?; end
      @input.shift
    end
  end

  def connect(button_pin_nr, ƛ)
    t = nil
    PiPiper.after pin: button_pin_nr, goes: :down, pull: :up do
      sleep(DEBOUNCE_DELAY) # debounce button (min click time-'distance')
      if t.nil? || !t.alive?
        t = Thread.new{
          sleep DOUBLE_CLICK_DELAY
          ƛ.call(:click)
        }
      else
        t.kill
        ƛ.call(:double_click)
      end
    end
  end
end
