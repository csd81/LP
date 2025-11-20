# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.

# 'Products': A set holding the names of the final products (e.g., 'chair').
set Products;
# 'Raw_Materials': A set holding the names of the materials (e.g., 'wood').
set Raw_Materials;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Storage': The *maximum* amount of each raw material 'r' available.
param Storage {r in Raw_Materials}, >=0, default 1e100;
# 'Consumption_Rate': The "recipe" matrix: amount of 'r' per unit of 'p'.
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
# 'Revenue': The money we get for selling one unit of 'p'.
param Revenue {p in Products}, >=0, default 0;
# 'Min_Usage': A *minimum* amount of raw material 'r' that we *must* consume.
param Min_Usage {r in Raw_Materials}, >=0, <=Storage[r], default 0;
# 'Min_Production': A *minimum* quantity of product 'p' that we *must* produce.
param Min_Production {p in Products}, >=0, default 0;
# 'Max_Production': A *maximum* quantity of product 'p' that we *can* produce.
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

# === 3. VARIABLE DECLARATIONS ===
# This is the "shortest" and most important part of this model.
# All simple bounds are applied *directly* to the variables.

# 'production': The quantity of each product 'p' to make.
# We tell the solver 'production[p]' *must* be between
# 'Min_Production[p]' and 'Max_Production[p]'.
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];

# 'usage': A *helper variable* to store the total material consumed.
# We tell the solver this variable *must* end up between
# the 'Min_Usage[r]' and 'Storage[r]' limits.
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];

# 'total_revenue': A helper variable to store the final revenue.
var total_revenue;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.
# Because the bounds are in the 'var' section, these constraints
# are only for "calculating" or "linking" the variables.
s.t.
# 'Usage_Calc': This constraint *links* 'production' and 'usage'.
# It says: The 'usage[r]' variable *must be equal to* the
# total material consumed by the 'production' decisions.
# The solver must find 'production' values that satisfy
# *both* this equation *and* the 'usage' bounds (from ).
Usage_Calc {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];
s.t.
# 'Total_Revenue_Calc': This constraint links 'production'
# and 'total_revenue'.
Total_Revenue_Calc: total_revenue = sum {p in Products} Revenue[p] * production[p];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Revenue: total_revenue;'
# The solver's goal is to find 'production' values that
# satisfy all constraints/bounds and make the
# 'total_revenue' helper variable as large as possible.
maximize Total_Revenue: total_revenue;

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run.
solve;

# Print the final, maximized total revenue.
printf "Total Revenue: %g\n", total_revenue;
# This loop prints the optimal quantity for each product.
for {p in Products}
{
	printf "Production of %s: %g\n", p, production[p];
}

# This loop prints the usage report for each material.
# It can use the 'usage' helper variable directly.
for {r in Raw_Materials}
{
	printf "Usage of %s: %g, remaining: %g\n", r, usage[r], Storage[r] - usage[r];
}

# Marks the end of the model file.
end;