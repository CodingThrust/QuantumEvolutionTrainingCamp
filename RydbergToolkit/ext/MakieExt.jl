module MakieExt

using CairoMakie, RydbergToolkit
using RydbergToolkit: AbstractLattice

function RydbergToolkit.plot_pulse(Δ1, Ω1, tspan::NTuple{2, <:Real})
    fig = Figure(size=(960, 320))
    ax1 = Axis(fig[1, 1], ylabel = "Ω/2π (MHz)", xlabel = "Time (μs)")
    ax2 = Axis(fig[1, 2], ylabel = "Δ/2π (MHz)", xlabel = "Time (μs)")
    t = LinRange(tspan[1], tspan[2], 200)
    lines!(ax1, t, Ω1.(t) ./ 2π)
    lines!(ax2, t, Δ1.(t) ./ 2π)
    fig[1, 1] = ax1
    fig[1, 2] = ax2
    return fig
end

function RydbergToolkit.plot_lattice(lattice::AbstractLattice, size::NTuple{D, Int}; unitdisk=0.0) where D
    sites = generate_sites(lattice, size...)
    return plot_sites(sites; unitdisk)
end

RydbergToolkit.plot_sites(sites::AbstractVector; unitdisk=0.0, annotate=false) = plot_sites(map(x -> (x...,), sites); unitdisk, annotate)
function RydbergToolkit.plot_sites(sites::AbstractVector{NTuple{D, T}}; unitdisk=0.0, annotate=false) where {D, T}
    @assert D <= 3 "Dimension of lattice to be visualized must be <= 3, got: $D"
    if D == 1
        sites = [(site[1], 0) for site in sites]
    end
    fig = Figure()
    if D == 3
        ax = Axis3(fig[1, 1], aspect=:data, xlabel="x/μm", ylabel="y/μm", zlabel="z/μm")
    else
        ax = Axis(fig[1, 1], aspect=DataAspect(), xlabel="x/μm", ylabel="y/μm")
    end
    nsites = length(sites)
    for i in 1:nsites-1, j in i+1:nsites
        if distance(sites[i], sites[j]) < unitdisk
            lines!(ax, [sites[i][1], sites[j][1]], [sites[i][2], sites[j][2]], color=:black)
        end
    end
    scatter!(ax, sites, color=:blue, markersize=10)
    if annotate
        for (i, site) in enumerate(sites)
            text!(ax, site .+ ntuple(j -> 0.5, D), text=string(i), align=(:center, :center))
        end
    end
    return fig
end
distance(a, b) = sqrt(sum(abs2, a .- b))

end
