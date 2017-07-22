---
layout: page
title: Install readdy
---

Get [miniconda](https://conda.io/docs/install/quick.html)
```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
```
Install miniconda. When asked for install location, some place under `/storage/mi/yourusername/` is recommended
```bash
bash Miniconda3-latest-Linux-x86_64.sh
```
Source your `~/.bashrc` or restart the terminal, and check if it worked
```bash
which conda
```
should give you `/storage/mi/yourusername/miniconda3/bin/conda`.

Create environment
```bash
conda create -n readdy-workshop python=3 h5py numpy matplotlib jupyter
```
Activate the created environment
```bash
source activate readdy-workshop
```
Install readdy from our conda channel
```bash
conda install -f -c readdy/label/dev readdy
```
Check if it worked, start a python interpreter and do
```python
>>> import readdy._internal as api
>>> sim = api.Simulation()
>>> sim.set_kernel("CPU")
```
If this does not return an error, you are readdy (HA!).
