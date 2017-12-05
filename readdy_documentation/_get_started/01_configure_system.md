---
layout: page
title: 1. Configure the system
position: 1
sectionName: configure
---


At first create a `ReactionDiffusionSystem`, which determines _what_ to simulate.
This includes setting a unit system, the size and periodicity of
the simulation-box, particle species, [reactions]({{site.baseurl}}/reactions.html), 
[potentials]({{site.baseurl}}/potentials.html) and [topologies]({{site.baseurl}}/topologies.html).
These are set via properties and methods of the `system` object. 

The system's only required argument is the simulation box size. The box itself is centered around the origin, so given a `ReactionDiffusionSystem(box_size=(a,b,c))`, the actual box can be described by $$ [-\frac{a}{2}, \frac{a}{2} )\times [-\frac{b}{2}, \frac{b}{2} ) \times [-\frac{c}{2}, \frac{c}{2} ) \subset \mathbb{R}^3$$.

The boundaries of the box can be either (partially) non-periodic or fully periodic. The degree of periodicity is set by either the `periodic_boundary_conditions` named constructor argument or property. A box that is periodic in y and z directions but not in x direction amounts to setting
```python
readdy.ReactionDiffusionSystem([1,1,1], periodic_boundary_conditions=[False, True, True])
# or
system = readdy.ReactionDiffusionSystem([1,1,1])
system.periodic_boundary_conditions = [False, True, True]
```

The physical units default to
- length in nanometers,
- time in nanoseconds,
- energy in kilojoule per mol.

If not specified otherwise, the temperature will default to $$293\,\text{K}$$. A different temperature can be either provided by the `temperature` named argument in the constructor or the `temperature` property. This behavior changes if one works in a unitless setup, see below.

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
When setting the `unit_system` constructor argument to `None`, i.e., one wants to perform a simulation without units, the thermal energy will be defaulted to `kbt=1` and one cannot set a temperature anymore but has to set `kbt` directly.
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

