module OrdinalIndexing

export st, nd, rd, th, OrdinalSuffixedInteger

struct OrdinalSuffixedInteger{T<:Integer} <: Number
	n :: T

	function OrdinalSuffixedInteger{T}(n::Integer) where {T<:Integer}
		n >= 0 || throw(ArgumentError("ordinal must be > 0"))
		new{T}(n)
	end
end
OrdinalSuffixedInteger(n::Integer) = OrdinalSuffixedInteger{typeof(n)}(n)
const th = OrdinalSuffixedInteger(true)
const st = th
const nd = th
const rd = th

_eltype(O::OrdinalSuffixedInteger{T}) where {T} = T

OrdinalSuffixedInteger{T}(O::OrdinalSuffixedInteger{U}) where {T<:Integer,U<:Integer} =
	OrdinalSuffixedInteger(convert(T, Integer(O)))
OrdinalSuffixedInteger(O::OrdinalSuffixedInteger) = O
OrdinalSuffixedInteger{T}(O::OrdinalSuffixedInteger{T}) where {T<:Integer} = O

function Base.convert(::Type{OrdinalSuffixedInteger{T}}, O::OrdinalSuffixedInteger) where {T}
	OrdinalSuffixedInteger{T}(Integer(O))
end

Base.Integer(a::OrdinalSuffixedInteger) = a.n
Base.Int(a::OrdinalSuffixedInteger) = Int(a.n)

Base.oneunit(O::OrdinalSuffixedInteger) = OrdinalSuffixedInteger(oneunit(_eltype(O)))
Base.oneunit(::Type{OrdinalSuffixedInteger{T}}) where {T} = OrdinalSuffixedInteger(oneunit(T))

const OrdinalIntOrInt = Union{OrdinalSuffixedInteger, Integer}
const OrdinalIntOrReal = Union{OrdinalSuffixedInteger, Real}

Base.:(+)(a::OrdinalSuffixedInteger) = a
Base.:(+)(a::OrdinalIntOrInt, b::OrdinalIntOrInt) = OrdinalSuffixedInteger(Integer(a) + Integer(b))
Base.:(-)(a::OrdinalIntOrInt, b::OrdinalIntOrInt) = OrdinalSuffixedInteger(Integer(a) - Integer(b))
Base.:(*)(a::OrdinalIntOrInt, b::OrdinalIntOrInt) = OrdinalSuffixedInteger(Integer(a) * Integer(b))

Base.:(<)(a::OrdinalSuffixedInteger, b::OrdinalSuffixedInteger) = Integer(a) < Integer(b)
Base.:(<=)(a::OrdinalSuffixedInteger, b::OrdinalSuffixedInteger) = Integer(a) <= Integer(b)

Base.:(==)(a::OrdinalSuffixedInteger, b::OrdinalSuffixedInteger) = Integer(a) == Integer(b)

_maybetail(::Tuple{}) = ()
_maybetail(t::Tuple) = Base.tail(t)

function Base.to_indices(A, inds::Tuple{Any,Vararg}, I::Tuple{OrdinalSuffixedInteger,Vararg})
	indsrest = _maybetail(inds)
	Irest = Base.tail(I)
	(Integer(first(I)) + first(first(inds)) - 1, to_indices(A, indsrest, Irest)...)
end

##########################################################################

struct MixedOrdinalUnitRange{A,B}
	a :: A
	b :: B
end

function MixedOrdinalUnitRange(a::OrdinalSuffixedInteger{V}, b::U) where {V,U<:Integer}
	T = promote_type(V, U)
	a2 = OrdinalSuffixedInteger{T}(a)
	b2 = T(b)
	MixedOrdinalUnitRange{typeof(a2),typeof(b2)}(a2, b2)
end
function MixedOrdinalUnitRange(a::U, b::OrdinalSuffixedInteger{V}) where {V,U<:Integer}
	T = promote_type(V, U)
	a2 = T(a)
	b2 = OrdinalSuffixedInteger{T}(b)
	MixedOrdinalUnitRange{typeof(a2),typeof(b2)}(a2, b2)
end
function MixedOrdinalUnitRange(a::OrdinalSuffixedInteger, b::OrdinalSuffixedInteger)
	T = promote_type(typeof(a), typeof(b))
	a2, b2 = T(a), T(b)
	b2 = b2 < a2 ? a2 - oneunit(a2) : b2
	MixedOrdinalUnitRange{typeof(a2),typeof(b2)}(a2, b2)
end

function Base.:(:)(a::OrdinalIntOrReal, b::OrdinalIntOrReal)
	MixedOrdinalUnitRange(a, b)
end

# OrdinalUnitRange behaves like a UnitRange{<:OrdinalSuffixedInteger}
const OrdinalUnitRange{T<:OrdinalSuffixedInteger} = MixedOrdinalUnitRange{T,T}

