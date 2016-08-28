class RemoteController
  def initialize(command_history)
    @command_map = {}
    @command_history = command_history
  end

  def command(action_type, command)
    @command_map[action_type] = command
  end

  def undo_on_action(action_type)
    @command_map[action_type] = lambda{ || @command_history.undo }
  end

  def on_action(action_type)
    command = @command_map[action_type]
    # TODO?: Order is important here
    # cmmand_history expects todo command to have been pushed to history before it is called
    @command_history.push_command(command)
    command.call
  end
end
