---
title: Thursday - Custom potentials
sectionName: thursday
position: 4
---

### Task 0) Implementing a C++ potential
Make sure you are within a conda environment that has `readdy` installed, say `workshop`.
Clone the template for a custom potential into a directory called `mypotential`
```bash
git clone https://github.com/chrisfroe/custom-potential-template.git mypotential
cd mypotential
git submodule init
git submodule update
```
This should give you the following directory structure
```bash
mypotential
├── binding.cpp
├── cmake
│   └── Modules
│       └── FindREADDY.cmake
├── CMakeLists.txt
├── run.py
├── setup.py
└── pybind11/
```
Implement the potential in `binding.cpp` and build it
```bash
(workshop) $ python setup.py develop
```
Make sure that it works, run the following short python script:
```python
import numpy as np
import readdy
import mypot as mp

system = readdy.ReactionDiffusionSystem([10, 10, 10])
system.add_species("A", 0.001)

# use the potential you implemented
system.potentials.add_custom_external("A", mp.MyExternalPotential, 1., 1.)
#system.potentials.add_custom_pair("A", "A", mp.MyPairPotential, 1., 1., 1.)
sim = system.simulation(kernel="SingleCPU")

sim.add_particles("A", np.random.random((3000, 3)))
sim.run(1000, .1)
```
.

### Task 1) External potential, double well

__1a)__ Consider the __external__ potential

$$
U(x,a,b)=a((x/b)^2-1)^2
$$

that only depends on the x-coordinate, $a,b>0$.

Plot this potential in the range $[-2b,+2b]$ for $a=4$ and $b=5$. How will particles behave in this potential? 

__1b)__ Implement $U$ as `MyExternalPotential`.
The according force on a particle is then given by

$$
\mathbf{F}(x,a,b) \cdot \mathbf{\hat x} = -\frac{\mathrm{d}U(x,a,b)}{\mathrm{d}x}
$$

Note that the force only has a x-component. Y and z component are 0. Hints for the `binding.cpp`:
- The `MyExternalPotential` C++ class needs two parameters `forceConst` ($a$) and `distance` ($b$), implemented as private members
- These are given to the class as constructor arguments
- The `PYBIND_MODULE` section also needs to accomodate to the two arguments

```
// binding.cpp
class MyExternalPotential : public readdy::model::potentials::PotentialOrder1{
public:
    explicit MyExternalPotential(
        ParticleType ptype,
        readdy::scalar forceConst,
        readdy::scalar distance) 
    : PotentialOrder1(ptype),
      forceConst(forceConst),
      distance(distance) { }
    // ...
private:
    readdy::scalar forceConst;
    readdy::scalar distance;
};

PYBIND11_MODULE (mypot, m) {
    py::module::import("readdy");

    py::class_<MyExternalPotential, readdy::model::potentials::PotentialOrder1>(m, "MyExternalPotential")
    .def(py::init<ParticleType, readdy::scalar, readdy::scalar>());
}
```

The `// ...` denotes the parts you have to fill in.

Once you are done implementing it, you have to compile it
```bash
(workshop) $ python setup.py develop
```
If this returns no errors the potential has been built, and the according module was made available to your `(workshop)` environment.

__1c)__ You can now go to your jupyter notebook and set up a system. The simulation box will have `box_size=[30, 30, 30]` and will be __periodic__. There will be one species `A` with `diffusion_constant=0.1`. The only potential in the system will be the one you implemented:
```python
system.potentials.add_custom_external("A", mp.MyExternalPotential, 4., 5.)
```
The last two arguments are forwarded to the C++ constructor, i.e. they are `forceConst` and `distance`.

Simulate the system for 1000 particles initially placed in the origin `(0,0,0)`
```python
simulation.add_particles("A", np.zeros((1000,3)))
```
Observe the trajectory and the particle positions
```python
simulation.record_trajectory(100)
simulation.observe.particle_positions(100)
```
Run the simulation for 100000 steps and a timestep of $\tau=0.05$.

Have a look at the VMD output, do your observations match your expectations?

