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