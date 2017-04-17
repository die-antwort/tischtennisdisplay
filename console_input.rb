class ConsoleInput
  def get_next
    char = $stdin.getc
    char == "\n" ? get_next : char
  end
end
