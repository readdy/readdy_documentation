---
title: Pair potentials
sectionName: pair_potentials
position: 4
subsection: true
---

Pair potentials or second-order potentials are potentials that depend on the relative positioning of a pair of particles to one another. They are registered with respect to two not necessarily distinct particle types and then exert a force on each particle of these types individually.

Currently available pair potentials are:
* TOC
{:toc}

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

Similarly to a [weak interaction](#weak-interaction-piecewise-harmonic) potential, the Lennard-Jones potential models the interaction between a pair of particles. However it is not a soft potential and therefore requires a relatively small time step in order to function correctly. The potential term reads

$$
V_\text{LJ}(\|\mathbf{x_1}-\mathbf{x_2}\|_2) = V_\text{LJ}(r) = k(\varepsilon, n, m)\left[ \left(\frac{\sigma}{r}\right)^m - \left(\frac{\sigma}{r}\right)^n \right],
$$

where $k(\varepsilon, n, m)\in\mathbb{R}$ is the force constant, $\sigma\in\mathbb{R}$ the distance at which the inter-particle potential is zero, $\varepsilon\in\mathbb{R}$ the depth of the potential well, i.e., $V_\text{LJ}(r_\text{min})=-\varepsilon$, and $m,n\in\mathbb{N}, m>n$ exponents which determine the stiffness and range of the potential. For the classical Lennard-Jones potential the exponents are given by $m=12$ and $n=6$.
The potential itself approaches but never reaches zero beyond the interaction well. Therefore, a cutoff is introduced, usually at $r_c=2.5\sigma$ (for the 12-6 LJ potential), which is the point at which the potential as roughly $1/60$th of its minimal value $-\varepsilon$. This however leads to a jump discontinuity at $r_c$ in the energy landscape, which can be avoided by shifting the potential by the value at the discontinuity:

$$
V_{\text{LJ}_\text{trunc}}(r) = \begin{cases} V_\text{LJ}(r)  - V_\text{LJ}(r_c) &\text{, if } r \leq r_c,\\ 0&\text{, otherwise.} \end{cases}
$$

The force constant $k$ is chosen such that the depth at the well is is $V(r_\mathrm{min}) = -\varepsilon$, i.e.,

$$
k = -\frac{\varepsilon}{\left( \frac{\sigma}{r_\mathrm{min}} \right)^m - \left( \frac{\sigma}{r_\mathrm{min}} \right)^n}.
$$

{: .centered}
![](assets/potentials/lennard_jones_12_6.png)

Different choices of exponents that can be found in the literature are, e.g., $9-3$, $9-6$, or  $8-6$.

{: .centered}
![](assets/potentials/lennard_jones.png)

Adding such a potential to a system can be achieved by calling
```python
system.potentials.add_lennard_jones(
    "A", "B", m=12, n=6, cutoff=2.5, shift=True, epsilon=1.0, sigma=1.0)
)
```
yielding a truncated 12-6 Lennard-Jones potential between particles of type A and B with a zero inter-particle potential at $\sigma=2.5$, a well depth of $\varepsilon=1.0$, and a cutoff radius of $r_c=2.5 = 2.5\cdot\sigma$. If the shift in the energy landscape to avoid the jump discontinuity is not desired, it can be switched off by setting `shift=False`.

## Screened electrostatics

The "screened electrostatics" (also: Yukawa or Debye-Hückel) potential is a potential that represents electrostatic interaction (both repulsive or attractive), which is screened with a certain screening depth. This kind of potential becomes important when dealing with particles representing proteins that have a net-charge. However, it is usually more expensive to evaluate than, e.g., [harmonic repulsion](#harmonic-repulsion), as it requires a larger cutoff and smaller time step. If the electrostatic term is attractive, a core repulsion term is added. The potential term reads

$$
V(\|\mathbf{x_1}-\mathbf{x_2}\|_2) = V(r) = \begin{cases}
C\frac{\exp(-\kappa r)}{r} + D\left( \frac{\sigma}{r} \right)^n &\text{, if } r \leq r_c,\\
0 &\text{, otherwise,}
\end{cases}
$$

where $C\in\mathbb{R}$ is the electrostatic repulsion strength in units of energy times distance, $\kappa\in\mathbb{R}$ is the inverse screening depth in units of 1/length, $D\in\mathbb{R}$ is the repulsion strength in units of energy, $\sigma\in\mathbb{R}$ is the core repulsion radius or zero-interaction radius in units of length, $n\in\mathbb{N}$ is the core repulsion exponent (dimensionless), and $r_c\in\mathbb{R}$ the cutoff radius in units of length. It typically has the following shape:

{: .centered}
![](assets/potentials/screened_electrostatic.png)

One can observe that the first term in the potential's definition diverges towards $-\infty$ for $r\searrow 0$ which is an effect that gets countered by the second term, diverging towards $+\infty$ for $r\searrow 0$. The depth of the potential well increases with an increasing exponent $n$.

Adding such a potential to a system amounts to
```python
system.potentials.add_screened_electrostatics(
    "A", "B", electrostatic_strength=-1., inverse_screening_depth=1.,
    repulsion_strength=1., repulsion_distance=1., exponent=6, cutoff=6.
)
```
which would introduce an electrostatic interaction between particles of type A and B that resembles the above plot.
