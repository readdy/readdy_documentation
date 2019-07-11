---
title: Configuration
sectionName: simulation_configuration
position: 1
---

In the following it will be explained how to [add particles](#adding-particles), [add topologies](#adding-topologies),
[configure](#kernel-configuration) specifics of the selected kernel, how to [record a trajectory](#recording-a-trajectory), and how to perform [checkpointing](#checkpointing).

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

A topology can be added by invoking
```python
my_topology = simulation.add_topology(topology_type="My topology type", particle_types="T", 
                                      positions=np.random.random((100, 3)))
```
which requires a "My topology type" topology type and a topology species "T" 
[to be registered]({{site.baseurl}}/system.html#topologies) in the `ReactionDiffusionSystem`. In this example the 
topology will contain 100 randomly placed topology particles of type "T" that are for now disconnected.
If the topology should contain several different particle types one can pass a list of particle types to the `particle_types` argument
that contains types for all the positions:
```python
my_topology = simulation.add_topology(
    topology_type="My topology type",
    particle_types=["T1", "T2", "T3", "T2", "T1"],
    positions=np.random.random((5, 3))
)
```

Unless the topology consists out of only one particle, one still needs to set up the connectivity graph before running 
the simulation. The returned object `my_topology` is a topology object as the ones described in 
[topology reactions]({{site.baseurl}}/system.html#the-reaction-function). Edges in the graph can be introduced like
```python
my_graph = my_topology.get_graph()
for i in range(len(graph.get_vertices())-1):
    my_graph.add_edge(i, i+1)
```
where the indices that go into `add_edge` correspond to the particle positions that were entered in `add_topology`.

The simulation can only be executed if the graph of each topology is connected,
- i.e., there are no independent
  components (between each pair of vertices there is at least one path in the graph that connects them), 

and for each edge there is a bond,
- i.e., all particle type pairs that are contained in the graph have at least one entry in the 
  [topology potential configuration]({{site.baseurl}}/system.html#topology_potentials).
  
Should one of these two conditions be not fulfilled, starting the simulation will raise an error.

## Kernel configuration

In case of selecting the CPU kernel with a parallelized implementation of the ReaDDy model, one can change certain
aspects of its behavior:

- The number of threads to be used can be selected by
  ```python
  simulation.kernel_configuration.n_threads = 4
  ```
- Mainly due to pairwise interactions and bimolecular reactions there is a neighbor list to reduce the time needed for 
  evaluating these. The neighbor list imposes a spatial discretization on the simulation box into cuboids. In the
  default case, each of these cuboids has an edge length of at least the maximal cutoff radius / reaction radius.
  This means that instead of naively looping over all particle pairs ($\mathcal{O}(N^2)$), one can assign each particle
  to its cuboid and then loop over all particles in a cuboid and its 26 neighboring cuboids to find particle pairs.
  
  When collecting particle pairs in this fashion one effectively approximates a sphere with cuboids. The number of
  potential interaction or reaction partners can be further reduced by using only a fraction of the edge length but
  increasing the search radius of the neighboring boxes so that one still covers at least the cutoff radius in each
  spatial dimension.
  
  Reducing the edge length usually comes with a price, at some point the bookkeeping of neighboring boxes dominates
  the runtime.
  
  The edge length and therefore search radius can be controlled by
  ```python
  simulation.kernel_configuration.cell_linked_list_radius = 4
  ```
  which would yield cuboids with $\frac{1}{4}$ the edge lengths of the default case.

## Recording a trajectory

ReaDDy records trajectories and observable data in HDF5 files. For doing so one needs to set an output file
```python
simulation.output_file = "my_trajectory.h5"
```
and instruct the simulation to record a trajectory:
```python
simulation.record_trajectory(stride=1, name="", chunk_size=1000)
```
The `stride` arguments causes the trajectory to be recorded every `stride` time steps. If a `name` (other than
the default one) is given, the trajectory data will be stored in a different data set. The `chunk_size` is mainly
a performance parameter that has an effect on how large every chunk of data in the binary file is going to be,
influencing the time needed for IO during the simulation and the resulting file size.

For reading back the trajectory data, please refer to [post-processing]({{site.baseurl}}/results.html).

## Checkpointing

Checkpoints in ReaDDy consist out of the particles' and topologies' configurations at specific points in simulation time. They can be enabled by calling
```python
simulation.make_checkpoints(stride=1000, output_directory="checkpoints/", max_n_saves=10)
```
which causes checkpoints to be made every 1000 steps. Each checkpoint is a separate file and all checkpoint files will be
saved to the directory specified by `output_directory`. The option `max_n_saves` decides how many checkpoint files
are allowed to be saved to the directory, e.g. if `max_n_saves=10` then only the last 10 _most recent_ checkpoints
are kept.

Once the simulation has run its course and checkpoint files have been written, they can be listed by
```python
simulation.list_checkpoint_files('checkpoints/')
```
A particular checkpoint file can in principle also contain multiple checkpoints. They can be inspected by
```python
simulation.list_checkpoints('checkpoints/checkpoint_10000.h5')
```
and a system's state can be restored by a call to
```python
simulation.load_particles_from_checkpoint('checkpoints/checkpoint_10000.h5')
```
amounting to restoring the latest checkpoint of that particular file. If the file contains multiple checkpoints, let's say 5, you can
select the 5th checkpoint by supplying the optional argument `n=4` (enumeration starts at `n=0` per file).

Oftentimes you just need the last checkpoint of all checkpoint files in a certain directory. This can be achieved by
```python
simulation.load_particles_from_latest_checkpoint('checkpoints/')
``` 

It should be noted that if the simulation should be continued and the `output_directory` for the new checkpoints is the 
same as of the original simulation, the old checkpoint files will be overwritten. If you want to keep the checkpoints
of the original simulation, specify another `output_directory`.
