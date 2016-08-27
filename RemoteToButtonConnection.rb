require "pi_piper"
include PiPiper
class RemoteToButtonConnection
  @@doubleClickDelay = 0.5
  def self.connect(buttonPinNr, remoteController)
    #pin = Pin.new(:pin => buttonPinNr)
    #pin.release
    t = nil
    after pin: buttonPinNr, goes: :down, pull: :up do
      puts "low level click" 
      if t == nil
        t = Thread.new { 
          sleep @@doubleClickDelay;
          puts "click detected"
          remoteController.onAction(:click)
          t = nil
        }
      else
        t.kill
        t = nil
        puts "doubleClick"
        remoteController.onAction(:doubleClick)
      end
    end
  end
end
