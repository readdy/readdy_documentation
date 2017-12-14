---
layout: page
title: Install readdy
---

## Linux and Mac

Get [miniconda](https://conda.io/docs/install/quick.html)

Add the conda-forge channel and install readdy
```bash
# add conda-forge channel
conda config --add channels conda-forge

# optional: create environment for readdy, switch to that environment
conda create -n readdy python=3
source activate readdy

# install readdy
conda install -c readdy readdy
```
Check if it worked, start a python interpreter and do
```python
>>> import readdy
```
If this does not return an error, you are ready to readdy.

### Latest build

To obtain the latest but possibly unstable build directly from the master branch, one can invoke

```bash
conda install -c readdy/label/dev readdy
```
