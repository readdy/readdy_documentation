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

## Reactions

## Particle positions

## Particles

## Number of particles

## Energy

## Forces

## Reaction counts

## Virial

## Pressure
