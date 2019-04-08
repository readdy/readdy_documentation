---
title: Running the simulation
sectionName: simulation_run
position: 3
---

Per default, the simulation loop looks like below

{: .centered}
![](assets/architecture/simulation_loop_1000px.png)

This means that all observables are evaluated at the initial state regardless of their `stride`, after which
the actual loop is performed. 

A simulation is started by invoking
```python
simulation.run(n_steps=1000, timestep=1e-5)
```
where `n_steps` is the number of time steps to perform and the `timestep` is the time step. Per default an overview
of the system configuration is printed upon simulation start, this can be disabled by providing the 
argument `show_system=False`.

One can influence portions of the loop through the `simulation` object:

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

Reactions in ReaDDy are evaluated per time step, meaning that each particle might have multiple possible reaction
partners. In order to solve this, one can chose between two different reaction handlers:

- The `UncontrolledApproximation` reaction handler is the less rigorous of the two. It performs as follows:
    1. A list of all possible reaction events is gathered.
    2. For each element of this list a decision is made whether it is to be evaluated based on the time step and its 
       rate as described in the section about [reactions]({{site.baseurl}}/system.html#reactions).
    3. The filtered list is shuffled.
    4. For each event in the list evaluate it unless its educts have already been consumed by another reaction event.
  
  A problem of this reaction handler is that it does not give preference to reaction events based on their rate in case
  of a conflict, i.e., two events that share educts. However in the limit of small time steps this problem disappears.
  
  This reaction handler can be selected by invoking
  ```python
  simulation.reaction_handler = "UncontrolledApproximation"
  ```
  
- The `Gillespie` reaction handler is the default choice and is statistically exact in the sense that it imposes a 
  Gillespie reaction order on the events of a particular time step: 
  
  A list of all possible reaction events is gathered. Then
  1. Each reaction event is assigned its normalized reaction rate $\lambda_i/\sum_i\lambda_i$
  2. A random event is picked from the list based on its normalized reaction rate, i.e., a uniform random 
    number between 0 and 1 is drawn and then used together with the cumulative normalized reaction rates to determine
    the event
  3. Depending on its rate the reaction described by the event might be performed:
    - if not the event is simply removed from the list
    - if it was performed it is also removed and any other event that shared educts with this particular event
  4. if there are still events in the list go back to 1., otherwise stop
  
  An example of conflicting reaction events with expected outcome might be
  
  $$
   \left\{ \begin{array}{rcc} A + B &\xrightarrow{\lambda_1}& C\\ A &\xrightarrow{\lambda_2}& D \end{array} 
   \right. \xrightarrow{\lambda_1 \gg \lambda_2} \left\{ \begin{array}{rcc} A + B &\xrightarrow{\lambda_1}& C\\
   &\mathrm{ignored}  \end{array} \right.
  $$
  
  This reaction handler can be selected by invoking
    ```python
    simulation.reaction_handler = "Gillespie"
    ```
