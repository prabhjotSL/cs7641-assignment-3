Install Instructions
====================

Run `bin/setup_jruby.sh` from a console. This will load jruby into the path and install Nokogiri (which was used to parse XML).


Running Instructions
====================

To run the code type `bin/console` (after installing) and it will load an IRB console that you can use to play with BlackjackExperimenter (used to Q-Learning, Value Iteration, and Policy Iteration) as well as MazeExperimenter. 

To do that type

```ruby
maze_experimenter = MazeExperimenter.new
maze_experimenter.value_iteration #=> Prints output
maze_experimenter.policy_iterationg #=> Prints output
maze_experimenter.q_learning #=> Runs Q-Learning code

blackjack = BlackjackExperimenter.new # Runs QLearning by default
blackjack.value_iteration
blackjack.policy_iteration
```


You can also play the games by typing `Blackjack.play!` or `Maze.play!` as well. Though I don't really suggest that since you have to kill the process to exit out.

I honestly preferred to have this inside of a console so I could interact with it. You could easily run this on a command line but I think this is easier this way.
