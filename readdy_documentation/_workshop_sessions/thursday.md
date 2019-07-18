---
title: Thursday
sectionName: thursday
position: 4
---

{% if true %}

This session will deal with the self assembly of macromolecular structures due to reactions.

### Task 1) linear filament (e.g. actin) assembly

{: .centered}
![](https://www.kerafast.com/images/Product/large/1477.jpg)

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
    "detach",
    "filament",
    reaction_function=reaction_function, 
    rate_function=rate_function)
```

Familiarize yourself with this kind of [structural topology reaction](https://readdy.github.io/system.html#structural-reactions)

Repeat the same analysis as before, and also observe your VMD output. 

- How large is the equilibration rate?
- What will be the length of the filament for $t\to\infty$?

### Task 2) Assembly of virus capsids

{: .centered}
![](https://cdn.rcsb.org/pdb101/motm/images/200-Quasisymmetry_in_Icosahedral_Viruses-Quasisymmetry.jpg)

This task will suggest a model for the assembly of monomers into hexamers, and in the bonus task: the assembly of these hexamers into even larger superstructures.

First we need a model for one monomer, which should look as follows

{: .centered}

 ![](assets/monomer.svg)

It is essentially one bigger `core` particle with two `sites` attached. This is sometimes called a _patchy particle_, i.e. a particle with reaction patches. In the language of ReaDDy, this group of particles is a topology, let's give it the name `CA`

```python
system.topologies.add_type("CA")
system.add_topology_species("core", 0.1)
system.add_topology_species("site", 0.1)
```

The angle between the triplet `site--core--site`, shall be fixed to 120°. The `sites` shall react with the `sites` of other monomers to form a dimer that looks like

{: .centered}

![](assets/dimer.svg)

For this dimer, the four particles shall be confined to a single 2D plane, which we do using topology potentials. Summarizing all potentials that you need to configure for the particles:

- harmonic bond between `core--site` with force constant 100 and length 1
- harmonic bond between `core--core` with force constant 100 and length 2
- harmonic bond between `site--site` with force constant 100 and length 0.1
- harmonic angle between `site--core--site` with force constant 200 and equilibrium angle 120 degrees
- harmonic angle between `site--core--core` with force constant 200 and equilibrium angle 120 degrees
- harmonic angle between `core--core--core` with force constant 200 and equilibrium angle 120 degrees
- dihedral between `core--core--core--core` with force constant 200, mutliplicity of 1 and equilibrium angle of 0
- dihedral between `site--core--core--core` with force constant 200, mutliplicity of 1 and equilibrium angle of 0
- dihedral between `site--core--core--site` with force constant 200, mutliplicity of 1 and equilibrium angle of 0
- (normal) harmonic repulsion between `core` and `core` with force constant 80 and interaction distance 2

The __formation of the dimer__ will be done using a [spatial topology reaction](https://readdy.github.io/system.html#spatial-reactions)

of the form 

```python
system.topologies.add_spatial_reaction(
    "attach: CA(site)+CA(site)->CA(site--site) [self=true]", rate=10., radius=0.4)
```

After such a reaction the connectivity looks like `(...)--core--site--site--core--(...)`. In a second step after the reaction we want to get rid of the two `site` particles in the middle. This will be done using a [structural topology reaction](https://readdy.github.io/system.html#structural-reactions) of the following kind (make sure that you understand what happens in these code snippets. Do ask, if you have problems understanding!). The first ingredient is the rate function for the structural reaction, i.e. given a toplogy this function shall return a very high rate, if there is a `site--site` connection, and shall return 0 otherwise

```python
def clean_sites_rate_function(topology):
    edges = topology.get_graph().get_edges()
    vertices = topology.get_graph().get_vertices()

    if len(vertices) > 3:
        for e in edges:
            v1_ref, v2_ref = e[0], e[1]
            v1 = v1_ref.get()
            v2 = v2_ref.get()
            v1_type = topology.particle_type_of_vertex(v1)
            v2_type = topology.particle_type_of_vertex(v2)
            if v1_type == "site" and v2_type == "site":
                return 1e12
    else:
        return 0.
    return 0.
