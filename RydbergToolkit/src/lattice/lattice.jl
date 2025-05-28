# This file is copied from BloqadeLattices.jl
"""
    AbstractLattice{D}

Supertype for all `D` dimensional lattices.

# Implementation

[`lattice_vectors`](@ref) and [`lattice_sites`](@ref) functions must be defined
which should both return an indexable iterable containing the Bravais lattice vectors and 
lattice sites respectively. (e.g.: [`GeneralLattice`](@ref) returns a tuple of tuples containing the 
Bravais lattice vectors and lattice sites).
"""
abstract type AbstractLattice{D} end

"""
    dimension(::AbstractLattice{D})

Returns the space dimension of target lattice.
e.g. [`ChainLattice`](@ref) is a 1D lattice, hence returns 1.
"""
dimension(::AbstractLattice{D}) where {D} = D

function _generate_sites(lattice_vectors, lattice_sites, repeats::Vararg{Int,D}; scale = 1.0) where {D}
    @assert length(lattice_vectors) == D
    @assert D > 0 && length(lattice_sites) > 0
    @assert all(>=(0), repeats)
    @assert all(x -> length(x) == (D), lattice_vectors)
    @assert all(x -> length(x) == (D), lattice_sites)
    T = eltype(first(lattice_vectors))
    locations = NTuple{D,T}[]  # we might want to avoid using `push!` later.
    for ci in CartesianIndices(repeats)
        baseloc = mapreduce(i -> (ci.I[i] - 1) .* lattice_vectors[i], (x, y) -> x .+ y, 1:D)
        for siteloc in lattice_sites
            push!(locations, (baseloc .+ siteloc) .* scale)
        end
    end
    return locations
end

"""
    GeneralLattice{D,K,T} <: AbstractLattice{D}
    GeneralLattice(vectors, sites)

The general lattice type for tiling the space. Type parameter `D` is the dimension,
`K` is the number of sites in a unit cell and `T` is the data type for coordinates, e.g. `Float64`. Input arguments are

* `vectors` is a vector/tuple of D-tuple. Its length is D, it specifies the Bravais lattice vectors.
* `sites` is a vector/tuple of D-tuple. Its length is K, it specifies the sites inside a Bravais cell.
"""
struct GeneralLattice{D,K,T} <: AbstractLattice{D}
    vectors::NTuple{D,NTuple{D,T}}
    sites::NTuple{K,NTuple{D,T}}
end
GeneralLattice(vectors, sites) = GeneralLattice((vectors...,), (sites...,))

"""
    lattice_vectors(lattice::AbstractLattice)

Returns Bravais lattice vectors as a D-Tuple of D-Tuple, where D is the space dimension.
"""
lattice_vectors(general_lattice::GeneralLattice) = general_lattice.vectors

"""
    lattice_sites(lattice::AbstractLattice)

Returns sites in a Bravais lattice unit cell as a Tuple of D-Tuple, where D is the space dimension.
"""
lattice_sites(general_lattice::GeneralLattice) = general_lattice.sites

"""
    struct HoneycombLattice <: AbstractLattice{2}

Type representing 2D Honeycomb Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a honeycomb pattern, 
with number of site repetitions being specified by additional arguments of [`generate_sites`](@ref).
Honeycomb is a 2D Lattice, so there must be two integer arguments as additional inputs.

# Example

```jldoctest
julia> generate_sites(HoneycombLattice(), 5, 5)
50-element Vector{Tuple{Float64, Float64}}:
 (0.0, 0.0)
 (0.5, 0.2886751345948129)
 (1.0, 0.0)
 (1.5, 0.2886751345948129)
 (2.0, 0.0)
 (2.5, 0.2886751345948129)
 (3.0, 0.0)
 (3.5, 0.2886751345948129)
 (4.0, 0.0)
 (4.5, 0.2886751345948129)
 ⋮
 (2.5, 3.7527767497325675)
 (3.0, 3.4641016151377544)
 (3.5, 3.7527767497325675)
 (4.0, 3.4641016151377544)
 (4.5, 3.7527767497325675)
 (5.0, 3.4641016151377544)
 (5.5, 3.7527767497325675)
 (6.0, 3.4641016151377544)
 (6.5, 3.7527767497325675)

```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::HoneycombLattice)`](@ref) and
[`lattice_sites(::HoneycombLattice)`](@ref).
"""
struct HoneycombLattice <: AbstractLattice{2} end

