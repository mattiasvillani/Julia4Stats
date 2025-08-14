using LinearAlgebra, Distributions, Statistics, Plots, LaTeXStrings

# Julia as a calculator
a = 2
b = 3
c = a + b
sin(3)

# Basic data types
typeof(a) # Integer
typeof(1.0) # Float
d = "Hej"
typeof(d) # String
println(d * ", Värld!") # Multiplication to concatenate strings

# Loops and all that
for i in 1:10
    println("Hello, World! $i") # String interpolation with $-sign
end

a = 1
while a < 10
    println("a is $a")
    a += 1
end

# Python-style enumerate loop
for (counter, item) in enumerate(["a", "b", "c"])
    println("Item $counter is $item")
end

[i^2 for i in 1:10] # List comprehension to create a vector of squares

[i*j for i in 1:3, j in 1:3] # Nested list comprehension to create a matrix

# Defining functions
function myfunc(x)
    return x^2 + 2x + 1
end
myfunc(3)

mysimplefunc(x) = x^2 + 2x + 1 # Shorter syntax for simple functions

# Function with multiple arguments and default values
function f(x, y = 1)
    return x^2 + y^2
end
f(4,2)
f(4)  # y defaults to 1

# Function with multiple return values as a tuple
function g(x, y)
    return x + y, x - y
end
res = g(3, 2) # R-style returning a tuple
res[1]
res[2]

a, b = g(3, 2) # Matlab-style unpacking when called
a
b

# Vector, matrix, and array operations
v = [1, 2, 3] # Vector of integers
v = [1.0, 2, 3] # Vector of Floats
v[1]    
v[1:2] # Accessing the first two elements
v[end] # Accessing the last element
A = [1 2; 3 4; 5 6] # Matrix
A[:,1] # Accessing the first column
A[1,:] # Accessing the first row
A[1,2] # Accessing the element at row 1, column 2
A = rand(3,2,4) # 3D array with random numbers
A[:,:,1] # Accessing the first "slice" of the 3D array
A[2,2,1] # Accessing the element at row 2, column 2, slice 1
I(3) # Identity matrix of size 3x3


A = randn(10,3)
C = rand(3,3)
b = [1, 2, 3]
A*b # Matrix-vector multiplication
A*C # Matrix-matrix multiplication
D = A'*A
isposdef(D)
det(D)      # Determinant of matrix A
inv(D)      # Inverse of matrix A
eigvals(D) # Eigenvalues of matrix A
eigvecs(D)
kron(A, D) # Kronecker product of A with itself
Symmetric(D) # Makes A symmetric if it isn't because of floating point numerics

F = [A; C] # Concatenating matrices vertically, same as vcat(A, C)
[A randn(10,2)] # Concatenating matrices horizontally, same as hcat(A, randn(10,2))

# Unicode is allowed in Julia: type \alpha and Tab to get α
n = 100
x = randn(n) # covariate data
X = [ones(n) x]
β = [1,3]
y = X*β + randn(n) # Linear model
βhat = inv(X'X)X'y # Linear regression using matrix inversion. Note X'X = X'*X etc
βhat = X \ y # Linear regression using Matlab-type backslash operator

# Define your operator
⊗(A, B) = kron(A, B) # Kronecker product operator
A ⊗ D == kron(A, D) 
inv(A'*A ⊗ D) == inv(A'*A) ⊗ inv(D) # not necessarily true, because of floating point errors
inv(A'*A ⊗ D) ≈  inv(A'*A) ⊗ inv(D) # always true ( ≈ typed as \approx and Tab)

# Plot the regression line
regline(x, β) = β[1] + β[2]*x # Regression line function
plot(x, y, seriestype=:scatter, label="Data", markercolor = :gray, 
    xlabel = "x", ylabel = "y", title = "Linear regression example")
plot!([minimum(x), maximum(x)], [regline(minimum(x), β), regline(maximum(x), β)], 
    color = "red", lw = 2, label="True regression Line")
plot!([minimum(x), maximum(x)], [regline(minimum(x), βhat), regline(maximum(x), βhat)], 
    color = "blue", lw = 2, label="Estimated regression Line")
    
# String interpolation with $-sign
plot!(title = "Estimated slope: $(round(βhat[2], digits=2))")

# LaTeX in plots with LaTeXStrings.jl package
plot!(title = "There is nothing " * L"\beta"*" about this plot",
      xlabel = L"\alpha\cdot \gamma", ylabel = L"\beta^n",)


# Basic statistics
v = randn(10000)
mean(v) # Mean of vector v
std(v)  # Standard deviation of vector v    
median(v) # Median of vector v
quantile(v, [0.025,0.5,0.975]) # Quantiles of vector v

# Broadcasting
x = [1, 2, 3]
y = [4, 5, 6]
x*y                     # error: x*y is not defined for vectors x'*y is
x .* y                  # element-wise multiplication with dot operator
sin(x)                  # gives an error sin(x) is not defined for arrays
sin.(x) # broadcasting with dot operator. The sin function is applied to each element of x.
sin.(cos.(x))           # fused broadcasting, only one loop is created.
sin.(A)                 # Broadcasting works for matrices and arrays as well.
myfunc.([1,2,3])        # Broadcasting a user-defined function
g.([1,2,3], [1,2,1])    # Broadcasting a function with multiple arguments

# Multiple dispatch
function addEmUp(x::Int, y::Int)
    return x + y
end
addEmUp(1,2)

function addEmUp(x::String, y::String)
    return x * y
end
addEmUp("Hello, ", "World!") # Calls the String version

addEmUp(1.0, 2.0) # Errors, there is no method for Float64

function addEmUp(x::Real, y::Real)
    return x + y
end
addEmUp(1.0, 2.0) # ok now

addEmUp(1.0, 2 + 3*im) # Complex numbers are not Real, so this will error

# Define a function without type annotations, defaults to Any
function addEmUp(x, y)
    return x + y
end
addEmUp(1.0, 2 + 3*im) # Works now, dispatched to the generic method with type Any

addEmUp(3, "hej")      # Does not work, dispatches to the generic method and fails.

Int <: Real     # Int is a subtype of Real
Real <: Number  # Real is a subtype of Number
Number <: Any   # Real is a subtype of Any
Real <: Complex
Complex <: Number
String <: Number

# Julia is JIT compiled, so important that compiler can infer types (type stable)
function clipzero(x)
    if x < 0
        return 0
    else
        return x
    end
end
clipzero(2)     # Returns Int64
clipzero(2.0)   # Returns Float64
clipzero(-2)    # Returns Int64
clipzero(-2.0)  # Returns Int64
# The return value TYPE depends on the VALUE of the input.

@code_warntype clipzero(2.0) # Function is type not type stable. Red text!

function clipzero_stable(x)
    if x < 0
        return zero(x) # zero(x) returns the same type as x
    else
        return x
    end
end
clipzero_stable(2)     # Returns Int64
clipzero_stable(2.0)   # Returns Float64
clipzero_stable(-2)    # Returns Int64
clipzero_stable(-2.0)  # Returns Float64

@code_warntype clipzero_stable(2.0) # Function is type stable. No red text!