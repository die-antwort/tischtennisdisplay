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
    @points = @points > 0 ? @points - 1 : 0
    call_all_change_handlers
  end

  def reset
    @points = 0
    call_all_change_handlers
  end

  def set(points)
    @points = points
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
