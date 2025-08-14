using CSV, DataFrames, DataFramesMeta, Plots, Statistics, LaTeXStrings, Measures

## READING AND WRITING DATA FROM FILE
titanic = CSV.read("data/titanic.csv", DataFrame) # read from file directly into a DataFrame
titanic[1:5, :]         # Show the first 5 rows of the DataFrame
titanic[:, [1,2,4,5]]   # Show columns 1, 3, and 4
titanic.age             # Access the 'age' column

# Read data from a URL using the standard library Downloads
using Downloads
url = "https://github.com/mattiasvillani/Julia4Stats/raw/main/data/titanic.csv"
http_response = Downloads.download(url)
titanic = CSV.read(http_response, DataFrame)

# Write data to a file
A = randn(100, 3)                       # Generate a random matrix 
CSV.write("data/random_data.csv", A)    # Error: expects a table (DataFrame) not a matrix
df = DataFrame(A, :auto)        # Convert the matrix to a DataFrame, automatic naming cols
df = DataFrame(A, ["x", "y", "z"])  # Convert the matrix to a DataFrame, naming cols
df = DataFrame(A, [:x, :y, :z])   # Alternative, using Julia symbols.

# Write the DataFrame to a CSV file
CSV.write("data/random_data.csv", df)

## DataFrames.jl

# Basic construction of a DataFrame by named columns.
df = DataFrame(age = [45, 64, 78, 52], b = ["M", "F", "F", "M"])
df = DataFrame(randn(5,4), :auto)  # Matrix constructor
df = DataFrame([[1, 2], [0, 0]], ["column1", "second_column"])  # From a vector of vectors
names(df)

# Build up a DataFrame incrementally
df = DataFrame()
df.A = randn(10)
df."this is a terrible column name" = randn(10)
df[:, :new_col] = randn(10)  # Add a new column
df

x = [1, 2, missing, 4]  # Julia has a missing data type
mean(x)
mean(skipmissing(x))  # Calculate mean, skipping missing values

df = DataFrame(i = 1:5, x = [missing, 4, missing, 2, 1],
                        y = [missing, missing, "c", "d", "e"])
dropmissing(df)     # returns a vector with rows with missing values dropped
dropmissing!(df)    # modifies df in place, dropping rows with missing values

# DataFrames.jl has some data wrangling capabilities built-in
df = DataFrame(
    name = ["Alice", "Bob", "Charlie"],
    age  = [25, 30, 35],
    score = [88, 92, 95]
)

# Transform, Select, and Filter
df2 = transform(df, :age => (x -> 2x) => :age_doubled)
transform!(df, :age => (x -> 2x) => :age_doubled)      # Modify df in place
df_selected = select(df, :name, :age_doubled)
df_filtered = filter(:age => >(28), df)

# Combine using DataFrames.jl
df_extra = DataFrame(
    name = ["Alice", "Bob", "Diana"],
    city = ["Stockholm", "Gothenburg", "Malmö"]
)
# Inner join: keeps only matching names
df_joined = innerjoin(df, df_extra, on = :name)

# Left join: keeps all rows from df, adds city if available. missing otherwise
df_left = leftjoin(df, df_extra, on = :name)

## DataFramesMeta for data wrangling, using julias macro @chain to pipe operations
df = DataFrame(
    name = ["Alice", "Bob", "Charlie"],
    age  = [25, 30, 35],
    score = [88, 92, 95]
)
result = @chain df begin
    @transform(:age_doubled = 2 .* :age)
    @subset(_, :score .> 90)       # pipes to first argument, here explicitly using _
    @select(:name, :score, :age_doubled) 
    leftjoin(df_extra, on = :name)          # normal DataFrames function
end
