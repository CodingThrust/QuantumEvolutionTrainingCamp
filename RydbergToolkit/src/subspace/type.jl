struct Subspace{D, INT, BS<:AbstractVector{INT}}
    n::Int
    basis::BS
    map::Dict{INT, Int}
end
indexof(subspace::Subspace, config::DitStr) = subspace.map[config]
function Subspace(n::Int, basis::BS; nlevel=2) where {INT, BS<:AbstractVector{INT}}
    @assert issorted(basis) "subspace basis must be sorted."
    @assert 0 ≤ first(basis) && last(basis) ≤ (INT(nlevel)^n - 1) "subspace index out of range, must be in [0, $(INT(nlevel)^n - 1)]"
    map = Dict{INT, Int}()
    for (subspace_index, fullspace_index) in enumerate(basis)
        map[fullspace_index] = subspace_index
    end
    return Subspace{nlevel, INT, BS}(n, basis, map)
end
Base.length(subspace::Subspace) = length(subspace.basis)

"""
    SubspaceArrayReg{D, T, INT, BS, VT} <: AbstractArrayReg{D,T,VT}
    SubspaceArrayReg(subspace::Subspace{D, INT, BS}, state::VT) where {T, D, INT, BS, VT}

Array register defined on a subspace.

# Fields
- `state`: state vector.
- `subspace`: subspace.
"""
struct SubspaceArrayReg{D, T, INT, BS<:AbstractVector{INT}, VT<:AbstractVector{T}} <: YaoArrayRegister.AbstractArrayReg{D,T,VT}
    subspace::Subspace{D, INT, BS}
    state::VT
    function SubspaceArrayReg(subspace::Subspace{D, INT, BS}, state::VT) where {D, INT, BS, VT}
        @assert length(state) == length(subspace) "size of state $(size(state, 1)) does not match size of subspace $(length(subspace))"
        return new{D, eltype(state), INT, BS, VT}(subspace, state)
    end
end
Base.copy(reg::SubspaceArrayReg) = SubspaceArrayReg(reg.subspace, copy(reg.state))

function YaoArrayRegister.ArrayReg(reg::SubspaceArrayReg{D}) where D
    st = similar(reg.state, 2^nqudits(reg))
    fill!(st, zero(eltype(st)))
    st[reg.subspace.basis .+ 1] .= reg.state
    return ArrayReg{D}(reshape(st, length(st), 1))
end

YaoAPI.nqudits(reg::SubspaceArrayReg) = reg.subspace.n
YaoAPI.nactive(reg::SubspaceArrayReg) = reg.subspace.n
YaoArrayRegister.state(reg::SubspaceArrayReg) = reg.state
YaoArrayRegister.statevec(reg::SubspaceArrayReg) = reg.state
YaoArrayRegister.relaxedvec(reg::SubspaceArrayReg) = reg.state
YaoArrayRegister.datatype(reg::SubspaceArrayReg) = eltype(reg.state)

"""
    zero_state([T=ComplexF64], subspace)

Create a `SubspaceArrayReg` in zero state in given subspace.

# Arguments

- `T`: optional, element type, default is `ComplexF64`.
- `subspace`: required, the subspace of rydberg state.
"""
YaoArrayRegister.zero_state(subspace::Subspace{D, INT, BS}) where {D, INT, BS} = zero_state(ComplexF64, subspace)
function YaoArrayRegister.zero_state(::Type{T}, subspace::Subspace{D, INT, BS}) where {T, D, INT, BS}
    return product_state(DitStr{D, subspace.n}(zero(INT)), subspace)
end

"""
    rand_state([T=ComplexF64], subspace)

Create a random state in the given subspace.
"""
YaoArrayRegister.rand_state(subspace::Subspace{D, INT, BS}) where {D, INT, BS} = rand_state(ComplexF64, subspace)
function YaoArrayRegister.rand_state(::Type{T}, subspace::Subspace{D, INT, BS}) where {T<:Complex, D, INT, BS}
    state = normalize!(rand(T, length(subspace)))
    return SubspaceArrayReg(subspace, state)
