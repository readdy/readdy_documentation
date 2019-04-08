---
title: Topology reactions
sectionName: topology_reactions
position: 7
subsection: true
---

Topology reactions provide means to change the structure of a topology during the course of a simulation. Changing the structure can involve: 
- Changing particle types of particles inside topologies and therefore changing the force field, 
- breaking and forming bonds inside a topology resulting in different connectivity or the separation of a topology in separated instances, 
- attaching particles to topologies, 
- connecting two topologies by introducing an edge between their graphs.

These changes are divided into two types: Structural reactions and spatial reactions, where, as the name suggests, structural reactions change the internal structure of a topology and are independent of the actual spatial configuration of the system and spatial reactions represent local changes of the graph triggered by spatial events, i.e., attaching particles or forming bonds between two topology instances. The following sections are ordered accordingly:

* TOC
{:toc}

## Structural reactions
Structural topology reactions are defined on the topology type. They basically consist out of two functions:
* the reaction function, taking a topology object as input and returning a `reaction recipe` describing what the structural changes are to be applied to the topology
* the rate function, which takes a topology object as input and returns a corresponding fixed rate.

The rate function is evaluated initially and then only when the topology has changed due to other reactions. The reaction function is only evaluated when a topology reaction is performed. It should be noted that these function evaluations can have negative performance impacts when occurring frequently.

{: .centered}
![](assets/topologies/topology_fission.png)

The above figure shows an example of a structural topology reaction. In the upper row there are particles $i,j,k,l$ from left to right with a graph that connects the pairs $(i,j)$, $(j,k)$, and $(k,l)$. Due to this adjacency, there are bonds $b_{01}$, $b_{12}$, and $b_{23}$ as well as angles $a_{012}$ and $a_{123}$. 
The lower row represents the configuration after a topology reaction that removed the edge $(k,l)$. In its absence the bond $b_{12}$ and the angle $a_{123}$ are removed and the topology originally consisting out of four particles decays into two topologies - one with three particles and one trivial topology containing just one particle.

### The reaction function
In order to configure such a reaction for a reaction diffusion system, one first needs to set up a function that given a topology returns an instance of `StructuralReactionRecipe`, essentially describing the desired changes in structure:
```python
def no_op_reaction_function(topology):
    recipe = readdy.StructuralReactionRecipe(topology)
    return recipe
```
One can base the behavior of the reaction on the current state of the topology instance. It offers information about the contained particles configuration:
- `topology.get_graph()` yields the connectivity graph of the topology:
  - `graph.get_vertices()` yields a list of vertices that has a 1-1 correspondence to what is yielded by `topology.particles`. Each vertex is itself can again be iterated, yielding its adjacent vertices:
    ```python
    # for every vertex
    for v in graph.get_vertices():
        print("vertex {}".format(v.particle_index))
        # obtain number of its neighbors' neighbors
        n_neighbors_neighbors = 0
        for neighbor in v:
            for neighbor_neighbor in neighbor.get():
                n_neighbors_neighbors += 1
    ```
  - `graph.get_edges()` yields a list of edges contained in the graph, where each edge is represented by a tuple of vertex-references, that can be dereferenced by a call to `get()`:
    ```python
    for e in graph.get_edges():
        v1_ref, v2_ref = e[0], e[1]
        v1 = v1_ref.get()
        v2 = v2_ref.get()
        print("edge {} -- {}".format(v1.particle_index, v2.particle_index))
    ```
- `topology.position_of_vertex(v)` yields the position of the particle corresponding to the provided vertex (or vertex pointer, so a call to `.get()` is not required),
- `topology.particle_type_of_vertex(v)` yields the type of the particle corresponding to the provided vertex (or vertex pointer, so a call to `.get()` is not required),
- `particle_id_of_vertex` yields the unique id of the particle corresponding to the provided vertex (or vertex pointer, so a call to `.get()` is not required).