"""
    lattice_vectors(::HoneycombLattice)

Returns the Bravais lattice vectors for a Honeycomb lattice as a Tuple of Tuples containing
floats.

The vectors are defined as:
- 𝐚₁ = (1.0, 0.0)
- 𝐚₂ = (0.5, 0.5√3)
"""
lattice_vectors(::HoneycombLattice) = ((1.0, 0.0), (0.5, 0.5 * sqrt(3)))

"""
    lattice_sites(::HoneycombLattice)

Returns the Bravais Lattice sites for a Honeycomb lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0, 0.0)
- (0.5, 0.5√3)
"""
lattice_sites(::HoneycombLattice) = ((0.0, 0.0), (0.5, 0.5 / sqrt(3)))

"""
    struct SquareLattice <: AbstractLattice{2}

Type representing 2D Square Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a square pattern,
with number of site repetitions being specified by additional arguments of [`generate_sites`](@ref).
Square is a 2D Lattice, so there must be two integer arguments as additional inputs.

# Example

```jldoctest
julia> generate_sites(SquareLattice(), 4, 4)
16-element Vector{Tuple{Float64, Float64}}:
 (0.0, 0.0)
 (1.0, 0.0)
 (2.0, 0.0)
 (3.0, 0.0)
 (0.0, 1.0)
 (1.0, 1.0)
 (2.0, 1.0)
 (3.0, 1.0)
 (0.0, 2.0)
 (1.0, 2.0)
 (2.0, 2.0)
 (3.0, 2.0)
 (0.0, 3.0)
 (1.0, 3.0)
 (2.0, 3.0)
 (3.0, 3.0)

```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::SquareLattice)`](@ref) and
[`lattice_sites(::SquareLattice)`](@ref).
"""
struct SquareLattice <: AbstractLattice{2} end

"""
    lattice_vectors(::SquareLattice)

Returns the Bravais lattice vectors for a Square lattice as a Tuple of Tuples containing
floats.
    
The vectors are defined as:
- 𝐚₁ = (1.0, 0.0)
- 𝐚₂ = (0.0, 1.0)
"""
lattice_vectors(::SquareLattice) = ((1.0, 0.0), (0.0, 1.0))

"""
    lattice_sites(::SquareLattice)

Returns the Bravais Lattice sites for a Square lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0, 0.0)
"""
lattice_sites(::SquareLattice) = ((0.0, 0.0),)

"""
    struct TriangularLattice <: AbstractLattice{2}

Type representing 2D Square Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a triangle pattern, 
with number of site repetitions being specified by additional arguments of [`generate_sites`](@ref).
Triangle is a 2D Lattice, so there must be two integer arguments as additional inputs.

# Example

```jldoctest
julia> generate_sites(TriangularLattice(), 3, 3)
9-element Vector{Tuple{Float64, Float64}}:
 (0.0, 0.0)
 (1.0, 0.0)
 (2.0, 0.0)
 (0.5, 0.8660254037844386)
 (1.5, 0.8660254037844386)
 (2.5, 0.8660254037844386)
 (1.0, 1.7320508075688772)
 (2.0, 1.7320508075688772)
 (3.0, 1.7320508075688772)

```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::TriangularLattice)`](@ref) and
[`lattice_sites(::TriangularLattice)`](@ref).
"""
struct TriangularLattice <: AbstractLattice{2} end

