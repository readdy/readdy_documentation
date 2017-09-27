---
title: Fission
sectionName: fission
position: 4
---

In a fission reaction, a particle of type $C$ will dissociate into two particles of type $B$ and $A$.
This will occur with the rate constant $k$. The two products will be placed at a distance smaller than
the reaction radius $R$ (`product_distance`).

$$ C \overset{k}{\rightarrow} A \overset{R}{+} B $$

Add a fission reaction to the `system`

```python
system.reactions.add("fis: C -> A +(2) B", rate=0.1)
```
which is equivalent to
```python
system.reactions.add_fission(
    name="fis", type_from="C", type_to1="A", type_to2="B", rate=0.1, product_distance=2.
)
```

