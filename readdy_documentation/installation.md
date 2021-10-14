---
layout: page
title: Install readdy
---

## Linux and Mac

Get [miniconda](https://docs.conda.io/en/latest/miniconda.html).

Create an environment (optional) and add the conda-forge channel to install readdy:
```bash
# optional: create environment for readdy, switch to that environment
conda create -n readdy python=3.9
conda activate readdy

# add conda-forge channel
conda config --env --add channels conda-forge
conda config --set channel_priority strict

# install readdy
conda install readdy
```
Check if it worked, start a python interpreter and do
```python
>>> import readdy
```
If this does not return an error, you are ready to readdy.

### Latest build

To obtain the latest but possibly unstable build you can build from source by using `conda-build` on the recipe.
