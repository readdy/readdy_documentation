---
title: Monday - Setup & get started
sectionName: monday
position: 1
---

### Task 0)

We go through the installation and the basic features of readdy step by step.

### Task 1)

Register a piecewise harmonic potential for A particles that live
on a 2D membrane
```python
sim.periodic_boundary = [True, True, True]
sim.kbt = 1.
sim.box_size = api.Vec(30., 30., 20.)

# register particle type
particle_radius = 0.5
sim.register_particle_type("A", 0.2, particle_radius)

# the potential that confines particles
origin = np.array([-16.,-16.,-0.001])
extent = np.array([32.,32.,0.002])
sim.register_potential_box("A", 200., api.Vec(*origin), api.Vec(*extent), False)

# the pairwise interaction
sim.register_potential_piecewise_weak_interaction(
    "A", "A", force_constant=20., desired_particle_distance=2.*particle_radius,
    depth=0.93, no_interaction_distance=4.*particle_radius
)

# add particles
rnd = np.random.uniform
for i in range(100):
    pos = np.array([-10., -10., 0.]) + rnd(size=3) * np.array([20.,20.,0.])
    sim.add_particle("A", api.Vec(*pos))

```

Perform a simulation and observe the radial distribution

```python
# define observables and run
traj_handle = sim.register_observable_flat_trajectory(stride=10)

rdf_data = []
def get_rdf(x):
    global rdf_data
    rdf_data.append(x)

rdf_handle = sim.register_observable_radial_distribution(
    stride=100, bin_borders=np.arange(0.,7.,0.05), type_count_from=["A"],
    type_count_to=["A"], particle_to_density=1., callback=get_rdf
)
with cl.closing(api.File("./obs.h5", api.FileAction.CREATE, api.FileFlag.OVERWRITE)) as f:
    traj_handle.enable_write_to_file(file=f, data_set_name="traj", chunk_size=10000)
    t1 = time.perf_counter()
    sim.run_scheme_readdy(True) \
        .write_config_to_file(f) \
        .with_reaction_scheduler("UncontrolledApproximation") \
        .with_skin_size(3.) \
        .configure_and_run(50000, 0.005)
    t2 = time.perf_counter()
    print("Simulated", t2 - t1, "seconds")
```

Obtain the __mean__ radial distribution function
```python
rdfs = np.array([x[1] for x in rdf_data])
bins = np.array(rdf_data[0][0])
n_rdfs = len(rdfs)
mean_rdfs = np.sum(rdfs, axis=0) / n_rdfs
```

From the radial distribution, estimate how the pair-potential looks like, assuming

$$ g(r) \propto e^{-U(r)}$$

What could be a source of error? Did you really find the true potential or rather an effective potential?
