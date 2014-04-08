class Blackjack
  def initialize(bet = 5)
    @deck = Deck.new

    @dealer_hand = Hand.new
    @your_hand = Hand.new

    2.times do
      @dealer_hand << @deck.draw
      @your_hand << @deck.draw
    end

    @dealer_lost = false
    @you_lost = false

    if anybody_get_21?
      @push = true
      return bet
    else
      until game_finished?

      end

      reward
    end
  end

  def finished?
    (
      @your_hand.worth > 21 ||
      @dealer_hand.worth > 21 ||
      (@dealer_stopped && @you_stopped)
    )
  end

  def anybody_get_21?
    if @your_hand.worth == 21 && @dealer_hand.worth == 21
      puts "You both got 21, busted"
    end
  end

  def hit
    puts "Hitting"
    @your_hand << @deck.draw
  end

  def stand
    wait_for_dealer!
  end

  def wait_for_dealer!
    puts "Standing waiting for dealer"
  end

  def lost?

  end

  def reward
    if lost?
      -bet
    elsif push?
      bet
    else
      2 * bet
    end
  end
end