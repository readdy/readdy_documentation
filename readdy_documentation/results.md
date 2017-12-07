---
layout: page
title: Post-processing
---

Once you have simulated the system, you can analyze the observables that were recorded.

# Visual representation of the trajectory

To look at the time-series of the position of particles, you can use [VMD](http://www.ks.uiuc.edu/Research/vmd/).
Therefore we provide a function to convert the trajectory into a VMD-readable `xyz` file. 
```python
trajectory = readdy.Trajectory('out.h5')
trajectory.convert_to_xyz(particle_radii={'A': 1.})
```

In shell you can then call `vmd` as follows
```bash
vmd -e out.xyz.tcl
```
