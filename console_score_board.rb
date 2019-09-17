class ConsoleScoreBoard
  def display(left_score, right_score, effect: nil, side: nil)
    print left_score
    print " (#{effect})" if effect && side != :right
    print "  :  "
    print right_score
    print " (#{effect})" if effect && side != :left
    print "\n"
  end
end
