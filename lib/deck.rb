class Deck
  def initialize
    @cards_in_play = (1..52).map {|i| Card.new(i) }.shuffle
    @discard_pile = []
    @in_play = []
  end

  def draw(times = 1)
    to_player = @cards_in_play.shift(times)
    @in_play.concat(to_player)
    to_player
  end

  def return_to_deck(cards)
    Array(cards).each do |card|
      @discard_pile << card
      @in_play.reject! {|c| c == card}
    end
  end
end