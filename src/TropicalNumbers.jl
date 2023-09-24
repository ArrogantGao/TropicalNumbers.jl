module TropicalNumbers

export Tropical, TropicalF64, TropicalF32, TropicalF16, CountingTropicalF16, CountingTropicalF32, CountingTropicalF64, content, TropicalAndOr
export CountingTropical
export TropicalTypes


include("tropical.jl")
include("tropical_andor.jl")
include("tropical_minplus.jl")
include("tropical_maxmul.jl")
include("counting_tropical.jl")

const TropicalTypes{T} = Union{CountingTropical{T}, Tropical{T}}

# alias
# defining constants like `TropicalF64`.
for NBIT in [16, 32, 64]
    @eval const $(Symbol(:Tropical, :F, NBIT)) = Tropical{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:TropicalMaxMul, :F, NBIT)) = TropicalMaxMul{$(Symbol(:Float, NBIT))}
    @eval const $(Symbol(:TropicalMinPlus, :F, NBIT)) = TropicalMinPlus{$(Symbol(:Float, NBIT))}
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
        # Base.div(a::$T, b::Bool) = b ? a : a / zero(a)
        # Base.div(b::Bool, a::$T) = b ? inv(a) : zero(a)
        Base.div(a::$T, b::Bool) = b ? a : a ÷ zero(a)
        Base.div(b::Bool, a::$T) = b ? one(a) ÷ a : zero(a)
    end
end

end # module