With these information, there are several operations that can be added to a recipe:
- `recipe.change_particle_type(vertex_index, type)`: Changes the particle type of the to `vertex_index` associated particle to the given type, where the vertex index corresponds to the particle's index.
- `recipe.add_edge(v_index1, v_index2):` Introduces an edge in the graph between vertices corresponding to indices `v_index1` and `v_index2`.
- `recipe.remove_edge(v_index1, v_index2)`: Attempts to remove an edge between vertices corresponding to the indices. Depending on the configuration of the topology reaction, this can lead to a failed state or multiple sub-topologies.
- `recipe.remove_edge(edge):` Same as with indices just that it takes an edge instance as contained in `graph.get_edges()`.
- `recipe.separate_vertex(index)`: Removes all edges from the topology's graph that contain the vertex corresponding to the provided index. If no new edge is formed between the given vertex this call, depending on the configuration of the reaction, can lead to a failed state or to formation of a topology consisting out of only one particle. In the latter case, this call can be followed by a call to `recipe.change_particle_type`, where the target type is no topology type. Then, no one-particle topology will be formed but the particle will simply be emitted and treated as normal particle.
- `recipe.change_topology_type(type):` Changes the type of the topology to the given type, potentially changing its structural and spatial topology reactions.

### The rate function
Same as ordinary reactions, also structural topology reactions have a rate with which they occur. This rate is microscopic, has units of inverse time and can be understood as the probability per unit time of the reaction taking place. Same as for normal reactions, the probability is evaluated as $p=1-e^{-\lambda\tau}$, where $\lambda\geq0$ is the rate and $\tau$ the integration time step.

In order to define a rate for a certain structural reaction, one needs to provide a rate function:
```python
def my_rate_function(topology):
    n = len(topology.get_graph().get_vertices())
    if n > 3:
      return .5 * n
    else:
      return 20.
```
The function takes a topology instance as argument and returns a floating point value representing the rate in terms of the magnitude w.r.t. the default units. In this example it returns half the number of vertices if the number of vertices is larger than three, otherwise a constant value of 20.

For performance reasons it is only evaluated if the topology changes structurally, therefore the rate should optimally not depend on anything that can change a lot in the simulation time between evaluating the rate function and performing the reaction, e.g., the particles' spatial configuration.

### Adding a structural reaction
Given these two functions, the reaction and the rate function, all that is left to do is to add them to a certain topology type in the system:
```python
system.topologies.add_structural_reaction(
    topology_type="TType", 
    reaction_function=no_op_reaction_function, 
    rate_function=my_rate_function, 
    raise_if_invalid=True, expect_connected=False
)
```
adding a structural reaction to all topologies of type `TType` with the provided reaction and rate functions. The first option `raise_if_invalid` raises, if set to `True`, an error if the outcome of the reaction function is invalid, otherwise it will just roll back to the state of before the reaction and print a warning into the log. The second option `expect_connected` can trigger depending on the value of `raise_if_invalid` a raise if set to `True` and the topology's connectivity graph decayed into two or more independent components.

## Spatial reactions
Spatial reactions are locally triggered by proximity of particles, therefore they are not only defined on topology types but also on particle types. In principle there are two kinds of spatial reactions: The kind that causes forming a bond between two particles and the kind that just changes a particle/topology type, corresponding to particle fusion and enzymatic reactions, respectively. Analogously spatial topology reactions also possess 
- a rate determining how likely the reaction occurs per time step as well as 
- a radius determining the volume which is scanned for potential reaction partners.

To simplify the definition of these reactions a descriptor language is used, deciding about the nature of the reaction. It consists out of a label and a topology-particle-type reaction equation:

$$
\begin{aligned}
  \mathrm{label\_enzymatic: }& T_1(P_1)+T_2(P_2)\rightarrow T_3(P_3) + T_4(P_4)\\
  \mathrm{label\_fusion: } & T_1(P_1)+T_2(P_2)\rightarrow T_3(P_3\mathrm{--}P_4)
\end{aligned}
$$

