require './game.rb'
require './game_to_score_board_connection.rb'
require './player_score.rb'
require './player_score_increment_command.rb'
require './remote_controller.rb'
require './remote_to_button_connection.rb'
require './score_board_drawer.rb'
require './command_history.rb'
class GameFacade
  P1_BUTTON_PIN_NR = 14
  P2_BUTTON_PIN_NR = 15
  P1_SHIFT_REGISTER = 18
  P2_SHIFT_REGISTER = 23

  def initialize
    global_command_history = CommandHistory.new
    p1_score = remote_controlled_score(P1_BUTTON_PIN_NR, global_command_history)
    p2_score = remote_controlled_score(P2_BUTTON_PIN_NR, global_command_history)
    game = Game.new(p1_score, p2_score)
    game_to_score_board = GameToScoreBoardConnection.new(game)
    score_board_drawer = ScoreBoardDrawer.new(game_to_score_board, P1_SHIFT_REGISTER, P2_SHIFT_REGISTER)
    subscribe_board_drawer_to_score_changes(p1_score, p2_score, score_board_drawer)
    game.on_finished{ puts "facade knows game is finished, rewire remote, tear down current game, start new game on next click" }
  end

  def remote_controlled_score(input_pin, command_history)
    score = PlayerScore.new
    remote_controller = remote_controller_for(PlayerScoreIncrementCommand.new(score), command_history)
    RemoteToButtonConnection.connect(input_pin, remote_controller)
    score
  end

  def remote_controller_for(increment_command, command_history)
    remote_controller = RemoteController.new(command_history)
    remote_controller.on(:click, increment_command)
    remote_controller
  end

  def subscribe_board_drawer_to_score_changes(p1_score, p2_score, board_drawer)
    p1_score.on_change{ board_drawer.redraw }
    p2_score.on_change{ board_drawer.redraw }
  end
end
