class RemoteController
  def initialize()
    @thisWorks = "this works"
  end
  def works? 
    puts @thisWorks
  end
  def setCommand(actionType, command)
    puts "set command called"
  end
end
