---
title: Potentials
sectionName: potentials
position: 2
---

Potentials create an energy landscape in which particles diffuse in, subject to the corresponding forces.
They can be used to build traps, obstacles or compartments for particles.
Or for clustering and crowding effects that are typically observed in biological fluid-like media.

Potentials in ReaDDy are divided into first-order potentials/__external potentials__,
i.e. those that depend only on the position of one particle, and
second-order potentials/__pair potentials__, i.e. those that depend on the relative 
position of two particles. 
The [topology]({{site.baseurl}}/topologies.html) functionality also provides higher order potentials like angles and dihedrals.

All potentials are added to the potential registry, which is part of the `ReactionDiffusionSystem`
```python
system = readdy.ReactionDiffusionSystem()
system.potentials.add(...)
```

# External potentials

External potentials or first-order potentials only depend on the position of a single particle.
They are registered with respect to one particle type. The potential will
then exert a force on each particle (with the given type) individually for its particular position.

## Box

{: .centered}
![](assets/box_potential.gif)

A box potential acting with a harmonic force on particles of the given type once they leave the area
spanned by the cuboid that has `origin` as its front lower left and `origin+extent` as its back upper right
vertex, respectively.

Add a box potential to the `system`, centered with respect to the simulation box:
```python
system.box_size = [3, 3, 3] # sets the size of the simulation box
system.potentials.add_box(
    particle_type="A", force_constant=10., origin=[-1, -1, -1], extent=[2, 2, 2]
) # sets the size and parameters of the box potential
```
Note that the __simulation box__ and the __box potential__ are completely independent.
In the above example the simulation box is chosen larger than the full extent of the box potential. This is because
particles should never leave the simulation box, if it is non-periodic. The box potential however is a soft potential,
i.e. particles may penetrate the boundaries of it for a short time and then be pushed back inside. To make sure that
particles do not penetrate the simulation box, it has a slightly larger extent.

## Sphere

{: .centered}
![](assets/sphere_potential.gif)


## Spherical barrier

A potential that forms a concentric barrier at a certain radius around a given origin. It is given a height
(in terms of energy) and a width. Note that the height can also be negative, then this potential acts as
a 'sticky' sphere. The potential consists of harmonic snippets, such that the energy landscape is continuous
and differentiable, the force is only continuous and not differentiable.

# Pair potentials

## Harmonic repulsion

Description of harmonic repulsion

## Lennard-Jones

Description of Lennard-Jones potential
