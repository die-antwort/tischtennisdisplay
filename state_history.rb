class StateHistory
  def initialize(command_history, state_keeper)
    command_history.on_push{ push_state }
    command_history.on_undo{ pop_state }
    @state_keeper = state_keeper
    @history = []
  end

  def push_state
    @history.push(@state_keeper.state)
  end

  def pop_state
    @history.pop
  end

  attr_reader :history

  def clear
    @history = []
  end
end
