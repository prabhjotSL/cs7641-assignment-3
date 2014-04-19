class Maze
  java_import 'burlap.debugtools.RandomFactory'
  java_import 'burlap.oomdp.auxiliary.DomainGenerator'
  java_import 'burlap.oomdp.core.Attribute'
  java_import 'burlap.oomdp.core.Domain'
  java_import 'burlap.oomdp.core.ObjectClass'
  java_import 'burlap.oomdp.core.ObjectInstance'
  java_import 'burlap.oomdp.core.PropositionalFunction'
  java_import 'burlap.oomdp.core.State'
  java_import 'burlap.oomdp.core.TransitionProbability'
  java_import 'burlap.oomdp.singleagent.Action'
  java_import 'burlap.oomdp.singleagent.SADomain'
  java_import 'burlap.oomdp.singleagent.explorer.TerminalExplorer'
  java_import 'burlap.oomdp.singleagent.explorer.VisualExplorer'
  java_import 'burlap.oomdp.visualizer.Visualizer'

  ATTX = 'x'
  ATTY = 'y'
  ATTLOCTYPE = "locType"
  CLASSAGENT = 'mouse'
  CLASSLOCATION = 'cheese'
  ACTIONNORTH = 'north'
  ACTIONSOUTH = 'south'
  ACTIONEAST = 'east'
  ACTIONWEST = 'west'

  PFATLOCATION = "atLocation"
  PFWALLNORTH = "wallToNorth"
  PFWALLSOUTH = "wallToSouth"
  PFWALLEAST = "wallToEast"
  PFWALLWEST = "wallToWest"

  attr_reader :map, :svg_xml
  attr_accessor :num_location_types

  def initialize(svg_file)
    parse_svg(svg_file)
    @num_location_types = 1
    @transition_dynamics = 4.times.map do |i|
      4.times.map do |j|
        if i != j
          0.0
        else
          1.0
        end
      end
    end
  end

  def self.play!
    # This is just for me to try things out in the terminal
    maze = new('./Prim_Maze.svg')

    domain = maze.generateDomain
    state = get_one_agent_one_location_state(domain)
    set_agent(state, 0, 0)
    set_location(state, 0, 10, 10)

    explorer = TerminalExplorer.new(domain)
    explorer.add_action_short_hand('n', ACTIONNORTH)
    explorer.add_action_short_hand('e', ACTIONEAST)
    explorer.add_action_short_hand('w', ACTIONWEST)
    explorer.add_action_short_hand('s', ACTIONSOUTH)

    explorer.explore_from_state(state)
  end

  def self.get_one_agent_one_location_state(domain)
    state = State.new
    state.add_object(ObjectInstance.new(domain.get_object_class(CLASSLOCATION), CLASSLOCATION + '0'))
    state.add_object(ObjectInstance.new(domain.get_object_class(CLASSAGENT), CLASSAGENT + '0'))

    state
  end

  def self.set_agent(state, x, y)
    object = state.get_objects_of_true_class(CLASSAGENT).get(0)
    object.set_value(ATTX, x)
    object.set_value(ATTY, y)
  end

  def self.set_location(state, i, x, y)
    obj = state.get_objects_of_true_class(CLASSLOCATION).get(i)

    obj.set_value(ATTX, x)
    obj.set_value(ATTY, y)
    obj.set_value(ATTLOCTYPE, 0)
  end

  def self.movement_direction_from_index(i)
    {
      0 => [0, 1],
      1 => [0, -1],
      2 => [1, 0],
      3 => [-1, 0],
    }.fetch(i)
  end

  def parse_svg(svg_file)
    doc = Nokogiri::XML.parse(File.read(svg_file))
    @svg_xml = Nokogiri::XML.parse(File.read('./Prim_Maze.svg'))
    @width = svg_xml.root.attr('width').to_i
    @height = svg_xml.root.attr('height').to_i
    @map = Array.new(@height) { Array.new(@width) { 0 }}

    @svg_xml.css('line').each do |line|
      x1 = line.attr("x1").to_i
      x2 = line.attr("x2").to_i
      y1 = line.attr("y1").to_i
      y2 = line.attr("y2").to_i
      draw_line(x1, y1, x2, y2)
    end
  end

  def draw_line(x1, y1, x2, y2)
    if x1 == x2
      # Up and down
      yy1, yy2 = [y1, y2].sort
      yy1.upto(yy2).each do |y|
        @map[x1][y] = 1
      end
    else
      xx1, xx2 = [x1, x2].sort
      xx1.upto(xx2).each do |x|
        @map[x][y1] = 1
      end
    end
  end

  def generateDomain
    domain = SADomain.new

    xatt = Attribute.new(domain, ATTX, Attribute::AttributeType::DISC)
    xatt.set_disc_values_for_range(0, @width - 1, 1)

    yatt = Attribute.new(domain, ATTY, Attribute::AttributeType::DISC)
    yatt.set_disc_values_for_range(0, @height - 1, 1)

    ltatt = Attribute.new(domain, ATTLOCTYPE, Attribute::AttributeType::DISC)
    ltatt.set_disc_values_for_range(0, num_location_types - 1, 1)

    mouse = ObjectClass.new(domain, CLASSAGENT)
    mouse.add_attribute(xatt)
    mouse.add_attribute(yatt)

    cheese = ObjectClass.new(domain, CLASSLOCATION)
    cheese.add_attribute(xatt)
    cheese.add_attribute(yatt)
    cheese.add_attribute(ltatt)

    MovementAction.new(ACTIONNORTH, domain, @transition_dynamics[0], self)
    MovementAction.new(ACTIONSOUTH, domain, @transition_dynamics[1], self)
    MovementAction.new(ACTIONEAST, domain, @transition_dynamics[2], self)
    MovementAction.new(ACTIONWEST, domain, @transition_dynamics[3], self)

    AtLocationPF.new(PFATLOCATION, domain, [CLASSAGENT, CLASSLOCATION])

    WallToPF.new(PFWALLNORTH, domain, [CLASSAGENT], self, 0)
    WallToPF.new(PFWALLSOUTH, domain, [CLASSAGENT], self, 1)
    WallToPF.new(PFWALLEAST, domain, [CLASSAGENT], self, 2)
    WallToPF.new(PFWALLWEST, domain, [CLASSAGENT], self, 3)

    domain
  end

  def move(state, xd, yd)
    mouse = state.get_objects_of_true_class(CLASSAGENT).get(0)

    mx = mouse.get_disc_val_for_attribute(ATTX)
    my = mouse.get_disc_val_for_attribute(ATTY)

    nx = mx + xd
    ny = my + yd

    if !(0...@width).include?(nx) || !(0...@height).include?(ny) || @map[nx][ny] == 1 ||
        (xd > 0 && (@map[mx][my] == 3 || @map[mx][my] == 4)) ||
        (xd < 0 && (@map[nx][ny] == 3 || @map[nx][ny] == 4)) ||
        (yd > 0 && (@map[mx][my] == 2 || @map[mx][my] == 4)) ||
        (yd < 0 && (@map[nx][ny] == 2 || @map[nx][ny] == 4))

      nx = mx
      ny = my
    end
    mouse.set_value(ATTX, nx)
    mouse.set_value(ATTY, ny)
  end

  class AtLocationPF < PropositionalFunction
    def initialize(name, domain, params)
      super(name, domain, params.to_java(:string))
    end

    def isTrue(state, params)
      mouse = state.get_object(params[0])
      cheese = state.get_object(params[1])

      mx = mouse.get_disc_val_for_attribute(ATTX)
      my = mouse.get_disc_val_for_attribute(ATTY)

      cx = cheese.get_disc_val_for_attribute(ATTX)
      cy = cheese.get_disc_val_for_attribute(ATTY)

      (mx == cx && my == cy)
    end
  end

  class WallToPF < PropositionalFunction
    def initialize(name, domain, parameter_classes, game, direction)
      super(name, domain, parameter_classes.to_java(:string))
      @dcomps = Maze.movement_direction_from_index(direction)
      @xdelta = @dcomps[0]
      @ydelta = @dcomps[1]
    end

    def isTrue(state, params)
      mouse = state.get_object(params[0])

      mx = mouse.get_disc_val_for_attribute(ATTX)
      my = mouse.get_disc_val_for_attribute(ATTY)

      cx = mx + @xdelta
      cy = my + @ydelta

      !(0..@maze.width).include?(cx) || !(0..@maze.height).include?(cy) || @maze.map[cx][cy] == 1
    end
  end

  class MovementAction < Action
    def initialize(name, domain, directions, game)
      super(name, domain, '')
      @game = game
      @direction_probs = directions
      @rand = RandomFactory.get_mapped(0)
    end

    def performActionHelper(state, params)
      roll = @rand.next_double
      cur_sum = 0.0
      dir = 0

      @direction_probs.each_with_index do |prob, i|
        cur_sum += prob
        if roll < cur_sum
          dir = i
          break
        end
      end

      dcomps = Maze.movement_direction_from_index(dir)
      @game.move(state, dcomps[0], dcomps[1])
      state
    end

    def getTransitions(state, params)
      transitions = java.util.ArrayList.new
      @direction_probs.each_with_index do |prob, i|
        if prob == 0
          next
        else
          ns = state.copy
          dcomps = Maze.movement_direction_from_index(i)
          @game.move(ns, dcomps[0], dcomps[1])

          is_new = true
          throw transitions.first.p if transitions.length == 1
          transitions.each do |transition|
            if transition.s.equals(ns)
              is_new = false
              transition.p += prob
              break
            end
          end

          if is_new
            tp = TransitionProbability.new(ns, prob.to_java(:double))
            transitions.add(tp)
          end
        end
      end

      transitions
    end
  end
end