```

The second ingredient is the reaction function, that performs the removing of the two `site` particles, after the rate function has returned a very high rate

```python
def clean_sites_reaction_function(topology):

    recipe = readdy.StructuralReactionRecipe(topology)
    vertices = topology.get_graph().get_vertices()

    def search_configuration():
        # dfs for finding configuration core-site-site-core
        for v1 in vertices:
            if topology.particle_type_of_vertex(v1) == "core":
                for v2_ref in v1.neighbors():
                    v2 = v2_ref.get()
                    if topology.particle_type_of_vertex(v2) == "site":
                        for v3_ref in v2.neighbors():
                            v3 = v3_ref.get()
                            if v3.particle_index != v1.particle_index:
                                if topology.particle_type_of_vertex(v3) == "site":
                                    for v4_ref in v3.neighbors():
                                        v4 = v4_ref.get()
                                        if v4.particle_index != v2.particle_index:
                                            if topology.particle_type_of_vertex(v4) == "core":
                                                return v1.particle_index, v2.particle_index, v3.particle_index, v4.particle_index

    core1_p_idx, site1_p_idx, site2_p_idx, core2_p_idx = search_configuration()

    # find corresponding vertex indices from particle indices
    core1_v_idx = None
    site1_v_idx = None
    site2_v_idx = None
    core2_v_idx = None
    for i, v in enumerate(vertices):
        if v.particle_index == core1_p_idx and core1_v_idx is None:
            core1_v_idx = i
        elif v.particle_index == site1_p_idx and site1_v_idx is None:
            site1_v_idx = i
        elif v.particle_index == site2_p_idx and site2_v_idx is None:
            site2_v_idx = i
        elif v.particle_index == core2_p_idx and core2_v_idx is None:
            core2_v_idx = i
        else:
            pass

    if (core1_v_idx is not None) and (core2_v_idx is not None) and (site1_v_idx is not None) and (
            site2_v_idx is not None):
        recipe.add_edge(core1_v_idx, core2_v_idx)
        recipe.separate_vertex(site1_v_idx)
        recipe.separate_vertex(site2_v_idx)
        recipe.change_particle_type(site1_v_idx, "dummy")
        recipe.change_particle_type(site2_v_idx, "dummy")
    else:
        raise RuntimeError("core-site-site-core wasn't found")

    return recipe
```

Finally add the structural reaction to the system

```python
system.topologies.add_structural_reaction(
    "clean_sites", topology_type="CA", 
    reaction_function=clean_sites_reaction_function,
    rate_function=clean_sites_rate_function,
    raise_if_invalid=True,
    expect_connected=False)
```

__2a)__ Simulate the system described above in a __periodic box__ of size `[25, 25, 25]` for `n_steps=50000` steps with a timestep of 0.005. Initially place 150 `CA` patchy particles uniformly distributed in the box. While simulating, observe the trajectory and topologies with the __same stride__.

```python
sim.record_trajectory(n_steps//2000)
sim.observe.topologies(n_steps//2000)
```

What do you observe in the VMD output? Do particles assemble in the way you expected?

__Hints__:

- You should place the particles such that the `site` particles are already at   their prescribed 120 degree angle and a distance of 1 away from the `core`     particle. Adding one such particle can be done in the following way
  
  ```python
  core = np.array([0., 0., 0.])
  site1 = np.array([0., 0., 1.])
  site2 = np.array([np.sin(np.pi * 60. / 180.), 0., - 1. * np.cos(np.pi * 60. / 180.)])
  
  top = sim.add_topology("CA", ["site", "core", "site"], np.array([site1, core, site2]))
  top.get_graph().add_edge(0, 1)
  top.get_graph().add_edge(1, 2)
  ```
- To distribute the particles uniformly you should add a random translation vector to all positions `core`, `site1` and `site2`.
- If you want to be super cool, you can rotate the patchy particle by a random amount before translating it. Ask google how to generate a random rotation matrix and how to apply it to your vectors `core`, `site1` and `site2`

__2b)__ From your output file and using the topologies and trajectory observable, calculate the _time dependent_ distribution of molecular mass. This means: Given an instance of a topology, the degree of polymerization is the number of connected `core` particles in this topology. For one polymer the molecular mass is equal to the degree of polymerization. Obtain such a value for all topologies in a given timestep and make a histogram of that. Now that histogram only counts the occurrence of how many times a topology with a certain molecular mass shows up. To convert that into a distribution of molecular mass itself, you have to multiply the number of occurrence for each degree of polymerization by the degree of polymerization itself. Repeat this for all observed times to obtain as many histograms as there are timesteps.

__Hints__

- The actual trajectory can be obtained from the trajectory file like so
  
  ```python
  traj_file = readdy.Trajectory(out_file)
  traj = traj_file.read()
  ```
- The particle type (string) of a particle with index `v` at time `t` is
  
  ```python
  traj[t][v].type
  ```
- Construct the histogram for each time using `np.histogram(current_sizes, bins=bin_edges)`, where `current_sizes` is the list of the molecular masses you have obtained, and `bin_edges=np.linspace(1,10,1)`
- For plotting it might come in handy to convert the `bin_edges` to `bin_centers`, by calculating the midpoints for each bin
- Plot the histograms using the following snippet
  
  ```python
  xs = np.array(times) * dt
  ys = bin_centers
  X, Y = np.meshgrid(xs, ys-1)
  Z = all_histograms.transpose()
  plt.pcolor(X, Y, Z, cmap=plt.cm.viridis_r)
  plt.xlabel("Time")
  plt.ylabel("Degree of polymerization")
  plt.title("Distribution of molecular mass")
  ```

__2c)__ Calculate a similar distribution of molecular mass, but now only for _completely assembled_ topologies, i.e. topologies with no open `site` particles left. What is the percentage of "misfolded" topologies?

__2d)__ From looking at your distribution of pentamers, hexamers, and heptamers. Can you form a full capsid out of the patchy particles we have used? Have a look at the introductory image with the viruses, what do you notice about the capsomers?  

__2e) Bonus task__: Introduce a third reactive patch for each patchy particle called `offsite`, which allows binding to other `offsite` particles. In this way try to assemble a larger super structure out of the hexamers.

{% endif %}
