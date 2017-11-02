---
title: Conversion
sectionName: conversion
position: 1
---
In a conversion reaction, a particle of type $A$ will convert into type $B$ with the rate constant $k$

$$ A \overset{k}{\rightarrow} B $$

Adding a conversion reaction to the `system` amounts to

```python
system.reactions.add_conversion(name="conv", type_from="A", type_to="B", rate=0.1)
```
which is equivalent to
```python
system.reactions.add("conv: A -> B", rate=0.1)
```
