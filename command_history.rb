class CommandHistory
  def initialize
    @history = []
  end

  def undo
    @history.pop # pops itself off the history
    last_command = @history.pop
    unless last_command.nil?
      last_command.undo
    end
  end

  def push_command(command)
    @history.push(command)
  end
end
