class StateHistory
  def initialize(command_history, state_keeper)
    command_history.on_push{ pushState }
    command_history.on_undo{ popState }
    @state_keeper = state_keeper
    @history = []
  end

  def pushState
    @history.push(@state_keeper.state)
  end

  def popState
    @history.pop
  end

  attr_reader :history

  def clear
    @history = []
  end
end
