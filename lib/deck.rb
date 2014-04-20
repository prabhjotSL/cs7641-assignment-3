class Deck
  def initialize
    @cards_in_play = (1..52).map {|i| Card.new(i) }.shuffle
  end

  def draw(times = 1)
    raise 'No more cards :(' if @cards_in_play.empty?
    @cards_in_play.shift
  end
end