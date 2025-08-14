function R2(σ²ᵧ, β, Σ)
    SST = σ²ᵧ + β'*Σ*β
    SSR = β'*Σ*β
    return SSR/SST
end