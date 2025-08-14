using CSV, Downloads, Tidier # Tidier export DataFrame

# Read data from a URL using the standard library Downloads
url = "https://github.com/mattiasvillani/Julia4Stats/raw/main/data/titanic.csv"
http_response = Downloads.download(url)
titanic = CSV.read(http_response, DataFrame)

# Making up random data to demonstrate a join
titanic_extra = DataFrame(
    name = titanic.name,
    height = sample(100:200, nrow(titanic)),
    weight = sample(30:0.1:100, nrow(titanic)),
)

## TidierData.jl for data wrangling using @chain macro from Tidier.jl
# transform (mutate) → filter → select → combine (left_join)
titanic2 = @chain titanic begin
    @mutate(survived = survived == 1)
    @mutate(first_class = pclass == 1)
    @filter(fare > 10)
    @left_join(titanic_extra) 
    @select(name, survived, age, sex, first_class, height, weight)
end

