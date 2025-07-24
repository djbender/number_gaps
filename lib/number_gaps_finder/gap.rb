class Gap
  attr_reader :f, :l

  def initialize(f:, l:)
    @f = f
    @l = l
  end

  def pair
    [f, l]
  end

  def inspect
    "#<Gap f:#{f} l:#{l}>"
  end
end
