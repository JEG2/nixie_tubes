# Team NixieTubes


## First 24hrs commit

https://github.com/JEG2/nixie_tubes/compare/c2e32ef7b02369baa073df14c051ba27cb21d1b4...9b18cd840297b70534c4728a591348fcf66fd3e0


## Summary


### The ICFP Language

https://github.com/JEG2/nixie_tubes/blob/5e2a11e6298a9c41b3b097fe5513eba173b9c9a4/lib/nixie_tubes/universal_translator.ex

Our ICFP compiler passed the language test but fell apart on more complicated uses of the apply operator.  We decided to made use of the echo service to evaluate the programs for us instead.


### Lambdaman

https://github.com/JEG2/nixie_tubes/blob/5e2a11e6298a9c41b3b097fe5513eba173b9c9a4/lib/nixie_tubes/lambda_man.ex

Erlang's Digraph helped out a lot here to work out a solution that basically divided the board into clusters of dots, and then moved the player to the smaller / closest cluster of points and chewed through them.

`lambdaman21` was an exception, which we built an interactive terminal video game interface for to solve by hand using WASD

This led to some questionable undercooking of our shell to make work, please don't tell the health department:

`stty -echo -cooked; mix run -e 'LambdaMan.interactive(21)'; stty echo cooked`

This read from the saved "/priv/lambdaman/21.txt" problem file, and wrote movements to "/priv/lambdaman/21_solution.txt" (which we then submitted by hand).

In lieu of writing a compiler / compressor for solutions, we stuck with our strategy of re-purpose when possible. For the `lambdaman6`, we took the problem, removed the concat and changed the string from "." to "R"


### Spaceship

https://github.com/JEG2/nixie_tubes/blob/main/lib/nixie_tubes/spaceship.ex

Our algorithm was basically take one point at a time, accelerate to the half way point, decelerate the other half of the way.  Surprisingly this worked for every problem on the board.


### 3d

Goodness gracious, what a fun game.

Continuing in the theme of taking advantage of the tools available, we made use of the test service to walk through our programs instead of building a visualizer, and solved the two of these we managed to solve by hand in emacs.  Thank the gods for rectangular selections.

Our by hand scratch pads are: 
https://github.com/JEG2/nixie_tubes/blob/main/lib/nixie_tubes/absolute_value.txt

### Efficiency

This was also by hand, with a bit of reverse engineering. TODO: study lambda calculus before next year.


### Other bits and bobs

[school_interface](https://github.com/JEG2/nixie_tubes/blob/5e2a11e6298a9c41b3b097fe5513eba173b9c9a4/lib/nixie_tubes/school_interface.ex) -- higher level utility for talking to the service

[solver](https://github.com/JEG2/nixie_tubes/blob/5e2a11e6298a9c41b3b097fe5513eba173b9c9a4/lib/nixie_tubes/solver.ex) -- an attempt at something that would iterate over problems from the API and retry ones that we didn't have the best score for, which we used to great success for Spaceship

[submitomatic](https://github.com/JEG2/nixie_tubes/blob/5e2a11e6298a9c41b3b097fe5513eba173b9c9a4/lib/nixie_tubes/submitomatic.ex) -- the api wrapper
