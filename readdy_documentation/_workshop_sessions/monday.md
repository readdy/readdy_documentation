---
title: Monday - ReaDDy intro
sectionName: monday
position: 1
---

### Task 0) installation

Get miniconda and install it

```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

Check your `quota -s`. If your `home` directory is limited in space, you might want to install it under `storage`, i.e. when prompted for install location, choose either `/home/mi/user/miniconda3` or `/storage/mi/user/miniconda3` (replace `user` with your username). Your `~/.bashrc` should contain the line

```bash
. /storage/mi/user/miniconda3/etc/profile.d/conda.sh
```

to enable the `conda` command. If you try out `which conda`, you should see its function definition, and you're good to go.

Create a conda environment `workshop`

```bash
conda create -n workshop
```

and activate it.

```bash
conda activate workshop
```

Add `conda-forge` as default channel

```bash
conda config --add channels conda-forge --env
```

and install the latest `readdy` in it

```bash
(workshop) $ conda install -c readdy/label/dev readdy
```

Check if it worked, start a python interpreter and do

```python
import readdy
print(readdy.__version__)
```

If this does not return an error, you are ready to readdy (almost).
Make sure you also have `vmd` installed. It should be installed on the universities machines.

### Task 1) Python, ipython notebook, numpy, matplotlib crash course

Follow along the [ipython-intro](https://github.com/chrisfroe/readdy-workshop-2019-session-notebooks/blob/master/1_monday/ipython-intro.ipynb). You should be able to reproduce the presented usage in your own ipython notebook.
The notebook covers the following:

- usage of an ipython notebook
- filesystem operations with `os`
- save and load data objects with `pickle`
- numerical operations with `numpy`
- plotting with `matplotlib.pyplot`

### Task 2) ReaDDy intro I: Particles, diffusion and potentials

Follow along the [readdy-intro](https://github.com/chrisfroe/readdy-workshop-2019-session-notebooks/blob/master/1_monday/readdy-intro-1-particles-diffusion-potentials.ipynb). You should be able to reproduce the presented usage in your own ipython notebook.
The notebook covers the following:

- principle workflow of readdy: `system` and `simulation`
- adding particle species to `system`
- adding potentials to `system`
- spatial layout of [simulation box](https://readdy.github.io/system.html) and [box potentials]()
- adding particle instances at given positions to `simulation`
- convert trajectory output to VMD viewable format

### Task 3) ReaDDy intro II: Reactions, observables and checkpoints

Follow along the [readdy-observables](https://github.com/chrisfroe/readdy-workshop-2019-session-notebooks/blob/master/1_monday/readdy-intro-2-reactions-observables-checkpoints.ipynb)
The notebook covers the following:

- adding reaction to `system`
- adding observable to `simulation`
- reading back the observable from trajectory file
- using checkpoints to continue a simulation


### Task 4) Crowded mixture, MSD

The time dependent mean squared displacement (MSD) is defined as

$$
\langle(\mathbf{x}_t-\mathbf{x}_0)^2\rangle_N
$$

where $\mathbf{x}_t$ is the position of a particle at time $t$, and  $\mathbf{x}_0$ is its initial position. The difference of these is then squared, yielding a squared travelled distance. This quantity is then averaged over all particles.

The __task__ is to set up a crowded mixture of particles and __measure the MSD__. There is one species A with diffusion coefficient 0.1. The simulation box shall be $20\times20\times20$ and non-periodic, i.e. define a box potential that keeps particles inside, e.g. with an extent $19\times19\times19$ and appropriate origin.

Define a harmonic repulsion between A particles with force constant 100 and interaction distance 2.

Add 1000 A particles to the simulation, uniformly distributed within the box potential. 

Observe the [positions of particles](https://readdy.github.io/simulation.html#particle-positions) with a stride of 1.

Run the simulation with a time step size of 0.01 for 20000 steps.

In the post-processing you have to calculate the MSD from the observed positions. Implement the following steps:

1. Convert positions list into numpy array  $T\times N\times3$
2. From every particles position subtract the initial position
3. Square this
4. Average over particles `np.mean(...)`

Since the positions observable returns a list of list, it might come in handy to convert this to a numpy array of shape $T\times N\times3$ (step 1). You may use the following brute force method to do this

```python
T = len(positions)
N = len(positions[0])
pos = np.zeros(shape=(T, N, 3))
for t in range(T):
    for n in range(N):
        pos[t, n, 0] = positions[t][n][0]
        pos[t, n, 1] = positions[t][n][1]
        pos[t, n, 2] = positions[t][n][2]
```

You shall implement steps 2.-4. by yourself.

__4a)__ Finally plot the MSD as a function of time in a log-log plot, let's call this the _crowded_ result. (Hint: You may find that there is an initial jump in the squared displacements. Equilibrating the particle positions before starting the measurement may help you there. Make use of checkpointing to use an already equilibrated state)

__4b)__ Repeat the whole procedure, but do not register the harmonic repulsion between particles, this shall be the _free_ result. Compare the MSD to the previous result, possibly in the same plot.

__4c)__ Additionally plot the analytical solution for freely diffusing particles

$$
\langle(\mathbf{x}_t-\mathbf{x}_0)^2\rangle_N = 6 D t
$$

From your resulting plot identify "finite size saturation", "subdiffusion", "reduced normal diffusion", "ballistic/normal diffusion"

### Task 5) Crowded mixture, RDF

The radial distribution function (RDF) $g(r)$ describes how likely it is to find two particles at distance $r$. Compare the  RDF of harmonically repelling particles and the RDF of non-repelling particles.

Therefore set up the same system as in Task 4) but this time the system shall be periodic and there is no box potential.

You may want to equilibrate the initial particle positions, use checkpointing.


Instead of observing the particle positions, observe the [radial distribution function](https://readdy.github.io/simulation.html#radial-distribution-function)

```python
simulation.observe.rdf(stride=1000, bin_borders=np.arange(0.,10.,0.2),
                       types_count_from="A", types_count_to="A",
                       particle_to_density=n_particles/system.box_volume)
```

In the post-processing, you shall use

```python
_, bin_centers, distribution = traj.read_observable_rdf()
```

to obtain the observable. The `distribution` contains multiple $g(r)$, one for each time it was recorded. Average them over time.

__5a)__ Plot the RDF as a function of the distance (i.e. mean`distribution` as function of `bin_centers`)

__5b)__ Perform the same procedure but for non-interacting particles, compare with the previous result, preferably in the same plot. What are your observations?

