function unitdisk_graph(locs::AbstractVector, unit::Real)
    n = length(locs)
    g = SimpleGraph(n)
    for i=1:n, j=i+1:n
        if sum(abs2, locs[i] .- locs[j]) <= unit ^ 2
            add_edge!(g, i, j)
        end
    end
    return g
end

"""
    independent_set_subspace(graph)
    independent_set_subspace(base, graph, vmap)

Create a subspace from given graph's maximal independent set.
"""
function independent_sets(base::T, graph::SimpleGraph, vmap::Vector{Int}) where T
    # enumerate all possible independent sets
    if nv(graph) == 0
        return [base]
    elseif nv(graph) == 1
        return [base, base | (one(T) << (vmap[1] - 1))]
    end
    # case 1: the first vertex is in the independent set
    subgraph1, subvmap1 = induced_subgraph(graph, setdiff(1:nv(graph), [1] ∪ neighbors(graph, 1)))
    sub1 = independent_sets(base | (one(T) << (vmap[1] - 1)), subgraph1, vmap[subvmap1])
    # case 2: the first vertex is not in the independent set
    subgraph2, subvmap2 = induced_subgraph(graph, 2:nv(graph))
    sub2 = independent_sets(base, subgraph2, vmap[subvmap2])
    return vcat(sub1, sub2)
end

function independent_sets(graph::SimpleGraph)
    n = nv(graph)
    @assert n <= 128 "number of vertices in a graph is too large! $(n) > 128"
    if isempty(edges(graph))
        @warn "graph has empty edges, creating a subspace contains the entire fullspace, consider using a full space register."
    end
    sort!(independent_sets(zero(n > 64 ? Int128 : Int64), graph, collect(1:n)))
end

is_independent_set(base::T, graph::SimpleGraph) where T <: Integer = is_independent_set([readbit(base, i) for i in 1:nv(graph)], graph)
function is_independent_set(base::Vector, graph::SimpleGraph)
    for e in edges(graph)
        isone(base[src(e)]) && isone(base[dst(e)]) && return false
    end
    return true
end

"""
    blockade_subspace(atoms[, radius=1.0])

Create a blockade approximation subspace from given atom positions and radius.
"""
function blockade_subspace(atoms::AbstractVector, radius::AbstractFloat = 1.0)
    return Subspace(length(atoms), independent_sets(unitdisk_graph(atoms, radius)))
end