Base.first(O::MixedOrdinalUnitRange) = O.a
Base.last(O::MixedOrdinalUnitRange) = O.b
Base.step(O::OrdinalUnitRange{T}) where {T} = oneunit(T)
Base.length(O::OrdinalUnitRange) = Integer(O.b + oneunit(O.b) - O.a)
Base.size(O::OrdinalUnitRange) = (length(O),)

function firstlastinds(ax, indrange)
	a = indrange.a
	b = indrange.b
	inda = to_indices(ax, (a,))[1]
	indb = to_indices(ax, (b,))[1]
	(inda, indb)
end

function Base.to_indices(A, inds::Tuple{Any, Vararg}, I::Tuple{MixedOrdinalUnitRange, Vararg})
	inda, indb = firstlastinds(first(inds), first(I))
	(inda:indb, to_indices(A, Base.tail(inds), Base.tail(I))...)
end

struct MixedOrdinalStepRange{A,S,B}
	a :: A
	s :: S
	b :: B
end

function MixedOrdinalStepRange(a::OrdinalSuffixedInteger,
		s::Union{OrdinalSuffixedInteger,Integer}, b::OrdinalSuffixedInteger)
	T = promote_type(typeof(a), typeof(b))
	a2, s2, b2 = T(a), T(s), T(b)
	b2 = b2 < a2 ? a2 - oneunit(a2) : b2
	MixedOrdinalStepRange{typeof(a2), typeof(s2), typeof(b2)}(a2, s2, b2)
end

Base.first(O::MixedOrdinalStepRange) = O.a
Base.last(O::MixedOrdinalStepRange) = O.b
Base.step(M::MixedOrdinalStepRange) = M.s

# OrdinalStepRange behaves like a StepRange{<:OrdinalSuffixedInteger}
const OrdinalStepRange{O<:OrdinalSuffixedInteger} = MixedOrdinalStepRange{O,O}
const OrdinalRangeTypes{T} = Union{OrdinalUnitRange{T}, OrdinalStepRange{T}}

Base.eltype(O::OrdinalRangeTypes{T}) where {T} = T
Base.length(O::OrdinalStepRange) = length(Integer(O.a):Integer(O.s):Integer(O.b))
Base.size(O::OrdinalStepRange) = (length(O),)

function Base.:(:)(a::OrdinalIntOrReal, step::OrdinalIntOrReal, b::OrdinalIntOrReal)
	MixedOrdinalStepRange(a, step, b)
end

function Base.to_indices(A, inds::Tuple{Any, Vararg}, I::Tuple{MixedOrdinalStepRange, Vararg})
	indrange = first(I)
	inda, indb = firstlastinds(first(inds), indrange)
	(inda:Integer(step(indrange)):indb, to_indices(A, Base.tail(inds), Base.tail(I))...)
end

# specialize getindex for ranges to avoid collecting
function Base.getindex(x::AbstractRange, i::Union{MixedOrdinalUnitRange, MixedOrdinalStepRange})
	getindex(x, to_indices(x, (i,))...)
end
function Base.view(x::AbstractRange, i::Union{MixedOrdinalUnitRange, MixedOrdinalStepRange})
	getindex(x, to_indices(x, (i,))...)
end

Base.isempty(O::OrdinalRangeTypes) = length(O) == 0
Base.iterate(O::OrdinalRangeTypes) = isempty(O) ? nothing : (first(O), first(O))
function Base.iterate(O::OrdinalRangeTypes{T}, i) where {T}
	i == last(O) && return nothing
	next = convert(T, i + step(O))
	(next, next)
end

function Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, s::OrdinalSuffixedInteger)
	1 <= Integer(s) <= length(inds)
end

function Base.show(io::IO, O::OrdinalSuffixedInteger)
	n = Integer(O)
	m = n % 10
	if m == 1
		print(io, n, n == 11 ? "th" : "st")
	elseif m == 2
		print(io, n, n == 12 ? "th" : "nd")
	elseif m == 3
		print(io, n, n == 13 ? "th" : "rd")
	else
		print(io, n, "th")
	end
	return nothing
end

Base.show(io::IO, M::MixedOrdinalUnitRange) = print(io, M.a, ":", M.b)
Base.show(io::IO, M::MixedOrdinalStepRange) = print(io, M.a, ":", step(M), ":", M.b)

function Broadcast.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::typeof(*), r::AbstractUnitRange, t::OrdinalSuffixedInteger)
	MixedOrdinalUnitRange(first(r)*t, last(r)*t)
end
function Broadcast.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::typeof(*), r::AbstractRange, t::OrdinalSuffixedInteger)
	MixedOrdinalStepRange(first(r)*t, step(r), last(r)*t)
end

end
