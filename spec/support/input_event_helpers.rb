require_relative "../../input_event"

module InputEventHelpers
  def l; InputEvent.new(:left); end
  def r; InputEvent.new(:right); end
  def L; InputEvent.new(:left, :confirm); end
  def R; InputEvent.new(:right, :confirm); end
  def u; InputEvent.new(:left, :undo); end
  def i; InputEvent.new(:right, :undo); end
end
