class Hand
  include Comparable

  attr_accessor :standing

  def initialize
    @cards = []
  end

  def <<(card)
    @cards.concat(Array(card))
  end

  def worth
    worth = 0

    @cards.each do |c|
      worth += c.value
    end

    if worth > 21
      -1
    else
      Rational(Math::exp(worth), Math::exp(21))
    end
  end

  def <=>(other_hand)
    worth <=> other_hand.worth
  end

  def to_s
    "hand contains: #{@cards.map {|c| c.to_s }.join(', ')}. Value of #{worth}"
  end
end
