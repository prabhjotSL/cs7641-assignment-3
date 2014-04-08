class Card
  FACES = %w[Ace].concat((2..10).to_a).concat(%w[Jack Queen King])
  include Comparable

  attr_reader :modulo

  def initialize(number)
    @number = number
    @modulo = (@number - 1) % 13
  end

  def face
    FACES[@modulo]
  end

  def suit
    case @number
    when (0..12)
      "Spades"
    when (13..26)
      "Hearts"
    when (26..39)
      "Diamonds"
    when (39..52)
      "Clubs"
    end
  end

  def +(other)
    self.modulo + other.modulo + 2
  end

  def to_s
    "#{face} of #{suit}"
  end

  def value
    value = [@modulo + 1]
    value << 11 if ace?
    value
  end

  def ace?
    @modulo == 0
  end

  def <=>(card)
    self.modulo <=> card.modulo
  end
end