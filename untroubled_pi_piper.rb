require "pi_piper"

module UntroubledPiPiper 
  extend PiPiper

  def self.after(options)
    reset_pin options[:pin]
    super
  end

  def self.reset_pin(pin_nr)
    system "echo #{pin_nr} > /sys/class/gpio/unexport 2>/dev/null"
  end

  class Pin < PiPiper::Pin
    def initialize(options)
      UntroubledPiPiper.reset_pin options[:pin]
      super
    end
  end
end
