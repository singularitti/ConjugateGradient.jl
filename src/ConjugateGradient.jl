module ConjugateGradient

using LinearAlgebra: norm, ⋅
using OffsetArrays: OffsetVector, Origin

export Iteration, cg

"""
    Iteration(alpha, beta, x, r, p)

Record data in a single iteration within the conjugate gradient method.
"""
struct Iteration
    "The step size in the direction of the search vector."
    alpha::Float64
    "The factor used for calculating the new search direction."
    beta::Float64
    "The solution vector at the current iteration."
    x::Vector{Float64}
    "The residual vector at the current iteration."
    r::Vector{Float64}
    "The search direction vector at the current iteration."
    p::Vector{Float64}
end

"""
    cg(𝐀, 𝐛, 𝐱₀=zeros(length(𝐛)); atol=eps(), maxiter=2000)

Solves the linear system ``𝐀 𝐱 = 𝐛`` using the Conjugate Gradient method.

# Arguments
- `𝐀`: square, symmetric, positive-definite matrix.
- `𝐛`: right-hand side vector.
- `𝐱₀`: initial guess for the solution. Defaults to a zero vector of appropriate length.
- `atol`: absolute tolerance for convergence. Defaults to machine epsilon.
- `maxiter`: maximum number of iterations. Defaults to `2000`.

# Returns
- `𝐱`: the solution vector.
- `iterations`: an `OffsetVector` containing iteration history for each step.
- `isconverged`: a boolean indicating whether the algorithm has converged.
"""
function cg(𝐀, 𝐛, 𝐱₀=zeros(length(𝐛)); atol=eps(), maxiter=2000)
    isconverged = false
    𝐱ₙ = 𝐱₀
    𝐫ₙ = 𝐛 - 𝐀 * 𝐱ₙ  # Initial residual, 𝐫₀
    𝐩ₙ = 𝐫ₙ  # Initial momentum, 𝐩₀
    iterations = OffsetVector([], Origin(0))
    for _ in 0:maxiter
        if norm(𝐫ₙ) < atol
            isconverged = true
            break
        end
        𝐀𝐩ₙ = 𝐀 * 𝐩ₙ  # Avoid duplicated computation
        αₙ = 𝐫ₙ ⋅ 𝐫ₙ / (𝐩ₙ ⋅ 𝐀𝐩ₙ)  # `⋅` means dot product between two vectors
        𝐱ₙ₊₁ = 𝐱ₙ + αₙ * 𝐩ₙ
        𝐫ₙ₊₁ = 𝐫ₙ - αₙ * 𝐀𝐩ₙ
        βₙ = 𝐫ₙ₊₁ ⋅ 𝐫ₙ₊₁ / (𝐫ₙ ⋅ 𝐫ₙ)
        𝐩ₙ₊₁ = 𝐫ₙ₊₁ + βₙ * 𝐩ₙ
        push!(iterations, Iteration(αₙ, βₙ, 𝐱ₙ, 𝐫ₙ, 𝐩ₙ))
        𝐱ₙ, 𝐫ₙ, 𝐩ₙ = 𝐱ₙ₊₁, 𝐫ₙ₊₁, 𝐩ₙ₊₁  # Prepare for a new iteration
    end
    return 𝐱ₙ, iterations, isconverged
end

function Base.show(io::IO, ::MIME"text/plain", iteration::Iteration)
    println(io, summary(iteration))
    println(io, " α = ", iteration.alpha)
    println(io, " β = ", iteration.beta)
    println(io, " 𝐱 = ", iteration.x)
    println(io, " 𝐫 = ", iteration.r)
    println(io, " 𝐩 = ", iteration.p)
    return nothing
end

end
