---
layout: homepage
title: ReaDDy
---

Welcome to the website of ReaDDy - a particle-based reaction-diffusion simulator, written in C++ with python bindings. 
ReaDDy is an open-source project, developed and maintained by Moritz Hoffmann, Christoph Fröhner and Frank Noé 
of the Computational Molecular Biology group at the Freie Universität Berlin.

We are making final changes before a first proper release in the very near future. 

This project continues the [java software](https://github.com/readdy/readdy_java) of the same name, by Johannes Schöneberg and Frank Noé.[^1]

[Contact us](mailto:readdyadmin@lists.fu-berlin.de) if you want to use ReaDDy now or in some future project.

[^1]: J. Schöneberg and F. Noé, “ReaDDy--a software for particle-based reaction-diffusion dynamics in crowded cellular environments.”, PLoS One, vol. 8, no. 9, p. e74261, 2013.

## Get started

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