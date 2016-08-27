require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  def self.connect(buttonPinNr, remoteController)
    puts "listening to button presses with nr: " + buttonPinNr.to_s + " and notifying the remoteController about them"
    after pin: buttonPinNr, goes: :down, pull: :up do
      puts "button was pressed, notifying remote controller"
      remoteController.onAction(:click)
    end
  end
end
