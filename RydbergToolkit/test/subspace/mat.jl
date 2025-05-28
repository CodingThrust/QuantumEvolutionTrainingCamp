using Test
using Random
using RydbergToolkit.YaoSubspaceArrayReg
using YaoBlocks
using YaoBlocks.YaoArrayRegister.SparseArrays

@testset "mat" begin
    ss = sort(randperm(1023)[1:100])
    U = zeros(ComplexF64, 1024, 1024)
    U[ss, ss] = rand_unitary(length(ss))
    H = U * U'
    for g in [
            put(10, 2 => X),
            put(10, 3 => Rx(0.4)),
            put(10, 2:6 => matblock(rand_unitary(32))) * 2,
            control(10, (3, -5), (2, 7) => matblock(rand_unitary(4))),
            chain(matblock(U)),
            igate(10),
            subroutine(10, kron(X, X), (5, 2)),
            control(10, (3, -5), (2, 7) => matblock(rand_unitary(4)))',
            put(10, 2 => X) + matblock(rand_unitary(1024)),
            YaoBlocks.time_evolve(matblock(H), 0.3),
        ]
        @info "testing $g"
        M = SparseMatrixCSC(mat(g))[ss .+ 1, ss .+ 1]
        @test M ≈ mat(g, Subspace(nqudits(g), ss))
    end
    # test chain
    g = chain(matblock(U), matblock(U))
    @test mat(g, Subspace(nqudits(g), ss)) ≈ mat(g)[ss .+ 1, ss .+ 1]
end