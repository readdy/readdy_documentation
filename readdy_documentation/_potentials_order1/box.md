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

Add a box potential to the `system`
```python
system.potentials.add()
```