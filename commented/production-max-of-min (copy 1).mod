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
# 'Revenue': The money we get for selling one unit of 'p'.
# (Note: Revenue is *not* used in the objective, but is calculated).
param Revenue {p in Products}, >=0, default 0;
# 'Min_Usage': A *minimum* amount of raw material 'r' that we *must* consume.
param Min_Usage {r in Raw_Materials}, >=0, default 0;
# 'Min_Production': A *minimum* quantity of product 'p' that we *must* produce.
param Min_Production {p in Products}, >=0, default 0;
# 'Max_Production': A *maximum* quantity of product 'p' that we *can* produce.
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver needs to find.

# 'production': The quantity of each product 'p' to make.
# The solver is bound by the 'Min_Production' and 'Max_Production' params.
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];

# 'usage': A helper variable to store the total material consumed.
# The solver is bound by the 'Min_Usage' and 'Storage' params.
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];

# 'total_revenue': A helper variable to *calculate* the revenue.
# It is *not* being optimized, just calculated for the final report.
var total_revenue;

# 'min_production': This is the *key variable* for the objective.
# It's a single variable that the solver will be forced
# to set to the value of the *smallest* 'production[p]'.
var min_production;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.
s.t.
# 'Usage_Calc': Links 'production' and 'usage'.
# The 'usage' variable must equal the total material consumed.
Usage_Calc {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];
s.t.
# 'Total_Revenue_Calc': Calculates the 'total_revenue' variable
# based on the final production plan.
Total_Revenue_Calc: total_revenue = sum {p in Products} Revenue[p] * production[p];
s.t.
# 'Minimum_Production_Calc': This is the core logic.
# '{p in Products}' means this rule is created *for each product*.
# It forces the 'min_production' variable to be *less than or equal to*
# *every* 'production[p]' value.
# To maximize 'min_production' (in the objective), the solver
# must raise it to the level of the *lowest* 'production[p]'.
Minimum_Production_Calc {p in Products}: min_production <= production[p];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Minimum_Production: min_production;'
# The solver's goal is to find a production plan that
# satisfies all the constraints AND makes the 'min_production'
# variable as large as possible. This "pulls up" the
# lowest production level, making the plan as balanced as possible.
maximize Minimum_Production: min_production;

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run.
solve;

# Print the final calculated revenue (for the 'maximin' solution).
printf "Total Revenue: %g\n", total_revenue;
# Print the optimal "minimum production" level.
printf "Minimum Production: %g\n", min_production;

# This loop prints the optimal quantity for each product.
# You will see that one (or more) of these values
# will be equal to the 'Minimum Production' printed above.
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