require 'csv'
class Blackjack
  java_implements 'burlap.oomdp.auxiliary.DomainGenerator'
  java_import 'burlap.oomdp.core.Attribute'
  java_import 'burlap.oomdp.core.ObjectClass'
  java_import 'burlap.oomdp.singleagent.SADomain'
  java_import 'burlap.oomdp.singleagent.explorer.VisualExplorer'
  java_import 'burlap.oomdp.core.State'
  java_import 'burlap.oomdp.core.ObjectInstance'

  HIT = 'hit'
  STAND = 'stand'
  CLASSAGENT = 'player'
  YOUR_HAND = 'your_hand'

  def initialize
    @deck = Deck.new
    @hand = Hand.new
    @standing = false
  end

  def hit
    puts 'Hitting'
    @deck.draw
  end

  def stand
    puts 'Standing'
    @standing = true
  end

  def standing?
    @standing
  end

  def get_clean_state(domain)
    s = State.new
    a = ObjectInstance.new(domain.get_object_class(CLASSAGENT), CLASSAGENT)
    s.add_object(a)
    set_agent(s, 0)
  end

  def set_agent(state, value)
    agent = state.get_first_object_of_class(CLASSAGENT)
    agent.set_value(YOUR_HAND, 0)
  end

  def generateDomain
    domain = SADomain.new

    your_hand_value = Attribute.new(domain, YOUR_HAND, Attribute::AttributeType::INT)
    your_hand_value.set_lims(0,21)

    agent = ObjectClass.new(domain, CLASSAGENT)
    agent.add_attribute(your_hand_value)

    BlackjackAction.new(HIT, domain, self)
    BlackjackAction.new(STAND, domain, self)

    BlackjackTF.new(self)

    domain
  end

  class BlackjackTF
    java_implements 'TerminalFunction'

    def initialize(game)
      @game = game
    end

    def isTerminal(state)
      current_value = state.get_first_object_of_class(CLASSAGENT).get_value_for_attribute(YOUR_HAND)

      if current_value > 21 || @game.standing?
        true
      else
        false
      end
    end
  end

  class PayoffFunction
    java_implements 'RewardFunction'

    def reward(s, action, sprime)

    end
  end
end