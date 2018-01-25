---
title: Running the simulation
sectionName: simulation_run
position: 3
---

Per default, the simulation loop looks like below

{: .centered}
![](assets/architecture/simulation_loop_1000px.png)

This means that all observables are evaluated at the initial state regardless of their `stride`, after which
the actual loop is performed. One can influence portions of the loop through the `simulation` object:

- Per default a progress bar is shown when the simulation is executed, however it can be hidden
  ```python
  print(simulation.show_progress)
  simulation.show_progress = False
  ```
- If one does not want to evaluate topology reactions at all, one can invoke
  ```python
  simulation.evaluate_topology_reactions = False
  ```
- Evaluation of forces can be deactivated by invoking
  ```python
  simulation.evaluate_forces=False
  ```
- Evaluation of observables can be switched off altogether by
  ```python
  simulation.evaluate_observables=False
  ```
  Note that setting this to `False` also causes the trajectory to not be recorded.
- In case of a large simulation box but small interaction radii one can sometimes boost performance by artifically 
  increasing the cuboid size of the neighbor list's spatial discretization by setting
  ```python
  simulation.skin = s
  ```
  where $s\geq 0$ is a scalar that will be added to the maximal cutoff.
  
Furthermore, one can select the

* TOC
{:toc}

## Integrator

Currently the only available integrator is the `EulerBDIntegrator` which is selected by default and can be selected by
a call to 
```python
simulation.integrator = "EulerBDIntegrator"
```

It integrates the [isotropic brownian dynamics]({{site.baseurl}}/system.html#particle-species)

$$
\frac{d\mathbf{x}(t)}{dt} = -D\frac{\nabla V(\mathbf{x}(t))}{k_BT} + \xi(t)
$$

with an Euler-Maruyama discretization

$$
\mathbf{x}_{t+\tau} = \mathbf{x}_t - \tau D\frac{\nabla V(\mathbf{x}(t))}{k_BT} + \sqrt{2D\tau}\eta_t,
$$

where

$$
\eta_t \sim \begin{pmatrix}\mathcal{N}(0, 1) & \cdots & \mathcal{N}(0, 1) \end{pmatrix}^T.
$$

## Reaction handler

## Simulation scheme
