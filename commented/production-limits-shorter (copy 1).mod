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

# 'Min_Usage': A *minimum* amount of raw material 'r' that
# we *must* consume (e.g., due to a contract).
param Min_Usage {r in Raw_Materials}, >=0, <=Storage[r], default 0;
# 'Min_Production': A *minimum* quantity of product 'p' that
# we *must* produce.
param Min_Production {p in Products}, >=0, default 0;
# 'Max_Production': A *maximum* quantity of product 'p' that
# we *can* produce (e.g., market demand).
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'production': The quantity of each product 'p' to make.
var production {p in Products}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (limitations).
s.t.
# 'Material_Balance': This is a "ranged constraint" for material usage.
# It's a "shorter" way to write *two* constraints:
# 1) The total consumed (the 'sum') must be >= 'Min_Usage[r]'.
# 2) The total consumed (the 'sum') must be <= 'Storage[r]'.
Material_Balance {r in Raw_Materials}: Min_Usage[r] <= sum {p in Products} Consumption_Rate[r,p] * production[p] <= Storage[r];
s.t.
# 'Production_Limits': This is another "ranged constraint".
# It's a "shorter" way to write *two* constraints:
# 1) 'production[p]' must be >= 'Min_Production[p]'.
# 2) 'production[p]' must be <= 'Max_Production[p]'.
# This sets the lower and upper bounds for our variable.
Production_Limits {p in Products}: Min_Production[p] <= production[p] <= Max_Production[p];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Revenue:'
# The solver's goal is to find the 'production' values
# that satisfy *all* constraints and make the
# total revenue as large as possible.
maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run.
solve;

# Print the final, maximized total revenue.
printf "Total Revenue: %g\n", sum {p in Products} Revenue[p] * production[p];

# === 7. POST-SOLVE CALCULATIONS ===
# These parameters are calculated *after* the 'solve' command.

# 'Material_Consumed': Calculates the total consumption for each 'r'.
param Material_Consumed {r in Raw_Materials} := sum {p in Products} Consumption_Rate[r,p] * production[p];
# 'Material_Remained': Calculates the leftover amount for each 'r'.
param Material_Remained {r in Raw_Materials} := Storage[r] - Material_Consumed[r];

# === 8. OUTPUT RESULTS ===

# This loop prints the optimal quantity for each product.
for {p in Products}
{
	printf "Production of %s: %g\n", p, production[p];
}

# This loop prints the usage report for each material.
for {r in Raw_Materials}
{
	printf "Usage of %s: %g, remaining: %g\n", r, Material_Consumed[r], Material_Remained[r];
}

# Marks the end of the model file.
end;