"""
    lattice_vectors(::TriangularLattice)

Returns the Bravais lattice vectors for a Triangular lattice as a Tuple of Tuples containing
floats.
    
The vectors are defined as:
- 𝐚₁ = (1.0, 0.0)
- 𝐚₂ = (0.5, 0.5√3)
"""
lattice_vectors(::TriangularLattice) = ((1.0, 0.0), (0.5, 0.5 * sqrt(3)))

"""
    lattice_sites(::TriangularLattice)

Returns the Bravais Lattice sites for a Triangular lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0, 0.0)
"""
lattice_sites(::TriangularLattice) = ((0.0, 0.0),)

"""
    struct ChainLattice <: AbstractLattice{1}

Type representing 1D Chain Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a chain pattern, 
with number of site repetitions being specified by the additional argument of [`generate_sites`](@ref).
Chain is a 1D Lattice, so there must be one integer argument as additional inputs.

# Example

```jldoctest
julia> generate_sites(ChainLattice(), 5)
5-element Vector{Tuple{Float64}}:
 (0.0,)
 (1.0,)
 (2.0,)
 (3.0,)
 (4.0,)
```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::ChainLattice)`](@ref) and
[`lattice_sites(::ChainLattice)`](@ref).
"""
struct ChainLattice <: AbstractLattice{1} end

"""
    lattice_vectors(::ChainLattice)

Returns the Bravais lattice vectors for a Chain lattice as a Tuple of Tuples containing
floats.
    
The vectors are defined as:
- 𝐚₁ = (1.0,)
"""
lattice_vectors(::ChainLattice) = ((1.0,),)

"""
    lattice_sites(::ChainLattice)

Returns the Bravais Lattice sites for a Chain lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0,)
"""
lattice_sites(::ChainLattice) = ((0.0,),)

"""
    struct LiebLattice <: AbstractLattice{2}

Type representing 2D Lieb Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a Lieb (square-depleted) pattern, 
with number of site repetitions being specified by additional arguments of [`generate_sites`](@ref).
Lieb is a 2D Lattice, so there must be two integer arguments as additional inputs.

# Example

```jldoctest
julia> generate_sites(LiebLattice(), 3, 3)
27-element Vector{Tuple{Float64, Float64}}:
 (0.0, 0.0)
 (0.5, 0.0)
 (0.0, 0.5)
 (1.0, 0.0)
 (1.5, 0.0)
 (1.0, 0.5)
 (2.0, 0.0)
 (2.5, 0.0)
 (2.0, 0.5)
 (0.0, 1.0)
 ⋮
 (0.0, 2.0)
 (0.5, 2.0)
 (0.0, 2.5)
 (1.0, 2.0)
 (1.5, 2.0)
 (1.0, 2.5)
 (2.0, 2.0)
 (2.5, 2.0)
 (2.0, 2.5)
```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::LiebLattice)`](@ref) and
[`lattice_sites(::LiebLattice)`](@ref).
"""
struct LiebLattice <: AbstractLattice{2} end

"""
    lattice_vectors(::LiebLattice)

Returns the Bravais lattice vectors for a Lieb lattice as a Tuple of Tuples containing
floats.
        
The vectors are defined as:
- 𝐚₁ = (1.0, 0.0)
- 𝐚₂ = (0.0, 1.0)
"""
lattice_vectors(::LiebLattice) = ((1.0, 0.0), (0.0, 1.0))

"""
    lattice_sites(::LiebLattice)

Returns the Bravais Lattice sites for a Lieb lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0, 0.0)
- (0.5, 0.0)
- (0.0, 0.5)
"""
lattice_sites(::LiebLattice) = ((0.0, 0.0), (0.5, 0.0), (0.0, 0.5))

