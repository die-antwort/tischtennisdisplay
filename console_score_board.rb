class ConsoleScoreBoard
  def display(left_score, right_score, blink: false)
    puts "#{maybe_blinking(left_score, blink == :left || blink == :both)}:" + 
         "#{maybe_blinking(right_score, blink == :right || blink == :both)}"
  end

  def maybe_blinking(string, blinking)
    if blinking
      "\e[5m#{string}\e[0m"
    else
      string
    end
  end
end
