using RCall, PyCall

# Just some regression data to play with
n = 100
p = 3
X = randn(n,p)
β = [1, 2, 0.5]
σ = 0.3
y  = X*β + σ*randn(n)

# Call R from Julia with RCall.jl
R"plot(rnorm(10))"  # Evaluates in R
R"plot(rnorm($n))"  # Julia variables are interpolated into R code with $-sign
@rput y             # Push Julia variable y to R
@rput X
R"modelFit <- lm(y ~ X)"
R"summary(modelFit)"
R"betaHat <- modelFit$coef"
βhat = @rget betaHat # Pull the R variable betaHat back to Julia
βhat # lives in Julia now

R"optim(0, $(x -> x-cos(x)), method='BFGS')" # anonymous x -> x-cos(x) evaluated in Julia

# triple quotes for R chunks
x = 2
@rput x
R"""
    f <- function(x, y) x + y
    out <- f(1, $y)
"""
out = @rget out # Pull the R variable out back to Julia

# We can wrap R functions in Julia functions
function ARMAacf(ar, ma; lagmax, pacf = false) 
    R"""
        acf_theo = ARMAacf(ar = $ar, ma = $ma, lag.max = $lagmax, pacf = $pacf)
    """
    @rget acf_theo
	return acf_theo
end

ARMAacf([0.5, -0.2], [0.3]; lagmax = 5) # This is Julia function now


# Using Julia from R

############## PRELMINARIES TO GET JULIA RUNNING FROM R  ########################
# First, install Julia by downloading it from https://julialang.org/install/

# Install JuliaCall package in R 
# install.packages("remotes") # needed R package for Github install of R packages
# library(remotes) 

#remotes::install_github("Non-Contradiction/JuliaCall") # installs the JuliaCall package
#library(JuliaCall)

options(JULIA_HOME = " ~/.juliaup/bin/julia")     # Set the path to your Julia binary
julia_setup()                                     # Setup Julia
julia_command("a = sqrt(2.0)")                    # Just for testing if the install worked.

# Install needed Julia packages
julia_install_package("LinearAlgebra")           # Installs Julia package
julia_library("LinearAlgebra")                   # Loads Julia package
julia_install_package("Distributions")
julia_library("Distributions")
################################################################################

julia_source("code/poisloglik.jl") # Julia code file, contains:
#function poisreg_loglik(β, y, X)                        
#   return sum(logpdf.(Poisson.(exp.(X*β)), y))
#end

# This is the R function definition, wrapping the Julia function
poisreg_loglik <- function(beta_, y, X){
  return(julia_call("poisreg_loglik", beta_, y, X))
}
X = cbind(1, matrix(rnorm(100)))
beta_ = c(0.5,-0.5)
y = rpois(100, lambda = exp(X %*% beta_))
poisreg_loglik(beta_, y, X)


# Using Python from Julia with PyCall.jl

# You may need to set the path to Anaconda Python and re-build PyCall.jl: 
# Restart Julia after building PyCall.jl
# ENV["PYTHON"] = "/home/mv/anaconda3/bin/python"
# ] build PyCall

# Plot using matplotlib from Python
plt = pyimport("matplotlib.pyplot")
x = range(0; stop=2*pi, length=1000); 
y = sin.(3*x + 4*cos.(2*x));
plt.plot(x, y, color="red", linewidth=2.0, linestyle="--")
plt.show()

# Using SciPy for optimization
so = pyimport("scipy.optimize")
so.newton(x -> cos(x) - x, 1)

# Use Python functions in Julia
py"""
import numpy as np

def my_sin(x):
    print("hello from the Python side.")
    return np.sin(x)
"""
py"my_sin"(π/2)

function my_sin(x)
    return(py"my_sin"(x))
end
my_sin(π/2) # This is a Julia function that calls the Python function



