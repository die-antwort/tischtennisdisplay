class PlayerScore
  def initialize
    @points = 0
    @changeHandler = lambda { || }
  end

  def increment
    @points = @points+1
    @changeHandler.call
  end

  def decrement
    @points = @points-1
    @changeHandler.call
  end
  
  def getScore
    return @points
  end

  def points
    @points
  end
  
  def onChange(&handler)
    @changeHandler = handler
  end
end
