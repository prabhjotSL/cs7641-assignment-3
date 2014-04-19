class Deck
  def initialize
    @cards_in_play = (1..52).map {|i| Card.new(i) }.shuffle
  end

  def draw(times = 1)
    @cards_in_play.shift
  end
end