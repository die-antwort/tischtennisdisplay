require './Game.rb'
require './GameToScoreBoardConnection.rb'
require './PlayerScore.rb'
require './PlayerScoreIncrementCommand.rb'
require './RemoteController.rb'
require './RemoteToButtonConnection.rb'
require './ScoreBoardDrawer.rb'
class GameFacade
  @@p1ButtonPinNr = 14
  @@p2ButtonPinNr = 15
  @@p1ShiftRegister = 18
  @@p2ShiftRegister = 23

  def initGame() 
    p1Score = getRemoteControlledScore(@@p1ButtonPinNr)
    p2Score = getRemoteControlledScore(@@p2ButtonPinNr)
    game = Game.new(p1Score, p2Score)
    gameToScoreBoard = GameToScoreBoardConnection.new(game)
    scoreBoardDrawer = ScoreBoardDrawer.new(gameToScoreBoard, @@p1ShiftRegister, @@p2ShiftRegister)
    scoreBoardDrawer.redraw();
  end

  def getRemoteControlledScore(inputPin) 
    score = PlayerScore.new
    remote = getRemote(PlayerScoreIncrementCommand.new(score))    
    RemoteToButtonConnection.connect(inputPin, remote)
    return score
  end

  def getRemote(incrementCommand)
    remote = RemoteController.new
    remote.setCommand(:click, incrementCommand)
    remote.setUndoOnAction(:doubleClick)
    return remote
  end

end
