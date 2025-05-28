"""
    AbstractSimulator

Abstract type for all simulators.
"""
abstract type AbstractSimulator end

"""
    RydbergSystem{D, T}
    RydbergSystem(coordinates::AbstractVector{<:AbstractVector{T}}; C=2π * 862690) where T

A Rydberg system is defined by the coordinates of the atoms and the interaction strength.

# Fields
- `coordinates`: the coordinates of the atoms.
- `C`: the interaction strength.
"""
struct RydbergSystem{D, T}
    coordinates::Vector{SVector{D, T}}
    C::T
end
function RydbergSystem(coordinates::AbstractVector{<:AbstractVector{T}}; C=2π * 862690) where T
    D = length(first(coordinates))
    @assert all(x -> length(x) == D, coordinates) "all coordinates must have the same dimension, got $(length(first(coordinates))) and $(length(x))"
    coordinates = collect(SVector{D, T}, coordinates)
    return RydbergSystem(coordinates, T(C))
end

"""
    interaction_strength(sys::RydbergSystem, i, j)

Return the interaction strength between the i-th and j-th atom.
"""
function interaction_strength(sys::RydbergSystem, i, j)
    return sys.C / norm(sys.coordinates[i] - sys.coordinates[j])^6
end

"""
    natoms(sys::RydbergSystem)

Return the number of atoms in the Rydberg system.
"""
natoms(sys::RydbergSystem) = length(sys.coordinates)

# struct RydbergHamiltonian{T}
#     topology::SimpleGraph{Int}
#     interaction::Vector{T}
#     detuning::Vector{T}
#     rabi::Vector{T}
#     function RydbergHamiltonian(topology::SimpleGraph{Int}, interaction::Vector{T}, detuning::Vector{T}, rabi::Vector{T}) where T
#         @assert length(interaction) == ne(topology) "interaction must have the same length as the number of edges in the topology, got $(length(interaction)) and $(ne(topology))"
#         @assert length(detuning) == length(rabi) == nv(topology) "detuning and rabi must have the same length as the number of vertices in the topology, got $(length(detuning)), $(length(rabi)) and $(nv(topology))"
#         new{T}(topology, interaction, detuning, rabi)
#     end
# end
# struct RydbergPXPHamiltonian{T}
#     topology::SimpleGraph{Int}
#     detuning::Vector{T}
#     rabi::Vector{T}
#     function RydbergPXPHamiltonian(topology::SimpleGraph{Int}, detuning::Vector{T}, rabi::Vector{T}) where T
#         @assert length(detuning) == length(rabi) == nv(topology) "detuning and rabi must have the same length as the number of vertices in the topology, got $(length(detuning)), $(length(rabi)) and $(nv(topology))"
#         new{T}(topology, detuning, rabi)
#     end
# end

struct SimulationIterator{T, D, BT<:AbstractSimulator, AT, DT, RT}
    reg::AT              # register
    backend::BT          # simulator backend
    sys::RydbergSystem{D, T}  # Rydberg system
    pxp_cutoff::T        # distance below which the interaction is treated as infinite
    longtail_cutoff::T   # distance above which the interaction is treated as 0
    detuning::DT
    rabi::RT
    tstart::T
    tstop::T
    dt::T  # TODO: use an iterator for t
    function SimulationIterator(reg, backend, sys::RydbergSystem{D, T}, detuning, rabi; pxp_cutoff=0, longtail_cutoff=Inf, tstart, tstop, dt) where {D, T}
        @assert tstart < tstop "tstart must be less than tstop, got $tstart and $tstop"
        @assert dt > 0 "dt must be positive, got $dt"
        @assert pxp_cutoff >= 0 "pxp_cutoff must be non-negative, got $pxp_cutoff"
        @assert longtail_cutoff >= 0 "longtail_cutoff must be non-negative, got $longtail_cutoff"
        new{T, D, typeof(backend), typeof(reg), typeof(detuning), typeof(rabi)}(reg, backend, sys, T(pxp_cutoff), T(longtail_cutoff), detuning, rabi, T(tstart), T(tstop), T(dt))
    end
