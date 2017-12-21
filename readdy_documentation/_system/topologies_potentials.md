---
title: Potentials
sectionName: topology_potentials
position: 6
subsection: true
---

Topologies are defined by a set of particles that are connected with a graph and a lookup table that defines what connectivities between what particle types yield which potentials.
This section deals with the latter, i.e., with the lookup table. The lookup table is independent of the topology type, so all potentials that are defined here will be applied to pairs/triples/quadruples of particles which are connected in the respective topologies connectivity graph.

{: .centered}
![](assets/topologies/topology_graph.png)

In this picture the dashed lines denote the connectivity graph between the particles, the blue lines bond potentials, the green lines angle potentials, and the orange lines dihedral potentials. One can see that bonds are defined on pairs of particles, angles on triples, dihedrals on quadruples. In this particular case one has

| Bonds                | Angles                                | Dihedrals                                               |
| -------------------- | ------------------------------------- | ------------------------------------------------------- |
| $A\leftrightarrow A$ | $C\leftrightarrow B\leftrightarrow A$ | $A\leftrightarrow A\leftrightarrow B \leftrightarrow A$ |
| $A\leftrightarrow B$ |                                       |                                                         |
| $A\leftrightarrow C$ |                                       |                                                         |

In an actual instance of a topology one would also have to define a bond between particles of type $C\leftrightarrow C$ or remove that edge from the graph, otherwise it would not be considered valid.

ReaDDy supports three types of potentials within topologies:

* TOC
{:toc}

## Harmonic bonds

{: .centered}
![](assets/topologies/top_bond.png)

Harmonic bonds model, e.g., covalent bonds in a molecular structure. The potential term yields forces that push pairs of particles away from one another if they become closer than a certain distance and attracts them if they are further apart than that distance. It reads

$$
V(\|\mathbf{x}_1-\mathbf{x}_2\|_2) = V(r) = k(r-r_0)^2,
$$

where $r_0$ is the preferred distance and $k$ the force constant.

Adding such a potential term to a system amounts to, e.g.,
```python
system.add_topology_species("T1", diffusion_constant=2.)
system.add_topology_species("T2", diffusion_constant=4.)
system.topologies.configure_harmonic_bond(
    "T1", "T2", force_constant=10., length=2.
)
```
which would have the effect of introducing for each topology a harmonic bond with force constant 10 and preferred distance 2 between each adjacent pair of particles with types "T1" and "T2", respectively.

## Harmonic angles

Harmonic angles are potential terms that yield a preferred configuration for a triple of particles in terms of the spanned angle $\theta$.

{: .centered}
![](assets/topologies/top_angle.png)



## Cosine dihedrals

{: .centered}
![](assets/topologies/top_dihedral.png)
