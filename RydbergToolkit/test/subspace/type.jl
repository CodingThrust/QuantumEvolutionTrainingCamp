using Test
using Random
using YaoBlocks.YaoArrayRegister
using YaoBlocks
using RydbergToolkit.YaoSubspaceArrayReg
using LinearAlgebra

@testset "zero_state" begin
    subspace_v = [0, 1, 4, 8]
    raw_st = zeros(ComplexF64, length(subspace_v))
    raw_st[1] = 1
    r = zero_state(Subspace(10, subspace_v))
    @test state(r) ≈ raw_st
    @test YaoSubspaceArrayReg.basis(r) == YaoSubspaceArrayReg.BitStr{10}.(subspace_v)

    raw_st = rand(ComplexF64, length(subspace_v))
    r = SubspaceArrayReg(Subspace(10, subspace_v), raw_st)
    @test nactive(r) == 10
    @test nqubits(r) == 10
    @test relaxedvec(r) isa Vector
    @test state(r) isa Vector
    @test statevec(r) isa Vector
    normalize!(r)
    @test isnormalized(r)

    space = sort(randperm(1 << 5)[1:6] .- 1)
    @test_throws AssertionError SubspaceArrayReg(Subspace(10, space), rand(5))
end

@testset "rand_state" begin
    subspace = [0, 1, 4, 8]
    @test isnormalized(rand_state(Subspace(5, subspace)))
end

@testset "product_state" begin
    subspace = [0, 1, 4, 8]
    @test_throws AssertionError product_state(bit"010", Subspace(5, subspace))
    r = product_state(bit"1000", Subspace(5, subspace))
    @test isone(r.state[end])

    r = product_state(bit"1000", Subspace(5, subspace))
    @test isone(r' * r)
end

@testset "reg operations" begin
    subspace = [0, 1, 4, 8]
    a = SubspaceArrayReg(Subspace(5, subspace), ComplexF64[0.0, 0.8, 0.6, 0.0])
    b = rand_state(Subspace(5, subspace))
    @test a == a
    @test most_probable(a, 2) == YaoSubspaceArrayReg.BitStr{5}.([1, 4])
    @test YaoSubspaceArrayReg.regadd!(copy(a), b).state ≈ (a.state + b.state)
    @test YaoSubspaceArrayReg.regsub!(copy(a), b).state ≈ (a.state - b.state)
    @test YaoSubspaceArrayReg.regscale!(copy(a), 0.5).state ≈ 0.5 * a.state
    @test (a * 0.5).state ≈ 0.5 * a.state
    @test (-a).state ≈ -a.state
    @test (a / 0.5).state ≈ a.state / 0.5
    @test (a + b).state ≈ a.state + b.state
    @test (a - b).state ≈ a.state - b.state
end

@testset "ArrayReg(::SubspaceArrayReg)" begin
    subspace_v = [0, 1, 4, 8]
    r = rand_state(Subspace(10, subspace_v))
    @test ArrayReg(r).state[subspace_v.+1] ≈ r.state
end

@testset "probs(::SubspaceArrayReg)" begin
    subspace_v = [0, 1, 4, 8]
    @test sum(probs(rand_state(Subspace(10, subspace_v)))) ≈ 1.0
end

@testset "getindex(::SubspaceArrayReg, ::DisStr)" begin
    subspace = [0, 1, 4, 8]
    reg = zero_state(Subspace(5, subspace))
    @test reg[bit"00000"] == 1
    @test reg[bit"00001"] == 0
    @test reg[bit"00011"] == 0
    @test reg[bit"00100"] == 0
    @test reg[bit"01000"] == 0
    @test reg[bit"01001"] == 0
    @test reg[bit"01011"] == 0
    @test reg[bit"01111"] == 0
    @test reg[bit"11111"] == 0
end
