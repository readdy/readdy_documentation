---
title: Building from source
sectionName: build
position: 1
---

ReaDDy has the following dependencies (__bold__ printed are expected to be present on the system):
- __hdf5__
- __cmake__
- spdlog, included by git submodule
- c-blosc, included by git submodule
- h5rd, included by git submodule
- catch2, for testing, included by git submodule
- for python bindings
	- pybind11, included by git submodule
	- __python 3__ with __numpy__, __h5py__


### Build by using CMake
This type of build is suggested if one is interested in development of the software. 
There are a number of ReaDDy specific CMake options that influence the type of build:

| CMake option = default                          | Description |
| ----------------------------------------------- | --- |
| `READDY_CREATE_TEST_TARGET=ON`                  | Determining if the test targets should be generated. |
| `READDY_CREATE_MEMORY_CHECK_TEST_TARGET=OFF`    | Determining if the test targets should be additionally called through valgrind. Requires the previous option to be ON and valgrind to be installed. |
| `READDY_INSTALL_UNIT_TEST_EXECUTABLE=OFF`       | Determining if the unit test executables should be installed. This is option is mainly important for the conda recipe. |
| `READDY_BUILD_SHARED_COMBINED=OFF`              | Determining if the core library should be built monolithically or as separated shared libraries. |
| `READDY_BUILD_PYTHON_WRAPPER=ON`                | Determining if the python wrapper should be built. |
| `READDY_DEBUG_PYTHON_MODULES=OFF`               | If this flag is set to ON, the generated python module will be placed in-source rather than in the output directory to enable faster development. |
| `READDY_DEBUG_CONDA_ROOT_DIR=""`                | This option is to be used in conjunction with the previous option and only has effect if it is set to ON. It should point to the conda environment which is used for development and then effects the output directory of the binary files such that they get compiled directly into the respective environment. |
| `READDY_GENERATE_DOCUMENTATION_TARGET=OFF`      | Determines if the documentation target should be generated or not, which, if generated, can be called by "make doc". |
| `READDY_GENERATE_DOCUMENTATION_TARGET_ONLY=OFF` | This option has the same effect as the previous option, just that it does not need any dependencies other than doxygen to be fulfilled and generates the documentation target exclusively. |
| `READDY_LOG_CMAKE_CONFIGURATION=OFF`            | This option determines if the status of relevant cmake cache variables should be logged at configuration time or not. |
| `READDY_KERNELS_TO_TEST="SingleCPU,CPU"`        | Comma separated list of kernels against which the core library should be tested within the test targets. |

After having configured the cmake cache variables, one can invoke cmake and make and compile the project.
Altogether, a shell script invoking cmake with modified parameters in an environment with multiple python versions could look like [this](https://github.com/readdy/readdy/blob/master/tools/dev/configure.sh).

### Build by using conda-build
```bash
conda install conda-build
conda-build PATH_TO_READDY/tools/conda-recipe
```
