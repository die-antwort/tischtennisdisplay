class RemoteController
  def initialize()
    @commandHistory = Array.new
    @commandMap = {}
  end

  def setCommand(actionType, command)
    @commandMap[actionType] = command
  end

  def undo() 
    @commandHistory.pop() #pops itself off the history
    @commandHistory.pop().undo #gets last command and pops it off
  end

  def setUndoOnAction(actionType) 
    @commandMap[actionType] = lambda { || self.undo() }
  end

  def onAction(actionType)
    command = @commandMap[actionType]
    @commandHistory.push(command);
    command.execute
  end

end
