---
title: Wednesday
sectionName: wednesday
position: 3
---

{% if false %}

This session will cover macromolecules and how they assemble into superstructures
### Task 1) polymer and radius of gyration
![](assets/polymer.png)

In this task we will calculate the [radius of gyration](https://en.wikipedia.org/wiki/Radius_of_gyration#Molecular_applications) of a polymer as a function of the stiffness of the polymer.

We will only need one particle species `monomer` with diffusion constant $D=0.1$. Note that this will not be a _normal_ species but will be a __topology species__:
```python
system.add_topology_species("monomer", 0.1)
```

The __simulation box__ shall have `box_size= [32.,32.,32.]`, and be __non-periodic__. This means that there has to be a __box potential__ registered for the type `monomer` with force constant 50, `origin=np.array([-15,-15,-15])` and `extent=np.array([30,30,30])`. 

Between monomers there should be a harmonic repulsion potential with `force_constant=50` and `interaction_distance=1`

In order to build a polymer we use [topologies](https://readdy.github.io/system.html#topologies). At first we need to register a type of toplogy
```python
system.topologies.add_type("polymer")
```
The monomers in a polymer must be held together by [harmonic bonds](https://readdy.github.io/system.html#harmonic-bonds), defined by pairs of particle types
```python
system.topologies.configure_harmonic_bond(
    "monomer", "monomer", force_constant=100., length=1.)
```
For this example we also specify an [angular potential](https://readdy.github.io/system.html#harmonic-angles), that is defined for a triplet of particle types
```python
system.topologies.configure_harmonic_angle(
    "monomer", "monomer", "monomer", force_constant=stiffness, 
    equilibrium_angle=np.pi)
```
where an `equilibrium_angle`$=\pi$ means 180 degrees.
The next step is creating the __simulation__. Then we specify the observables, the trajectory and the particle positions
```python
simulation.record_trajectory(stride=10000)
simulation.observe.particle_positions(stride=1000)
```
Now we need to set the initial positions of particles and set up the polymer connectivity, therefore we do a 3D random walk that generates us the initial positions of the chain of particles
```python
n_particles = 50
init_pos = [np.zeros(3)]
for i in range(1, n_particles):
    displacement = np.random.normal(size=(3))
    # normalize the random vetor
    displacement /= np.sqrt(np.sum(displacement * displacement))
    # append the new position to the chain
    init_pos.append(init_pos[i-1]+displacement)
init_pos = np.array(init_pos)
```
Now that we have generated the positions we have to add them to the simulation together with the actual topology instance
```python
top = sim.add_topology("polymer", len(init_pos)*["monomer"], init_pos)
```
The last step is to define the connectivity
```python
for i in range(1, n_particles):
    top.get_graph().add_edge(i-1, i)
```
Now that we have defined the simulation object we can run the simulation
```python
if os.path.exists(sim.output_file):
    os.remove(sim.output_file)
sim.run(1000000, 2e-2)
```

__1a)__ Implement the simulation described above for `stiffness=0.1`. From the recorded trajectory, have a look at the VMD output. Does the structure of the polymer change in the initial phase?

__1b)__ Do the same simulation as above, but now calculate the radius of gyration as a function of time. Given the positions observable, you can calculate the radius of gyration as follows (the assertion statements may help you understand how the arrays are shaped):
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
Plot the radius of gyration as a function of time, is it equilibrated? Calculate its time average and standard deviation over the whole timeseries.

__1c)__ Put all of the above into one function `simulate(stiffness)` that performs the whole simulation and analysis for a given stiffness parameter and returns the mean (one number only, not an array) and standard deviation of the radius of gyration. The function body should roughly consist of
```python
def simulate(stiffness):
    system = readdy.ReactionDiffusionSystem(...)
    ... # system configuration
    simulation = system.simulation(...)
    out_file = os.path.join(data_dir, "polymer_"+str(stiffness)+".h5")
    ... # simulation setup
    simulation.run(...)
    ... # calculation of radius of gyration
    return mean_radius_of_gyration, deviation_radius_of_gyration
```
Measure the mean radius of gyration with standard deviation as a function of the stiffness parameter for values `[0.1, 0.5, 1.0, 5.0, 10.]`. This might look like:
```python
values = [0.1, 0.5, 1., 5., 10.]
rgs = []
devs = []
for stiffness in values:
    rg, dev = simulate(stiffness)
    rgs.append(rg)
    devs.append(dev)
```
Plot the mean radius of gyration as a function of the stiffness. Explain your result by looking also at the VMD output.

### Task 2) linear filament assembly
In this task we will also look at a linear polymer chain, but this time we will not place it initially, but instead we will let it self-assemble from monomers in solution. The polymer that we will build will have the following structure
```
head--core--(...)--core--tail
```
where `(...)` means that there can be many core particles, but the structure is always linear.

The simulation box is  __periodic__  with `box_size=[20., 20., 20.]`.

We define three __topology particle species__ and one normal particle species
```python
system.add_species("substrate", 0.1)
system.add_topology_species("head", 0.1)
system.add_topology_species("core", 0.1)
system.add_topology_species("tail", 0.1)
```
We also define one topology type
```python
system.topologies.add_type("filament")
```
There should be the following potentials for topology particles
```python
system.topologies.configure_harmonic_bond(
    "head", "core", force_constant=100, length=1.)
system.topologies.configure_harmonic_bond(
    "core", "core", force_constant=100, length=1.)
system.topologies.configure_harmonic_bond(
    "core", "tail", force_constant=100, length=1.)
```
Like in task 1) the polymer should be stiff, we can compactly write this for all triplets of particle types:
```python
triplets = [
    ("head", "core", "core"),
    ("core", "core", "core"),
    ("core", "core", "tail"),
    ("head", "core", "tail")
]
for (t1, t2, t3) in triplets:
    system.topologies.configure_harmonic_angle(
        t1, t2, t3, force_constant=50., 
        equilibrium_angle=np.pi)
```
We now introduce a [topology reaction](https://readdy.github.io/system.html#topology_reactions). They allow changes to the graph of a topology in form of a reaction. Here we will use the following definition.
```python
system.topologies.add_spatial_reaction(
    "attach: filament(head) + (substrate) -> filament(core--head)",
    rate=5.0, radius=1.5
)
```
Using the [documentation](https://readdy.github.io/system.html#spatial-reactions), familiarize yourself, what this means. Do not hesitate to ask, since topology reactions can become quite a tricky concept!

Next create a simulation object. We want to observe the following
```python
simulation.record_trajectory(stride=100)
simulation.observe.topologies(stride=100)
```
Add one filament topology to the simulation
```python
init_top_pos = np.array([
    [ 1. ,0. ,0.],
    [ 0. ,0. ,0.],
    [-1. ,0. ,0.]
])
top = simulation.add_topology(
  "filament", ["head", "core", "tail"], init_top_pos)
top.get_graph().add_edge(0, 1)
top.get_graph().add_edge(1, 2)
```
Additionally we need substrate particles, that can attach themselves to the filament
```python
n_substrate = 300
origin = np.array([-10., -10., -10.])
extent = np.array([20., 20., 20.])
init_pos = np.random.uniform(size=(n_substrate,3)) * extent + origin
simulation.add_particles("substrate", positions=init_pos)
```
Then, run the simulation
```python
if os.path.exists(simulation.output_file):
    os.remove(simulation.output_file)
dt = 5e-3
simulation.run(400000, dt)
```
One important observable will be the length of the filament as a function of time. It can be obtained from the trajectory as follows:
```python
times, topology_records = traj.read_observable_topologies()
chain_length = [ len(tops[0].particles) for tops in topology_records ]
```
The last line is a [list comprehension](https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions). `tops` is a list of topologies for a given time step. Hence, `tops[0]` is the first (and in this case, the only) topology in the system. `tops[0].particles` is a list of particles belonging to this topology. Thus, its length yields the length of the filament.

__2a)__ Have a look at the VMD output. Describe what happens? Additionally plot the length of the filament as a function of time. __Note__ that you shall now plot the simulation time and not the time step indices, i.e. do the following
```python
times = np.array(times) * dt
```
where `dt` is the time step size.

__2b)__ Using your data of the filament-length, fit a function of the form

