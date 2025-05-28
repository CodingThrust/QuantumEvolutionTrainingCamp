struct TimeDependent{T, FT}
    value::Vector{T}
    f!::FT
end
function value!(td::TimeDependent, t)
    td.f!(td.value, t)
    return td.value
end
value!(v::Vector, t) = v
Base.length(td::TimeDependent) = length(td.value)

function (td::TimeDependent)(t)
    value!(td, t)
    return td.value
end

function piecewise_linear(clocks::Vector{T}, values::Vector{T}) where T
    @assert length(clocks) == length(values) "clocks must have the same length as values, got $(length(clocks)) and $(length(values))"
    @assert iszero(first(clocks)) && issorted(clocks) "clocks must be sorted and start from 0, got $(clocks)"
    #return linear_interpolation(clocks, values; extrapolation_bc=Line())
    return linear_interpolation(clocks, values)
end

struct GlobalPulse{FT}
    pulse::FT
    n::Int
end
(pulse::GlobalPulse)(t) = fill(pulse.pulse(t), pulse.n)
