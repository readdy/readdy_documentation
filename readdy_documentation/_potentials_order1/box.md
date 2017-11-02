---
title: Box
sectionName: box
position: 1
---

{: .centered}
![](assets/box_potential.gif)

A box potential acting with a harmonic force on particles of the given type once they leave the area
spanned by the cuboid that has `origin` as its front lower left and `origin+extent` as its back upper right
vertex, respectively.

Add a box potential to the `system`, centered with respect to the simulation box:
```python
system.box_size = [3, 3, 3] # sets the size of the simulation box
system.potentials.add_box(
    particle_type="A", force_constant=10., origin=[-1, -1, -1], extent=[2, 2, 2]
) # sets the size and parameters of the box potential
```
Note that the __simulation box__ and the __box potential__ are completely independent.
In the above example the simulation box is chosen larger than the full extent of the box potential. This is because
particles should never leave the simulation box, if it is non-periodic. The box potential however is a soft potential,
i.e. particles may penetrate the boundaries of it for a short time and then be pushed back inside. To make sure that
particles do not penetrate the simulation box, it has a slightly larger extent.
