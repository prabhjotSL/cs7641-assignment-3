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

    worth
  end

  def busted?
    worth > 21
  end

  def <=>(other_hand)
    worth <=> other_hand.worth
  end

  def to_s
    "hand contains: #{@cards.map {|c| c.to_s }.join(', ')}. Value of #{worth}"
  end
end
