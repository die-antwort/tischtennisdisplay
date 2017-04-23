class InputEvent
  attr_reader :side, :type
  SIDES = [:left, :right].freeze
  TYPES = [:normal, :confirm, :undo].freeze

  def initialize(side, type = :normal)
    raise ArgumentError, "Invalid side passed: #{side}" unless SIDES.include? side
    raise ArgumentError, "Invalid type passed: #{type}" unless TYPES.include? type
    @side = side
    @type = type
  end

  def left?
    @side == :left
  end

  def right?
    @side == :right
  end

  def normal?
    @type == :normal
  end

  def confirm?
    @type == :confirm
  end

  def undo?
    @type == :undo
  end

  def to_s
    "<InputEvent :#{type} :#{side}>"
  end
end
