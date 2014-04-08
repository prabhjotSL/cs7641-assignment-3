class PlotTest
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

  def initialize
    grid = HelloGridWorld.data

    tf = SinglePFTF.new(grid.domain.get_prop_function(GridWorldDomain::PFATLOCATION))

    rf = GoalBasedRF.new(TFGoalCondition.new(tf), 5, -0.1)

    sg = ConstantStateGenerator.new(grid.state)

    hashing_factory = DiscreteStateHashFactory.new

    q_learning_factory = Class.new do
      java_implements LearningAgentFactory

      def initialize(grid, rf, tf, hashing_factory)
        @grid = grid
        @rf = rf
        @tf = tf
        @hashing_factory = hashing_factory
      end

      def agentName
        "Q-Learning"
      end

      def generateAgent
        QLearning.new(@grid.domain, @rf, @tf, 0.99, @hashing_factory, 0.3, 0.1)
      end
    end

    qq = q_learning_factory.new(grid, rf, tf, hashing_factory)

    exp = LearningAlgorithmExperimenter.new(grid.domain, rf, sg, 10, 100, qq)

    exp.set_up_plotting_configuration(500, 250, 2, 1000, TrialMode::MOSTRECENTANDAVERAGE, PerformanceMetric::CUMULATIVESTEPSPEREPISODE, PerformanceMetric::AVERAGEEPISODEREWARD)

    exp.start_experiment
  end
end