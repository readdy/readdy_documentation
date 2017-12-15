---
title: What is ReaDDy?
sectionName: what_is
position: 1
---

{% include video.html fname="logo" %}

The logo simulation mimicks a predator prey system, i.e., a population growth process that frequently occurs in biology. Sometimes, this growth process is subjected to spatial constraints. There are three different particle types, referring to that biological model:

- Type 1, the red “logo particles“, serve as the spatial barriers. They have been given an attraction potential between them and start in a position that resembles the ReaDDy logo.
- Type 2, the purple “prey“. If there are no predators around, they will replicate.
- Type 3, the grey “predator” particles. They die out if there is no prey but replicate in their presence by consuming them.

It is visible during the time course of the simulation, that the spatial distribution of the particles, their crowding inducing occurrence in masses as well as spatial constraints like barriers influence the growth of the populations dramatically. What is true for this simplified example is ubiquitous not only in molecular and cellular biology but in multiple other fields.

ReaDDy has been designed to fit the modeling requirements of such processes: Particle (or agent) based reaction diffusion systems in which particle-particle interactions play an important role and where the systems are subjected to crowding or spatial constraints.
