require 'csv'
class BlackjackDomain
  java_implements 'burlap.oomdp.auxiliary.DomainGenerator'
  java_import 'burlap.oomdp.core.Attribute'
  java_import 'burlap.oomdp.core.ObjectClass'
  java_import 'burlap.oomdp.singleagent.SADomain'
  attr_reader :bet

  def initialize(bet = 1, dealer_threshold = 17, your_threshold = 17)
    @bet = bet
    @deck = Deck.new

    @dealer_threshold = dealer_threshold
    @your_threshold = your_threshold

    @dealer_hand = Hand.new
    @your_hand = Hand.new

    2.times do
      @dealer_hand << @deck.draw
      @your_hand << @deck.draw
    end
  end

  def play!
    until finished?
      if @dealer_hand.worth == 21
        you_lose!
        break
      end

      dealer_action = (@dealer_hand.worth < @dealer_threshold) ? :hit : :stand

      public_send(dealer_action, @dealer_hand)

      break if @dealer_hand.busted?

      your_action = (@your_hand.worth < @your_threshold) ? :hit : :stand

      public_send(your_action, @your_hand)
    end
  end

  def you_lose!
    @you_lost = true
  end

  def lost?
    @you_lost || @your_hand < @dealer_hand
  end

  def finished?
    (
      @your_hand.busted? ||
      @dealer_hand.busted? ||
      (@dealer_hand.standing && @your_hand.standing)
    )
  end

  def push?
    @your_hand.worth == @dealer_hand.worth
  end

  def hit(player)
    player << @deck.draw
  end

  def stand(player)
    player.standing = true
  end

  def reward
    if lost?
      -bet
    elsif push?
      0
    else
      bet
    end
  end

  def generateDomain
    domain = SADomain.new

    your_hand_value = Attribute.new(domain, "your_hand_value", Attribute::AttributeType::INT)
    your_hand_value.set_lims(0,21)

    dealer_hand_value = Attribute.new(domain, "dealer_hand_value", Attribute::AttributeType::INT)
    dealer_hand_value.set_lims(0,21)

    agent = ObjectClass.new(domain, 'player')
    agent.add_attribute(your_hand_value)
    agent.add_attribute(dealer_hand_value)

    BlackjackAction.new('hit', domain)
    BlackjackAction.new('stand', domain)

    domain

  end

  def hit_action
    Class.new()
  end

  # def self.rewards(times, dealer_threshold, your_threshold)
  #     payoffs = []
  #
  #     times.times do |i|
  #       game = new
  #       game.play!
  #       payoffs << game.reward
  #     end
  #
  #     payoffs
  #   end
  #
  #   def self.payoffs_by_thresholds!
  #     matrix = Array.new(21) { Array.new(21) }
  #     (1..21).each do |dealer_thresh|
  #       (1..21).each do |your_thresh|
  #         puts "#{dealer_thresh}_#{your_thresh}"
  #
  #         matrix[dealer_thresh - 1][your_thresh - 1] = Blackjack.rewards(10000, dealer_thresh, your_thresh).inject(&:+)
  #       end
  #     end
  #
  #     CSV.open("./payoffs_for_each_threshold.csv", 'wb') do |row|
  #       row << ["Row: dealer threshold Col: your threshold"].concat((1..21).to_a)
  #       matrix.each_with_index do |rr, i|
  #         row << [i + 1].concat(rr)
  #       end
  #     end
  #   end
end