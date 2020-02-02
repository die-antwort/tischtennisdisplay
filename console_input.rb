require 'io/console'
require "concurrent-edge"
require_relative 'input_event'

class ConsoleInput
  def initialize
    @inputs = Concurrent::Channel.new(capacity: 1000)
    t = Thread.new do
      while true
        ch = $stdin.getch
        raise Interrupt if ch == "\u0003" # Ctrl-c
        @inputs.put(ch)
      end
    end
    t.abort_on_exception = true
  end

  def get(block: true)
    char =
      if block
        @inputs.take
      else
        @inputs.poll
      end
    input_event_from_char(char)
  end

  private

  def input_event_from_char(c)
    case c
    when 'l' then InputEvent.new(:left)
    when 'r' then InputEvent.new(:right)
    when 'L' then InputEvent.new(:left, :undo)
    when 'R' then InputEvent.new(:right, :undo)
    end
  end
end
