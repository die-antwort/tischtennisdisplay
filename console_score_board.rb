require "curses"
require_relative "./score_board"

class ConsoleScoreBoard < ScoreBoard
  def initialize
    Curses.init_screen
    Curses.curs_set(0) # hide cursor
    super(nil, nil, nil)
  end

  def init_clock_pin(*); end
  def clock; end

  def update(left_bits, right_bits)
    Curses.erase
    left = bits_to_characters(left_bits)
    right = bits_to_characters(right_bits)
    Curses.setpos(0, 0)
    Curses.addstr("Raw bits: %3s %3s" % [left_bits, right_bits])
    left.zip(right).each_with_index do |(l, r), i|
      Curses.setpos(i + 2, 10)
      Curses.addstr(l.to_s)
      Curses.setpos(i + 2, 40)
      Curses.addstr(r.to_s)
    end
    Curses.refresh
  end

  private

  def bits_to_characters(bits)
    bits ||= 0
    decade = [
      " ",
      bits & 0b0000_0001 != 0 ? "*" : " ",
      " ",
      bits & 0b0000_0001 != 0 ? "*" : " ",
      " ",
    ]
    unit = [
      bits & 0b0000_0010 != 0 ? " *** " : "     ",
      "#{bits & 0b0100_0000 != 0 ? '*' : ' '}   #{bits & 0b0000_0100 != 0 ? '*' : ' '}",
      bits & 0b1000_0000 != 0 ? " *** " : "     ",
      "#{bits & 0b0010_0000 != 0 ? '*' : ' '}   #{bits & 0b0000_1000 != 0 ? '*' : ' '}",
      bits & 0b0001_0000 != 0 ? " *** " : "     ",
    ]
    decade.zip(unit).map{ |(d, u)| "#{d}   #{u}".split(//).map{ |c| "#{c}#{c}" }.join}.flat_map.with_index{ |line, i| [line] * (i.even? ? 1 : 4) }
  end
end
