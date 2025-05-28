# Reference

## Lattices
```@autodocs
Modules = [RydbergToolkit]
Pages = ["lattice/lattice.jl"]
Order = [:type, :function]
```

## PXP approximation
```@autodocs
Modules = [RydbergToolkit.YaoSubspaceArrayReg]
Pages = ["subspace/subspace.jl", "subspace/type.jl", "subspace/instruct.jl", "subspace/measure.jl", "subspace/mat.jl"]
Order = [:type, :function]
```

## Simulation

Required interfaces:
- [`rydberg_hamiltonian`](@ref): construct the Rydberg Hamiltonian.
- `iterate(iter::SimulationIterator{T, D, BT<:AbstractSimulator})` (alternative): iterator interface for simulation.
- [`create_zero_state`](@ref): create the zero state of the Rydberg system.
- [`time_evolve_step!`](@ref): time evolve the Rydberg system for a single step.
- [`psi`](@ref): return the wavefunction of the configuration.
- [`entropy`](@ref): compute the von Neumann entropy of the Rydberg system.
- `expect`: compute the expectation value of observable. The following interfaces are also accepted:
  - density operator at site `i`.

Derived interfaces:
- [`simulate`](@ref): simulate the Rydberg system.
- [`density`](@ref): compute the density of the Rydberg system.
- [`probability`](@ref): compute the probability of the configuration.

```@autodocs
Modules = [RydbergToolkit]
Pages = ["Core.jl"]
Order = [:type, :function]
```

### Exact simulation - Yao backend

```@autodocs
Modules = [RydbergToolkit]
Pages = ["exact.jl"]
Order = [:type, :function]
```

### Tensor network simulation - MISKit backend

```@autodocs
Modules = [RydbergToolkit]
Pages = ["mpskit.jl"]
Order = [:type, :function]
```

## Visualization
```@autodocs
Modules = [RydbergToolkit]
Pages = ["visualize.jl"]
Order = [:type, :function]
```
