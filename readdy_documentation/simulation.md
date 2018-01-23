---
layout: page
title: Simulation
---

The `system` object can generate one or multiple `simulation` objects, which determine _how_ to simulate the `system`.
This includes among other things the diffusion integrator, the reaction handler, [observables]({{site.baseurl}}/observables.html).
The initial positions of particles are also set on the `simulation` object.

Given a `system` one can generate a `simulation` by invoking
```python
simulation = system.simulation()
```
The function takes a number of arguments that influence the way the simulation is executed:
```python
simulation = system.simulation(
    kernel="SingleCPU",
    output_file="",
    integrator="EulerBDIntegrator",
    reaction_handler="Gillespie",
    evaluate_topology_reactions=True,
    evaluate_forces=True,
    evaluate_observables=True,
    skin=0
)
```
Except for the `kernel` argument, all of these arguments can also be modified by setting properties on the
simulation object. The configuration of the reaction diffusion `system` is copied into the simulation object,
so subsequent changes to the reaction diffusion system will not propagate into the simulation.

## Selecting a kernel
Currently there are two different kernels that are supported: the `SingleCPU` and the `CPU` kernel. As the name
suggests, the `SingleCPU` kernel is single-threaded whereas the `CPU` kernel attempts to parallelize as much as
possible, thus making use of more cores.

It can be expected that the `SingleCPU` implementation is roughly as fast as the `CPU` implementation with two threads,
as it applies Newton's third law for calculating pairwise forces and evaluates reactions per particle pair, which are
the two major performance bottlenecks.

{% assign sections = site.simulation | sort: 'position' %}
{% for section in sections %}
<section id="{{ section.sectionName }}">
<h1>{{ section.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ section.content | markdownify }}
</section>
{% endfor %}
