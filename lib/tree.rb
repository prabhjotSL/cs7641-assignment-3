class Tree
  include Enumerable

  attr_accessor :left, :right

  def each(&block)
    yield left
    yield right
  end
end