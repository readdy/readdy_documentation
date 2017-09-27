---
title: Decay
sectionName: decay
position: 2
---
In a decay reaction, a particle of type $A$ will disappear with the rate constant $k$

$$ A \overset{k}{\rightarrow} \emptyset $$

Add a decay reaction to the `system`

```python
system.reactions.add_decay(name="decay of A", particle_type="A", rate=0.1)
```
which is equivalent to
```python
system.reactions.add("decay of A: A ->", rate=0.1)
```