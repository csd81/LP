# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.
# They will be loaded from a data (.dat) file.

# 'Products': A set holding the names of the final products
# we can make and sell (e.g., 'chair', 'table').
set Products;

# 'Raw_Materials': A set holding the names of the materials
# we have in stock (e.g., 'wood', 'glue').
set Raw_Materials;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Storage': An array. For each raw material 'r', this
# is the total amount we have available (our inventory).
param Storage {r in Raw_Materials}, >=0;

# 'Consumption_Rate': A 2D-array (matrix) that defines
# the "recipe" for each product.
# 'Consumption_Rate[r,p]' is the amount of raw material 'r'
# needed to produce *one unit* of product 'p'.
# 'default 0' means it's assumed to be 0 if not in the data.
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;

# 'Revenue': An array. For each product 'p', this is the
# money we get for selling *one unit* of it.
param Revenue {p in Products}, >=0, default 0;

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'production': An array of variables, one for each product 'p'.
# This variable will hold the *quantity* of product 'p' to make.
# '>=0' means we can't produce a negative amount.
var production {p in Products}, >=0;

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules (limitations).

# 'Material_Balance': Creates one rule for each raw material.
# It says the total amount of material 'r' consumed
# (the sum on the left) must be less than or equal to
# the amount we have in 'Storage[r]'.
s.t. Material_Balance {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] <= Storage[r];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Revenue:' tells the solver to find the solution
# that gives the *largest* possible value for this expression.
# This calculates the total revenue by summing up
# (Revenue per unit) * (Units produced) for all products.
maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for the 'production' variables.
solve;

# Print the final, maximized total revenue.
printf "Total Revenue: %g\n", sum {p in Products} Revenue[p] * production[p];

# === 7. POST-SOLVE CALCULATIONS ===
# These parameters are calculated *after* the 'solve' command.
# They use the optimal 'production[p]' values found by the solver.
# This is a clean way to prepare data for the final report.

# 'Material_Consumed': Calculates the total consumption for
# each raw material 'r' based on the optimal solution.
param Material_Consumed {r in Raw_Materials} := sum {p in Products} Consumption_Rate[r,p] * production[p];

# 'Material_Remained': Calculates the leftover amount for each 'r'.
param Material_Remained {r in Raw_Materials} := Storage[r] - Material_Consumed[r];

# === 8. OUTPUT RESULTS ===

# This 'for' loop iterates through each product...
for {p in Products}
{
	# ...and prints how much of it we decided to produce.
	printf "Production of %s: %g\n", p, production[p];
}

# This 'for' loop iterates through each raw material...
for {r in Raw_Materials}
{
	# ...and prints the usage/remaining report using our
	# pre-calculated parameters.
	printf "Usage of %s: %g, remaining: %g\n", r, Material_Consumed[r], Material_Remained[r];
}

# Marks the end of the model file.
end;