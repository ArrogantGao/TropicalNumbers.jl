module TropicalNumbers

export content, neginf, posinf
export TropicalTypes, AbstractSemiring

export TropicalAndOr
export Tropical, TropicalF64, TropicalF32, TropicalF16
export TropicalMaxMul, TropicalMaxMulF64, TropicalMaxMulF32, TropicalMaxMulF16
export TropicalMaxPlus, TropicalMaxPlusF64, TropicalMaxPlusF32, TropicalMaxPlusF16
export TropicalMinPlus, TropicalMinPlusF64, TropicalMinPlusF32, TropicalMinPlusF16
export CountingTropical, CountingTropicalF16, CountingTropicalF32, CountingTropicalF64


"""
    AbstractSemiring <: Number

A [`Semiring`](https://en.wikipedia.org/wiki/Semiring) is a set R equipped with two binary operations + and ⋅, called addition and multiplication, such that:

* (R, +) is a monoid with identity element called 0;
* (R, ⋅) is a monoid with identity element called 1;
* Addition is commutative;
* Multiplication by the additive identity 0 annihilates ;
* Multiplication left- and right-distributes over addition;
* Explicitly stated, (R, +) is a commutative monoid.

[`Tropical number`](https://en.wikipedia.org/wiki/Tropical_geometry) are a set of semiring algebras, described as 
* (R, +, ⋅, 0, 1).
where R is the set, + and ⋅ are the opeartions and 0, 1 are their identity element, respectively.

In this package, the following tropical algebras are implemented:
* TropicalAndOr, ([T, F], or, and, false, true);
* Tropical (TropicalMaxPlus), (ℝ, max, +, -Inf, 0);
* TropicalMinPlus, (ℝ, min, +, Inf, 0);
* TropicalMaxMul, (ℝ⁺, max, ⋅, 0, 1).

We implemented fast tropical matrix multiplication in [`TropicalGEMM`](https://github.com/TensorBFS/TropicalGEMM.jl/) and [`CuTropicalGEMM`](https://github.com/ArrogantGao/CuTropicalGEMM.jl/).
"""
abstract type AbstractSemiring <: Number end

include("tropical_maxplus.jl")
include("tropical_andor.jl")
include("tropical_minplus.jl")
include("tropical_maxmul.jl")
include("counting_tropical.jl")

const TropicalTypes{T} = Union{CountingTropical{T}, Tropical{T}}
const TropicalMaxPlus = Tropical

# alias
# defining constants like `TropicalF64`.
for NBIT in [16, 32, 64]
    @eval const $(Symbol(:Tropical, :F, NBIT)) = Tropical{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:TropicalMaxPlus, :F, NBIT)) = TropicalMaxPlus{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:TropicalMinPlus, :F, NBIT)) = TropicalMinPlus{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:TropicalMaxMul, :F, NBIT)) = TropicalMaxMul{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:CountingTropical, :F, NBIT)) = CountingTropical{$(Symbol(:Float, NBIT)),$(Symbol(:Float, NBIT))}
end

# alias
for T in [:Tropical, :TropicalMaxMul, :TropicalMinPlus, :CountingTropical]
    for OP in [:>, :<, :(==), :>=, :<=, :isless]
        @eval Base.$OP(a::$T, b::$T) = $OP(a.n, b.n)
    end
    @eval begin
        content(x::$T) = x.n
        content(x::Type{$T{X}}) where X = X
        Base.isapprox(x::AbstractArray{<:$T}, y::AbstractArray{<:$T}; kwargs...) = all(isapprox.(x, y; kwargs...))
        Base.show(io::IO, ::MIME"text/plain", t::$T) = Base.show(io, t)
        Base.isnan(x::$T) = isnan(content(x))
    end
end

for T in [:TropicalAndOr]
    for OP in [:>, :<, :(==), :>=, :<=, :isless]
        @eval Base.$OP(a::$T, b::$T) = $OP(a.n, b.n)
    end
    @eval begin
        content(x::$T) = x.n
        Base.isapprox(x::AbstractArray{<:$T}, y::AbstractArray{<:$T}; kwargs...) = all(isapprox.(x, y; kwargs...))
        Base.show(io::IO, ::MIME"text/plain", t::$T) = Base.show(io, t)
        Base.isnan(x::$T) = isnan(content(x))
    end
end

for T in [:Tropical, :TropicalMaxMul, :TropicalMinPlus, :CountingTropical]
    @eval begin
        # this is for CUDA matmul
        Base.:(*)(a::$T, b::Bool) = b ? a : zero(a)
        Base.:(*)(b::Bool, a::$T) = b ? a : zero(a)
        Base.:(/)(a::$T, b::Bool) = b ? a : a / zero(a)
        Base.:(/)(b::Bool, a::$T) = b ? inv(a) : zero(a)
        Base.div(a::$T, b::Bool) = b ? a : a ÷ zero(a)
        Base.div(b::Bool, a::$T) = b ? one(a) ÷ a : zero(a)
    end
end

end # module
