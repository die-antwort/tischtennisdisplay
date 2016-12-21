require './game_to_score_board_connection.rb'
require './player_score.rb'
require './player_score_increment_command.rb'
require './remote_controller.rb'
require './remote_to_button_connection.rb'
require './score_board_drawer.rb'
require './command_history.rb'
require './player_score_reset_command.rb'
require './game.rb'
require './state_history.rb'
class ContinuousTableTennisScoreBoard

  def initialize(p1_button_pin:, p2_button_pin:, clock_pin:, p1_shift_register:, p2_shift_register:)
    @p1_score = PlayerScore.new
    @p2_score = PlayerScore.new
    command_history = CommandHistory.new
    @p1_remote = RemoteController.new(command_history)
    @p2_remote = RemoteController.new(command_history)
    RemoteToButtonConnection.connect(p1_button_pin, @p1_remote)
    RemoteToButtonConnection.connect(p2_button_pin, @p2_remote)
    clicks_increment
    @game = setup_redrawing_game(p1_shift_register, p2_shift_register, clock_pin)
    @game.on_finished{ clicks_start_new_game }
    @state_history = StateHistory.new(command_history, @game)
  end

  def clicks_increment
    @p1_remote.on(:click, player_score_increment_command(@p1_score))
    @p2_remote.on(:click, player_score_increment_command(@p2_score))
  end


  def setup_redrawing_game(p1_shift_register, p2_shift_register, clock_pin)
    game = Game.new(@p1_score, @p2_score)
    game_to_score_board = GameToScoreBoardConnection.new(game)
    score_board_drawer = ScoreBoardDrawer.new(game_to_score_board, p1_shift_register, p2_shift_register, clock_pin)
    subscribe_board_drawer_to_score_changes(@p1_score, @p2_score, score_board_drawer)
    score_board_drawer.redraw
    game
  end

  def clicks_start_new_game
    puts "game finished"
    new_game_command = PlayerScoreResetCommand.new(@p1_score, @p2_score, on_call: lambda{ commit_state_history; clicks_increment })
    @p1_remote.on(:click, new_game_command)
    @p2_remote.on(:click, new_game_command)
  end

  def commit_state_history
    puts "game commited"
    puts @state_history.history
    @state_history.clear
  end


  def player_score_increment_command(score)
    PlayerScoreIncrementCommand.new(score, on_undo: lambda{
    @p1_remote.on(:click, player_score_increment_command(@p1_score))
    @p2_remote.on(:click, player_score_increment_command(@p2_score))
    })
  end

  def subscribe_board_drawer_to_score_changes(p1_score, p2_score, board_drawer)
    p1_score.on_change{ board_drawer.redraw }
    p2_score.on_change{ board_drawer.redraw }
  end

end