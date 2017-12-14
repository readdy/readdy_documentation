---
title: Topologies
sectionName: topologies
position: 5
subsection: false
---

Topologies are a way to include molecular structure in a reaction-diffusion simulation. More specifically, a topology is a group of particles with fixed potential terms like bonds and angles between certain particles. 
Topologies in ReaDDy consist of two ingredients:
- A connectivity graph between a fixed set of particles,
- a lookup table for potential terms between certain combinations of particle types.

How to set up the actual connectivity graph can be found in the section about [setting up and running the simulation]({{site.baseurl}}/simulation.html), as it requires particles being added to the simulation.

Since particles that are part of a topology are internally treated differently than "normal" particles, their species have to be configured by a call to
```python
system.add_topology_species("T", diffusion_constant=2.0)
```

Furthermore, for operations that function on the topology level, topologies also have a "topology type" which can be seen as the generalization of a "particle type". To add such a type, one can invoke
```python
system.topologies.add_type("My topology type")
```
