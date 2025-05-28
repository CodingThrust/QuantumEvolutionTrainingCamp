using Test
using Random
using LinearAlgebra
using YaoBlocks.YaoArrayRegister
using YaoBlocks.BitBasis
using YaoBlocks
using RydbergToolkit.YaoSubspaceArrayReg

@testset "measure" begin
    Random.seed!(8)
    test_subspace = sort(randperm(32)[1:32]) .- 1
    # prepare a zero state
    r = zero_state(Subspace(5, test_subspace))
    sample1 = measure!(r)
    @test sample1 == zero(BitStr64{5})
    # 1. sampling
    r = rand_state(Subspace(5, test_subspace))
    samples = measure(r; nshots = 10000)
    @test samples isa Vector{<:BitStr}
end

