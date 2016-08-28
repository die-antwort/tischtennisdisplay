class PlayerScore
  attr_reader :points

  def initialize
    @points = 0
    @change_handlers = []
  end

  def increment
    @points += 1
    call_all_change_handlers
  end

  def decrement
    @points -= 1
    call_all_change_handlers
  end

  def on_change(&handler)
    @change_handlers.push(handler)
  end

  private

  def call_all_change_handlers
    @change_handlers.each(&:call)
  end
end
