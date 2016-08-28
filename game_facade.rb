require './game.rb'
require './game_to_score_board_connection.rb'
require './player_score.rb'
require './player_score_increment_command.rb'
require './remote_controller.rb'
require './remote_to_button_connection.rb'
require './score_board_drawer.rb'
require './command_history.rb'
class GameFacade
  @@p1_button_pin_nr = 14
  @@p2_button_pin_nr = 15
  @@p1_shift_register = 18
  @@p2_shift_register = 23

  def init_game
    global_command_history = CommandHistory.new
    p1_score = remote_controlled_score(@@p1_button_pin_nr, global_command_history)
    p2_score = remote_controlled_score(@@p2_button_pin_nr, global_command_history)
    game = Game.new(p1_score, p2_score)
    game_to_score_board = GameToScoreBoardConnection.new(game)
    score_board_drawer = ScoreBoardDrawer.new(game_to_score_board, @@p1_shift_register, @@p2_shift_register)
    subscribe_board_drawer_to_score_changes(p1_score, p2_score, score_board_drawer)
    game.on_finished { || puts "facade knows game is finished, rewire remote, tear down current game, start new game on next click" }
  end

  def remote_controlled_score(input_pin, command_history)
    score = PlayerScore.new
    remote = remote(PlayerScoreIncrementCommand.new(score), command_history)
    RemoteToButtonConnection.connect(input_pin, remote)
    score
  end

  def remote(increment_command, command_history)
    remote = RemoteController.new(command_history)
    remote.command(:click, increment_command)
    remote.undo_on_action(:doubleClick)
    remote
  end

  def subscribe_board_drawer_to_score_changes(p1_score, p2_score, board_drawer)
    p1_score.on_change{ || board_drawer.redraw }
    p2_score.on_change{ || board_drawer.redraw }
  end
end
