export MixModel, copy, LL, AIC, AIC3, BIC, describe

"""
Structure of mixture model parameters.

# Variables
- `α::Vector{Float32}`: Weights of the components
- `μ::Vector{Float32}`: Means of the components
- `σ::Vector{Float32}`: SDs of the components
"""
mutable struct MixModel
    α::Vector{Float32}
    μ::Vector{Float32}
    σ::Vector{Float32}
    kernel::Function
end

Base.copy(est::MixModel) = MixModel(est.α, est.μ, est.σ, est.kernel)

"""
    LL(x::Vector{<:Real}, est::MixModel)

Get the log-likelihood of a mixture model detailed in `est`, using the data `x`.

See also: [`AIC`](@ref), [`AIC3`](@ref), [`BIC`](@ref)
"""
LL(x::Vector{<:Real}, est::MixModel) = sum(
                                            log(sum(est.α .* est.kernel.(x[i], est.μ, est.σ)))
                                        for i=1:length(x))

"""
    AIC(x::Vector{<:Real}, est::MixModel)

Get the AIC of a mixture model, using the data `x`.
The AIC for a model ``M`` is given by:
`` AIC(M) =  2k - 2l(M)``
Where ``k`` is the number of parameters and ``l(M)`` is the log-likelihood.

See also: [`AIC3`](@ref), [`BIC`](@ref), [`LL`](@ref)
"""
AIC(x::Vector{<:Real}, est::MixModel) = 2*(3 * length(est.μ) - 1) - 2*LL(x, est)

"""
    AIC3(x::Vector{<:Real}, est::MixModel)

Get the modified AIC, "AIC3", of a mixture model using the data `x`.
The AIC3 for a model ``M`` is given by [^3]:
`` AIC(M) = 3k - 2l(M)``
Where ``k`` is the number of parameters and ``l(M)`` is the log-likelihood.

[^3]: Bozdogan, H. (1994). Mixture-model cluster analysis using model selection criteria and a new informational measure of complexity. In Proceedings of the first US/Japan conference on the frontiers of statistical modeling: An informational approach (pp. 69-113). Springer, Dordrecht.

See also: [`AIC`](@ref), [`BIC`](@ref), [`LL`](@ref)
"""
AIC3(x::Vector{<:Real}, est::MixModel) = 3*(3 * length(est.μ) - 1) - 2*LL(x, est)

"""
    BIC(x::Vector{<:Real}, est::MixModel)

Get the Bayesian Information Criterion of a mixture model using the data `x`.
The BIC for a model ``M`` is given by:
`` BIC(M) = log(n)k - 2l(M) ``
Where ``n`` is the sample size and ``l(M)`` is the log-likelihood

See also: [`AIC`](@ref), [`AIC3`](@ref), [`LL`](@ref)
"""
BIC(x::Vector{<:Real}, est::MixModel) = log(length(x))*(3 * length(est.μ) - 1) - 2*LL(x, est)

"""
    describe(est::MixModel; data::Vector{<:Real})

Pretty-print the parameters and fit indicies for the mixture model `est`.
If `data` is not specified, fit indicies will not be printed.
"""
function describe(est::MixModel; data::Union{Vector{<:Real}, Nothing} = nothing)

    if (data != nothing)
        println(repeat('-', length("Log-likelihood: $(LL(data, est))")))
        println("\nLog-likelihood: $(LL(data, est))")
        println("AIC: $(AIC(data, est))")
        println("AIC3: $(AIC3(data, est))")
        println("BIC: $(BIC(data, est))\n")
    else
        println("------------------\n")
    end

    for i ∈ 1:length(est.α)
        println("Component $i:")
        println("\tα: $(est.α[i])")
        println("\tμ: $(est.μ[i])")
        println("\tσ: $(est.σ[i])\n")
    end

    if (data != nothing)
        println(repeat('-', length("Log-likelihood: $(LL(data, est))")))
    else
        println("------------------")
    end
end
