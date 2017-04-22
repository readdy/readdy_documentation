---
layout: page
title: Development
---

## Build
ReaDDy has the following __dependencies__:
- HDF5
- cmake
- *optional*: python (2 or 3), numpy (for python bindings)
- *testing*: gtest (included by git submodule)

### Build by using CMake
This type of build is suggested if one is interested in development of the software. There are a number of CMake options that influence the type of build:

| CMake option = default | Description |
| --- | --- |
| READDY_CREATE_TEST_TARGET:BOOL=ON | Determining if the test targets should be generated. |
| READDY_CREATE_MEMORY_CHECK_TEST_TARGET:BOOL=OFF | Determining if the test targets should be additionally called through valgrind. Requires the previous option to be ON and valgrind to be installed. |
| READDY_INSTALL_UNIT_TEST_EXECUTABLE:BOOL=OFF | Determining if the unit test executables should be installed. This is option is mainly important for the conda recipe. |
| READDY_BUILD_SHARED_COMBINED:BOOL=OFF | Determining if the core library should be built monolithically or as separated shared libraries. |
| READDY_BUILD_PYTHON_WRAPPER:BOOL=ON | Determining if the python wrapper should be built. |
| READDY_DEBUG_PYTHON_MODULES:BOOL=OFF | If this flag is set to ON, the generated python module will be placed in-source rather than in the output directory to enable faster development. |
| READDY_DEBUG_CONDA_ROOT_DIR:PATH="" | This option is to be used in conjunction with the previous option and only has effect if it is set to ON. It should point to the conda environment which is used for development and then effects the output directory of the binary files such that they get compiled directly into the respective environment. |
| READDY_GENERATE_DOCUMENTATION_TARGET:BOOL=OFF | Determines if the documentation target should be generated or not, which, if generated, can be called by "make doc". |
| READDY_GENERATE_DOCUMENTATION_TARGET_ONLY:BOOL=OFF | This option has the same effect as the previous option, just that it does not need any dependencies other than doxygen to be fulfilled and generates the documentation target exclusively. |
| READDY_LOG_CMAKE_CONFIGURATION:BOOL=OFF | This option determines if the status of relevant cmake cache variables should be logged at configuration time or not. |
| READDY_KERNELS_TO_TEST:STRING="SingleCPU,CPU" | Comma separated list of kernels against which the core library should be tested within the test targets. |
| *advanced*: INCLUDE_PERFORMANCE_TESTS:BOOL=OFF | Flag indicating if the performance tests should be part of the unit test target or not. |

