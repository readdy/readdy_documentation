---
title: Observables
sectionName: observables
position: 2
---

The currently available observables are:
* TOC
{:toc}

There are three things that all observables have in common: The evaluation can be strided, they can have a `callback` 
function and they can be saved to the `simulation.output_file`.

The `callback` is usually a function that takes one argument being the current value of the observable. During the 
course of the simulation this callback function will be evaluated whenever the particular observable is evaluated.

Per default, whenever an `output_file` is given, the registered observables' outputs are saved to that file. Each
observable has a certain place in the group hierarchy of the HDF5 file, however this place can be modified so that, 
e.g., multiple observables of the same type can be recorded into the same file.
To this end, the `save` argument of the respective observable can be modified. By providing
- `None` or `False` writing the results to file can be switched off,
- providing a dictionary with keys `'name'` and `'chunk_size'` can modify the name under which the observable data is stored
  in the group hierarchy and the [hdf5 chunk size](https://support.hdfgroup.org/HDF5/doc/Advanced/Chunking/Chunking_Tutorial_EOS13_2009.pdf).
  The `chunk_size` is always to be considered into the "temporal direction", i.e., if an observable yields data in the form of
  `3x3` matrices each time it is evaluated, a chunk would be of shape `(3, 3, chunk_size)`.

## Radial distribution function

The radial distribution function for certain particle types can be observed by
```python
def rdf_callback(current_value):
    print(current_value)

simulation.observe.rdf(
    stride=1, 
    bin_borders=np.linspace(0., 2., 10), 
    types_count_from=["A"], 
    types_count_to=["B"], 
    particle_to_density=1./system.box_volume,
    callback=rdf_callback)
``` 
which causes the observable to be evaluated in each time step (`stride=1`) and print the value (`callback=rdf_callback`).
The RDF is determined by calculating evaluating the distance from all particles of a type contained in `types_count_from` to
all particles of a type contained in `types_count_to` and then binning the distance into a histogram as given by `bin_borders`.
The histogram is normalized with respect to $g(r) = 4\pi r^2\rho dr$, where $\rho$ is the number density of particles 
with types contained in `types_count_to`, reflected by `particle_to_density`. 

## Particles

This observable records all particles in the system, as in: Each particle's type, (unique) id, and position.
It can be registered by
```python
def particles_callback(particles):
    types, ids, positions = particles
    print("Particle 5 has type {}, id {}, and position {}."
          .format(types[5], ids[5], positions[5])

simulation.observe.particles(
    stride=5,
    callback=particles_callback,
    save=False
)
```
where the argument of the callback function is a 3-tuple containing a list of types, unique ids, and positions
corresponding to each particle in the system. In this example the callback function prints these properties of the
fifth particle every fifth time step, the output of the observable is not saved into the trajectory file (`save=False`).

## Particle positions

The particles' positions can be recorded by
```python
simulation.observe.particle_positions(
    stride=200, 
    types=None, 
    callback=lambda x: print(x)
)
```
which makes this observable very similar to the `particles` one, however one can select specific types of particles
that are recorded. In case of `types=None`, all particle positions will be recorded, in case of `types=["A", "B"]`
only positions of particles with type `A` or `B` are returned.
In this case the callback will simply print `x` every 200 steps, where `x` is a list of three-dimensional vectors.
Since `save` is not explicitly set to `False` or `None` the observed data will be recorded into the trajectory file
if n `simulation.output_file` was configured.

## Number of particles

When one is only interested in the sheer number of particles then one can use this observable. Depending on the input,
it will either observe the total number of particles or the number of particles per selected type:
```python
simulation.observe.number_of_particles(
    stride=1,
    types=["A", "B", "C"],
    callback=lambda x: print(x),
    save=False
)
```
This example records the numbers of particles with types `A`, `B`, `C` in each time step. The callback takes
a list with three elements as argument where each element corresponds to a particle type as given in `types` and 
contains the respective counts. If `types=None` was given, the observable would record the total number of particles,
regardless of their types.

## Energy

The system's current potential energy can be observed by
```python
simulation.observe.energy(
    stride=123,
    callback=lambda x: print("Potential energy is {}".format(x)),
    save=False
)
```
where `stride=123` indicates that the observable will be evaluated every 123rd time step. The argument of the callback
function is a scalar value and the observable's output is not saved to a potentially configured trajectory file. 

## Forces

The forces acting on particles can be observed by
```python
simulation.observe.forces(
    stride=1,
    types=["A"],
    callback=lambda x: print(sum(x))
)
```
yielding an observable that is evaluated every time step (`stride=1`) and collects the forces acting on all particles
of type `A`. If `types=None`, all types are considered. The callback function takes a list of vectors as argument.
Since `save` is not further specified, this observable would be recorded into the trajectory file.

## Reactions

This observable records all occurred reactions in the system for a particular time step. It can be registered by invoking
```python

def reactions_callback(reactions):
    for r in reactions:
        print("{} reaction {} occurred: {} -> {}, position {}"
              .format(r.type, r.reaction_label, r.educts, r.products, r.position))
    print("----")

simulation.observe.reactions(
    stride=5,
    callback=reactions_callback
)   
```
where `stride=5` indicates that the observable is evaluated every fifth time step. The callback takes a list of
reaction records as argument, where each reaction record stores information about the
- type of reaction (`r.type`), i.e., one of conversion, fission, fusion, enzymatic, decay,
- reaction name (`r.reaction_label`), i.e., the name under which the reaction was registered in the `system`,
- educt unique particle ids (`r.educts`) as in the [particles observable]({{site.baseurl}}/simulation.html#particles),
- product unique particle ids (`r.products`),
- and position (`r.position`) of the reaction event which is evaluated to the midpoint between educts in case of a bimolecular reaction.

Since the `save` argument was left out, it is defaulted and given a `simulation.output_file`, the observed reactions are 
recorded.

## Reaction counts

Instead of recording [all reaction events]({{site.baseurl}}/simulation.html#reactions) one can also record the number 
of occurred reactions per registered reaction per time step. This can be achieved by
```python
simulation.observe.reaction_counts(
    stride=2,
    callback=lambda x: print(x),
    save=False
)
```
where `stride=2` causes the observable to be evaluated every second time step. The callback function takes
a dictionary as argument where the keys are the reaction names as given in the 
[system configuration]({{site.baseurl}}/system.html#reactions) and the values
are the occurrences of the corresponding reaction in that time step.

## Virial

## Pressure
