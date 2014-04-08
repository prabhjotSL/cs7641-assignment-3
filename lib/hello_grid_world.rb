
class HelloGridWorld
  include_package 'burlap.domain.singleagent.gridworld'
  include_package 'burlap.oomdp.core'
  java_import 'burlap.oomdp.singleagent.explorer.VisualExplorer'
  java_import 'burlap.oomdp.visualizer.Visualizer'

  def initialize
    grid = self.class.data

    v = GridWorldVisualizer.get_visualizer(grid.domain, grid.grid_world.map)
    exp = VisualExplorer.new(grid.domain, v, grid.state)

    exp.add_key_action("w", GridWorldDomain::ACTIONNORTH)
    exp.add_key_action("s", GridWorldDomain::ACTIONSOUTH)
    exp.add_key_action("a", GridWorldDomain::ACTIONWEST)
    exp.add_key_action("d", GridWorldDomain::ACTIONEAST)

    exp.init_gui

  end

  def self.data
    grid_world = GridWorldDomain.new(11,11)
    grid_world.set_map_to_four_rooms
    grid_world.prob_succeed_transition_dynamics = 0.8

    domain = grid_world.generate_domain
    state = GridWorldDomain.get_one_agent_one_location_state(domain)
    GridWorldDomain.set_agent(state, 0, 0)
    GridWorldDomain.set_location(state, 0, 10, 10)

    Struct.new(:domain, :state, :grid_world).new(domain, state, grid_world)
  end
end