__1d)__ Make a histogram of all x-positions. Therefore use the positions observable in the following way
```python
times, positions = traj.read_observable_particle_positions()

# convert to numpy array
T = len(positions)
N = len(positions[0])
pos = np.zeros(shape=(T, N, 3))
for t in range(T):
    for n in range(N):
        pos[t, n, 0] = positions[t][n][0]
        pos[t, n, 1] = positions[t][n][1]
        pos[t, n, 2] = positions[t][n][2]

# only look at x
xs = pos[:,:,0].flatten()

# make the histogram
hist, bin_edges = np.histogram(
  xs, bins=np.arange(-15.,15.,0.5), density=True)

# from the bin_edges, calculate the bin_centers
bin_centers = []
for i in range(len(bin_edges)-1):
    bin_centers.append(0.5 * (bin_edges[i] + bin_edges[i+1]))
bin_centers = np.array(bin_centers)
```
Plot the histogram `hist` as a function of the x-coordinates `bin_centers`. What is the ratio of probability of being in the transition state $x=0$ over the probability of being in one of the ground states $x=b$?

__1e)__ In statistical mechanics, the above histogram describes a probability distribution $\rho(x)$. When a system is closed, isolated and coupled to a heat bath with temperature $T$, one can assume that the distribution is related to the potential $U$ in the following way:

$$
\rho(x) \propto e^{-U(x)/k_BT}
$$

where $k_BT=1$ in our case. Using this assumption, try to recover your potential, i.e. solve the above equation for $U$, and calculate it as a function of x, given your histogram.

Compare this result for $U$ against the true potential you have implemented. What could be sources of error here?

