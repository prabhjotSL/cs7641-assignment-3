class MazeExperimenter
  include_package 'burlap.domain.singleagent.gridworld'
  include_package 'burlap.oomdp.core'
  include_package 'burlap.behavior.singleagent.auxiliary.performance'
  java_import 'burlap.oomdp.core.TerminalFunction'
  java_import 'burlap.oomdp.singleagent.RewardFunction'
  include_package 'burlap.behavior.singleagent.learning'
  java_import 'burlap.behavior.singleagent.learning.tdmethods.QLearning'
  java_import 'burlap.behavior.singleagent.planning.deterministic.TFGoalCondition'
  java_import 'burlap.oomdp.auxiliary.common.ConstantStateGenerator'
  java_import 'burlap.behavior.statehashing.DiscreteStateHashFactory'
  include_package 'burlap.oomdp.singleagent'
  java_import 'burlap.oomdp.singleagent.common.SinglePFTF'
  java_import 'burlap.behavior.singleagent.planning.stochastic.policyiteration.PolicyIteration'
  java_import 'burlap.behavior.singleagent.planning.stochastic.valueiteration.ValueIteration'
  def initialize
    @maze = Maze.new('./Prim_Maze.svg')

    @domain = @maze.generateDomain
    @state = Maze.get_one_agent_one_location_state(@domain)
    Maze.set_agent(@state, 0, 0)
    Maze.set_location(@state, 0, 185, 185)

    @tf = SinglePFTF.new(@domain.get_prop_function(Maze::PFATLOCATION))

    @rf = GoalBasedRF.new(TFGoalCondition.new(@tf), 5, -0.1)

    @sg = ConstantStateGenerator.new(@state)

    @hashing_factory = DiscreteStateHashFactory.new
  end

  def policy_iteration
    pi = PolicyIteration.new(@domain, @rf, @tf, 0.9, @hashing_factory, 1, 100, 100)

    pi.plan_from_state(@state)
  end

  def value_iteration
    vi = ValueIteration.new(@domain, @rf, @tf, 0.9, @hashing_factory, 1, 100)

    vi.plan_from_state(@state)
  end

  def q_learning
    q_learning_factory = Class.new do
      java_implements LearningAgentFactory

      def initialize(domain, rf, tf, hashing_factory)
        @domain = domain
        @rf = rf
        @tf = tf
        @hashing_factory = hashing_factory
      end

      def agentName
        "Q-Learning"
      end

      def generateAgent
        QLearning.new(@domain, @rf, @tf, 0.99, @hashing_factory, 0.3, 0.1)
      end
    end

    qq = q_learning_factory.new(domain, rf, tf, hashing_factory)

    exp = LearningAlgorithmExperimenter.new(domain, rf, sg, 10, 100, qq)

    exp.set_up_plotting_configuration(500, 250, 2, 1000, TrialMode::MOSTRECENTANDAVERAGE, PerformanceMetric::CUMULATIVESTEPSPEREPISODE, PerformanceMetric::AVERAGEEPISODEREWARD)

    exp.start_experiment
  end
end