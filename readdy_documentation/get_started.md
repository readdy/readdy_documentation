---
layout: page
title: Get started
---
 
```python
import readdy

system = readdy.ReactionDiffusionSystem()

system.box_size = [10, 10, 10]
system.add_species("A", 2.0)
system.reactions.add("mydecay: A ->", rate=1.)
system.reactions.add("myfission: A -> A +(1) A", rate=3.)

simulation = system.simulation(kernel="CPU")

simulation.observe.number_of_particles(stride=1)
simulation.output_file = "out.h5"
simulation.add_particle("A", [0.,0.,0.])

simulation.run(100, 0.01)
```

The above snippet performs a ReaDDy simulation, which consists of three steps:
- configure the system
- configure the simulation
- run the simulation 

At first create a `ReactionDiffusionSystem`, which determines _what_ to simulate.
This includes the size and periodicity of
the simulation-box, particle species, [reactions]({{site.baseurl}}/reactions.html), 
[potentials]({{site.baseurl}}/potentials.html) and [topologies]({{site.baseurl}}/topologies.html).
These are set via properties and methods of the `system` object.

The `system` object generates a `simulation` object, which determines _how_ to simulate the `system`.
This includes the diffusion integrator, the reaction handler, [observables]({{site.baseurl}}/observables.html).
The initial positions of particles are also set on the `simulation` object.

Finally `run` the simulation for the given number of steps and time step. 
