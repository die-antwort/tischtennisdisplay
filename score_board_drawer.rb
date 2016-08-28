class ScoreBoardDrawer
  def initialize(game_board_connection, p1_shift_register, p2_shift_register)
    @p1_shift_register = p1_shift_register
    @p2_shift_register = p2_shift_register
    @game_board_connection = game_board_connection
  end

  def redraw
    # puts "should redraw score board with these bits:"
    puts @game_board_connection.score_board_state
  end
end