end

"""
    product_state([T=ComplexF64], config, subspace)

Create a product state of given config from `subspace`.
"""
function YaoArrayRegister.product_state(config::DitStr{D, N}, subspace::Subspace{D, INT, BS}) where {D, N, INT, BS}
    return product_state(ComplexF64, config, subspace)
end
function YaoArrayRegister.product_state(::Type{T}, config::DitStr{D, N}, subspace::Subspace{D, INT, BS}) where {T,D,N,INT,BS}
    @assert config in subspace.basis "config $config is not in given subspace"
    state = zeros(T, length(subspace))
    state[indexof(subspace, config)] = 1
    return SubspaceArrayReg(subspace, state)
end

# TODO: make upstream implementation more generic
function LinearAlgebra.normalize!(r::SubspaceArrayReg)
    normalize!(r.state)
    return r
end

YaoArrayRegister.isnormalized(r::SubspaceArrayReg) = norm(r.state) ≈ 1
function Base.isapprox(x::SubspaceArrayReg, y::SubspaceArrayReg; kwargs...)
    return nlevel(x) == nlevel(y) && x.n == y.n && isapprox(x.state, y.state; kwargs...) && (x.subspace.basis == y.subspace.basis)
end

function YaoArrayRegister.probs(r::SubspaceArrayReg)
    return abs2.(r.state)
end

function Base.:*(bra::YaoArrayRegister.AdjointRegister{D,<:SubspaceArrayReg}, ket::SubspaceArrayReg{D}) where D
    return dot(statevec(parent(bra)), statevec(ket))
end

YaoArrayRegister.basis(r::SubspaceArrayReg{D}) where D = reinterpret(DitStr{D,nqudits(r),eltype(r.subspace.basis)}, r.subspace.basis)
YaoArrayRegister.chstate(r::SubspaceArrayReg{D}, state) where D = SubspaceArrayReg(r.subspace, state)
YaoArrayRegister.nbatch(r::SubspaceArrayReg) = YaoArrayRegister.NoBatch()

## Redefine inplace APIs
# NOTE: non-inplace versions are defined on the abstract type: AbstractArrayReg
function YaoArrayRegister.regadd!(lhs::SubspaceArrayReg{D}, rhs::SubspaceArrayReg{D}) where D
    @assert lhs.subspace.n == rhs.subspace.n
    @assert length(lhs.subspace.basis) == length(rhs.subspace.basis)
    lhs.state .+= rhs.state
    return lhs
end

function YaoArrayRegister.regsub!(lhs::SubspaceArrayReg{D}, rhs::SubspaceArrayReg{D}) where D
    @assert lhs.subspace.n == rhs.subspace.n
    @assert length(lhs.subspace.basis) == length(rhs.subspace.basis)
    lhs.state .-= rhs.state
    return lhs
end

function YaoArrayRegister.regscale!(lhs::SubspaceArrayReg, x)
    lhs.state .*= x
    return lhs
end

function Base.:(==)(lhs::SubspaceArrayReg, rhs::SubspaceArrayReg)
    return nlevel(lhs) == nlevel(rhs) && lhs.subspace.n == rhs.subspace.n && lhs.subspace.basis == rhs.subspace.basis && lhs.state == rhs.state
end

function YaoArrayRegister.most_probable(reg::SubspaceArrayReg{D}, n::Int) where D
    imax = sortperm(abs2.(reg.state); rev = true)[1:n]
    return DitStr{D, nqubits(reg)}.(reg.subspace.basis[imax])
end

function Base.getindex(reg::SubspaceArrayReg{D, T}, key::DitStr{D}) where {D, T}
    nqudits(reg) == length(key) || error("number of qudits in register and ditstring does not match")
    if haskey(reg.subspace.map, key)
        subspace_idx = reg.subspace.map[key]
        return reg.state[subspace_idx]
    else
        return zero(T)
    end
end