---
layout: page
title: Post-processing
---

Once the system is simulated, the trajectory and stored observables can be analyzed. For this purpose a trajectory
object can be created by providing a path to the output file of a simulation:

```python
trajectory = readdy.Trajectory('out.h5')
```

# Visual representation of the trajectory

To look at the time-series of the position of particles, one can use [VMD](http://www.ks.uiuc.edu/Research/vmd/).
To this end there is a function to convert the hdf5 trajectory into a VMD-readable `xyz` file. 
```python
trajectory.convert_to_xyz(particle_radii={'A': 1.})
```

In shell you can then call `vmd` as follows
```bash
vmd -e out.xyz.tcl
```

The `particle_radii` are all defaulted to `1.` unless otherwise specified.

# Information about the simulated system

The trajectory file stores some information about the system that was simulated. Given a trajectory object, one can obtain
```python
# the thermal energy
trajectory.kbt
# the volume of the simulation box
trajectory.box_volume
# the dimensions of the simulation box
trajectory.box_size
# whether periodic boundary conditions were used
trajectory.periodic_boundary_conditions
# diffusion constants for registered particle types
trajectory.diffusion_constants
# a mapping from particle type name -> internal particle type id
trajectory.particle_types
# registered reactions
trajectory.reactions
```

# Reading observable data

All observables including the actual trajectory have functions to read back the recorded data.

The actual trajectory can be read back as a list of lists by invoking
```python
for frame in trajectory.read():
  for particle in frame:
    print("Particle with id {} of type {} at position {}" 
          .format(particle.id, particle.type, particle.position))
```

Except for the trajectory all observables can be stored at a different place in the file by providing a `save` argument 
when [registering them]({{site.baseurl}}/simulation.html#observables). For such a case each method of the trajectory 
object that can obtain observable data has an additional argument `data_set_name` that needs to be set accordingly.
If the default `save` argument was used or it was not specified, one can omit the `data_set_name`.

Since one can configure observables with different strides an array with simulation times is always returned, i.e.,
if an observable was configured with a stride of 5, it would contain `[0, 5, 10, ...]`. 

- The [radial distribution function]({{site.baseurl}}/simulation.html#radial-distribution-function) data can be read back by
  ```python
  time, bin_centers, distribution = trajectory.read_observable_rdf()
  ```
  where `time` is a list of simulation times, `bin_centers` are the bin centers and `distribution` contains the RDF
  in shape of a `(T, N)` array (T being the number of recordings and N being the number of bins).
- The [particles]({{site.baseurl}}/simulation.html#particles) data can be obtained by
  ```python
  time, types, ids, positions = trajectory.read_observable_particles()
  ```
  where `time` is a list of simulation times, `types` is a list of particle type ids that can be converted to their respective
  names by calling `trajectory.species_name(a_particular_id)`, `ids` is a list of lists containing the unique ids of each particle, and 
  `positions` is a list of lists containing particle positions.
- The [particle positions]({{site.baseurl}}/simulation.html#particle-positions) data can be obtained by
  ```python
  time, positions = trajectory.read_observable_particle_positions()
  ```
  where `time` is a list of simulation times and `positions` is a list of `(N_t, 3)`-shaped arrays, where `N_t` is the number of
  particles in particular time step.
- The [number of particles]({{site.baseurl}}/simulation.html#number-of-particles) data can be obtained by
  ```python
  time, counts = trajectory.read_observable_number_of_particles()
  ```
  where `time` is a list of simulation times and `counts` is an array containing the recorded number of particles per 
  requested type.
- The [energy]({{site.baseurl}}/simulation.html#energy) observable data can be obtained by
  ```python
  time, energy = trajectory.read_observable_energy()
  ```
  where `time` is a list of simulation times and `energy` is a list of potential energy values.
- The [forces]({{site.baseurl}}/simulation.html#forces) observable data can be obtained by
  ```python
  time, forces = trajectory.read_observable_forces()
  ```
  where `time` is a list of simulation times and `forces` is a list of arrays containing the forces acting on each
  particle for each evaluated time step.
- The [reactions]({{site.baseurl}}/simulation.html#reactions) observable data can be obtained by
  ```python
  time, reactions = trajectory.read_observable_reactions()
  ```
  where `time` is a list of simulation times and `reactions` is a list of lists containing the occurred reaction events
  for each evaluated time step. The reaction event data can be accessed just like in the callback function of the observable.
- The [reaction counts]({{site.baseurl}}/simulation.html#reaction-counts) observable data can be obtained by
  ```python
  time, counts = trajectory.read_observable_reaction_counts()
  ``` 
  where `time` is a list of simulation times and `counts` is a dictionary with the reaction names as keys and the corresponding counts
  as values, i.e.,
  ```python
  counts['my_reaction']
  ```
  is an array of length `N` where `N` is the number of evaluations of the observable with the number of occurrences of `my_reaction`.
- The [virial]({{site.baseurl}}/simulation.html#virial) observable data can be obtained by
  ```python
  time, virials = trajectory.read_observable_virial()
  ```
  where `time` is a list of simulation times and `virials` contains the system's pressure virial for each simulation 
  time in that it was evaluated.
- The [pressure]({{site.baseurl}}/simulation.html#pressure) observable data can be obtained by
  ```python
  time, pressure = trajectory.read_observable_pressure()
  ```
  where `time` is a list of simulation times and `pressure` contains the corresponding pressure per simulation time.