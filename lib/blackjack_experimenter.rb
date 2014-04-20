class BlackjackExperimenter
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
  java_import 'burlap.behavior.singleagent.planning.stochastic.policyiteration.PolicyIteration'
  java_import 'burlap.behavior.singleagent.planning.stochastic.valueiteration.ValueIteration'

  def initialize
    @game = Blackjack.new

    @domain = @game.generateDomain
    @state = Blackjack.get_clean_state(@domain)

    @tf = Blackjack::BlackjackTF.new(@game)

    @rf = Blackjack::PayoffRewardFunction.new(@game)

    @sg = ConstantStateGenerator.new(@state)

    @hashing_factory = DiscreteStateHashFactory.new

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

    qq = q_learning_factory.new(@domain, @rf, @tf, @hashing_factory)

    exp = LearningAlgorithmExperimenter.new(@domain, @rf, @sg, 10, 100, qq)

    exp.set_up_plotting_configuration(500, 250, 2, 1000, TrialMode::MOSTRECENTANDAVERAGE, PerformanceMetric::CUMULATIVESTEPSPEREPISODE, PerformanceMetric::AVERAGEEPISODEREWARD)
    #
    exp.start_experiment
  end

  def policy_iteration
    pi = PolicyIteration.new(@domain, @rf, @tf, 0.9, @hashing_factory, 1, 10000, 10000)

    timing = Benchmark.measure do
      pi.plan_from_state(@state)
    end

    puts timing

    pi
  end

  def value_iteration
    vi = ValueIteration.new(@domain, @rf, @tf, 0.9, @hashing_factory, 1, 10000)

    timing = Benchmark.measure do
      vi.plan_from_state(@state)
    end

    puts timing
    vi
  end
end