where $T_i$ denote topology types, $P_i$ denote particle types. 
- The first reaction is of "enzymatic" type, changing the types of particles corresponding to $P_1$ to $P_3$ and $P_2$ to $P_4$ if they are contained in topologies of type $T_1$ and $T_2$ which are also changed to $T_3$ and $T_4$, respectively.
- The second reaction is of "fusion" type, merging two topologies of types $T_1$ and $T_2$ by forming a bond between a particle pair with types $P_1$ and $P_2$ in their respective topologies. The result is a topology of type $T_3$ and the particles between which the bond was formed are of types $P_3$ and $P_4$.

Some of these reactions can also be performed with a topology and a free particle. In particular, the following types of reactions are possible:

- `TT-Fusion: T1(p1)+T2(p2) -> T3(p3--p4)`: a fusion of a topology of type `T1` with a topology of type `T2` by forming a bond between a pair of particles with types `p1` and `p2`, where the product is a topology of type `T3` and the newly connected particles changed their types to `p3` and `p4`, respectively.
- `TT-Fusion-self: T1(p1)+T1(p2) -> T3(p3--p4) [self=true]`: a fusion of two topologies of type `T1` similarly to the first type with the difference that now also particles within the same topology can be reaction partners.
- `TP-Fusion: T1(p1)+(p2) -> T2(p3--p4)`: attaching a free particle of type `p2` to a topology of type `T1` if it is close to a particle of type `p1` in that topology, yielding a topology of type `T2` in which the newly connected particles are now of type `p3` and `p4`, respectively.
- `TT-Enzymatic: T1(p1)+T2(p2) -> T3(p3)+T4(p4)`: not changing the structure of the graph of the reaction partners but changing particle types possibly locally influencing the force field and changing topology types possibly leading to different topology reactions.
- `TP-Enzymatic: T1(p1)+(p2) -> T2(p3)+(p4)`: same as the `TT-Enzymatic` reaction just that here it is performed with one topology and one free particle.

Adding such a reaction to a system amounts to, e.g.,
```python
system.topologies.add_spatial_reaction(
  'TT-Fusion: T1(p1)+T2(p2) -> T3(p3--p4)', rate=1., radius=1.
)
```
where the rate is in units of `1/time` and the radius is a length. The descriptor is always the first argument and can be of any of the above discussed types.

It should be noted that while usually "normal" [particle-particle reactions]({{site.baseurl}}/reactions.html) are not possible with topology-typed particles, one can define enzymatic reactions where the catalyst is a topology type as this leaves the topology untouched and therefore can be evaluated in the normal reaction procedure.

```python
system.add_species("A", diffusion_constant=1.)
system.add_species("B", diffusion_constant=1.)
system.add_topology_species("P", diffusion_constant=.5)
system.topologies.add_type("T")

# OK, this attaches the particle A to the topology
system.topologies.add_spatial_reaction('label1: T1(P)+(A)->T1(P--P)')
# Fails, A is not a topology species type
system.topologies.add_spatial_reaction('label1: T1(P)+(A)->T1(P--A)')
# Fails, P is not a normal particle type
system.topologies.add_spatial_reaction('label1: T1(P)+(P)->T1(P--P)')
# OK, this is a normal fusion reaction
system.reactions.add('A +(2.) A -> A', rate=.1)
# Fails, P is not a normal particle type but a topology particle type
system.reactions.add('A +(2.) P -> A', rate=.2)
# OK, this is the special case where P is the catalyst
system.reactions.add('A +(2.) P -> B + P', rate=.3)
```

## Predefined reactions

For convenience there are predefined topology reactions that can be added to a certain topology type.

### Topology dissociation

This reaction causes a topology to break bonds with a rate of `n_edges*bond_breaking_rate`, causing it to dissociate. In this process it may decompose into multiple independent components of the same topology type. Consequently, each of these independent components again has a topology dissociation reaction.

Adding such a reaction to a system amounts to
```python
system.topologies.add_type("T")
system.topologies.add_topology_dissociation("T", bond_breaking_rate=10.)
```
