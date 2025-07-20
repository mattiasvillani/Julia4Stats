# The Getting started tutorial on turinglang.org (https://turinglang.org/docs/tutorials/docs-00-getting-started/)

using Turing, StatsPlots

# Define a simple Normal model with unknown mean and variance
@model function gdemo(x, y)
    s² ~ InverseGamma(2, 3)
    m ~ Normal(0, sqrt(s²))
    x ~ Normal(m, sqrt(s²))
    y ~ Normal(m, sqrt(s²))
end

chain = sample(gdemo(1.5, 2), NUTS(), 1000, progress=false)

plot(chain)
mean(chain[:m]), mean(chain[:s²])