end

function Base.iterate(iter::SimulationIterator{T, D, BT}, state=1) where {T, D, BT<:AbstractSimulator}
    if state > ceil(Int, (iter.tstop - iter.tstart) / iter.dt)
        return nothing
    end
    tstart = (state - 1) * iter.dt
    dt_actural = min(iter.tstop - tstart, iter.dt)
    H = rydberg_hamiltonian(iter.backend, iter.sys, iter.detuning(tstart + dt_actural/2), iter.rabi(tstart + dt_actural/2); pxp_cutoff=iter.pxp_cutoff, longtail_cutoff=iter.longtail_cutoff)
    time_evolve_step!(iter.backend, iter.reg, H, dt_actural)
    return (tstart + dt_actural, iter.reg), state + 1
end

"""
    simulate(reg, simulator::AbstractSimulator, sys::RydbergSystem{D, T}, detuning, rabi, tspan::NTuple{2, <:Real}; dt::T=T(0.01), pxp_cutoff::T=T(0), longtail_cutoff::T=T(Inf)) where {D, T}

Simulate the Rydberg system.

# Arguments
- `reg`: the register to simulate.
- `simulator`: the simulator to use.
- `sys`: the Rydberg system.
- `detuning`: the detuning of the Rydberg system.
"""
function simulate(reg, simulator::AbstractSimulator, sys::RydbergSystem{D, T}, detuning, rabi, tspan::NTuple{2, <:Real}; dt::T=T(0.01), pxp_cutoff::T=T(0), longtail_cutoff::T=T(Inf)) where {D, T}
    iter = SimulationIterator(reg, simulator, sys, detuning, rabi; tstart=tspan[1], tstop=tspan[2], dt, pxp_cutoff, longtail_cutoff)
    for (t, reg) in iter end
    return iter.reg
end

##### Interfaces for different simulators
"""
    create_zero_state(simulator::AbstractSimulator, sys::RydbergSystem{D, T}; pxp_approx=false) where {D, T}

Create a zero state for the Rydberg system.
"""
function create_zero_state end

"""
    rydberg_hamiltonian(simulator::AbstractSimulator, sys::RydbergSystem{D, T}, detuning::Vector{T}, rabi::Vector{T}; pxp_cutoff::T=0, longtail_cutoff::T=Inf) where {D, T}

Return the Rydberg Hamiltonian for the Rydberg system.
"""
function rydberg_hamiltonian end

"""
    rydberg_hamiltonian_pxp(simulator::AbstractSimulator, sys::RydbergSystem{D, T}, detuning::Vector{T}, rabi::Vector{T}) where {D, T}

Return the Rydberg Hamiltonian for the Rydberg system using PXP approximation.
"""
function rydberg_hamiltonian_pxp end

"""
    time_evolve_step!(backend::AbstractSimulator, reg::AbstractRegister, H::AbstractMatrix, dt::Real)

Time evolve the register for a step of size dt. It changes the register in place.
"""
function time_evolve_step! end

##### Observables
"""
    density(reg::AbstractRegister, i::Int)

Return the density matrix of the i-th atom.
"""
function density end

"""
    entropy(reg::AbstractRegister, site::Int)

Return the entropy of the 1:site atoms and the rest.
"""
function entropy end

"""
    probability(reg, config::DitStr)

Return the probability of the configuration.
"""
probability(reg, config::DitStr) = abs2(psi(reg, config))

"""
    psi(reg, config::DitStr)

Return the wavefunction of the configuration.
"""
function psi end

function unitdisk_graph(locs::AbstractVector, unit::Real)
    n = length(locs)
    g = SimpleGraph(n)
    for i=1:n, j=i+1:n
        if sum(abs2, locs[i] .- locs[j]) <= unit ^ 2
            add_edge!(g, i, j)
        end
    end
    return g
end