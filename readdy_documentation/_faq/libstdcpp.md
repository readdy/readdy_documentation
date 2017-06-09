---
title: Wrong libstdc++ version
sectionName: libstdc++ version
position: 1
---

If you are getting an ImportError like below
```python
import readdy._internal.readdybinding.api as api
ImportError: /usr/lib/x86_64-linux-gnu/libstdc++.so.6: version 'CXXABI_1.3.9' not found 
(required by /home/username/miniconda2/envs/myenv/lib/python3.6/site-packages/readdy/_internal/readdybinding.cpython-36m-x86_64-linux-gnu.so)
```

installing the conda package `libgcc` via
```bash
conda install libgcc
```
MAY solve the problem.


It might happen that this does not resolve the issue since the libstdc++ from conda might still be too old. 
We are building with a rather recent version of gcc (version >5) and its corresponding libstdc++. 
The only way to solve this then is to have a system wide set of rather current versions of gcc/libstdc++ available.