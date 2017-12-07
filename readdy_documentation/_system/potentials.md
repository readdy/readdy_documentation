---
title: Potentials
sectionName: potentials
position: 2
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

# External potentials

External potentials or first-order potentials are potentials that solely depend on the absolute position of each particle, i.e., the relative positioning of particles towards one another has no influence.
They are registered with respect to a certain particle type. The potential will
then exert a force on each particle of that type individually.

## Box

{: .centered}
![](assets/box_potential.gif)

A box potential is a potential acting with a harmonic force on particles of the given type once they leave the area
spanned by the cuboid that has `origin` as its front lower left and `origin+extent` as its back upper right vertex, respectively.

Adding a box potential to the `system` amounts to:
```python
system.box_size=[3, 3, 3]
system.potentials.add_box(
    particle_type="A", force_constant=10., origin=[-1, -1, -1], extent=[2, 2, 2]
)
```
Note that the __simulation box__ and the __box potential__ are completely independent.
In the above example the simulation box is chosen larger than the full extent of the box potential. This is because
particles should never leave the simulation box if it is non-periodic. The box potential however is a soft potential,
i.e., particles may penetrate the boundaries of it for a short time and then be pushed back inside. To make sure that
particles do not penetrate the simulation box, it has a slightly larger extent.

In particular there is a check upon simulation start that if the simulation box is not completely periodic, there must be a box potential for each particle type to keep it contained in the non-periodic directions, i.e., if there is no box potential such that
```
box_lower_left[dim] < potential_lower_left[dim] 
  and box_upper_right[dim] > potential_upper_right[dim]
```
where `dim` is a non-periodic direction, an error is raised.


## Spherical potential

{: .centered}
![](assets/sphere_potential.gif)

A potential that forms a concentric barrier at a certain radius around a given origin. It is given a height
(in terms of energy) and a width. Note that the height can also be negative, then this potential acts as
a 'sticky' sphere. The potential consists of harmonic snippets, such that the energy landscape is continuous
and differentiable, the force is only continuous and not differentiable.

### Spherical exclusion (`sphere_out`)

Adds a spherical potential that keeps particles of a certain type excluded from the inside of the specified sphere. Adding such a potential to a reaction diffusion system amounts to
```python
system.box_size = [3, 3, 3])
system.potentials.add_sphere_out(
    particle_type="A", force_constant=10., origin=[0, 0, 0], radius=1.
)
```
yielding a spherical region of radius `1` in the center of the simulation box which keeps particles of type `A` from entering that region with a harmonic repulsion potential.

### Spherical inclusion (`sphere_in`)

Adds a spherical potential that keeps particles of a certain type restrained to the inside of the specified sphere.

### Spherical barrier (`spherical_barrier`)

A potential that forms a concentric barrier at a certain radius around a given origin. It is given a height (in terms of energy) and a width. Note that the height can also be negative, then this potential acts as a  'sticky' sphere. The potential consists of harmonic snippets, such that the energy landscape is continuous and differentiable, the force is only continuous and not differentiable.

# Pair potentials

## Harmonic repulsion

Description of harmonic repulsion

## Weak interaction piecewise harmonic

todo

## Lennard-Jones

Description of Lennard-Jones potential

## Screened electrostatics

