---
title: Wednesday
sectionName: wednesday
position: 3
---

{: .centered}
![](assets/polymer.png)

This session will cover macromolecules and their dynamics. In particular we want to model short RNA chains, represented by linear chains of beads.

Assume $N$ beads of particles at positions $$\mathbf{x}_i$$, 
the $i$th bead is connected with the $i+1$th bead by a spring which has a fixed length $l$. 
Thus the whole chain of particles is linearly connected. 
The vector $$\mathbf{r}_i=\mathbf{x}_{i+1}-\mathbf{x}_i$$ is the segment that connnects adjacent beads.

{: .centered}
![](assets/segments.svg)

One can measure how strongly the $i$th and the $j$th segment correlate by considering the scalar product $$\mathbf{r}_i\cdot\mathbf{r}_j$$. 

{: .centered}
![](assets/segments_correlation.svg)

Since this value alone is quite meaningless, one can consider its average over a whole ensemble of segments. This average can be taken over all segments, i.e. $\forall i,j$ in the linear chain, and also over many times if the linear chain evolves over time. For realistic polymers one typically observes that the $i$th segment strongly correlates with the $j=i+1$th segment. However for $j\gg i$ the correlation vanishes. Phenomenologically this is understood by an exponential decay of the correlation

$$
\langle \mathbf{r}_i\cdot\mathbf{r}_j \rangle=l^2\exp\left(-|j-i|\,l/l_p\right)
$$

where we have defined the __persistence length__ $l_p$. The value of $l_p$ is determined by the interaction of the beads. For example _structured_ RNA molecules typically show a persistence length of 72nm. Today we will instead model _unstructed_ RNA molecules, which show a persistence length of roughly 2nm. 

We will consider two models for the polymer, namely

- the _freely jointed chain_ (FJC), and
- the _freely rotating chain_ (FRC).

In the FJC, the beads are connected by segments of fixed length $l=0.48$. Other than that there is no interaction.

In the FRC, the beads are also connected by segments of fixed length $l=0.48$. Additionally the angle between neighbouring segments is fixed to $\theta=35^\circ$.

### Task 1) Equilibrate polymers

In the first task you will 

- __a)__ equilibrate a freely jointed chain (FJC) of $N=50$ beads. Equilibration is ensured by measuring the [radius of gyration](https://en.wikipedia.org/wiki/Radius_of_gyration#Molecular_applications) of a polymer over time.
- __b)__ Once the polymer is equilibrated, you will measure the persistence length $l_p$.
- __c)__ Repeat a) and b) for the freely rotating chain (FRC)

We will only need one particle species `monomer` with diffusion constant $D=0.1$. Note that this will not be a _normal_ species but will be a __topology species__:

```python
system.add_topology_species("monomer", 0.1)
```

The __simulation box__ shall have `box_size= [102.,102.,102.]`, and be __non-periodic__. This means that there has to be a __box potential__ registered for the type `monomer` with force constant 50, `origin=np.array([-50,-50,-50])` and `extent=np.array([100,100,100])`. 

