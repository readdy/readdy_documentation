---
title: Enzymatic
sectionName: enzymatic
position: 5
---

In an enzymatic reaction, a particle of type $A$ convert into type $B$ in the presence of a particle of type $C$.
This will occur with the rate constant $k$, if the particles $A$ and $C$ are closer than the reaction radius
$R$ (`educt_distance`).

$$ A \overset{R}{+} C \overset{k}{\rightarrow} B + C$$

Add an enzymatic reaction to the `system`
```python
system.reactions.add("enz: A +(2) C -> B + C", rate=0.1)
```
which is equivalent to
```python
system.reactions.add_enzymatic(
    name="enz", type_catalyst="C", type_from="A", type_to="B", rate=0.1, educt_distance=2.
)
```

