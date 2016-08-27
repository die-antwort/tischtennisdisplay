require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  def self.connect(buttonPinNr, remoteController)
    t = nil
    after pin: buttonPinNr, goes: :down, pull: :up do
      if t == nil
        t = Thread.new { 
          sleep 0.2;
          remoteController.onAction(:click)
          t = nil
        }
      else
        t.kill
        t = nil
        remoteController.onAction(:doubleClick)
      end
    end
  end
end
