require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  def self.connect(buttonPinNr, remoteController)
    after pin: buttonPinNr, goes: :down, pull: :up do
      remoteController.onAction(:click)
    end
  end
end
