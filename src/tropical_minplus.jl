export TropicalMinPlus, TropicalMinPlusF64, TropicalMinPlusF32, TropicalMinPlusF16, content

posinf(::Type{T}) where T = typemax(T)
posinf(::Type{T}) where T<:AbstractFloat = typemax(T)
posinf(::Type{T}) where T<:Rational = typemax(T)
posinf(::Type{T}) where T<:Integer = T(999999)
posinf(::Type{Int16}) = Int16(16384)
posinf(::Type{Int8}) = Int8(+64)

"""
    TropicalMinPlus{T} <: Number
    
TropicalMinPlus is a semiring algebra that maps

* `+` to `min` in regular algebra,
* `*` to `+` in regular algebra,
* `1` to `0` in regular algebra,
* `0` to `Inf` in regular algebra (for integer content types, this is chosen as a large integer).

"""
struct TropicalMinPlus{T} <: Number
    n::T
    TropicalMinPlus{T}(x) where T = new{T}(T(x))
    function TropicalMinPlus(x::T) where T
        new{T}(x)
    end
    function TropicalMinPlus{T}(x::TropicalMinPlus{T}) where T
        x
    end
    function TropicalMinPlus{T1}(x::TropicalMinPlus{T2}) where {T1,T2}
        new{T1}(T2(x.n))
    end
end

Base.show(io::IO, t::TropicalMinPlus) = Base.print(io, "$(t.n)ₜ")

Base.:^(a::TropicalMinPlus, b::Real) = Tropical(a.n * b)
Base.:^(a::TropicalMinPlus, b::Integer) = Tropical(a.n * b)
Base.:*(a::TropicalMinPlus, b::TropicalMinPlus) = Tropical(a.n + b.n)
function Base.:*(a::TropicalMinPlus{<:Rational}, b::TropicalMinPlus{<:Rational})
    if a.n.den == 0
        a
    elseif b.n.den == 0
        b
    else
        TropicalMinPlus(a.n + b.n)
    end
end

Base.:+(a::TropicalMinPlus, b::TropicalMinPlus) = Tropical(min(a.n, b.n))
Base.typemin(::Type{TropicalMinPlus{T}}) where T = TropicalMinPlus(posinf(T))
Base.zero(::Type{TropicalMinPlus{T}}) where T = typemin(TropicalMinPlus{T})
Base.zero(::TropicalMinPlus{T}) where T = zero(TropicalMinPlus{T})

Base.one(::Type{TropicalMinPlus{T}}) where T = TropicalMinPlus(zero(T))
Base.one(::TropicalMinPlus{T}) where T = one(TropicalMinPlus{T})

# inverse and division
Base.inv(x::TropicalMinPlus) = Tropical(-x.n)
Base.:/(x::TropicalMinPlus, y::TropicalMinPlus) = TropicalMinPlus(x.n - y.n)
Base.div(x::TropicalMinPlus, y::TropicalMinPlus) = TropicalMinPlus(x.n - y.n)

Base.isapprox(x::TropicalMinPlus, y::TropicalMinPlus; kwargs...) = isapprox(x.n, y.n; kwargs...)

# promotion rules
Base.promote_type(::Type{TropicalMinPlus{T1}}, b::Type{TropicalMinPlus{T2}}) where {T1, T2} = Tropical{promote_type(T1,T2)}
