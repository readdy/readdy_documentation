---
title: Simulation schemes
sectionName: simulationschemes
position: 2
---

The system can be propagated in time in different ways, we call them _Schemes_. When you run your simulation 
using

```python
simulation.configure_and_run(time_step, number_steps)
```
you are using the default _ReaDDyScheme_.