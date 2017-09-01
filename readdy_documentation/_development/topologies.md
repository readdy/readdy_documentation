---
title: Topologies
sectionName: topologies
position: 3
---

A topology is a collection of particles, whose unique ids are stored in a `std::vector`. These particles are subject to bond-, angle- and dihedral-potentials. For a pair (or triple or quadruple) of particles to have a potential term, they have to be connected. The connection is defined by a graph, which is a linked list of vertices. Each vertex represents one particle in the topology and contains references to other vertices. The actual potential terms are yielded by a lookup table on pairs/triples/quadruples of particle types. All potentials holding the topology together are thus obtained from both the `Graph` and the `PotentialConfiguration`. 

## Internal structure of topologies

__Topology__ contains global particle indices and potential terms between them, referencing to local indices w.r.t. the global-particle-index-vector

__GraphTopology__ is a derived class of __Topology__ and has the following properties
  - has a topology type which currently defines the possible structural reactions
  - contains a graph consisting out of vertices that have a one-to-one correspondence  to particle indices in the respective topology:
    - the data structure for the vertices is a linked list, hence iterators can be used as vertex references and a tuple of vertex references denotes an edge in the graph
    - a topology graph needs to be connected upon simulation start
  - has `PotentialConfiguration` that contains particle-type pairs/triples/quadruples definitions for bonds/angles/torsion-potentials, respectively
  - the graph's connectivity together with the potential configuration gives the actual potential terms of the topology
  - topology needs to be connected w.r.t. bonds as yielded by graph+potential config upon simulation start
  - contains a vector of rates for structural reactions as registered for the topology type

## Potential terms
Potential terms hold the topology together.
They are configured in the `readdy::api::PotentialConfiguration`. This kernel-unique object holds three maps:
- `pairPotentials`: mapping `(type1, type2) -> bonds`
- `anglePotentials`: mapping `(type1, type2, type3) -> angles`
- `torsionPotentials`: mapping `(type1, type2, type3, type4) -> torsion angles`.

These maps apply a hashing and equality operator that allows for asking for the reverse key, e.g., `(type1, type2, type3)` and `(type3, type2, type1)` should yield the same value.

## Topology reactions
There are __structurally-dependent__ and __spatially-dependent__  reactions:

Structural means that the reaction recipe as well as its rate only depend on the topology's graph, no dependence on other particles or other topologies is possible. 
Spatial means that the reaction is occurring between two particles due to their spatial proximity. At least one of the particles must belong to a topology.

- __structural__ reactions are defined on the topology-type. They require a rate-function and a reaction-function. With structural reactions one can realize
  - Conversion of a topology, just a change of the graph
  - Fission, change of the graph but ending up with disconnected components. Think of a linear polymer that breaks apart in the middle
  - Special case: Fission of a topology that yields components which consist of only one particle with the flavor "NORMAL". Here, the topology will be erased and the particle will be treated normally.
- __spatial__ reactions are between two particle-types of which at least one has topology flavor with a certain topology-type
  - TopologyParticleReaction `TP`, association of a normal particle and a topology particle, the normal particle becomes a topology flavor and joins the list of particles and an edge in the graph is established.
  - TopologyTopologyReaction `TT`, association of two particles that already belong to a topology of a certain type, if these two are different topologies, their lists of particles and graphs are merged, and an edge is established between the given vertices. The type of the merged topology is determined by the reaction

All topology reactions are stored in the `TopologyRegistry`

## Structural topology reactions detail
A structural reaction may change the connectivity of the topologies' graph and may also change the types of the vertices, i.e. change the particle-type of a particle.
### Rate function 
A rate function has the signature `scalar(const GraphTopology&)` and is supposed to yield a rate depending on the current state of the topology. This rate is assumed to be constant as long as the topology keeps its type and its graph does not change. 
### Reaction function
A reaction function has the signature `reaction_recipe(GraphTopology&)` and is supposed to yield a reaction recipe that is a set of operations which will then be applied to the topology by the selected computing kernel. Available operations are:
- `addEdge(vertex1, vertex2)`: introduce an edge between two vertices
- `removeEdge(vertex1, vertex2)`: remove an edge between two vertices
- `separateVertex(vertex)`: remove all edges going from or to the given vertex
- `changeParticleType(vertex, newType)`: change the type of the particle corresponding to the given vertex
- `changeTopologyType(newType)`: change the topology's type

## Spatial topology reactions detail
Spatial reactions are defined on both particle types and topology types, before and after the reaction.
Additionally spatial reactions differ in behavior with respect to merging the topologies or not. Analogue to fusion-like or enzymatic-like reactions.

### Particle- and topology-types before and after the reaction
To simplify the definition of TP and TT reactions, one can use a describing string such as:

$$
\text{label: } T_1 (P_1) + T_2 (P_2)\to T_3(P_3) + T_4(P_4), 
$$

where $T_i$ and $P_i$ denote topology- and particle-types, respectively. The above example would be for an enzymatic TT reaction. In case of an enzymatic TP reaction, one can omit $T_2$ and $T_4$. In case one would like to perform a fusion reaction, the notation is

$$
\text{label: } T_1 (P_1) + T_2 (P_2)\to T_3(P_3\text{--}P_4), 
$$

where again $T_2$ can be omitted if a TP reaction is wanted.

In the special case of a TT-Fusion, one can additionally specify `[self=true]` at the end of the describing string to indicate that the topology may also form bonds with its own particles.

Examples:
- `TT-Fusion: T1 (p1) + T2 (p2) -> T3 (p3--p4) [self=true]`
- `TT-Fusion2: T1 (p1) + T2 (p2) -> T3 (p3--p4)`, where `self=false` is used as default
- `TT-Enzymatic: T1 (p1) + T2 (p2) -> T3 (p3) + T4 (p4)`
- `TP-Fusion: T1 (p1) + (p2) -> T2 (p3--p4)`
- `TP-Enzymatic: T1 (p1) + (p2) -> T3 (p3) + (p4)`

### Spatial reaction mode
The behavior of a reaction is summarized internally by an enum `SpatialTopologyReactionMode`, which is extracted from the user's descriptor string:

| SpatialTopologyReactionMode | meaning                                                                                                                                          |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------|
| `TT_ENZYMATIC`              | reaction between two topologies, no edge is created                                                                                              |
| `TT_FUSION`                 | reaction between two topologies, edge can only be established between particles of different topology instances                                  |
| `TT_FUSION_ALLOW_SELF`      | reaction between two topologies, edge can be established between particles of different instances and even within the same instance of a topology|
| `TP_ENZYMATIC`              | reaction between topology and particle changing types but not establishing a bond                                                                |
| `TP_FUSION`                 | reaction between topology and particle introducing a bond and possibly changing types                                                            |

__Use cases:__

| problem | STRMode |
| ------- | -------- |
| Linear polymers with two end-particles each. Polymers can fuse together at the ends, but not with themselves        | SpatialTopologyReaction with `STRMode==TT_FUSION`         |
| A complex/topology has an active site, that switches its type when a ligand/normal particle is close       | SpatialTopologyReaction with `STRMode==TP_ENZYMATIC`        |

