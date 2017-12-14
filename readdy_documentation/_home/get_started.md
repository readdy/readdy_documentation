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

The above snippet performs a ReaDDy simulation, which consists of three steps:
1. [Configure the system]({{site.baseurl}}/system.html)
2. [Setup and run the simulation]({{site.baseurl}}/simulation.html)
3. [Analyze results]({{site.baseurl}}/results.html)

See [this ipython notebook]({{site.baseurl}}/demonstration/api) for an example of the basic features
