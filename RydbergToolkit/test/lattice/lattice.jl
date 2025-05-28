using RydbergToolkit
using RydbergToolkit: offset_axes, rescale_axes, lattice_sites, lattice_vectors, clip_axes, random_dropout
using Test

@testset "lattices" begin
    for LT in [
        HoneycombLattice(),
        SquareLattice(),
        TriangularLattice(),
        LiebLattice(),
        KagomeLattice(),
        GeneralLattice(((1.0, 0.0), (0.0, 1.0)), [(0.0, 0.0)]),
    ]
        @test RydbergToolkit.dimension(LT) == 2
        @test generate_sites(LT, 5, 5) |> length == length(lattice_sites(LT)) * 25
    end
    lt1 = generate_sites(ChainLattice(), 5)
    @test lt1 |> length == length(lattice_sites(ChainLattice())) * 5
    l1 = generate_sites(HoneycombLattice(), 5, 5)
    l2 = offset_axes(l1, -1.0, -2.0)
    l3 = clip_axes(l2, (0.0, 3.0), (0.0, 4.0))
    @test all(loc -> 0 <= loc[1] <= 3 && 0 <= loc[2] <= 4, l3)
    l4 = l3 |> random_dropout(1.0)
    @test length(l4) == 0
    l4 = random_dropout(l3, 0.0)
    @test length(l4) == length(l3)
    l5 = random_dropout(l3, 0.5)
    @test length(l5) == 7
    @test_throws ArgumentError random_dropout(l3, -0.5)

    # Rectangular Lattice Defaults
    rectangular_lattice = RectangularLattice(1.0)
    @test lattice_sites(rectangular_lattice) == ((0.0, 0.0),)
    @test lattice_vectors(rectangular_lattice)[2][2] == rectangular_lattice.aspect_ratio

    # Lattice Dimensions

    # rescale axes
    sites = [(0.2, 0.3), (0.4, 0.8)]
    @test (sites |> rescale_axes(2.0)) == [(0.4, 0.6), (0.8, 1.6)]
end