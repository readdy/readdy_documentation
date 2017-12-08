---
title: External potentials
sectionName: external_potentials
position: 3
subsection: true
---

External potentials or first-order potentials are potentials that solely depend on the absolute position of each particle, i.e., the relative positioning of particles towards one another has no influence.
They are registered with respect to a certain particle type. The potential will
then exert a force on each particle of that type individually.

## Box

{: .centered}
![](assets/potentials/box_potential.png)

A box potential is a potential acting with a harmonic force on particles of the given type once they leave the area spanned by the cuboid that has `origin` as its front lower left and `origin+extent` as its back upper right vertex, respectively. Therefore, the cuboid is spanned by three intervals $C=\prod_{i=1}^dC_i$ with $C_i := [\text{origin}_i, \text{origin}_i+\text{extent}_i]$. Its energy term is given by

$$
V(\mathbf{x}) = \sum_{i=1}^d \begin{cases} 0&\text{, if } x_i \in C_i\\
 \frac{1}{2}k \,d(x_i, C_i)^2  &\text{, otherwise,} \end{cases}
$$

where $d(x_i, C_i)$ denotes the shortest distance between the set $C_i$ and the point $x_i$.

Adding a box potential to the `system` amounts to:
```python
system.box_size=[3, 3, 3]
system.potentials.add_box(
    particle_type="A", force_constant=10., origin=[-1, -1, -1], extent=[2, 2, 2]
)
```
Note that the __simulation box__ and the __box potential__ are completely independent.
In the above example the simulation box is chosen larger than the full extent of the box potential. This is because
particles should never leave the simulation box if it is non-periodic. The box potential however is a soft potential,
i.e., particles may penetrate the boundaries of it for a short time and then be pushed back inside. To make sure that
particles do not penetrate the simulation box, it has a slightly larger extent.

In particular there is a check upon simulation start that if the simulation box is not completely periodic, there must be a box potential for each particle type to keep it contained in the non-periodic directions, i.e., if there is no box potential such that
```
box_lower_left[dim] < potential_lower_left[dim] 
  and box_upper_right[dim] > potential_upper_right[dim]
```
where `dim` is a non-periodic direction, an error is raised.


## Spherical potential

{: .centered}
![](assets/potentials/sphere_potential.png)

In ReaDDy one can find three different types of spherical potentials:
- exclusion potentials to keep particles out of a spherical region,
- inclusion potentials to keep particles inside a spherical region,
- barriers that can function as a spatial separator or, if initialized with negative height, as a sticky spherical surface.

All these potentials are harmonic, i.e., particles can potentially penetrate.

### Spherical exclusion (`sphere_out`)

Adds a spherical potential that keeps particles of a certain type excluded from the inside of the specified sphere. Its energy term is given by 

$$
V(\mathbf{x}) = \begin{cases}
\frac{1}{2} k (\|\mathbf{x} - \mathbf{c}\|_2-r)^2 &\text{, if } \|\mathbf{x} - \mathbf{c}\|_2 < r,\\
0 &\text{, otherwise,} 
\end{cases}
$$

where $\mathbf{c}\in\mathbb{R}^3$ denotes the center of the sphere and $r\in\mathbb{R}_{>0}$ the radius of the sphere. 

{: .centered}
![](assets/potentials/sphere_out.png)

Adding such a potential to a reaction diffusion system amounts to
```python
system.box_size = [3, 3, 3]
system.potentials.add_sphere_out(
    particle_type="A", force_constant=10., origin=[0, 0, 0], radius=1.
)
```
yielding a spherical region of radius `1` in the center of the simulation box which keeps particles of type `A` from entering that region with a harmonic repulsion potential. Due to the harmonic nature of the potential and dependent on the force constant, particles are allowed to penetrate the sphere for a short period of time.

### Spherical inclusion (`sphere_in`)

Adds a spherical potential that keeps particles of a certain type restrained to the inside of the specified sphere. Its energy term is given by

$$
V(\mathbf{x}) = \begin{cases}
\frac{1}{2} k (\|\mathbf{x} - \mathbf{c}\|_2-r)^2 &\text{, if } \|\mathbf{x} - \mathbf{c}\|_2 \geq r,\\
0 &\text{, otherwise,} 
\end{cases}
$$

where $\mathbf{c}\in\mathbb{R}^3$ denotes the center of the sphere and $r\in\mathbb{R}_{>0}$ the radius of the sphere. 

{: .centered}
![](assets/potentials/sphere_in.png)

Adding such a potential to a system amounts to
```python
system.box_size = [3, 3, 3]
system.potentials.add_sphere_in(
    particle_type="A", force_constant=10., origin=[0, 0, 0], radius=1.
)
```
which will cause all particles of type `A` to be contained in a sphere of radius `1` centered in the origin with a harmonic repulsion potential. Due to the harmonic nature of the potential and dependent on the force constant, particles are allowed to penetrate the sphere for a short period of time.

### Spherical barrier (`spherical_barrier`)

A potential that forms a concentric barrier at a certain radius around a given origin. It is given a height (in terms of energy) and a width. Note that the height can also be negative, then this potential acts as a  'sticky' sphere. The potential consists of harmonic snippets, such that the energy landscape is continuous and differentiable, the force is only continuous and not differentiable. Its energy term is given by

$$
V(\mathbf{x}) = \begin{cases}
0 & \text{, if } \| \mathbf{x} - \mathbf{c}\|_2 < r - w,\\
\frac{2h}{w^2}(\| \mathbf{x} - \mathbf{c}\|_2 - r + w)^2 &\text{, if } r-w \leq \| \mathbf{x} - \mathbf{c}\|_2 < r - \frac{w}{2},\\
h - \frac{2h}{w^2}(\| \mathbf{x} - \mathbf{c}\|_2 - r)^2 &\text{, if }r - \frac{w}{2} \leq \| \mathbf{x} - \mathbf{c}\|_2 < r + \frac{w}{2},\\
\frac{2h}{w^2}(\| \mathbf{x} - \mathbf{c}\|_2 - r - w)^2 &\text{, if } r + \frac{w}{2} \leq \| \mathbf{x} - \mathbf{c}\|_2 < r + w,\\
0 &\text{, otherwise,}
\end{cases}
$$

where $\mathbf{c}\in\mathbb{R}^3$ is the center of the sphere, $r\in\mathbb{R}$ the sphere's radius, $w\in\mathbb{R}$ the width of the barrier, and $h\in\mathbb{R}$ the height of the barrier. 

{: .centered}
![](assets/potentials/spherical_barrier_potential.png)

Adding such a potential to a system amounts to
```python
system.box_size = [3, 3, 3]
# as a barrier
system.potentials.add_spherical_barrier(
    particle_type="A", height=1.0, width=0.1, origin=[0, 0, 0], radius=1.
)
# sticky
system.potentials.add_spherical_barrier(
    particle_type="A", height=-1.0, width=0.1, origin=[0, 0, 0], radius=1.
)
```
which will cause particles to be trapped inside or outside of the spherical barrier in the first case or will make them stick onto the surface of the sphere in the second case.
