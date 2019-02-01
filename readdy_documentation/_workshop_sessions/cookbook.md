---
title: Cookbook
sectionName: cookbook
position: 6
---

This section has some solutions to common problems you might run into.

- __The order__ in which you create and manipulate the `system` and `simulation` matters!

Remember that the workflow should always be
```python
system = readdy.ReactionDiffusionSystem(...)
# ... system configuration
simulation = system.simulation(...)
# ... simulation setup
simulation.run(...)
# ... analysis of results
```
If you made a mistake while registering species, potentials, etc., just create a new `system` and run the configuration again. The same goes for the `simulation`, just create a new one. In the jupyter notebooks it is sufficient, to just run all the cells again.


- __Simulation box__ and box potential for confining particles

If you want to confine particles to some cube without periodic boundaries, the box potential must be fully __inside__ the simulation box. Remember that the box is centered around `(0,0,0)`. For example the following will confine `A` particles to a cube of edge length 10
```python
system = readdy.ReactionDiffusionSystem(
    box_size=[12., 12., 12.], unit_system=None,
    periodic_boundary_conditions=[False, False, False])
system.add_species("A", 1.)
origin = np.array([-5., -5., -5.])
extent = np.array([10., 10., 10.])
system.potentials.add_box(
    "A", force_constant=10.,
    origin=origin, extent=extent)
```
The two vectors `origin` and `extent` span a cube in 3D space, the picture you should have in mind is the following
{: .centered}
![](assets/box_potential_within.png)

- __Initial placement__ of particles inside a certain volume

If you have already defined `origin` and `extent` of your confining box potential, it is easy to generate random positions uniformly in this volume
```python
n_particles = 30
uniform = np.random.uniform(size=(n_particles,3))
init_pos = uniform * extent + origin
```
Here `uniform` is a matrix `Nx3` where each row is a vector in the unit cube $\in\{[0,1]\times[0,1]\times[0,1]\}$ . This is multiplied with `extent`, yielding a uniform cube $\{[0,\mathrm{extent}_0]\times[0,\mathrm{extent}_1]\times[0,\mathrm{extent}_2]\}$. If you add the `origin` to this you get this cube at the right position (with respect to our box coordinates centered around `(0,0,0)`), i.e. 

$$
\begin{aligned}
\{&[\mathrm{origin}_0,\mathrm{extent}_0+\mathrm{origin}_0]\\
\times&[\mathrm{origin}_1,\mathrm{extent}_1+\mathrm{origin}_1]\\
\times&[\mathrm{origin}_2,\mathrm{extent}_2+\mathrm{origin}_2]\}
\end{aligned}
$$

- __2D plane__

If you want to confine particles to a 2D plane, just use the box potential but make the `extent` in one dimension very small, i.e.
```python
system = readdy.ReactionDiffusionSystem(
    box_size=[12., 12., 3.], unit_system=None,
    periodic_boundary_conditions=[False, False, False])
system.add_species("A", 1.)
origin = np.array([-5., -5., -0.01])
extent = np.array([10., 10., 0.02])
system.potentials.add_box(
    "A", force_constant=10.,
    origin=origin, extent=extent)
```
Having defined `origin` and `extent` it is now easy to add particles to this 2D plane. __Note__ that I also made the `box_size` in z direction smaller, however it should be large enough.


- __Output file size__

Please make use of your `/storage/mi/user` directories, your `home` will fill up quicker.
```python
data_dir = "/storage/mi/user" # replace user with your username
simulation.output_file = os.path.join(data_dir, "myfile.h5")
```
Additionally, use a `stride` on your observables, e.g.
```python
simulation.record_trajectory(stride=100)
# or
simulation.observe.particle_positions(stride=100)
```


- __Reaction descriptor language__

In expressions like
```python
system.reactions.add("fus: A +(2) B-> C", rate=0.1)
```
the value in the parentheses `+(2)` is the reaction distance.

- __look at VMD output if something is fishy__

This might reveal some obvious mistakes. Therefore you must have registered the according observable
```
simulation.record_trajectory(stride=100) # use appropriate stride
# ... run simulation
traj = readdy.Trajectory(simulation.output_file)
traj.convert_to_xyz(particle_radii={"A": 0.5, "B": 1.})
# particle_radii is optional here
```
Then in a bash shell do
```bash
vmd -e myfile.h5.xyz.tcl
```
or prefix with `!` in the jupyter notebook.