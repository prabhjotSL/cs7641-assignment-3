require 'csv'
class Blackjack
  java_implements 'burlap.oomdp.auxiliary.DomainGenerator'
  java_import 'burlap.oomdp.core.Attribute'
  java_import 'burlap.oomdp.core.ObjectClass'
  java_import 'burlap.oomdp.singleagent.SADomain'
  java_import 'burlap.oomdp.core.State'
  java_import 'burlap.oomdp.core.ObjectInstance'
  java_import 'burlap.oomdp.singleagent.explorer.TerminalExplorer'

  HIT = 'hit'
  STAND = 'stand'
  CLASSAGENT = 'player'
  YOUR_HAND = 'your_hand'
  STANDING = 'standing'
  BUSTED = 'busted'

  def initialize
    @deck = Deck.new
  end

  def hit(state)
    agent = state.get_objects_of_true_class(CLASSAGENT).get(0)

    if agent.get_value_for_attribute(STANDING).disc_val == 1
      puts 'Standing were not taking a hit'
    elsif agent.get_value_for_attribute(BUSTED).disc_val == 1
      puts 'You busted man'
    else
      card = @deck.draw
      new_value = card.value + agent.get_value_for_attribute(YOUR_HAND).disc_val

      if new_value > 21
        agent.set_value(BUSTED, 1)
      else
        agent.set_value(YOUR_HAND, new_value)
      end
    end

    state
  end

  def shuffle_deck!
    @deck = Deck.new
  end

  def stand(state)
    agent = state.get_objects_of_true_class(CLASSAGENT).get(0)

    unless agent.get_value_for_attribute(BUSTED) == 1
      agent.set_value(STANDING, 1)
    end

    state
  end

  def self.play!
    # This is just for me to try things out in the terminal
    game = new

    domain = game.generateDomain
    state = get_clean_state(domain)
    set_agent(state, 0)

    explorer = TerminalExplorer.new(domain)
    explorer.add_action_short_hand('h', HIT)
    explorer.add_action_short_hand('s', STAND)

    explorer.explore_from_state(state)
  end

  def self.get_clean_state(domain)
    s = State.new
    a = ObjectInstance.new(domain.get_object_class(CLASSAGENT), CLASSAGENT)
    s.add_object(a)
    set_agent(s, 0)
    s
  end

  def self.set_agent(state, value)
    agent = state.get_first_object_of_class(CLASSAGENT)
    agent.set_value(YOUR_HAND, 0)
    agent.set_value(STANDING, 0)
    agent.set_value(BUSTED, 0)
  end

  def generateDomain
    domain = SADomain.new

    your_hand_value = Attribute.new(domain, YOUR_HAND, Attribute::AttributeType::DISC)
    your_hand_value.set_disc_values_for_range(0, 21, 1)

    standing = Attribute.new(domain, STANDING, Attribute::AttributeType::DISC)
    standing.set_disc_values_for_range(0, 1, 1)

    busted = Attribute.new(domain, BUSTED, Attribute::AttributeType::DISC)
    busted.set_disc_values_for_range(0, 1, 1)

    agent = ObjectClass.new(domain, CLASSAGENT)
    agent.add_attribute(your_hand_value)
    agent.add_attribute(standing)
    agent.add_attribute(busted)

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
      agent = state.get_first_object_of_class(CLASSAGENT)

      if agent.get_value_for_attribute(BUSTED).disc_val == 1 || agent.get_value_for_attribute(STANDING).disc_val == 1
        @game.shuffle_deck!
        true
      else
        false
      end
    end
  end

  class PayoffRewardFunction
    java_implements 'RewardFunction'

    def initialize(game)
      @game = game
    end

    def reward(s, action, sprime)
      agent = s.get_first_object_of_class(CLASSAGENT)
      next_agent = sprime.get_first_object_of_class(CLASSAGENT)

      if next_agent.get_value_for_attribute(BUSTED).disc_val == 1
        -1.0.to_java(:double)
      else
        current_hand = agent.get_value_for_attribute(YOUR_HAND).disc_val
        next_hand = next_agent.get_value_for_attribute(YOUR_HAND).disc_val

        ((Math::exp(next_hand) - Math::exp(current_hand)) / Math::exp(21)).to_java(:double)
      end
    end
  end
end