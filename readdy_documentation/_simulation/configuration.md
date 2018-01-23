---
title: Configuration
sectionName: simulation_configuration
position: 1
---

In the following it will be explained how to [add particles](#adding-particles), [add topologies](#adding-topologies),
[configure](#kernel-configuration) specifics of the selected kernel, and how to [record a trajectory](#recording-a-trajectory).

## Adding particles

For adding particles to a system there are two separate methods. One is can be to place a single particle, one
is for bulk insertion.
Adding a single particle of type `A` to a simulation box amounts to
```python
simulation.add_particle(type="A", position=pos)
```
where `pos` can be a list `[x, y, z]`, tuple `(x, y, z)`, or a `numpy.ndarray: np.array([x, y, z])` with three entries
representing the x,y,z components.

When one wants several particles of a certain type to the simulation, one can can exchange multiple calls to
`simulation.add_particle` by the better performing variant
```python
X = np.random.random((100, 3))
simulation.add_particles(type="A", positions=X)
```
taking a `(N, 3)`-shaped numpy array as position argument, resulting in `N` particles with their respective positions
being added to the simulation. In this example, 100 particles of type `A` would be placed uniformly at random
in $[0,1)^3$.

## Adding topologies

## Kernel configuration

## Recording a trajectory
