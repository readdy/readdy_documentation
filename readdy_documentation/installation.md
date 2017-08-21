---
layout: page
title: Install readdy
---

## Linux

Get [miniconda](https://conda.io/docs/install/quick.html)
```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
```
Install miniconda.
```bash
bash Miniconda3-latest-Linux-x86_64.sh
```
Source your `~/.bashrc` or restart the terminal, and check if it worked
```bash
which conda
```
should give you the location where conda got installed

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
