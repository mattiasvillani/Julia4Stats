using LinearAlgebra, Distributions, Statistics, Plots

# Julia as a calculator
a = 2
b = 3
c = a + b
sin(3)

# Broadcasting
x = [1, 2, 3]
sin(x)  # gives an error sin(x) is not defined for arrays
sin.(x) # broadcasting with dot operator. The sin function is applied to each element of x.

# Plotting
xgrid = -pi:0.01:pi # or π:0.01:π using Unicode
plot(xgrid, sin.(xgrid), label="sin(x)", title="Sine Function", xlabel="x", ylabel="sin(x)")