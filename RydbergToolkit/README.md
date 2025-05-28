# RydbergToolkit

[![Build Status](https://github.com/CodingThrust/RydbergToolkit.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/CodingThrust/RydbergToolkit.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/gh/CodingThrust/RydbergToolkit.jl/graph/badge.svg?token=AHMltyX9v8)](https://codecov.io/gh/CodingThrust/RydbergToolkit.jl)


## Developer note

To develop this package, you need to [setup Julia](https://scfp.jinguo-group.science/chap1-julia/julia-setup.html) first. Then you can use the following commands:

### 1. Initialize and test the project
```bash
make init
make test
```
To later update the dependencies, you can use `make update`.

### 2. Documentation

The documentation is in the `docs` folder. To serve the docs, you can use the following command:
```bash
make serve
```