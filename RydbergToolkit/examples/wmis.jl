# Ref: https://queracomputing.github.io/Bloqade.jl/dev/tutorials/6.MWIS/main/
using RydbergToolkit, RydbergToolkit.Graphs
using Random, RydbergToolkit.YaoBlocks, RydbergToolkit.YaoBlocks.BitBasis
using GenericTensorNetworks
using RydbergToolkit.StaticArrays
using CairoMakie

function create_wmis_problem()
    unit = 3.0
    lattice = SquareLattice()
    atoms = map(x -> unit .* x, generate_sites(lattice, 3, 3));
    g = RydbergToolkit.unitdisk_graph(atoms, 4.5)

    Random.seed!(42)
    wts = [rand() for i in 1:nv(g)];
    wmis_problem = IndependentSet(g, wts)
    configs_mapped = GenericTensorNetworks.solve(GenericTensorNetwork(wmis_problem), ConfigsMax())[]
    MIS_config = BitStr{length(atoms)}(configs_mapped.c[1].data[1])
    return atoms, g, wts, wmis_problem, MIS_config
end


function build_adiabatic_sweep(Ω_max::Float64, Δ_max::Float64, t_max::Float64, weights::Vector{Float64})
    Ω = GlobalPulse(t -> Ω_max * sin(pi * t / t_max)^2, length(weights))
    Δ(t) = weights .* (Δ_max * (2 * t / t_max - 1))
    return Ω, Δ
end

function simulate_wmis(; Ω_max, Δ_max, t_max, weights, backend, atoms, MIS_config, dt = 1e-2)
    t_list = []
    P_MWIS = [] # MIS probability
    regs = []
    sys = RydbergSystem(SVector.(atoms))
    densities_all = []

    for t in 0.1:t_max*0.25:t_max*2.5
        @info "tmax = $t"
        densities = Vector{Float64}[]
        Ω1, Δ1 = build_adiabatic_sweep(Ω_max, Δ_max, t, weights)
        reg = create_zero_state(backend, sys)
        iter = SimulationIterator(reg, backend, sys, Δ1, Ω1; tstart=0.0, tstop=t, dt=dt, pxp_cutoff=4.5, longtail_cutoff=4.5)
        for (t, reg) in iter
            @info "t = $t"
            @info RydbergToolkit.probability(reg, MIS_config)
            push!(densities, [RydbergToolkit.density(reg, i) for i in 1:length(atoms)])
        end
        p = RydbergToolkit.probability(iter.reg, MIS_config)
        @info "p = $p"
        push!(t_list, t)
        push!(P_MWIS, p)
        push!(regs, iter.reg)
        push!(densities_all, densities)
    end
    return t_list, P_MWIS, regs, densities_all
end

function plot_wmis(t_list, pmis)
    fig = Figure(; size=(800, 300))
    ax1 = Axis(fig[1, 1]; ylabel = "MWIS Probability", xlabel = "Time (μs)")
    ax2 = Axis(fig[1, 2]; ylabel = "log(1 - MWIS Probability)", xlabel = "Time (μs)")

    scatter!(ax1, t_list, pmis)
    scatter!(ax2, t_list, broadcast(log, 1 .- pmis))

    return fig
end

function plot_densities(densities; total_time, nsites)
    fig = Figure(size=(800, 620))
    D = hcat(densities...)'
    ax = Axis(fig[1, 1]; xlabel = "Time (μs)", ylabel = "Site", xticks = 0:0.4:total_time, yticks = (0.5:1:nsites, string.(1:nsites)))
    shw = heatmap!(ax, LinRange(0, total_time, size(D, 1)), LinRange(0.5, nsites - 0.5, size(D, 2)), real(D), colormap = :viridis)
    Colorbar(fig[1, 2], shw)
    return fig
end

atoms, g, wts, wmis_problem, MIS_config = create_wmis_problem()
Ω_max = 2π * 4
Δ_max = 3 * Ω_max
t_max = 1.5
Ω1, Δ1 = build_adiabatic_sweep(Ω_max, Δ_max, t_max, wts);
plot_pulse(first ∘ Δ1, first ∘ Ω1, (0.0, t_max))
plot_sites(atoms; annotate=true)

t_list, pmis, reg, densities = simulate_wmis(; atoms, MIS_config, Ω_max, Δ_max, t_max, weights=wts, backend=ExactSimulator())
fig = plot_wmis(t_list, pmis)
fig = plot_densities(densities[end]; total_time=t_max, nsites=length(atoms))