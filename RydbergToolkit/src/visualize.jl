"""
    plot_pulse(Δ1, Ω1, tspan::NTuple{2, <:Real})

Plot the pulse, requires `using CairoMakie`.
"""
function plot_pulse end

"""
    plot_lattice(lattice::AbstractLattice, size::NTuple{D, Int}; unitdisk=0.0) where D

Plot the lattice, requires `using CairoMakie`.
"""
function plot_lattice end

"""
    plot_sites(sites::AbstractVector{NTuple{D, T}}; unitdisk=0.0) where {D, T}

Plot the sites, requires `using CairoMakie`.
"""
function plot_sites end

