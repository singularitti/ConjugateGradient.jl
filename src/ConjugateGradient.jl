module ConjugateGradient

using LinearAlgebra: norm, ⋅
using OffsetArrays: OffsetVector, Origin

export solve

struct Iteration
    alpha::Float64
    beta::Float64
    x::Vector{Float64}
    r::Vector{Float64}
    p::Vector{Float64}
end

function solve(A, 𝐛, 𝐱₀=zeros(length(𝐛)); atol=eps(), maxiter=2000)
    isconverged = false
    𝐱ₙ = 𝐱₀
    𝐫ₙ = 𝐛 - A * 𝐱ₙ  # Initial residual, 𝐫₀
    𝐩ₙ = 𝐫ₙ  # Initial momentum, 𝐩₀
    iterations = OffsetVector([], Origin(0))
    for _ in 0:maxiter
        if norm(𝐫ₙ) < atol
            isconverged = true
            break
        end
        A𝐩ₙ = A * 𝐩ₙ  # Avoid duplicated computation
        αₙ = 𝐫ₙ ⋅ 𝐫ₙ / (𝐩ₙ ⋅ A𝐩ₙ)  # `⋅` means dot product between two vectors
        𝐱ₙ₊₁ = 𝐱ₙ + αₙ * 𝐩ₙ
        𝐫ₙ₊₁ = 𝐫ₙ - αₙ * A𝐩ₙ
        βₙ = 𝐫ₙ₊₁ ⋅ 𝐫ₙ₊₁ / (𝐫ₙ ⋅ 𝐫ₙ)
        𝐩ₙ₊₁ = 𝐫ₙ₊₁ + βₙ * 𝐩ₙ
        push!(iterations, Iteration(αₙ, βₙ, 𝐱ₙ, 𝐫ₙ, 𝐩ₙ))
        𝐱ₙ, 𝐫ₙ, 𝐩ₙ = 𝐱ₙ₊₁, 𝐫ₙ₊₁, 𝐩ₙ₊₁  # Prepare for a new iteration
    end
    return 𝐱ₙ, iterations, isconverged
end

function Base.show(io::IO, iteration::Iteration)
    if get(io, :compact, false) || get(io, :typeinfo, nothing) == typeof(iteration)
        Base.show_default(IOContext(io, :limit => true), iteration)  # From https://github.com/mauro3/Parameters.jl/blob/ecbf8df/src/Parameters.jl#L556
    else
        println(io, summary(iteration))
        println(io, " n = ", Int(iteration.n))
        println(io, " α = ", iteration.alpha)
        println(io, " β = ", iteration.beta)
        println(io, " 𝐱 = ", iteration.x)
        println(io, " 𝐫 = ", iteration.r)
        println(io, " 𝐩 = ", iteration.p)
    end
end

end
