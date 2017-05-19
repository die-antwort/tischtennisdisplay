require "pi_piper"

class UntroubledPiPiper < PiPiper
  def self.after(options)
    reset_pin options[:pin]
    super
  end

  def self.reset_pin(pin_nr)
    system "echo #{pin_nr} > /sys/class/gpio/unexport 2>/dev/null"
  end

  class Pin < PiPiper::Pin
    def initialize(options)
      self.class.reset_pin options[:pin]
      super
    end
  end
end
