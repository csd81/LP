# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.

# 'Products': A set holding the names of the final products (e.g., 'chair').
set Products;
# 'Raw_Materials': A set holding the names of the materials (e.g., 'wood').
set Raw_Materials;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Storage': The *maximum* amount of each raw material 'r' available.
param Storage {r in Raw_Materials}, >=0;
# 'Consumption_Rate': The "recipe" matrix: amount of 'r' per unit of 'p'.
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
# 'Revenue': The money we get for *selling* one unit of 'p'.
param Revenue {p in Products}, >=0, default 0;
# 'Min_Usage': A *minimum* amount of raw material 'r' that we *must* consume.
param Min_Usage {r in Raw_Materials}, >=0, default 0;
# 'Min_Production': A *minimum* quantity of product 'p' that we *must* produce.
param Min_Production {p in Products}, >=0, default 0;
# 'Max_Production': A *maximum* quantity of product 'p' that we *can* produce.
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

# 'Material_Cost': This is the key new parameter.
# It's the cost to *purchase* one unit of raw material 'r'.
param Material_Cost {r in Raw_Materials}, >=0, default 0;

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver needs to find.

# 'production': The quantity of each product 'p' to make.
# All bounds (min/max) are applied directly here.
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];

# 'usage': A helper variable for total material consumed.
# All bounds (min usage/max storage) are applied directly here.
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];

# 'total_revenue': A helper variable to store the total revenue.
var total_revenue;
# 'profit': A helper variable to store the final profit.
var profit;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.

# 'Usage_Calc': Links 'production' and 'usage'.
# The 'usage' variable *must be equal to* the
# total material consumed by the 'production' decisions.
s.t. Usage_Calc {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];
s.t.
# 'Total_Revenue_Calc': Calculates the 'total_revenue' variable
# based on (Revenue per unit) * (Units produced).
Total_Revenue_Calc: total_revenue = sum {p in Products} Revenue[p] * production[p];
s.t.
# 'Profit_Calc': This is the new, crucial constraint.
# It defines profit as (Total Revenue) - (Total Material Cost).
# Total Material Cost = (Cost of 'r') * (Usage of 'r')
Profit_Calc: profit = total_revenue - sum {r in Raw_Materials} Material_Cost[r] * usage[r];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Profit: profit;'
# The solver's goal is to find 'production' values that
# satisfy all constraints/bounds and make the
# 'profit' helper variable as large as possible.
maximize Profit: profit;

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run.
solve;

# Print the final, maximized total revenue and profit.
printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;

# This loop prints the optimal quantity for each product.
for {p in Products}
{
	printf "Production of %s: %g\n", p, production[p];
}

# This loop prints the usage report for each material.
for {r in Raw_Materials}
{
	printf "Usage of %s: %g, remaining: %g\n", r, usage[r], Storage[r] - usage[r];
}

# Marks the end of the model file.
end;