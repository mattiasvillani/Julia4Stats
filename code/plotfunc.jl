# adding Plots.jl package programatically (needed if it is not already installed)
import Pkg; Pkg.add("Plots")
using Plots

# Define the function that does the work 
function plotfunction(func, a, b)
  xgrid = range(a, b, length = 100)
  plt = plot(xgrid, func.(xgrid), color = :blue, xlabel = "x", ylabel = "f(x)")
  return plt
end

# Use the function to produce the plot
plt = plotfunction(x -> x^2, -2, 2) # x -> x^2 defines an anonymous function

# save plot to file
savefig(plt, "myplot.pdf")