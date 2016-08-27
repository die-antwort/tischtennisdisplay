class RemoteToButtonConnection
  def self.connect(buttonPinNr, remoteController)
    puts "listening to button presses with nr: " + buttonPinNr.to_s + " and notifying the remoteController about them"
  end
end
