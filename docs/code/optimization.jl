using Plots, Distributions, GLM, LinearAlgebra, Optim, ForwardDiff
    
# Setting up the log likelihood function for logistic regression
function logisticreg_loglik(β, y, X)                        
    return sum( y.*(X*β)  .- log.(1 .+ exp.(X*β)) )
end

# Generate data from logistic regression with β = [1,-1,1,-1]
n = 500
p = 4
X = [ones(n,1) randn(n,p-1)]
β = [1,-1,1,-1]
probs = 1 ./ (1 .+ exp.(-X*β))
y = rand.(Bernoulli.(probs))
logisticreg_loglik(β, y, X) # Test drive the function to see that it works.

# Find the MLE of β using Optim.jl
β₀ = randn(p) # Initial guess for the optimization
optres = maximize(β -> logisticreg_loglik(β, y, X), β₀, BFGS(), autodiff = :forward)
βmle = Optim.maximizer(optres)

# Compute Hessian to get approximate standard errors
H(β) = ForwardDiff.hessian(β -> logisticreg_loglik(β, y, X), β)
Ωᵦ = Symmetric(-inv(H(βmle))) # This is J^{-1}
diag(Ωᵦ) # Diagonal elements are the variances of the MLEs
se = sqrt.(diag(Ωᵦ)) # Standard errors of the MLEs
println("βmle: \n", βmle)
println("Standard errors: \n", se)

# Automatic differentiation with ForwardDiff.jl
∂loglik(β) = ForwardDiff.gradient(β -> logisticreg_loglik(β, y, X), β)
∂loglik(βmle) # Gradient at the MLE, should be close to zero
∂loglik(β₀) # Gradient at the initial value
