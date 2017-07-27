---
title: Thursday - Lotka-Volterra
sectionName: thursday
position: 4
---

{: .centered}
[![](assets/wave.jpg)](https://www.youtube.com/watch?v=Kc2rN16f6xI)

Consider a Lotka-Volterra system with two particle types, predator (B) and prey (A). All particles will live on a 2D surface, as in the previous sessions. The surface's extent should be roughly 45.

### Task 1) well-mixed

Use the following parameters for the particle types as starting values: You can also change them and see if you get different behavior.

| species | diffusion | radius |
|:--------|:----------|:-------|
| B       | 1.3       | 1.0    |
| A       | 1.3       | 1.0    |

We will need three reactions for the Lotka-Volterra system to work. You can also play around with the rates here

$$ A \rightarrow A + A \quad \text{(birth)} $$

$$ A + B \rightarrow B + B \quad \text{(eat)} $$

$$ B \rightarrow \emptyset \quad \text{(decay)} $$

```python
sim.register_reaction_fission("birth", "A", "A", "A", rate=3e-2, product_distance=2.*particle_radius)
sim.register_reaction_enzymatic("eat", "B", "A", "B", rate=2e-2, educt_distance=2.*particle_radius)
sim.register_reaction_decay("decay", "B", rate=3e-2)
```

Place 100 particles of each type uniformly on the surface and simulate. While doing so, record the number of particles, as a function of time.
```python
# define observables and run
traj_handle = sim.register_observable_flat_trajectory(stride=100)

numbers_data = []
def append_numbers(x):
    global numbers_data
    numbers_data.append(x)
    print("A", x[0], "B", x[1])

sim.register_observable_n_particles(stride=1000, types=["A", "B"], callback=append_numbers)

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

- Have a look at the trajectory using vmd.
- Plot the time series of the number of particles for A and B in the same plot. What do you observe? How long is the oscillation time?
- Plot the numbers of A particles vs. the numbers of B particles, i.e. a phase-space plot.

### Task 2) diffusion-limited

Choose a box size of your liking and set up a similar Lotka-Volterra system as before, but this time more diffusion-limited. That means lower diffusion coefficients and faster reaction rates. Use values similar to

| parameter   | value |
|:------------|:------|
| diffusion A | 0.05  |
| diffusion B | 0.02  |
| birth rate  | 0.38  |
| eat rate    | 0.03  |
| decay rate  | 0.05  |
| timestep    | 0.02  |

feel free to adjust them.

The goal of this task is to create spatial patterns as described in [this paper](http://dx.doi.org/10.1063/1.4729141).

You can also try to perform these simulations in a 3D box or within a sphere, but start with a small volume.