### Task 2) Pair potential, nuclear waffles
Have a look at [this paper](https://arxiv.org/pdf/1409.2551.pdf).
There are two species N and P with potentials,

$$
V_{NP}(r) = ae^{-r^2/\Lambda} + (b-c)e^{-r^2/2\Lambda}
$$

$$
V_{NN}(r) = ae^{-r^2/\Lambda} + (b+c)e^{-r^2/2\Lambda}
$$

$$
V_{PP}(r) = ae^{-r^2/\Lambda} + (b+c)e^{-r^2/2\Lambda} + \frac{\alpha}{r}e^{-r/\lambda}
$$

with the following constants

| Symbol    | Value                                 |
| --------- | --------------------------------------|
| $a$       | $110\,\mathrm{MeV}$                   |
| $b$       | $-26\,\mathrm{MeV}$                   |
| $c$       | $24\,\mathrm{MeV}$                    |
| $\Lambda$ | $1.25\,\mathrm{fm}^2$                 |
| $\lambda$ | $10\,\mathrm{fm}$                     |
| $\alpha$  | $1.439836\times 10^2\,\mathrm{eV\,fm}$ (changed on purpose) |

The latter part of $V_{PP}$ is a screened electrostatic potential already available in ReaDDy, see [here](https://readdy.github.io/system.html#screened-electrostatics).

The gaussian potentials however are not implemented in ReaDDy. This is your task.

__2a)__ Implement the __pair__ potential

$$
U(r, A, L, r_0) = \left\{\begin{array}{rl}Ae^{-r^2/L}& \mathrm{if }~ r<r_0\\ 0&\mathrm{otherwise} \end{array}\right.
$$

as `MyPairPotential`. $A$ is the `prefactor` regulating the strength and the sign of interaction ($A>0$ repulsive, $A<0$ attractive). $L$ is the `variance`, that determines the width of the potential. $r_0$ is the `cutoff`. Use these names also in your `binding.cpp` for the constructor arguments.

You might want to have a look at how this potential actually looks like.

__Note:__ From the potential $U(r)$ you first have to derive the analytical expression for the force $F(\mathbf{x}_j- \mathbf{x}_i)$ acting between two particles located at $\mathbf{x}_i$ and $\mathbf{x}_j$. The following identities may help you to calculate the force.

$$
\mathbf{F}_i(\mathbf{x}_j-\mathbf{x}_i) = - \nabla_i U(r) = - \frac{\partial U}{\partial r} \frac{\partial r(\mathbf{x}_i, \mathbf{x}_j)}{\partial \mathbf{x}_i}
$$

$$
r(\mathbf{x}_i, \mathbf{x}_j) = \| \mathbf{x}_j - \mathbf{x}_i \| =
\|\mathbf{x}_{ij}\|
$$

$$
\frac{\partial r(\mathbf{x}_i, \mathbf{x}_j)}{\partial \mathbf{x}_i} = -\frac{\mathbf{x}_{ij}}{\| \mathbf{x}_{ij} \|}
$$

When you are done implementing, compile it
```bash
(workshop) $ python setup.py develop
```

__2b)__
Now make use of your pair potential in a jupyter notebook.

Consider a __periodic__ system with `box_size=[200., 200., 8.]`. There should be the two species `N` and `P`, standing for neutrons and protons. Both with `diffusion_constant=0.1`.

There shall be a 2D plane, but this shall extend the simulation box in x and y.
```python
# box, keeping particles on the 2d plane
system.potentials.add_box(
  particle_type="N", force_constant=100., 
  origin=[-110., -110., -0.01], extent=[220., 220., 0.02])
system.potentials.add_box(
  particle_type="P", force_constant=100.,
  origin=[-110., -110., -0.01], extent=[220., 220., 0.02])
```

Now configure the custom potentials, i.e. $V_{NN}$, $V_{PP}$ and $V_{NP}$ mentioned above. Therefore use the following constants
```python
a = 110.
b = -26.
c = 24.
variance = 1.25
l = 10.
cutoff = 3.5
alpha = 1.439e2
proton_fraction = 0.4
total_n = 1357 * 4
n_p = int(total_n * proton_fraction)
n_n = int(total_n * (1. - proton_fraction))
```
The potentials then read
```python
# the custom potentials
system.potentials.add_custom_pair(
    "N", "P", mp.MyPairPotential, a, variance, cutoff)
system.potentials.add_custom_pair(
    "N", "P", mp.MyPairPotential, b-c, 2.*variance, cutoff)

system.potentials.add_custom_pair(
    "N", "N", mp.MyPairPotential, a, variance, cutoff)
system.potentials.add_custom_pair(
    "N", "N", mp.MyPairPotential, b+c, 2.*variance, cutoff)

system.potentials.add_custom_pair(
    "P", "P", mp.MyPairPotential, a, variance, cutoff)
system.potentials.add_custom_pair(
    "P", "P", mp.MyPairPotential, b-c, 2.*variance, cutoff)
system.potentials.add_screened_electrostatics(
    "P", "P", electrostatic_strength=alpha, inverse_screening_depth=1/l,
    repulsion_strength=0., repulsion_distance=1., exponent=1, cutoff=2.*cutoff
)
```
Compare this with $V_{NN}$, $V_{PP}$ and $V_{NP}$ and validate that I did not make an error here.

Next is the simulation: use the __CPU kernel__. Observe the __trajectory__ with a __stride__ of 10, and the radial distribution function for the separate pairs
```python
sim.observe.rdf(
    100, bin_borders=np.arange(0.,25.,0.1),
    types_count_from=["P"], types_count_to=["P"],
    particle_to_density=float(n_p)*3./200./200.,
    save={"name": "PP", "chunk_size":100}
)
sim.observe.rdf(
    100, bin_borders=np.arange(0.,25.,0.1),
    types_count_from=["N"], types_count_to=["N"],
    particle_to_density=float(n_n)*3./200./200.,
    save={"name": "NN", "chunk_size":100}
)
sim.observe.rdf(
    100, bin_borders=np.arange(0.,25.,0.1),
    types_count_from=["N"], types_count_to=["P"],
    particle_to_density=float(n_p)*3./200./200.,
    save={"name": "NP", "chunk_size":100}
)
```
Add particles to the system. There shall be a certain amount of protons. `n_n` and `n_p` were defined above.
```python
origin = np.array([-100., -100., -0.01])
extent = np.array([200., 200., 0.02])

init_pos = np.random.uniform(size=(n_p,3)) * extent + origin
sim.add_particles("P", init_pos)

init_pos = np.random.uniform(size=(n_n,3)) * extent + origin
sim.add_particles("N", init_pos)
```
Finally run the simulation for 20000 steps and a time step size of 0.05

__2c)__ Obtain the radial distribution functions that were saved under different names. Average them over the time axis (`np.mean(...)`). Plot them all in the same plot. __Note:__ Since we were calculating the RDF on a 2D plane, we have to correct for this factor. This means plot the distributions as follows
```python
# note the additional " * bin_centers "
plt.plot(bin_centers, mean_distribution * bin_centers)
```
- How long are position correlations in this system, in absolute lengths?
- How many peaks are in the RDF of `PP`?
- What is the apparent collision radius of the `P` particles only considering their `PP` correlation? 
- What is the apparent collision radius of the `N` particles only considering their `NN` correlations?

__2d)__ Also observe your VMD output. Can you see waffles? What are the differences of how Schneider _et al_ in their paper simulated the system and what we did? Is ReaDDy an appropriate tool for such a system?

