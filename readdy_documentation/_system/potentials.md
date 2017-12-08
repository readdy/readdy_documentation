---
title: Potentials
sectionName: potentials
position: 2
subsection: false
---

Potentials create an energy landscape in which particles diffuse in, subject to the corresponding forces.
They can be used to build traps, obstacles or compartments for particles.
One could also utilize them for clustering and crowding effects that are typically observed in biological fluid-like media.

Potentials in ReaDDy are divided into first-order potentials/__external potentials__, i.e., those that depend only on the position of one particle, and
second-order potentials/__pair potentials__, i.e., those that depend on the relative position of two particles.
The [topology]({{site.baseurl}}/topologies.html) functionality also provides higher order potentials like angles and dihedrals.

All potentials are part of the `ReactionDiffusionSystem` and can be registered for certain particle types like
```python
system = readdy.ReactionDiffusionSystem()
system.potentials.add(...)
```