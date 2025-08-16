function poisreg_loglik(β, y, X)                        
    return sum(logpdf.(Poisson.(exp.(X*β)), y))
end