"""
    struct KagomeLattice <: AbstractLattice{2}

Type representing 2D Kagome Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a Kagome pattern, 
with number of site repetitions being specified by additional arguments of [`generate_sites`](@ref).
Kagome is a 2D Lattice, so there must be two integer arguments as additional inputs.

# Example

```jldoctest
julia> generate_sites(KagomeLattice(), 3, 3)
27-element Vector{Tuple{Float64, Float64}}:
 (0.0, 0.0)
 (0.25, 0.4330127018922193)
 (0.75, 0.4330127018922193)
 (1.0, 0.0)
 (1.25, 0.4330127018922193)
 (1.75, 0.4330127018922193)
 (2.0, 0.0)
 (2.25, 0.4330127018922193)
 (2.75, 0.4330127018922193)
 (0.5, 0.8660254037844386)
 ⋮
 (1.0, 1.7320508075688772)
 (1.25, 2.1650635094610964)
 (1.75, 2.1650635094610964)
 (2.0, 1.7320508075688772)
 (2.25, 2.1650635094610964)
 (2.75, 2.1650635094610964)
 (3.0, 1.7320508075688772)
 (3.25, 2.1650635094610964)
 (3.75, 2.1650635094610964)
```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::KagomeLattice)`](@ref) and
[`lattice_sites(::KagomeLattice)`](@ref).
"""
struct KagomeLattice <: AbstractLattice{2} end

"""
    lattice_vectors(::KagomeLattice)

Returns the Bravais lattice vectors for a Kagome lattice as a Tuple of Tuples containing
floats.
        
The vectors are defined as:
- 𝐚₁ = (1.0, 0.0)
- 𝐚₂ = (0.5, 0.5√3)
"""
lattice_vectors(::KagomeLattice) = ((1.0, 0.0), (0.5, 0.5 * sqrt(3)))

"""
    lattice_sites(::KagomeLattice)

Returns the Bravais Lattice sites for a Lieb lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0, 0.0)
- (0.25, 0.25√3)
- (0.75, 0.25√3)
"""
lattice_sites(::KagomeLattice) = ((0.0, 0.0), (0.25, 0.25 * sqrt(3)), (0.75, 0.25 * sqrt(3)))

"""
    struct RectangularLattice <: AbstractLattice{2}

Type representing 2D Rectangular Lattice.

Used as an argument of [`generate_sites`](@ref) function to produce tiling in a Rectangular pattern, 
with number of site repetitions being specified by additional arguments of [`generate_sites`](@ref).
Rectangular is a 2D Lattice, so there must be two integer arguments as additional inputs.
This type also enables the user to modify the length of one of the Bravais lattice vectors, 
by passing a single integer on construction as the aspect ratio.

# Example

```jldoctest
julia> generate_sites(RectangularLattice(2.0), 2, 2)
4-element Vector{Tuple{Float64, Float64}}:
 (0.0, 0.0)
 (1.0, 0.0)
 (0.0, 2.0)
 (1.0, 2.0)
```
Overriden functions to return lattice vectors and sites exists as 
[`lattice_vectors(::RectangularLattice)`](@ref) and
[`lattice_sites(::RectangularLattice)`](@ref).
"""
struct RectangularLattice <: AbstractLattice{2}
    aspect_ratio::Float64
end

"""
    lattice_vectors(r::RectangularLattice)

Returns the Bravais lattice vectors for a Rectangular lattice as a Tuple of Tuples containing
floats.
        
The vectors are defined as:
- 𝐚₁ = (1.0, 0.0)
- 𝐚₂ = (0.0, `r.aspect_ratio`), where `aspect_ratio` is a `Float64`.
"""
lattice_vectors(r::RectangularLattice) = ((1.0, 0.0), (0.0, r.aspect_ratio))

"""
    lattice_sites(::RectangularLattice)

Returns the Bravais Lattice sites for a Rectangular lattice as a Tuple of Tuples containing
floats.

The sites are defined as:
- (0.0, 0.0)
"""
lattice_sites(::RectangularLattice) = ((0.0, 0.0),)

"""
    generate_sites(lattice::AbstractLattice{D}, repeats::Vararg{Int,D}; scale=1.0)

Returns an array of tuples (lattice coordinates) by tiling the specified `lattice`.
The tiling repeat the `sites` of the lattice `m` times along the first dimension,
`n` times along the second dimension, and so on. `scale` is a real number that re-scales the lattice constant and atom locations.
"""
function generate_sites(lattice::AbstractLattice{D}, repeats::Vararg{Int,D}; scale = 1.0) where {D}
    return _generate_sites((lattice_vectors(lattice)...,), (lattice_sites(lattice)...,), repeats...; scale = scale)