$$
f(t)=a(1-e^{-bt})+3
$$

to your data. You should use [scipy.optimize.curve_fit](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.curve_fit.html) to do so
```python
import scipy.optimize as so

def func(t, a, b):
    return a*(1. - np.exp(-b * t)) + 3.

popt, pcov = so.curve_fit(func, times, chain_length)

print("popt", popt)
print("pcov", pcov)

f = lambda t: func(t, popt[0], popt[1])

plt.plot(times, chain_length, label="data")
plt.plot(times, f(times), label=r"fit $f(t)=a(1-e^{-bt})+3$")
plt.xlabel("Time")
plt.ylabel("Filament length")
plt.legend()
plt.show()
```
__Question:__ Given the result of the fitting parameters
- How large is the equilibration rate?
- What will be the length of the filament for $t\to\infty$?

__2c)__ We now introduce a disassembly reaction for the `tail` particle. This is done by adding the following to your system configuration.
```python
def rate_function(topology):
    """
    if the topology has at least (head, core, tail)
    the tail shall be removed with a fixed probability per time
    """
    vertices = topology.get_graph().get_vertices()
    if len(vertices) > 3:
        return 0.05
    else:
        return 0.

def reaction_function(topology):
    """
    find the tail and remove it,
    and make the adjacent core particle the new tail
    """
    recipe = readdy.StructuralReactionRecipe(topology)
    vertices = topology.get_graph().get_vertices()

    tail_idx = None
    adjacent_core_idx = None
    for v in vertices:
        if topology.particle_type_of_vertex(v) == "tail":
            adjacent_core_idx = v.neighbors()[0].get().particle_index
            tail_idx = v.particle_index

    recipe.separate_vertex(tail_idx)
    recipe.change_particle_type(tail_idx, "substrate")
    recipe.change_particle_type(adjacent_core_idx, "tail")

    return recipe


system.topologies.add_structural_reaction(
    "filament",
    reaction_function=reaction_function, 
    rate_function=rate_function)
```
Familiarize yourself with this kind of [structural topology reaction](https://readdy.github.io/system.html#structural-reactions)

Repeat the same analysis as before, and also observe your VMD output. 
- How large is the equilibration rate?
- What will be the length of the filament for $t\to\infty$?


{% endif %}
