class RemoteController
  def initialize(command_history, action_type_for_undo: :double_click)
    @command_map = {}
    @command_map[action_type_for_undo] = lambda{ @command_history.undo }
    @command_history = command_history
  end

  def on(action_type, command)
    @command_map[action_type] = command
  end

  def trigger(action_type)
    command = @command_map[action_type]
    # TODO?: Order is important here
    # cmmand_history expects todo command to have been pushed to history before it is called
    @command_history.push_command(command)
    command.call
  end
end
