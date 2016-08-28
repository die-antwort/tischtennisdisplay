class PlayerScore
  def initialize
    @points = 0
    @change_handler = lambda{ || }
  end

  def increment
    @points += 1
    @change_handler.call
  end

  def decrement
    @points -= 1
    @change_handler.call
  end

  def score
    @points
  end

  attr_reader :points

  def on_change(&handler)
    @change_handler = handler
  end
end
