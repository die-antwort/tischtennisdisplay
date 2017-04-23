require_relative 'input_event'

class ConsoleInput
  def get
    char = $stdin.getc
    char == "\n" ? get : input_event_from_char(char)
  end

  private
  def input_event_from_char(c)
    case c
    when 'l' then InputEvent.new(:left)
    when 'r' then InputEvent.new(:right)
    when 'L' then InputEvent.new(:left, :confirm)
    when 'R' then InputEvent.new(:right, :confirm)
    #because they are next to each other on my keyboard
    when 'u' then InputEvent.new(:left, :undo)
    when 'i' then InputEvent.new(:right, :undo)
    end
  end
end
