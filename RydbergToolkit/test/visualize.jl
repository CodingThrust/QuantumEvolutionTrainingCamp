using RydbergToolkit, CairoMakie
using RydbergToolkit: random_dropout, generate_sites
using Test

@testset "visualize pulse" begin
    Δ1 = piecewise_linear([0.0, 0.3, 1.6, 2.2, 2.2+1e-10, 4.2], 2π * [-10.0, -10.0, 10.0, 10.0, 0.0, 0.0]);
    Ω1 = piecewise_linear([0.0, 0.05, 1.6, 2.2, 2.2+1e-10, 4.2], 2π * [0.0, 4.0, 4.0, 0.0, 2.0, 2.0]);
    fig = plot_pulse(Δ1, Ω1, (0.0, 4.2))
    @test fig isa CairoMakie.Figure
end

@testset "visualize lattice" begin
    lattice = ChainLattice()
    fig = plot_lattice(lattice, (10,))
    @test fig isa CairoMakie.Figure

    lattice = SquareLattice()
    fig = plot_lattice(lattice, (10, 10))
    @test fig isa CairoMakie.Figure
    
    # Test 3D lattice visualization
    lattice3d = GeneralLattice(
        ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)),
        [(0.0, 0.0, 0.0)]
    )
    fig = plot_lattice(lattice3d, (3, 3, 3))
    @test fig isa CairoMakie.Figure
    
    # Test with random dropout
    sites = generate_sites(TriangularLattice(), 5, 5)
    random_sites = random_dropout(sites, 0.5)
    fig = plot_sites(random_sites; unitdisk=1.5)
    @test fig isa CairoMakie.Figure
end
