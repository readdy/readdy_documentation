---
title: Reactions
sectionName: reactions
position: 1
---

Reactions remove particles from, and add particles to the system. They typically have a microscopic/intrinsic rate $\lambda$.
This rate has units of inverse time and can be understood as the probability per unit time of the reaction occurring. Given an integration
step $\tau$ the probability of a reaction event is evaluated as $p = 1 - e^{-\lambda \tau}$.

Additionally `Fusion` and `Enzymatic` reactions can only occur when particles are closer than a certain distance $R$.

All reactions are added to the reaction registry, which is part of the `ReactionDiffusionSystem`
```python
system = readdy.ReactionDiffusionSystem()
system.reactions.add(...)
```

Each of the below listed reaction types can be registered in two ways: 
- Either with the generic `reactions.add(...)` method which accepts a descriptor string,
- or by calling `reactions.add_xxx(...)`, where `xxx` is to be replaced with one of `conversion`, `decay`, `fusion`, `fission`, or `enzymatic`.

## Conversion

In a conversion reaction, a particle of type $A$ will convert into type $B$ with the rate constant $\lambda$

$$ A \overset{\lambda}{\rightarrow} B $$

Adding a conversion reaction to the `system` amounts to

```python
system.reactions.add_conversion(name="conv", type_from="A", type_to="B", rate=0.1)
```
which is equivalent to
```python
system.reactions.add("conv: A -> B", rate=0.1)
```

## Decay

In a decay reaction, a particle of type $A$ will disappear with the rate constant $\lambda$

$$ A \overset{\lambda}{\rightarrow} \emptyset $$

Example of adding a decay reaction to the `system`:

```python
system.reactions.add_decay(name="decay of A", particle_type="A", rate=0.1)
```
which is equivalent to
```python
system.reactions.add("decay of A: A ->", rate=0.1)
```

## Fusion

In a fusion reaction, a particle of type $A$ will associate with type $B$ to form a particle of type $C$.
This will occur with the rate constant $\lambda$, if the particles $A$ and $B$ are closer than the reaction radius
$R$ (`educt_distance`). 

$$ A \overset{R}{+} B \overset{\lambda}{\rightarrow} C$$

Example of adding a fusion reaction to the `system`:

```python
system.reactions.add("fus: A +(2) B-> C", rate=0.1)
```
which is equivalent to
```python
system.reactions.add_fusion(
    name="fus", type_from1="A", type_from2="B", type_to="C", rate=0.1, educt_distance=2.
)
```

## Fission

In a fission reaction, a particle of type $C$ will dissociate into two particles of type $B$ and $A$.
This will occur with the rate constant $\lambda$. The two products will be placed at a distance smaller than
the reaction radius $R$ (`product_distance`).

$$ C \overset{\lambda}{\rightarrow} A \overset{R}{+} B $$

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

## Enzymatic

In an enzymatic reaction, a particle of type $A$ convert into type $B$ in the presence of a particle of type $C$.
This will occur with the rate constant $\lambda$, if the particles $A$ and $C$ are closer than the reaction radius
$R$ (`educt_distance`).

$$ A \overset{R}{+} C \overset{\lambda}{\rightarrow} B + C$$

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
