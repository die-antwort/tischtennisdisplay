class CommandHistory
  def initialize
    @history = []
    @push_handlers = []
    @undo_handlers = []
  end

  def undo
    @history.pop # pops itself off the history
    call_all_undo_handlers
    last_command = @history.pop
    unless last_command.nil?
      unless last_command.undo
        #if undo returns false, it is never popped"
        @history.push(last_command)
      else
        call_all_undo_handlers
      end
    end
  end

  def push_command(command)
    @history.push(command)
    call_all_push_handlers
  end

  def on_push(&handler)
    @push_handlers.push(handler)
  end

  def on_undo(&handler)
    @undo_handlers.push(handler)
  end

  private

  def call_all_push_handlers
    @push_handlers.each(&:call)
  end

  def call_all_undo_handlers
    @undo_handlers.each(&:call)
  end
end
