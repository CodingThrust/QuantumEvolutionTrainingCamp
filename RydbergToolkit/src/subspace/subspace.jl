# This file is copied from Bloqade.jl
module YaoSubspaceArrayReg

using YaoBlocks.YaoAPI
using YaoBlocks
using YaoBlocks.YaoArrayRegister
using YaoBlocks.YaoArrayRegister.StatsBase
using YaoBlocks.BitBasis
using YaoBlocks: ConstGate
using YaoBlocks.YaoArrayRegister: spzeros
using LinearAlgebra, Random
using Base.Cartesian: @nexprs

export SubspaceArrayReg, Subspace

include("type.jl")
include("measure.jl")
include("instruct.jl")
include("mat.jl")
end
