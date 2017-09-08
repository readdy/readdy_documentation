---
title: Architecture
sectionName: architecture
position: 2
---

### Source tree
```
readdy/
├── README.md
│   ...
│
├── cmake/
│   │
│   ├── Modules/
│   │   ├── (cmake modules)
│   └── sources/
│       └── (readdy source file lists)
│
├── docs/
│   └── (internal docs, doxygen configuration)
│
├── kernels/
│   │
│   ├── cpu/
│   │   ├── include/
│   │   │   └── (kernel includes)
│   │   ├── src/
│   │   │   └── (kernel sources)
│   │   └── test/
│   │       └── (kernel tests)
│   │
│   └── cuda/
│       └── (yet to be added)
│
├── include/
│   └── *.h (core library includes)
│
├── readdy/
│   │
│   ├── main/
│   │   └── (core library sources)
│   ├── test/
│   │   └── (core library tests)
│   └── examples/
│       └── (cpp examples)
│
├── readdy_testing/
│   └── (unit testing relevant tools)
│
├── libraries/
│   └── (c-blosc, h5rd, pybind11, spdlog)
│
└── wrappers/
    └── python/
        └── src/ (code for python api)
            ├── cxx/
            │   └── (c++ code for the python module)
            │
            └── python/
                └── (python api and tests)

```