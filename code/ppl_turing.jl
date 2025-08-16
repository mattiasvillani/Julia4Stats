using Turing, CSV, Downloads, DataFrames, LinearAlgebra, LaTeXStrings, Plots

# Reading and transforming the eBay data
url = "https://github.com/mattiasvillani/BayesianLearningBook/raw/main/data/ebaybids/ebaybids.csv" 
df = CSV.read(Downloads.download(url), DataFrame)
n = size(df,1)
y = df[:,:NBidders]
X = [ones(n,1) log.(df.BookVal) .- mean(log.(df.BookVal)) df.ReservePriceFrac .- mean(df.ReservePriceFrac) df.MinorBlem df.MajorBlem  df.NegFeedback df.PowerSeller df.IDSeller df.Sealed]

varnames = ["intercept", "logbook", "startprice", "minblemish", "majblemish",    
      "negfeedback", "powerseller", "verified", "sealed"]

# Setting up the poisson regression model
@model function poissonReg(y, X, τ)
    p = size(X,2)
    β ~ filldist(Normal(0, τ), p)  # all βⱼ are iid Normal(0, τ)
    λ = exp.(X*β)
    n = length(y)  
    for i in 1:n
        y[i] ~ Poisson(λ[i]) 
    end
end

# HMC sampling from posterior
p = size(X, 2)
μ = zeros(p)    # Prior mean
τ = 10          # Prior standard deviation Σ = τ²I
α = 0.70        # target acceptance probability in NUTS sampler
model = poissonReg(y, X, τ)
chain = sample(model, NUTS(α), 10000, discard_initial = 1000, verbose = false)
rateratio = exp.(chain.value) # exp(β) is the incidence rate ratio

gr(grid = false)
h = []
for i = 1:p
    ptmp = histogram(rateratio[:,i], nbins = 50, fillcolor = :indianred, linecolor = nothing, 
        normalize = true, title = varnames[i], xlab = L"\exp(\beta_{%$(i-1)})", 
        yaxis = false, fillopacity = 0.5)    
    push!(h, ptmp)
end
plot(h..., size = (600,600), legend = :right)


# Variational inference assuming posterior is independent normals
nSamples = 10
nGradSteps = 1000
approx_post = vi(model, ADVI(nSamples, nGradSteps)) # error when I try it now.
approx_post.dist.m # mean of variational approximation
approx_post.dist.σ # stdev of variational approximation
βsample = rand(approx_post, 10000)
expβvi = exp.(βsample)'


# Negative binomial regression 
@model function negbinomialReg(y, X, τ, μ₀, σ₀)
    p = size(X,2)
    β ~ filldist(Normal(0, τ), p)  # all βⱼ are iid Normal(0, τ)
    λ = exp.(X*β)
    ψ ~ LogNormal(μ₀, σ₀)             # log of overdispersion parameter
    n = length(y)  
    for i in 1:n
        y[i] ~ NegativeBinomial(ψ, ψ/(ψ + λ[i])) # mean is λ here, but var = λ(1 + λ/ψ) 
    end
end

μ₀ = 0   # Prior mean of log(ψ), where ψ is the overdispersion parameter
σ₀ = 10  
α = 0.70  # target acceptance probability in NUTS sampler
model = negbinomialReg(y, X[:,[1,3]], τ, μ₀, σ₀)
chain = sample(model, NUTS(α), 10000, discard_initial = 1000)
rateratio = exp.(chain.value)