java_import 'burlap.oomdp.singleagent.Action'

class BlackjackAction < Action
  def initialize(name, domain, game)
    @game = game
    super(name, domain, '')
  end

  def performActionHelper(state, params)
    @game.public_send(name)
  end
end