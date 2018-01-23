---
layout: page
title: System configuration
---

At first create a `ReactionDiffusionSystem`, which determines _what_ to simulate.
This includes setting a unit system, the size and periodicity of
the simulation-box, particle species, [reactions]({{site.baseurl}}/reactions.html),
[potentials]({{site.baseurl}}/potentials.html) and [topologies]({{site.baseurl}}/topologies.html).
These are set via properties and methods of the `system` object.


## Physical units
The for ReaDDy relevant units are units of length, time, and energy. An instance of a `ReactionDiffusionSystem` is equipped with a particular set of these units, internally expressing everything in terms of that set. Per default it is given by
- length in nanometers,
- time in nanoseconds,
- energy in kilojoule per mol.

Should a different set of units be desired, it can be provided as constructor argument, e.g.,
```python
custom_units = {'length_unit':'kilometer',
                'time_unit': 'hour',
                'energy_unit': 'kilocal/mol'}
system = readdy.ReactionDiffusionSystem([10, 10, 10] * readdy.units.meters,
                                        unit_system=custom_units)
print(system.box_size)
>>> [ 0.01  0.01  0.01] kilometer
print(system.kbt)
>>> 0.5824569789674953 kilocalorie / mole
```
When setting the `unit_system` constructor argument to `None`, one sets up a unitless system. In such a case the thermal energy will be defaulted to `kbt=1` and one cannot set a temperature anymore but has to set `kbt` directly.
```python
system = readdy.ReactionDiffusionSystem(box_size=(10, 10, 10), unit_system=None)
print(system.kbt)
>>> 1.0
system.kbt = 42.
print(system.kbt)
>>> 42.0
print(system.temperature)
>>> ValueError: No temperature unit was set. In a unitless system, refer to kbt instead.
```

Internally, ReaDDy uses [pint](https://pint.readthedocs.io/) for handling units, so in principle all unit arithmetics that are supported by pint can also be applied when setting up a ReaDDy simulation.

## The box size
The system's only required argument is the simulation box size. The box itself is centered around the origin, so given a `ReactionDiffusionSystem(box_size=(a,b,c))`, it can be described by $$ [-\frac{a}{2}, \frac{a}{2} )\times [-\frac{b}{2}, \frac{b}{2} ) \times [-\frac{c}{2}, \frac{c}{2} ) \subset \mathbb{R}^3$$.

## Periodic boundary conditions
The boundaries of the box can be either (partially) non-periodic or fully periodic. The degree of periodicity is set by either the `periodic_boundary_conditions` named constructor argument or property. A box that is periodic in y and z directions but not in x direction amounts to setting
```python
readdy.ReactionDiffusionSystem([1,1,1], periodic_boundary_conditions=[False, True, True])
# or
system = readdy.ReactionDiffusionSystem([1,1,1])
system.periodic_boundary_conditions = [False, True, True]
```
If the box is not periodic in one or more directions, the particles have to be provided with a potential that keeps them inside the simulation box, see the section about [potentials]({{site.baseurl}}/potentials.html) for details.

## Temperature
If not specified otherwise, the temperature will default to $$293\,\text{K}$$. A different temperature can be either provided by the `temperature` named argument in the constructor or the `temperature` property. This behavior changes if one works in a unitless setup, see below.

## Particle species
In order to add particle instances to the simulation, one first has to define the available species. This can be done by the `add_species` method of the system object.
The method takes as argument the species' name and a diffusion constant $$D$$ in units of $$\text{length}^2\text{time}^{-1}$$. The diffusion constant effects the magnitude of the random displacement in the governing dynamics, which are described by an overdamped Langevin equation

$$
\frac{d\mathbf{x}(t)}{dt} = -D\frac{\nabla V(\mathbf{x}(t))}{k_BT} + \xi(t),
$$

where $$k_B$$ is the Boltzmann constant, $$T$$ the temperature, $$V$$ the potential,  $$\mathbf{x}(t)\in\mathbb{R}^3$$ a vector corresponding to the instantaneous position of a particle at time $$t$$, and $$\xi(t)$$ is a random velocity with

$$
\langle \xi(t) \rangle = 0, \quad \langle \xi(t)\xi(t') \rangle = 2D\delta(t-t').
$$

This means that $$\xi$$ is a time-uncorrelated random variable that contains values according to a normal distribution in each of its components.

If one would want to register two species "A" and "B" with respective diffusion constants $$ 1\,\text{nm}^2\,\text{s}^{-1}$$ and $$2\,\text{km}^2\,\text{hour}^{-1}$$, the configuration, given the default unit set, would read
```python
system.add_species("A", diffusion_constant=1.)
system.add_species("B", diffusion_constant=2. * readdy.units.km**2 / readdy.units.hour)
```
where the latter diffusion constant is internally expressed in terms of the default units.

In case of particle types that take part in complexes (topologies), the `add_topology_species` method needs to be invoked, see the section about [topologies](#topologies) for details.

{% assign sections = site.system| sort: 'position' %}
{% for section in sections %}
<section id="{{ section.sectionName }}">
<h1>{{ section.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ section.content | markdownify }}
</section>
{% endfor %}
