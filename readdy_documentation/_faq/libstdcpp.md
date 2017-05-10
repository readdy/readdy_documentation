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

you may need to install the conda package `libgcc` via

```bash
conda install libgcc
```

We do not explicitly have this as a dependency.