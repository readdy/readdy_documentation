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

Add the conda-forge channel and install readdy
```bash
conda config --add channels conda-forge
conda install -c readdy/label/dev readdy
```
Check if it worked, start a python interpreter and do
```python
>>> import readdy
```
If this does not return an error, you are ready to readdy.
