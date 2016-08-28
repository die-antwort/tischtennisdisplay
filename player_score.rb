class PlayerScore
  def initialize
    @points = 0
    @change_handlers = Array.new
  end

  def increment
    @points += 1
    call_all_change_handlers
  end

  def decrement
    @points -= 1
    call_all_change_handlers
  end

  def call_all_change_handlers
    @change_handlers.each { |handler| handler.call }
  end

  def score
    @points
  end

  attr_reader :points

  def on_change(&handler)
    @change_handlers.push(handler)
  end
end