In order to build a polymer we use [topologies](https://readdy.github.io/system.html#topologies). At first we need to register a type of toplogy

```python
system.topologies.add_type("polymer")
```

The monomers in a polymer must be held together by [harmonic bonds](https://readdy.github.io/system.html#harmonic-bonds), defined by pairs of particle types

```python
system.topologies.configure_harmonic_bond(
    "monomer", "monomer", force_constant=50., length=0.48)
```

__Only in the case of a FRC__ we also specify an [angular potential](https://readdy.github.io/system.html#harmonic-angles), that is defined for a triplet of particle types

```python
system.topologies.configure_harmonic_angle(
    "monomer", "monomer", "monomer", force_constant=20., 
    equilibrium_angle=(180.-35.)/180.*np.pi)
```

where an `equilibrium_angle` is given in radians (Note that the equilibrium angle here is not the same as the $\theta$ as defined above, thus the conversion by 180 degrees).

The next step is creating the __simulation__. Then we specify the observables, the trajectory and the particle positions

```python
simulation.record_trajectory(stride=10000)
simulation.observe.particle_positions(stride=1000)
```

We also want to make use of checkpointing to continue simulation for an already equilibrated polymer. If there are no checkpoints, we want to create new positions for the polymer. The new positions represent a random walk in three dimensions with fixed step length `bond_length`.

```python
if os.path.exists(checkpoint_dir):
    # load checkpoint
    simulation.load_particles_from_latest_checkpoint(checkpoint_dir)
else:
    # new positions
    init_pos = [np.zeros(3)]
    for i in range(1, chain_length):
        displacement = np.random.normal(size=(3))
        displacement /= np.sqrt(np.sum(displacement * displacement))
        displacement *= bond_length
        init_pos.append(init_pos[i - 1] + displacement)
    init_pos = np.array(init_pos)

    # subtract center of mass
    init_pos -= np.mean(init_pos, axis=0)

    # add all particles for the topology at once
    top = simulation.add_topology("polymer", len(init_pos) * ["monomer"], init_pos)

    # set up the linear connectivity
    for i in range(1, chain_length):
        top.get_graph().add_edge(i - 1, i)

# this also creates the directory
simulation.make_checkpoints(n_steps // 100, 
  output_directory=checkpoint_dir, max_n_saves=10)
```

__Tip__: Keep two separate checkpoint directories output files and for the FJC and the FRC model. This means you may want to have the following defined in the beginning of your notebook

```python
chain_type = "fjc" # fjc or frc
out_dir = "/some/place/on/your/drive"
out_file = os.path.join(out_dir, f"polymer_{chain_type}.h5")
checkpoint_dir = os.path.join(out_dir, f"ckpts_{chain_type}")
```

Now that we have defined the simulation object we can run the simulation

```python
if os.path.exists(simulation.output_file):
    os.remove(simulation.output_file)
simulation.run(n_steps, dt)
```

and also observe the output

```python
traj = readdy.Trajectory(out_file)
traj.convert_to_xyz(
  particle_radii={"monomer": bond_length / 2.},
  draw_box=True)
```

__1a)__ The radius of gyration is a measure of how 'extended' in space a polymer is. To calculate it, we must have observed the particle positions. As a first step we convert the readdy output to a numpy array

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
```

Then from the `pos` array you may use the following to calculate the radius of gyration (the assertion statements may help you understand how the arrays are shaped)

```python
# calculate radius of gyration
mean_pos = np.mean(pos, axis=1)

difference = np.zeros_like(pos)
for i in range(n_particles):
    difference[:,i] = pos[:,i] - mean_pos

assert difference.shape == (T,N,3)

# square and sum over coordinates (axis=2)
squared_radius_g = np.sum(difference * difference, axis=2)

assert squared_radius_g.shape == (T,N)

# average over particles (axis=1)
squared_radius_g = np.mean(squared_radius_g, axis=1)

radius_g = np.sqrt(squared_radius_g)

assert radius_g.shape == times.shape == (T,)
```

Plot the radius of gyration as a function of time, is it equilibrated? If not, simulate for a longer time.

__1b)__ The mean correlation of segments $\langle \mathbf{r}_i\cdot\mathbf{r}_j \rangle$ shall be calculated from the `pos` array. You will average over all pairs of the linear chain and also over all times.

Use the following snippet to calculate the `segments` vector

```python
assert pos.shape == (T, N, 3)
# calculate segments
segments = pos[:, 1:, :] - pos[:, :-1, :]
```

The correlation between $i$ and $j$ shall be measured as a function of their separation $s=\mid j-i\mid$, which is a value between 0 and $N-1$, e.g.

```python
n_beads = pos.shape[1]
separations = np.arange(0, n_beads - 1, 1)
corrs = None # your task
```

Now for every separation $s$, calculate the average correlation, averaged over all pairs $(i,j)$ that lead to $$s=\mid j-i\mid$$.

__Hints:__

- The calculation may involve a double loop over all segments
  
  ```python
  for i in range(n_beads-1):
      for j in range(i, n_beads-1):
          # something
  ```
- The scalar product of the $i$th and the $j$th bead for all times is
  
  ```python
  np.sum(segments[:, i, :] * segments[:, j, :], axis=1)
  ```
  
  where the summation over `axis=1` is over the x,y,z coordinates

Then plot the mean correlation as a function of the separation. What do you observe?

To determine the persistence length $l_p$, fit a function of the form

$$
f(s)=c_1e^{-sc_2}
$$

to the data using `scipy.optimize.curve_fit`. From the constant $c_2$ you should be able to obtain the persistence length. What is its value?

__1c)__ Repeat a) and b) for the FRC. Note the value for $l_p$ for both models. 

Given the  values in the introduction text, which of the models (FJC, FRC) is better suited to model unstructured RNA?

### Task 2) Identify given structures

Obtain the two data files [`a.npy`](https://userpage.fu-berlin.de/chrisfr/readdy_website/assets/a.npy) and [`b.npy`](https://userpage.fu-berlin.de/chrisfr/readdy_website/assets/b.npy) and save them to a directory of your liking. Each of them contains 100 positions of beads, i.e. `a` and `b` are two polymer configurations. You can load them as follows

```python
a = np.load("a.npy")
b = np.load("b.npy")
assert a.shape == (100, 3)
assert b.shape == (100, 3)
```

Your task is to identify which of them is the FJC model and which is the FRC model, from what you've learned in task 1.

### Task 3) First-passage times of finding target

You shall now use the configuration `x.npy` (where `x` is either `a` or `b`)from task 2 that corresponds to the FRC, to set up another simulation, in which one bead of the polymer is of `target` type. Freely diffusing `A` particles have to find the `target` particle. The application you should have in mind is proteins docking to a certain part of nucleid acids, which is crucial for the function of each biological cell. To determine when an `A` particle has found the target we implement the following kind of reaction

$$
\mathrm{A} + \mathrm{target} \to \mathrm{B} + \mathrm{target}
$$

The time when the first `B` particle is created, then corresponds to the first-passage time of that reaction.

__3a)__ Perform a simulation that initializes the polymer from `x.npy` where the 10th bead is of type `target`, and places 50 `A` particles normally distributed (with variance $\sigma=0.5$) around the origin.

Therefore use the following system configuration

```python
system = readdy.ReactionDiffusionSystem(
    box_size=[16., 16., 16.],
    periodic_boundary_conditions=[False, False, False],
    unit_system=None)

system.add_topology_species("monomer", 0.1)
system.add_topology_species("target", 0.1)
system.add_species("A", 0.5)
system.add_species("B", 0.5)

system.topologies.add_type("polymer")

origin = np.array([-7.5, -7.5, -7.5])
extent = np.array([15., 15., 15.])

system.potentials.add_box("monomer", force_constant=50., origin=origin, extent=extent)
system.potentials.add_box("target", force_constant=50., origin=origin, extent=extent)
system.potentials.add_box("A", force_constant=50., origin=origin, extent=extent)
system.potentials.add_box("B", force_constant=50., origin=origin, extent=extent)
```

with the following topology potentials

```python
system.topologies.configure_harmonic_bond(
    "monomer", "monomer", force_constant=50., length=bond_length)
system.topologies.configure_harmonic_bond(
    "monomer", "target", force_constant=50., length=bond_length)


system.topologies.configure_harmonic_angle(
    "monomer", "monomer", "monomer", force_constant=20.,
    equilibrium_angle=2.530727415391778)
system.topologies.configure_harmonic_angle(
    "monomer", "monomer", "target", force_constant=20.,
    equilibrium_angle=2.530727415391778)
system.topologies.configure_harmonic_angle(
    "monomer", "target", "monomer", force_constant=20.,
    equilibrium_angle=2.530727415391778)
```

Define a boolean flag `interaction = True`.
If the bool `interaction` is `True` then there should be a [weak interaction](https://readdy.github.io/system.html#weak-interaction-piecewise-harmonic) between `A` and `monomer` particles with a `force_constant` of 50, `desired_distance=bond_length`, a `depth` of 1.4, and a `cutoff` of `2.2*bond_length`.
What does such an interaction result in?

Additionally there will be repulsion potentials between `monomers` and between `A` particles.

```python
system.potentials.add_harmonic_repulsion(
    "monomer", "monomer", force_constant=50., 
    interaction_distance=1.1*bond_length)
system.potentials.add_harmonic_repulsion(
    "A", "A", force_constant=50., interaction_distance=1.5*bond_length)
```

Finally the system needs the reaction

```python
system.reactions.add("found: A +(0.48) target -> B + target", rate=10000.)
```

where we use a very high rate, such that the reaction will happen directly on contact, where 0.48 is the contact distance.

Observe the number of B particles with a stride of 1.

Load the polymer configuration and turn the 10th monomer into a target.

```python
init_pos = np.load("x.npy")

types = len(init_pos) * ["monomer"]
types[10] = "target" # define the target to be the 10-th monomer

top = sim.add_topology("polymer", types, init_pos)
for i in range(1, len(init_pos)):
    top.get_graph().add_edge(i - 1, i)
```

Place 50 A particles normally distributed, with variance $\sigma=0.5$, around the origin.

Simulate the system with a timestep of 0.001 for 30000 steps. Have a look at the VMD output. 

- How do the `A` particles interact with the polymer?
- Calculate the first passage time from the observed number of particles, i.e. the time when the first `B` was created.

__3b)__ Combine the simulation procedure above into a function of the signature

```python
def find_target(interaction=False):
    ...
    # Since we will run many simulations
    # you may want to supress the textual output by
    # setting the two options show_progress
    # and show_summary
    sim.show_progress = False
    sim.run(..., show_summary=False)
    ...
    return passage_time
```

__Hint:__ One such simulation should not take much longer than 10 seconds.

Gather passage times in a list

```python
ts_int = []
```

Repeat the simulation many times (50-100 should suffice) and append the result to the list.

```python
from tqdm import tqdm_notebook as tqdm
n=50
for _ in tqdm(range(n)):
    ts_int.append(find_target(interaction=True))
```

As this might take a while, you will want to observe how long the whole process takes, which is done here using `tqdm`.

Do the same for the case of no interaction, i.e. set `interaction=False` and gather the results in another list `ts_noint`.

_ProTip:_ To save computation time, run this second case in a copy of your notebook (i.e. at the same time) and save the resulting list `ts_noint` into a pickle file, which you can read in in the original notebook.

For both cases `interaction=True` and `interaction=False`, calculate the distribution of first passage times, i.e. plot a histogram of the lists you constructed using `plt.hist()`. Use `bins=np.logspace(0,2,20)` and `density=True`.

When assuming a memory less (Poisson) process, the only relevant parameter is the mean rate $\lambda=N/\sum_{i=1}^N\tau_i$. Plot the distribution of first-passage-times  with mean rate $\lambda$, i.e. the Poisson probability __density__ (not the cumulative) of 1 event occurring before time t. Compare against your measured distribution of waiting times?

Is the process of finding the target with or without interaction well suited to be modeled as a memory-less process?

Now additionally mark the __mean__ first passage time for each case using `plt.vlines()`. Is the difference of the two cases well described by the mean first passage time?
