require './Game.rb'
require './GameToScoreBoardConnection.rb'
require './PlayerScore.rb'
require './PlayerScoreIncrementCommand.rb'
require './RemoteController.rb'
require './RemoteToButtonConnection.rb'
require './ScoreBoardDrawer.rb'
require './CommandHistory.rb'
class GameFacade
  @@p1ButtonPinNr = 14
  @@p2ButtonPinNr = 15
  @@p1ShiftRegister = 18
  @@p2ShiftRegister = 23

  def initGame() 
    globalCommandHistory = CommandHistory.new
    p1Score = getRemoteControlledScore(@@p1ButtonPinNr, globalCommandHistory)
    p2Score = getRemoteControlledScore(@@p2ButtonPinNr, globalCommandHistory)
    game = Game.new(p1Score, p2Score)
    gameToScoreBoard = GameToScoreBoardConnection.new(game)
    scoreBoardDrawer = ScoreBoardDrawer.new(gameToScoreBoard, @@p1ShiftRegister, @@p2ShiftRegister)
    subscribeBoardDrawerToScoreChanges(p1Score, p2Score, scoreBoardDrawer)
  end

  def getRemoteControlledScore(inputPin, commandHistory) 
    score = PlayerScore.new
    remote = getRemote(PlayerScoreIncrementCommand.new(score), commandHistory)    
    RemoteToButtonConnection.connect(inputPin, remote)
    return score
  end

  def getRemote(incrementCommand, commandHistory)
    remote = RemoteController.new(commandHistory)
    remote.setCommand(:click, incrementCommand)
    remote.setUndoOnAction(:doubleClick)
    return remote
  end
  
  def subscribeBoardDrawerToScoreChanges(p1Score, p2Score, boardDrawer)
    p1Score.onChange { || boardDrawer.redraw() }
    p2Score.onChange { || boardDrawer.redraw() }
  end

end
