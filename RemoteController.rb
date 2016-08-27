class RemoteController
  def initialize(commandHistory)
    @commandMap = {}
    @commandHistory = commandHistory
  end

  def setCommand(actionType, command)
    @commandMap[actionType] = command
  end

  def setUndoOnAction(actionType) 
    @commandMap[actionType] = lambda { || @commandHistory.undo() }
  end

  def onAction(actionType)
    command = @commandMap[actionType]
    #TODO?: Order is important here
    #cmmandHistory expects todo command to have been pushed to history before it is called
    @commandHistory.pushCommand(command)
    command.call
  end

end