After having configured the cmake cache variables, one can invoke cmake and make and compile the project.
Altogether, a shell script invoking cmake with modified parameters in an environment with multiple python versions could look like [this](https://github.com/readdy/readdy/blob/master/tools/dev/configure.sh).

### Build by using conda-build
```bash
conda install conda-build
conda-build PATH_TO_READDY/tools/conda-recipe
```
## Source tree structure
```
readdy/
├── README.md
│   ...
│
├── kernels/
│   │
│   ├── cpu/
│   │   ├── include/
│   │   │   └── (kernel includes)
│   │   ├── src/
│   │   │   └── (kernel sources)
│   │   └── test/
│   │       └── (kernel tests)
│   │
│   └── cuda/
│       └── (yet to be added)
│
├── include/
│   └── *.h (core library includes)
│
├── readdy/
│   │
│   ├── main/
│   │   └── (core library sources)
│   └── test/
│       └── (core library tests)
│
├── libraries/
│   └── (googletest, h5xx, pybind11, spdlog)
│
└── wrappers/
    └── python/
        └── src/ (code for python api)
            ├── cxx/
            │   └── (c++ code for the python module)
            │
            └── python/
                └── (python top-level api)

```

## Tasklist

### Functional features

Which functional features are we still lacking? Which will be next?
* Reversible reaction integrator
* Topologies [high],
    Topologies are superstructures grouping particles to e.g. molecules. Required features:
    - potentials between specific particles (bonds, angles, dihedrals)
    - consistent handling of reactions, i.e. particles involved in topologies can undergo reactions and topologies are correctly updated.
    - may include different handling of particle motion. Particles moving together in a topology may obey different dynamics (e.g. anisotropic diffusion)
* Membranes [high],
    Mohsen's membrane model includes special particle types and special dynamics. Should be somehow integrated into ReaDDy.
    - Treat these particles like other particles? Treat the membrane as a topology? Or are membranes different from standard particles?
    - Interactions and reactions between standard particles and membrane particles should be possible 
    (e.g. binding of a membrane-associated protein to a membrane that deforms the membrane locally)
* Special programs
    Plan/design how to integrate special programs such as compartment-based reactions with minimal user-side C++ programming overhead.

### Technical Features

Which technical features are we still lacking? Which will be next?
* Snapshot: Save simulation state such that we can continue a simulation run.
* Efficient parallel reaction handling (low-prio)
* Kernel: MPI
* Kernel: GPU
* High-level Python API
* Windows binaries

### Next Todos

* Planning / conceptual / software design: 
    - How do we build topologies 
    - Can we integrate membranes in this concept?
    - Consistency of membrane model with the remaining particle/topology concept? How can we integrate these concepts with minimal additional effort?
    - Relation to GPU Kernel: What part of topology handling can be done on the GPU? What on the CPU?
    - Membranes on the GPU?
* Apply for private repos in readdy organization.
* Chris: write down current status + next steps of reversible reaction scheme with interaction potential (for 1/2 particle system)

## Proposals


### General suggestions

- [ ] update API as below (and create top level python api):

```python
# define system here
system = ReactionDiffusionSystem(kernel="SingleCPU")

# create simulation (define algorithms to run the system)
simulation = system.simulation()  # use defaults. 
simulation.add_observable('rdf')  # actually part of the system, but configured through the simulation object
simulation.integrator = "EulerBDIntegrator"
simulation.compute_forces = False
simulation.reaction_scheduler = "UncontrolledApproximation"
simulation.evaluate_observables = False
simulation.run(10)  # does the configuration and runs the simulation

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
    - this point belongs together with the IO point
    - implement snapshotting using the observables framework
- [ ] implement IO (de-/serialization, dumping of trajectories into hdf5 files)
    - implement VMD plugin (see, e.g., lammps plugin on how to hide particles)
    - use and extend h5md?
    - use h5xx?
    - implement IO using the observables framework
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

### Aggregators and files (edit: now implemented)

As of now observables describe only one point in time. Aggregators are observables that accumulate
data. Suggestion:
- Since aggregators accumulate the data, only they can clear the data. Thus the aggregator should also
be responsible for the file-writing process.
- Aggregators (edit: observables in general) hold a file object, which is optional.

### Compartments

Compartments are defined as regions of the simulation box. Within those compartments certain instantaneous
conversions are defined. Those are different from actual reactions implementation wise but they
basically do the same thing. For example:
- A compartment is defined via $r > 10$, i.e. if a particle is more than 10 length units away from the origin
it is considered to be in the compartment.
- Associated with this compartment is a conversion `A -> B`, i.e. if an A particle travels into this compartment
it will be converted to a B particle instantaneously.
- One could define a second complementary compartment $r < 10$ with a conversion `B -> A`.
 
Why is this useful? For example:
- If one is only interested in setting up an observable for particles close to a certain point. E.g. I want to
know the pair correlation radial distribution of `A` particles around some other static particle, but I only need the 
radial distribution in close proximity (because the static particle might induce some crowding effects), 
I can set up a compartment that converts the `A` particles to `A_close` particles when they come close to the 
static particle. Then my observable only records the pair correlation of `A_close` particles.
- Absorbing boundary conditions can easily be implemented. Imagine I have a non-periodic system in x-direction and
I want to construct an absorbing boundary in the halfspace defined by $x < 0$ for a certain particle type `A`. One could
define the compartment $x < 0$ with the conversion `A -> N`, where `N` is a species that rapidly decays 
in the next timestep (i.e. `N` has an _actual_ decay reaction with a very high rate). 
Note that there is no second complementary compartment with a reverse conversion, i.e. `N` particles cannot become
`A` particles again. 

The execution of those conversions can be put into a Program, which is executed on the kernels. To
have full flexibility and accessibility from the Python layer, it makes sense to construct those compartments
similar to potentials.
Another nice feature is, that the computational complexity of applying the conversions is $O(N)$ when $N$ is the
total number of particles. So it should not take longer than the evaluation of first order potentials.

What types of compartments are easily implemented?:

- Radial, $ \| r-r_0 \| > \text{or} < R $, with three parameters
    - Vec3 origin $r_0$
    - double radius $R$
    - bool largerOrLess
- Plane, $ a_0 x_0 + a_1 x_1 + a_2 x_2 > \text{or} < d $, in Hesse normal form with three parameters
    - Vec3 normalCoefficients $a$
    - double distanceFromOrigin $d$
    - bool largerOrLess

Issues can arise if compartments overlap. Then it is implementation-dependent, which conversions get executed first
and thus which particle-type you end up with. There would be no _efficient_ way of determining if compartments overlap.
But when a particle is found to be in two compartments during run-time, warnings can be printed.