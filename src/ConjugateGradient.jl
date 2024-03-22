module ConjugateGradient

using LinearAlgebra: norm, ⋅
using OffsetArrays: OffsetVector, Origin

export Logger, solve, solve!, isconverged

struct Step
    alpha::Float64
    beta::Float64
    x::Vector{Float64}
    r::Vector{Float64}
    p::Vector{Float64}
end

abstract type AbstractLogger end
mutable struct EmptyLogger <: AbstractLogger
    isconverged::Bool
end
EmptyLogger() = EmptyLogger(false)
mutable struct Logger <: AbstractLogger
    isconverged::Bool
    data::OffsetVector{Step}
end
Logger() = Logger(false, OffsetVector([], Origin(0)))

function solve!(logger, A, 𝐛, 𝐱₀=zeros(length(𝐛)); atol=eps(), maxiter=2000)
    𝐱ₙ = 𝐱₀
    𝐫ₙ = 𝐛 - A * 𝐱ₙ  # Initial residual, 𝐫₀
    𝐩ₙ = 𝐫ₙ  # Initial momentum, 𝐩₀
    for n in 0:maxiter
        if norm(𝐫ₙ) < atol
            setconverged!(logger)
            break
        end
        A𝐩ₙ = A * 𝐩ₙ  # Avoid duplicated computation
        αₙ = 𝐫ₙ ⋅ 𝐫ₙ / (𝐩ₙ ⋅ A𝐩ₙ)  # `⋅` means dot product between two vectors
        𝐱ₙ₊₁ = 𝐱ₙ + αₙ * 𝐩ₙ
        𝐫ₙ₊₁ = 𝐫ₙ - αₙ * A𝐩ₙ
        βₙ = 𝐫ₙ₊₁ ⋅ 𝐫ₙ₊₁ / (𝐫ₙ ⋅ 𝐫ₙ)
        𝐩ₙ₊₁ = 𝐫ₙ₊₁ + βₙ * 𝐩ₙ
        log!(logger, Step(n, αₙ, βₙ, 𝐱ₙ, 𝐫ₙ, 𝐩ₙ))
        𝐱ₙ, 𝐫ₙ, 𝐩ₙ = 𝐱ₙ₊₁, 𝐫ₙ₊₁, 𝐩ₙ₊₁  # Prepare for a new iteration
    end
    return 𝐱ₙ
end
solve(A, 𝐛, 𝐱₀=zeros(length(𝐛)); kwargs...) = solve!(EmptyLogger(), A, 𝐛, 𝐱₀; kwargs...)

log!(::EmptyLogger, args...) = nothing
log!(logger::Logger, step) = push!(logger.data, step)

function setconverged!(logger::AbstractLogger)
    logger.isconverged = true
    return logger
end

isconverged(ch::Logger) = ch.isconverged

function Base.show(io::IO, step::Step)
    if get(io, :compact, false) || get(io, :typeinfo, nothing) == typeof(step)
        Base.show_default(IOContext(io, :limit => true), step)  # From https://github.com/mauro3/Parameters.jl/blob/ecbf8df/src/Parameters.jl#L556
    else
        println(io, summary(step))
        println(io, " n = ", Int(step.n))
        println(io, " α = ", step.alpha)
        println(io, " β = ", step.beta)
        println(io, " 𝐱 = ", step.x)
        println(io, " 𝐫 = ", step.r)
        println(io, " 𝐩 = ", step.p)
    end
end

end