end

############ manipulate sites ###############
"""
    offset_axes(sites, offsets::Vararg{T,D}) where {D, T}
    offset_axes(offsets...)

Offset the `sites` by distance specified by `offsets`.

```jldoctest
julia> sites = [(1.0, 2.0), (10.0, 3.0), (1.0, 12.0), (3.0, 5.0)]
4-element Vector{Tuple{Float64, Float64}}:
 (1.0, 2.0)
 (10.0, 3.0)
 (1.0, 12.0)
 (3.0, 5.0)

julia> RydbergToolkit.offset_axes(sites, 1.0, 3.0)
4-element Vector{Tuple{Float64, Float64}}:
 (2.0, 5.0)
 (11.0, 6.0)
 (2.0, 15.0)
 (4.0, 8.0)
```
"""
function offset_axes(sites, offsets::Vararg{T,D}) where {D,T}
    @assert length(offsets) == D
    return map(x -> x .+ offsets, sites)
end

"""
    rescale_axes(sites, scale::Real)

Rescale the `sites` by a constant `scale`.

```jldoctest
julia> sites = [(1.0, 2.0), (10.0, 3.0), (1.0, 12.0), (3.0, 5.0)]
4-element Vector{Tuple{Float64, Float64}}:
 (1.0, 2.0)
 (10.0, 3.0)
 (1.0, 12.0)
 (3.0, 5.0)

julia> RydbergToolkit.rescale_axes(sites, 2.0)
4-element Vector{Tuple{Float64, Float64}}:
 (2.0, 4.0)
 (20.0, 6.0)
 (2.0, 24.0)
 (6.0, 10.0)
```
"""
function rescale_axes(sites, scale::Real)
    return map(x -> x .* scale, sites)
end

"""
    random_dropout(sites, ratio::Real)

Randomly drop out `ratio * number of sites` atoms from `sites`, where `ratio` ∈ [0, 1].
"""
function random_dropout(sites, ratio::Real)
    (ratio >= 0 && ratio <= 1) || throw(ArgumentError("dropout ratio be in range [0, 1], got `$ratio`."))
    atoms = YaoArrayRegister.sample(1:length(sites), round(Int, length(sites) * (1 - ratio)); replace = false)
    return sites[sort!(atoms)]
end

"""
    clip_axes(sites, bounds::Vararg{Tuple{T,T},D}) where {D, T}
    clip_axes(bounds...)

Remove sites out of `bounds`, where `bounds` is specified by D D-tuples.

```jldoctest
julia> sites = [(1.0, 2.0), (10.0, 3.0), (1.0, 12.0), (3.0, 5.0)]
4-element Vector{Tuple{Float64, Float64}}:
 (1.0, 2.0)
 (10.0, 3.0)
 (1.0, 12.0)
 (3.0, 5.0)

julia> RydbergToolkit.clip_axes(sites, (-5.0, 5.0), (-5.0, 5.0))
2-element Vector{Tuple{Float64, Float64}}:
 (1.0, 2.0)
 (3.0, 5.0)
```
"""
function clip_axes(sites, bounds::Vararg{Tuple{T,T},D}) where {D,T}
    @assert length(bounds) == D
    @assert all(x -> length(x) == 2, bounds)
    return filter(x -> all(i -> bounds[i][1] <= x[i] <= bounds[i][2], 1:D), sites)
end
clip_axes(args::Vararg{T,D}) where {T,D} = ls -> clip_axes(ls, args...)
offset_axes(args::Vararg{T,D}) where {T,D} = ls -> offset_axes(ls, args...)
random_dropout(probability::Real) = ls -> random_dropout(ls, probability)
rescale_axes(scale::Real) = ls -> rescale_axes(ls, scale)