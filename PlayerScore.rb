class PlayerScore
  def initialize
    @points = 0
  end

  def increment
    @points = @points+1
  end

  def decrement
    @points = @points-1
  end
  
  def getScore
    return @points
  end

  def points
    @points
  end
end
