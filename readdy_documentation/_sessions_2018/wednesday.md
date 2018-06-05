---
title: Wednesday - tba
sectionName: wednesday
position: 3
---
{% if false %}

{: .centered}
![](assets/micell.jpg)

Register a particle type A and a partially
attractive potential.
```python
# register particle type
particle_radius = 0.5
sim.register_particle_type("A", diffusion_coefficient=0.2, radius=particle_radius)

# the pairwise interaction
sim.register_potential_piecewise_weak_interaction(
    "A", "A", force_constant=20.,
    desired_particle_distance=2.*particle_radius,
    depth=2.0, no_interaction_distance=4.*particle_radius
)
```

As in the sessions before, consider a flat quadratic surface,
that confines particles. The surface has an __edge length 54__
and a __force constant 200__. You can use the code of the previous sessions to generate the box potential and to distribute particles uniformly, but make sure to use the correct lengths. Set the system temperature to __kbt = 0.8__.

### Task 1)

Distribute __200 A particles__ uniformly and simulate for 200000 timesteps of stepsize 0.005. Calculate the mean-squared-displacement (MSD) as a function of time. Therefore we will use the `Particles` observable and calculate the MSD from this ourselves.

The execution of the simulation should look as follows
```python
# define observables and run
traj_handle = sim.register_observable_flat_trajectory(stride=10)

particles_data = []
def get_particles(x):
    global particles_data
    particles_data.append(x)

handle = sim.register_observable_particles(stride=100, callback=get_particles)

with cl.closing(api.File("./obs.h5", api.FileAction.CREATE, api.FileFlag.OVERWRITE)) as f:
    traj_handle.enable_write_to_file(file=f, data_set_name="traj", chunk_size=10000)
    t1 = time.perf_counter()
    sim.run_scheme_readdy(True) \
        .write_config_to_file(f) \
        .with_reaction_scheduler("UncontrolledApproximation") \
        .configure_and_run(200000, 0.005)
    t2 = time.perf_counter()
print("Simulated", t2 - t1, "seconds")
```

To calculate the MSD from `particles_data` use the following function:
```python
def get_msd(particles_data):
    # obtain positions and ids as numpy arrays
    positions = []
    ids = []
    for t in range(len(particles_data)):
        positions.append(
            np.array([[x[0], x[1], x[2]] for x in particles_data[t][2]])
        )
        ids.append(
            np.array([x for x in particles_data[t][1]])
        )
    positions = np.array(positions)
    ids = np.array(ids)

    # sort the positions with respect to ids in each timestep,
    # since they might have changed the index in the positions array
    sorted_positions = np.zeros_like(positions)
    for t in range(len(ids)):
        sort_indices = np.argsort(ids[t])
        sorted_positions[t] = positions[t][sort_indices]

    # calculate the actual msd
    difference = sorted_positions - sorted_positions[0]
    squared = difference * difference
    squared_deviation = np.sum(squared, axis=2)
    n_particles = sorted_positions.shape[1]
    mean_squared_deviation = np.sum(squared_deviation, axis=1) / n_particles
    return mean_squared_deviation
```

From the MSD, give a rough estimate of the time it takes for the particles to cluster together.
Hint: you might want to look at the MSD in a log-log plot.


### Task 2)

To actually observe micellization we need a lipid-like structure. E.g. one head-particle bound to one or multiple tail-particles. Therefore use the __topologies__ feature.
To construct a topology you need to do an additional import at the top of your notebook
```python
import readdy._internal.readdybinding.api.top as top
```

Register two particle species that we need

| species | diffusion | radius | flavor                            |
|:--------|:----------|:-------|:----------------------------------|
| head    | 0.5       | 1.0    | `api.ParticleTypeFlavor.TOPOLOGY` |
| tail    | 0.5       | 0.5    | `api.ParticleTypeFlavor.TOPOLOGY` |

Both of these types should be attached to the 2D surface as in the task before
```python
# the potential that confines particles
origin = np.array([-28.,-28.,-0.001])
extent = np.array([54.,54.,0.002])
sim.register_potential_box("head", 200., api.Vec(*origin), api.Vec(*extent), False)
sim.register_potential_box("tail", 200., api.Vec(*origin), api.Vec(*extent), False)
```

The two types `head` and `tail` shall also interact via potentials
```python
# the pairwise interactions
sim.register_potential_piecewise_weak_interaction(
    "tail", "tail", force_constant=30., desired_particle_distance=2.*particle_radius,
    depth=2.0, no_interaction_distance=4.*particle_radius
)
sim.register_potential_harmonic_repulsion("head", "head", force_constant=30.)
```

Now let's build a topology, i.e. a group of particles, bonded together.
The first step is to configure how the particles within a topology interact
```python
# topologies configuration
sim.configure_topology_bond_potential("head", "tail", force_constant=50, length=1.)
sim.configure_topology_bond_potential("tail", "tail", force_constant=50, length=1.)
```

The final step is to add the topologies and their particles to the simulation. We will add
```python
# adding the topologies
rnd = np.random.uniform
for i in range(50):
    particles = []
    pos = origin + rnd(size=3) * extent
    particles.append(sim.create_topology_particle("head", api.Vec(*pos)))
    tail_orientation = rnd(size=3)
    particles.append(sim.create_topology_particle("tail", api.Vec(*(pos + tail_orientation))))
    particles.append(sim.create_topology_particle("tail", api.Vec(*(pos + 2.*tail_orientation))))
    topology = sim.add_topology(particles)
    topology.get_graph().add_edge(0, 1)
    topology.get_graph().add_edge(1, 2)
```

Now use the simulation execution from task 1, and also the MSD calculation from task 1. Run the simulation, have a look at the VMD output. What do you observe and why?

Look at the MSD and make an estimate at which timescale the lipids cluster together.
{% endif %}