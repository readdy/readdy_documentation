---
title: Get started
sectionName: get_started
position: 2
---

```python
import readdy

# ----- Step 1: Set up reaction diffusion system

system = readdy.ReactionDiffusionSystem(box_size=(10, 10, 10))

system.add_species("A", diffusion_constant=2.0)
system.reactions.add("mydecay: A ->", rate=1.)
system.reactions.add("myfission: A -> A +(1) A", rate=3.)

# ----- Step 2: Create simulation instance out of configured system

simulation = system.simulation(kernel="CPU")

simulation.observe.number_of_particles(stride=5)
simulation.output_file = "out.h5"
simulation.add_particle("A", [0.,0.,0.])

# ------ Step 3: run the simulation

simulation.run(100, 0.01)
```
{% if false %}
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
{% endif %}

The above snippet performs a ReaDDy simulation, which consists of three steps:
1. [Configure the system]({{site.baseurl}}/1_system_conf.html)
2. [Setup the simulation]({{site.baseurl}}/2_simulation_setup.html)
3. [Run and analyze results]({{site.baseurl}}/3_run_and_results.html)

See [this ipython notebook]({{site.baseurl}}/demonstration/api) for an example of the basic features
