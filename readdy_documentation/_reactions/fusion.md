---
title: Fusion
sectionName: fusion
position: 3
---

In a fusion reaction, a particle of type $A$ will associate with type $B$ to form a particle of type $C$.
This will occur with the rate constant $k$, if the particles $A$ and $B$ are closer than the reaction radius
$R$ (`educt_distance`). 

$$ A \overset{R}{+} B \overset{k}{\rightarrow} C$$

Add a fusion reaction to the `system`

```python
system.reactions.add("fus: A +(2) B-> C", rate=0.1)
```
which is equivalent to
```python
system.reactions.add_fusion(
    name="fus", type_from1="A", type_from2="B", type_to="C", rate=0.1, educt_distance=2.
)
```

