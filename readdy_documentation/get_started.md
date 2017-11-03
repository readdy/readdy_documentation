---
layout: page
title: Get started
---
 
```python
import readdy

# ----- Step 1: Set up reaction diffusion system

# set up reaction diffusion system in a cube with edge lenge 10nm
system = readdy.ReactionDiffusionSystem(box_size=(10, 10, 10))

# registers a species 'A' with diffusion constant 2.0 nm**2/ns
system.add_species("A", 2.0)
# register a decay reaction for all particles of type A
system.reactions.add("mydecay: A ->", rate=1.)
# register a fission reaction for all particles of type A
system.reactions.add("myfission: A -> A +(1) A", rate=3.)

# ----- Step 2: Create simulation instance out of configured system

simulation = system.simulation(kernel="CPU")

# the number of particles is observed every fifth timestep
simulation.observe.number_of_particles(stride=5)
# the observations are written into the 'out.h5' file
simulation.output_file = "out.h5"
# this adds a particle of type 'A' positioned at the origin
simulation.add_particle("A", [0.,0.,0.])

# ------ Step 3: run the simulation
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
