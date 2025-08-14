using Plots, LaTeXStrings, RDatasets, GLM
import PlotlyJS

mtcars = dataset("datasets", "mtcars")

# Make a scatter plot of Horsepower vs Miles per gallon
gr() # the GR backend is the default backend for Plots.jl
plt = scatter(mtcars.HP, mtcars.MPG, 
     xlabel = "Horsepower", ylabel = "Miles per gallon",
     title = "MPG vs Horsepower", label = "Data points", 
     legend = :topright, color = :blue)

# Fit a linear model using GLM.jl
using GLM
lm_model = lm(@formula(MPG ~ HP), mtcars)

# Add the fitted line to the plot, note the mutating plot! function
plot!(mtcars.HP, predict(lm_model), 
     label = "Fitted line", color = :red, linewidth = 2)  

# Add a LaTeX string to the title
βhat = round.(coef(lm_model), digits = 3)
plot!(title = L"\beta_0 = %$(βhat[1])"* " and "* L"\beta_1 = %$(βhat[2])") 

# Save the plot to a file
savefig("mtcars_plot.pdf")

# Plot a surface, with GR and PlotlyJS backends
gr()
xs = range(-4, 4; length=150)
ys = range(-4, 4; length=150)
f(x, y) = sin(x) * cos(y) * exp(-(x^2 + y^2)/8)
Plots.surface(xs, ys, f; xlabel = L"x", ylabel = L"y", zlabel = L"f(x,y)", 
    legend=false, camera = (30, 60))

plotlyjs() # swithing to plotlyjs for interactive Plots
Plots.surface(xs, ys, f; xlabel = L"x", ylabel = L"y", zlabel = L"f(x,y)", 
    legend=false, camera = (30, 60))
