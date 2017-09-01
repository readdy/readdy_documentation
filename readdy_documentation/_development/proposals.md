
---
title: Proposals
sectionName: proposals
position: -1
---

### File specification

One file covers the extent of one simulation, e.g. changes in temperature (time-indepedent context)
can only span multiple simulations and thus multiple files. This means one might end up with multiple files for one realisation.
To get back a time ordering, the simulated step range should be stated in the file.
Additionally it has to be set when continuing a realisation, i.e. starting a new simulation.

```bash
file.h5
  readdy/
    time_range # might be an observable
    obs/
      labelx-msd/ # user defined labels for observables
      labely-rdf/
      labelz-traj/
    config/ # time independent information
      particle_types
      reactions
      potentials
    snapshots/
      0/
        positions
        topologies
        time_step_number
      1/
        positions
        topologies
        time_step_number
      ...
```


### Top level usage

```python
# define system here together with the units that readdy will use
system = ReactionDiffusionSystem(length_unit=units.swedish_miles)
system.kbt = 50. * units.kJ / units.mol # units will be converted when scheme is configured, run()
system.add_species("A", diffusion_const=4. * units.nm * units.nm / units.ns)
system.add_species("B", diffusion_const=5.) # default units will be used
system.add_reaction("A+{13.}B->{42.}C", radius_unit=units.nm, rate_unit=1./units.ns)
system.add_reaction("B->{3.}C")

# create simulation (define algorithms to run the system)
simulation = system.simulation(kernel="SingleCPU")  # use defaults.
simulation.observe_rdf(callback=lambda x: print(x), stride=5, bins=np.arange(0.,10.,1.)*units.nm, write_to_file=Ja,bitte)  # actually part of the system, but configured through the simulation object
simulation.output_file = "path/to/file"
simulation.integrator = "EulerBDIntegrator"
simulation.compute_forces = False
simulation.reaction_scheduler = "UncontrolledApproximation"
simulation.evaluate_observables = False
simulation.record_snapshots(stride=50, last_frame=True, output_dir="", overwrite=True)
simulation.run(10)  # does the configuration and runs the simulation, i.e. system and simulation are finalized here
# or
simulation.run_while(util.criterion.n_minutes(10))

# continue simulation
simulation.run(10)

# second call RAISES exception, because you can only simulate a system once.
simulation = system.simulation()  # use defaults.

# OR
simulation = system.simulation(integrator = "EulerBDIntegrator",
                               compute_forces = False,
...
)
simulation.run(10)
```

### General suggestions

- [ ] suggestion: Allow geometry files as input for a box potential such that more complicated shapes can be realized with external tools
- [ ] implement CUDA kernel
    - meet up with Felix to discuss HALMD integration
- [ ] implement reactions with topologies
    - come up with convenient API to create / manipulate topologies
- [ ] improve reaction scheduler to gain more performance
    - filter particles out, that do not participate in any reaction
    - upon event creation, check if event is scheduled to happen in the current time interval
    - this introduces a bias on the probabilities of the remaining events (if there are intersections), try to balance that
- [ ] improve neighbor lists to gain more performance
    - verlet lists
- [ ] snapshotting
    - implement snapshotting using the observables framework
- [x] implement IO (de-/serialization, dumping of trajectories into hdf5 files)
    - implement VMD plugin (see, e.g., lammps plugin on how to hide particles)
    - use and extend h5md?
- [ ] create benchmark (NCores x NParticles x rates)
    - maybe execute this benchmark automatically on some host
- [ ] domain decomposition (e.g., MPI)

### Topology reaction scheduling on GPUs

Let's assume we can do the following on the GPU
- Diffusion of normal particles and topologies
- Simple reactions, i.e. reactions between normal particles

Topology reactions can change the structure of topologies (e.g. polymerization,
binding/unbinding to a complex). This cannot be done on the GPU. Instead those reactions
have to be performed on the CPU, which is in principle not a problem when those reactions
occur rarely. The actual problem is, that the __GPU cannot halt on its own__ when it find out that
a topology reaction should be performed. There are two ways of determining how long the GPU
should execute:
1. with a fixed time $\tau$
    - the GPU executes diffusion and normal reactions for a time $\tau$ which is much larger
    than the integration step and then returns
    - the CPU performs all possible topology reaction events based on its current state,
    where reaction probabilities are $\mathrm{rate}\cdot \tau$. This could be done with the fixed timestep
    version of our reaction schedulers
2. with a time $\tau$ sampled from a Gillespie algorithm
    - given one system state with a number of possible topology reactions events,
    choose __one__ event and a corresponding $\tau$
    - perform this reaction and then let the GPU run for $\tau$
