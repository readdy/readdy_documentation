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

These changes are divided into two types: Structural reactions and spatial reactions, where, as the name suggests, structural reactions change the internal structure of a topology and are independent of the actual spatial configuration of the system and spatial reactions represent local changes of the graph triggered by spatial events, i.e., attaching particles or forming bonds between two topology instances.

## Structural reactions
Structural topology reactions are defined on the topology type. They basically consist out of two functions:
* the reaction function, taking a topology object as input and returning a `reaction recipe` describing what the structural changes are to be applied to the topology
* the rate function, which takes a topology object as input and returns a corresponding fixed rate.

The rate function is evaluated initially and then only when the topology has changed due to other reactions. The reaction function is only evaluated when a topology reaction is performed. It should be noted that these function evaluations can have serious performance impacts when occurring frequently.

## Spatial reactions 