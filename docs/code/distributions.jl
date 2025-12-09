using Distributions, Plots, LaTeXStrings, LinearAlgebra

dist = Normal(1,3) # Create a normal distribution with mean 1 and std dev 3
pdf(dist, 0) # Evaluate the PDF at x = 0
cdf(dist, 0) # Evaluate the CDF at x = 0
quantile(dist, 0.5) # Find the quantile at 50% (median)
rand(dist, 10) # Generate 10 random samples from the distribution   

# Location-scale by adding a location parameter and multiplying by a scale parameter
1 + 2*TDist(3)
TDist(μ, σ, ν) = μ + σ*TDist(ν)
TDist(3)
dist = TDist(1, 2, 3)
pdf(dist, 0) # Evaluate the PDF at x = 0

# Truncated distributions
truncdist = Truncated(Normal(0, 1), -1, 1) # Truncated normal distribution between -1 and 1
pdf(truncdist, 0) 
cdf(truncdist, -0.95) 

# Mixture distributions
mixdist = MixtureModel([Normal(0, 1), Normal(5, 3)], [0.5, 0.5]) # Mixture of two normals
x = range(-5, 20, length=1000)
plot(x, pdf.(mixdist, x), label="Mixture PDF", xlabel="x", ylabel="Density",
     title="Mixture of Two Normals", legend=:topright,
     color=:blue, linewidth=2)
samples = rand(mixdist, 10000) # Generate samples from the mixture distribution
histogram!(samples, bins = 50, normalize = true, color = :lightblue, alpha = 0.5, 
    label = "histogram of samples")

# Truncated mixture distributions
truncmixdist = Truncated(mixdist, -1, 5)
plot!(x, pdf.(truncmixdist, x), label="Truncated Mixture PDF", 
     xlabel="x", ylabel="Density", color=:indianred, linewidth=2)

# The mixture components can also be different distributions
d1 = Gamma(2, 1)
d2 = LogNormal(5, 3)
mixdist2 = MixtureModel([d1, d2], [0.2, 0.8])
x = range(0, 15, length=1000)
plot(x, pdf.(mixdist2, x), label="Gamma-LogNormal mixture PDF", 
     xlabel="x", ylabel="Density", color=:green, linewidth=2)

# Multivariate distributions
μ = [1, 2]
Σ = [1 0.5; 0.5 2]    
dist = MvNormal(μ, Σ) 
samples = rand(dist, 100);
chisqVals = quantile.(Chisq(2), reverse([eps(), 0.1, 0.25, 0.5, 0.75, 0.95]))
pdfAtContours = (1/√det(2*π*Σ))*exp.(-0.5*chisqVals)

x = range(-2, 4, length = 100)
y = range(-2, 6, length = 100)
f(x,y) = pdf(dist, [x, y])
contourf(x, y, f, levels = pdfAtContours, xlabel = L"x_1", ylabel = L"x_2", grid = false,
    title = "Bivariate Normal PDF", fill = true, color = :Blues, 
    linecolor = :black)
scatter!(samples[1, :], samples[2, :], color = :gray, 
    markerstrokecolor = :auto, markersize = 3, label = "")