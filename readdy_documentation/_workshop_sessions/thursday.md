---
title: Thursday
sectionName: thursday
position: 4
---   

{% if false %}

This session will deal with the self assembly of macromolecular structures due to reactions.

### Task 1) linear filament assembly

In this task we will look at a linear polymer chain, but instead of placing all beads initially, we will let it self-assemble from monomers in solution. The polymer that we will build will have the following structure

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

The polymer should be rather stiff, which is the case for Actin filaments in biological cells. We can compactly write this for all triplets of particle types:

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

__1a)__ Have a look at the VMD output. Describe what happens? Additionally plot the length of the filament as a function of time. __Note__ that you shall now plot the simulation time and not the time step indices, i.e. do the following

```python
times = np.array(times) * dt
```

where `dt` is the time step size.

__1b)__ Using your data of the filament-length, fit a function of the form

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

__1c)__ We now introduce a disassembly reaction for the `tail` particle. This is done by adding the following to your system configuration.

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

### Task 2) Assembly of virus capsids

This task will suggest a model for the assembly of monomers into hexamers, and in the bonus task: the assembly of these hexamers into even larger superstructures.

First we need a model for one monomer, which should look as follows

{: .centered}

 ![](assets/monomer.svg)

It is essentially one bigger `core` particle with two `sites` attached. This is sometimes called a _patchy particle_, i.e. a particle with reaction patches. The angle between the triplet `site--core--site`, shall be fixed to 120°. The `sites` shall react with the `sites` of other monomers to form a dimer that looks like

{: .centered}

![](assets/dimer.svg)

{% endif %}
