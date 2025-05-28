using Test, RydbergToolkit, Graphs
using RydbergToolkit: unitdisk_graph, independent_sets, blockade_subspace, is_independent_set
using YaoBlocks

@testset "blockade_subspace" begin
    fib(n) = n <= 2 ? 1 : fib(n-1) + fib(n-2)
    atoms = [(i, 0) for i in 1:10]
    subspace = blockade_subspace(atoms, 1.2)
    @test length(subspace) == fib(12)
    @test all(c -> is_independent_set(c, path_graph(10)), subspace.basis)

    graph = unitdisk_graph(atoms, 0.9)
    subspace = independent_sets(graph)
    @test length(subspace) == 1024
end

@testset "subspace register" begin
    fib(n) = n <= 2 ? 1 : fib(n-1) + fib(n-2)
    atoms = [(i, 0) for i in 1:10]
    subspace = blockade_subspace(atoms, 1.2)
    reg = rand_state(subspace)
    @test isnormalized(reg)
    @test nqudits(reg) == 10
    @test length(reg.subspace.basis) == fib(12)
end