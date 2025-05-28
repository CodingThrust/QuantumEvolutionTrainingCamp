using RydbergToolkit
using Documenter
using Test

@testset "exact simulation" begin
    include("exact.jl")
end

@testset "timedependent" begin
    include("timedependent.jl")
end

@testset "lattice" begin
    include("lattice/lattice.jl")
end

@testset "visualize" begin
    include("visualize.jl")
end

DocMeta.setdocmeta!(RydbergToolkit, :DocTestSetup, :(using RydbergToolkit); recursive=true)
Documenter.doctest(RydbergToolkit; manual=false, fix=false)