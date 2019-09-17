require 'io/console'
require_relative 'input_event'

class ConsoleInput
  def get
    char = $stdin.getch
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
