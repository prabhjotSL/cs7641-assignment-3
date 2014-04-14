java_import 'burlap.oomdp.singleagent.Action'

class BlackjackAction < Action
  def initialize(name, domain, deck)
    @deck = deck
    super(name, domain, '')
  end

  def performActionHelper(state, params)
    card = @deck.draw

  end
end