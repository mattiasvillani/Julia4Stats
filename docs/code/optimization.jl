using Plots, Distributions, GLM, LinearAlgebra, Optim, ForwardDiff

# Generate data from Poisson regression with β = [1,-1,1,-1]
n = 500
p = 4
X = [ones(n,1) randn(n,p-1)]
β = 0.2*[1,-1,1,-1]
λ = exp.(X*β)
y = rand.(Poisson.(λ))

# Setting up the log likelihood function for Poisson regression
function poisreg_loglik(β, y, X)                        
    return sum(logpdf.(Poisson.(exp.(X*β)), y))
end
poisreg_loglik(β, y, X) # Test drive the function to see that it works.

# Find the MLE of β using Optim.jl
β₀ = randn(p) # Initial guess for the optimization
optres = maximize(β -> poisreg_loglik(β, y, X), β₀, BFGS(), autodiff = :forward)
βmle = Optim.maximizer(optres)

# Compute Hessian to get approximate standard errors
H(β) = ForwardDiff.hessian(β -> poisreg_loglik(β, y, X), β)
Ωᵦ = Symmetric(-inv(H(βmle))) # This is J^{-1}
diag(Ωᵦ) # Diagonal elements are the variances of the MLEs
se = sqrt.(diag(Ωᵦ)) # Standard errors of the MLEs
println("βmle: \n", βmle)
println("Standard errors: \n", se)

# Automatic differentiation with ForwardDiff.jl
∂loglik(β) = ForwardDiff.gradient(β -> poisreg_loglik(β, y, X), β)
∂loglik(βmle) # Gradient at the MLE, should be close to zero
∂loglik(β₀) # Gradient at the initial value
