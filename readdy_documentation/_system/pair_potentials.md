---
title: Pair potentials
sectionName: pair_potentials
position: 4
subsection: true
---

Pair potentials or second-order potentials are potentials that depend on the relative positioning of a pair of particles to one another. They are registered with respect to two not necessarily distinct particle types and then exert a force on each particle of these types individually.

## Harmonic repulsion

A harmonic repulsion potential causes each two particles of a certain type to repulse each other once they enter a certain radius. It can be used to emulate a radius of a particle type while still allowing for a relatively large time step. The potential term is given by

$$
V(\mathbf{x}_1, \mathbf{x}_2) = \begin{cases}
\frac{1}{2}k(\|\mathbf{x_1} - \mathbf{x_2}\|_2 - r)^2 &\text{, if } \|\mathbf{x_1} - \mathbf{x_2}\|_2 < r,\\
0 &\text{, otherwise,}
\end{cases}
$$

where $r$ is the distance at which particles begin to interact with respect to this potential.

{: .centered}
![](assets/potentials/harmonic_repulsion.png)

Adding such a potential to a system amounts to, e.g.,
```python
system.potentials.add_harmonic_repulsion(
    "A", "A", force_constant=10., interaction_distance=5.
)
system.potentials.add_harmonic_repulsion(
    "B", "B", force_constant=10., interaction_distance=6.
)
system.potentials.add_harmonic_repulsion(
    "A", "B", force_constant=10., interaction_distance=2.5+3.
)
```
which would cause all particles of type `A` or `B` to repulse from all other particles of type `A` or `B`. This set of potentials can be understood as inducing a "soft" radius of $r_A = 2.5$ and $r_B=3$ for particle types `A` and `B`, respectively. Soft meaning that the particles' spheres can be penetrated for a short period of time by another particle before it is pushed out again.

## Weak interaction piecewise harmonic

A weak interaction piecewise harmonic potential causes particles to crowd together once they are within a certain distance of one another. It is defined by three harmonic terms and described by a force constant $k$ which is responsible for the strength of the repulsive part of the potential, a 'desired distance' $d$, i.e., a distance at which the potential energy is lowest inside the interaction radius, a 'depth' $h$, denoting the depth of the potential well and therefore the stickiness of the potential, and a 'cutoff' $r_c$, denoting the distance at which particles begin to interact. The potential term reads

$$
V(\|\mathbf{x}_1- \mathbf{x}_2\|_2) = V(r) = \begin{cases}
\frac{1}{2} k (r - d)^2 - h &\text{, if } r < d,\\
\frac{h}{2} \left(\frac{r_c - d}{2} \right)^{-2} (r - d)^2 - h &\text{, if } d\leq r < d + \frac{r_c - d}{2},\\
-\frac{h}{2}\left(\frac{r_c - d}{2}\right)^{-2}(r - r_c)^2 &\text{, if }d + \frac{r_c - d}{2}\leq r < r_c,\\
0 &\text{, otherwise.}
\end{cases}
$$

It typically has the following shape:

{: .centered}
![](assets/potentials/harmonic_interaction.png)

Adding such a potential to a system can be achieved by calling
```python
system.potentials.add_weak_interaction_piecewise_harmonic(
    "A", "B", force_constant=10., desired_distance=5., depth=2., cutoff=7.
)
```
yielding in this example a potential that lets all particle type pairings interact with one another given they are of type `A` and `B` and closer than the cutoff $r_c=7$. Once they are within range they would either by drawn into the potential well from the outside (third case in the potential term), kept in the potential well (second case in the potential term), or pushed back into the potential well if they come too close to one another (first case in the potential term).

## Lennard-Jones

Description of Lennard-Jones potential

## Screened electrostatics

