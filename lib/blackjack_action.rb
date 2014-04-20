java_import 'burlap.oomdp.singleagent.Action'

class BlackjackAction < Action
  def initialize(name, domain, game)
    @game = game
    @name = name
    super(name, domain, '')
  end

  def performActionHelper(state, params)
    @game.public_send(name, state)
  end
end