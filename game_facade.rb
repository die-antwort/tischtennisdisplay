require './game_to_score_board_connection.rb'
require './player_score.rb'
require './player_score_increment_command.rb'
require './remote_controller.rb'
require './remote_to_button_connection.rb'
require './score_board_drawer.rb'
require './command_history.rb'
require './player_score_reset_command.rb'
require './game.rb'
class GameFacade
  P1_BUTTON_PIN_NR = 14
  P2_BUTTON_PIN_NR = 15
  P1_SHIFT_REGISTER = '/dev/spidev0.0'.freeze
  P2_SHIFT_REGISTER = '/dev/spidev0.1'.freeze

  def initialize
    @p1_score = PlayerScore.new
    @p2_score = PlayerScore.new
    command_history = CommandHistory.new
    @p1_remote = RemoteController.new(command_history)
    @p2_remote = RemoteController.new(command_history)
    RemoteToButtonConnection.connect(P1_BUTTON_PIN_NR, @p1_remote)
    RemoteToButtonConnection.connect(P2_BUTTON_PIN_NR, @p2_remote)
    clicks_increment
    setup_redrawing_game.on_finished{ clicks_start_new_game }
  end

  def clicks_increment
    @p1_remote.on(:click, player_score_increment_command(@p1_score, @p1_remote))
    @p2_remote.on(:click, player_score_increment_command(@p2_score, @p2_remote))
  end

  def setup_redrawing_game
    game = Game.new(@p1_score, @p2_score)
    game_to_score_board = GameToScoreBoardConnection.new(game)
    score_board_drawer = ScoreBoardDrawer.new(game_to_score_board, P1_SHIFT_REGISTER, P2_SHIFT_REGISTER)
    subscribe_board_drawer_to_score_changes(@p1_score, @p2_score, score_board_drawer)
    score_board_drawer.redraw
    game
  end

  def clicks_start_new_game
    puts "game finished"
    new_game_command = PlayerScoreResetCommand.new(@p1_score, @p2_score, on_call: lambda{ clicks_increment })
    @p1_remote.on(:click, new_game_command)
    @p2_remote.on(:click, new_game_command)
  end


  def player_score_increment_command(score, remote)
    PlayerScoreIncrementCommand.new(score, on_undo: lambda{
      remote.on(:click, PlayerScoreIncrementCommand.new(score))
    })
  end

  def subscribe_board_drawer_to_score_changes(p1_score, p2_score, board_drawer)
    p1_score.on_change{ board_drawer.redraw }
    p2_score.on_change{ board_drawer.redraw }
  end
end
