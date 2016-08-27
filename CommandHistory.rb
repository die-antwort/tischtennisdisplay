class CommandHistory
  def initialize
    @history = Array.new
  end

  def undo() 
    @history.pop() #pops itself off the history
    lastCommand = @history.pop()
    if lastCommand != nil
      lastCommand.undo 
    end
  end

  def pushCommand(command)
    @history.push(command)
  end
end
