abstract type AbstractYaoSimulator <: AbstractSimulator end

"""
    ExactSimulator <: AbstractYaoSimulator

Exact simulator using Yao.jl.
"""
struct ExactSimulator <: AbstractYaoSimulator end

"""
    SubspaceSimulator{T} <: AbstractYaoSimulator

Subspace simulator using Yao.jl.

# Fields
- `blockade_radius`: the blockade radius of the Rydberg system.
"""
struct SubspaceSimulator{T} <: AbstractYaoSimulator
    blockade_radius::T
end

function rydberg_hamiltonian(::AbstractYaoSimulator, sys::RydbergSystem{D, T}, detuning::Vector{T}, rabi::Vector{T}; pxp_cutoff=0, longtail_cutoff=Inf) where {D, T}
    n = natoms(sys)
    @assert length(detuning) == length(rabi) == n "detuning and rabi must have the same length as the number of vertices in the topology, got $(length(detuning)), $(length(rabi)) and $n"

    pxp_topology, iteractive_edges, interaction = prepare_pxp_interaction(sys; pxp_cutoff=T(pxp_cutoff), longtail_cutoff=T(longtail_cutoff))
    pxp_terms = Add(n, [rabi/2 * kron(n, i => X, [j => P0 for j in neighbors(pxp_topology, i)]...) for (i, rabi) in enumerate(rabi)])
    detuning_terms = Add(n, [-detuning * put(n, i => P1) for (i, detuning) in enumerate(detuning)])
    h = pxp_terms + detuning_terms
    if !isempty(iteractive_edges)
        longtail_terms = Add(n, [strength * kron(n, e.src => P1, e.dst => P1) for (e, strength) in zip(iteractive_edges, interaction)])
        h += longtail_terms
    end
    return h
end

function prepare_pxp_interaction(sys::RydbergSystem{D, T}; pxp_cutoff::T=0, longtail_cutoff::T=Inf) where {D, T}
    # the PXP terms
    pxp_topology = unitdisk_graph(sys.coordinates, pxp_cutoff)

    # the longtail terms
    longtail_topology = unitdisk_graph(sys.coordinates, longtail_cutoff)
    iteractive_edges = [e for e in edges(longtail_topology) if !has_edge(pxp_topology, e.src, e.dst)]
    interaction = [interaction_strength(sys, e.src, e.dst) for e in iteractive_edges]
    !isempty(interaction) && maximum(interaction) > 1e3 && @warn "Atom locations might be too close, got interaction strength: $interaction, try PXP approximation?"
    return pxp_topology, iteractive_edges, interaction
end

create_zero_state(::ExactSimulator, sys::RydbergSystem{D, T}) where {D, T} = zero_state(Complex{T}, length(sys.coordinates))
function create_zero_state(sim::SubspaceSimulator{T}, sys::RydbergSystem{D, T}) where {D, T}
    return zero_state(Complex{T}, blockade_subspace(sys.coordinates, sim.blockade_radius))
end

function time_evolve_step!(::AbstractYaoSimulator, reg::AbstractRegister, H::AbstractBlock, dt::Real)
    return apply!(reg, YaoBlocks.time_evolve(H, dt))
end

##### Observables

function density(reg::AbstractRegister, i::Int)
    return real(expect(put(nqubits(reg), i => P1), reg))
end

function entropy(reg::AbstractRegister, site::Int)
    return von_neumann_entropy(reg, 1:site)
end

function psi(reg::ArrayReg, config::DitStr)
    return reg.state[config.buf + 1]
end
function psi(reg::SubspaceArrayReg, config::DitStr)
    idx = indexof(reg.subspace, config)
    return reg.state[idx]
end