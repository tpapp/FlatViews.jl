"""

## Extending for custom types

Custom types should define

1. `flat_length`,
2. `flat_eltype`,
3. `flatten_into_at!`
4. `reconstruct_like_at`
"""
module FlatViews

export flat_length, flat_eltype, flatten_into!, flatten, reconstruct_like

using DocStringExtensions: SIGNATURES

# FIXME Julia 1.11
# public flatten_into_at!, reconstruct_like_at

####
#### utilities
####

"""
$(SIGNATURES)

Starting value for the offset in `flatten_into_at!` and `reconstruct_like`. Internal.
"""
_start_offset(v::AbstractVector) = firstindex(v) - 1

"""
$(SIGNATURES)

Check that we have reached the end of the vector with the offset.
"""
function _check_end_offset(v::AbstractVector, i)
    i == lastindex(v) ||
        throw(DimensionMismatch("Expected argument vector to end at index $i"))
end

####
#### generic API (where applicable, functions are defined for atoms)
####

"Types that flatten into a single-element vector. Internal."
const ATOM = Number

"""
$(SIGNATURES)

Number of flattened elements in a collection.
"""
flat_length(::ATOM) = 1

"""
$(SIGNATURES)

Element type that a collection is flattened to.
"""
flat_eltype(::Type{T}) where {T<:ATOM} = T

"""
$(SIGNATURES)
"""
flatten_into_at!(v, c::ATOM, i::Int) = (i += 1; v[i] = c; i)

"""
$(SIGNATURES)

Flatten `c` into the vector `v`.

If `length(v) ≠ flat_length(c)`, an error is thrown.

`v` may have generalized indexing, elements will be placed starting at `firstindex(v)`.
"""
function flatten_into!(v, c)
    i = flatten_into_at!(v, c, _start_offset(v))
    _check_end_offset(v, i)
    v
end

"""
$(SIGNATURES)

Flatten `c` into a `Vector{flatten_eltype(c)}`.
"""
function flatten(c::S) where S
    T = flat_eltype(S)
    n = flat_length(c)
    v = Vector{T}(undef, n)
    flatten_into_at!(v, c, _start_offset(v))
    v
end

"""
$(SIGNATURES)

Reconstruct and object like `c` from `v`, starting at offset `i`.

Does not check if all the elements were used up from `v`.
"""
function reconstruct_like_at(c::T, v::AbstractVector, i) where {T<:ATOM}
    i += 1
    T(v[i]), i
end

"""
$(SIGNATURES)

Reconstruct and object like `c` from `v`, starting at offset `i`.

Checks if sizes are compatible and throws an error if they are not.
"""
function reconstruct_like(c, v::AbstractVector)
    r, i = reconstruct_like_at(c, v, _start_offset(v))
    _check_end_offset(v, i)
    r
end

####
#### abstract arrays
####

flat_length(a::AbstractArray) = sum(flat_length, a)

flat_eltype(::Type{<:AbstractArray{T}}) where T = flat_eltype(T)

function flatten_into_at!(v, c::AbstractArray{T}, i) where T
    if T <: Number
        l = length(c)
        copyto!(v, i + 1, c, firstindex(c), l)
        i + l
    else
        for e in vec(c)
            i = flatten_into_at!(v, c, i)
        end
        i
    end
end

function reconstruct_like_at(c::AbstractArray, v, i)
    j::Int = i
    function _f(c)
        r, j = reconstruct_like_at(c, v, j)
        r
    end
    [_f(c) for c in c], j
end

####
#### Tuple and NamedTuple
####

@generated function flat_length(c::T) where {T<:Tuple}
    mapfoldl(i -> :(flat_length(c[$i])), (a, b) -> :($a + $b), 1:fieldcount(T))
end

flat_length(c::NamedTuple) = flat_length(values(c))

@generated function flat_eltype(::Type{T}) where {T <: Tuple}
    S = mapfoldl(flat_eltype, promote_type, fieldtypes(T))
    :($(S))
end

flat_eltype(::Type{NamedTuple{N,T}}) where {N,T} = flat_eltype(T)

function flatten_into_at!(v, c::Tuple, i)
    foldl((i, e) -> flatten_into_at!(v, e, i), c; init = i)
end

flatten_into_at!(v, c::NamedTuple, i) = flatten_into_at!(v, values(c), i)

@generated function reconstruct_like_at(c::T, v, i) where {T<:Tuple}
    results = Symbol[]
    lines = Expr[]
    for j in 1:fieldcount(T)
        r = gensym("r$(j)")
        push!(results, r)
        push!(lines, :(($r, i) = reconstruct_like_at(c[$j], v, i)))
    end
    quote
        $(lines...)
        $(Expr(:tuple, results...)), i
    end
end

function reconstruct_like_at(c::NamedTuple{N}, v, i) where N
    r, i = reconstruct_like_at(values(c), v, i)
    NamedTuple{N}(r), i
end

end # module
