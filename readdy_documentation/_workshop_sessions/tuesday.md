---
title: Tuesday
sectionName: tuesday
position: 2
---

This session will cover a well studied reaction diffusion system, the Lotka Volterra system, that describes a predator prey dynamics. We will investigate how parameters in these system affect spatiotemporal correlations.

### Task 1) Diffusion influenced reaction

Consider the reaction

$$
A + A\to B\quad\text{with rate: }\lambda=0.1
$$

The reaction distance should be $R=1$.

Set up a periodic box with dimensions $20\times20\times20$

Add 1000 A particles with $D=1$. The diffusion constant of B should be $D=1$. 
They should be uniformly distributed in the box, use

```python
n_particles = 1000
init_pos = np.random.uniform(size=(n_particles,3)) * extent + origin
simulation.add_particles("A", init_pos)
```

Observe the [number of particles](https://readdy.github.io/simulation.html#number-of-particles) with a stride of 1. Additionally you can print the current number of particles using the callback functionality

```python
simulation.observe.number_of_particles(
  1, ["A","B"],
  callback=lambda x: print("A {}, B {}".format(x[0],x[1]))
)
```

Simulate the system for 10000 steps with time step size 0.01.

__1a)__ Obtain the number of particles and plot them as a function of time.

The analytic solution of the concentration of particles subject to the reaction above is obtained by solving the ODE

$$
\frac{\mathrm{d}a}{\mathrm{d}t} = -k a^2\quad a(0)=a_0
$$

which yields

$$
a(t) = \frac{1}{a_0^{-1}+kt}
$$

__1b)__ Fit the function $a(t)$ to your counts data, to obtain the parameter $k$. For $a_0$ use `n_particles`. Make use of [scipy.optimize.curve_fit](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.curve_fit.html). Can the function $a(t)$ describe the data well?

__1c)__ Repeat the procedures a) and b) but change the diffusion coefficient to $D=0.01$ and change the microscopic reaction rate to $\lambda=1$. What happened to your fit?

### Task 2) well mixed predatory-prey

Simulate a Lotka-Volterra/predator-prey system for the given parameters and __determine the period of oscillation__.

There are two particle species `A` (prey) and `B` (predator) with the same diffusion coefficient $D=0.7$. Both particle species shall be confined to a quadratic 2D plane with an edge length of roughly 100, and non periodic boundaries, i.e. the 2D plane must be fully contained in the simulation box. Choose a very small thickness for the plane, e.g. 0.02, and a force constant of 50.

Particles of the __same__ species interact via harmonic repulsion, with a force constant of 50, and an interaction distance of 2.

There are three reactions for the Lotka Volterra system: `birth`, `eat`, and `decay`.

$$
\mathrm{birth}: \mathrm{A}\to \mathrm{A} +\mathrm{A}\quad\mathrm{with }~ \lambda=4\times 10^{-2}, R=2
$$

$$
\mathrm{eat}: \mathrm{A}+\mathrm{B}\to \mathrm{B} +\mathrm{B}\quad\mathrm{with }~ \lambda=10^{-2}, R=2
$$

$$
\mathrm{decay}: \mathrm{B}\to \emptyset\quad\mathrm{with }~ \lambda=3\times 10^{-2}
$$

Initialize a system by randomly positioning 1000 particles of each species on the 2D plane. Run the simulation for 100,000 integration steps with a step size of 0.01. Observe the number of particles and the trajectory, with a stride of 100.

From the observable, plot the number of particles for the two species as a function of time in the same plot. Make sure to label the lines accordingly. Additionally plot the phase space trajectory, i.e. plot the number of predator particles against the number of prey particles.

__Question__: What is the period of oscillation?

### Task 3) diffusion influenced predator-prey

We simulate the same system as in Task 2) but now introduce a scaling parameter $\ell$. This scaling parameter is used to control the ratio of reaction rates $\lambda$ and the rate of diffusion $D$.

For a given parameter $\ell$

- change all reaction rate constants $\tilde\lambda=\lambda\times\sqrt{\ell}$. 
- change all diffusion coefficients $\tilde D= D/\sqrt{\ell}$.

where the tilde `~` denotes the actually used value in the simulation and the value without tilde is the one from Task 1).

This means that the ratio

$$
\frac{\tilde\lambda}{\tilde D} = \ell\,\frac{\lambda}{D}=\ell\times\mathrm{const}
$$

is controlled by $\ell$.

Perform the same simulation as in Task 1) but for different scaling parameters $\ell$, each time saving the resulting plots (time series and phase plot) to a file, use `plt.savefig(...)`. Run each simulation for $n$ number of integration steps, where

$$
n(\ell) = 10^4 + \frac{10^6}{\sqrt{\ell}}
$$

Vary the scaling parameter from 1 to 400.

__Question__: For which $\ell$ do you see a qualitative change of behavior in the system, both from looking at the plots and the VMD visualization? Which cases are reaction-limited and which cases are diffusion-limited?

### Task 4)

Starting from the parameters of a diffusion influenced system from Task 3), set up a simulation, where prey particles form a traveling wavefront, closely followed by predators. Therefore you might want to change the simulation box and box potential parameters to get a 2D rectangular plane.

[![](assets/wave.jpg)](https://www.youtube.com/watch?v=Kc2rN16f6xI)

Feel free to adjust all parameters. You can experiment with other spatial patterns as well, have a look at [this paper](http://dx.doi.org/10.1063/1.4729141).

