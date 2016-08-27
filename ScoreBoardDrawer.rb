class ScoreBoardDrawer
  def initialize(gameBoardConnection, p1ShiftRegister, p2ShiftRegister)
    @p1ShiftRegister = p1ShiftRegister
    @p2ShiftRegister = p2ShiftRegister
    @gameBoardConnection = gameBoardConnection
  end

  def redraw()
    #puts "should redraw score board with these bits:"
    puts @gameBoardConnection.getScoreBoardState
  end
end
