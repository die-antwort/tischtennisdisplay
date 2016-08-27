class Game
  @@winningScore = 11
  @@minDifference = 2

  def initialize(p1Score, p2Score)
    @p1Score = p1Score
    @p2Score = p2Score
  end

  def inProgress?() 
    p1Points = @p1Score.points
    p2Points = @p2Score.points
    dif = (p1Points-p2Points).abs
    return dif < @@minDifference ||
      [p1Points, p2Points].max < @@winningScore
  end

  def getLeadingPlayer()
    @p1Score.points > @p2Score.points ? :p1 : :p2
  end

  def winner() 
    if !inProgress?
      return getLeadingPlayer
    end
    return nil
  end

  def getGameState()
    return {
      :p1Points => @p1Score.points,
      :p2Points => @p2Score.points,
      :inProgress => inProgress?,
      :winner => winner
    }
  end
end
