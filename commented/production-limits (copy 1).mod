# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.

# 'Products': A set holding the names of the final products
# [cite_start]we can make and sell (e.g., 'chair', 'table'). [cite: 7]
set Products;
# 'Raw_Materials': A set holding the names of the materials
# [cite_start]we have in stock (e.g., 'wood', 'glue'). [cite: 7]
set Raw_Materials;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Storage': The *maximum* amount of each raw material 'r'
# available in our inventory.
# [cite_start]'default 1e100' means "unlimited" if not specified. [cite: 7]
param Storage {r in Raw_Materials}, >=0, default 1e100;

# 'Consumption_Rate': The "recipe" matrix.
# 'Consumption_Rate[r,p]' is the amount of raw material 'r'
# [cite_start]needed to produce *one unit* of product 'p'. [cite: 8]
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;

# 'Revenue': The money we get for selling *one unit*
# [cite_start]of each product 'p'. [cite: 8]
param Revenue {p in Products}, >=0, default 0;

# 'Min_Usage': A *minimum* amount of raw material 'r' that
# we *must* consume. This could be due to a contract.
# [cite_start]'default 0' means no minimum usage unless specified. [cite: 9]
param Min_Usage {r in Raw_Materials}, >=0, <=Storage[r], default 0;

# 'Min_Production': A *minimum* quantity of product 'p' that
# [cite_start]we *must* produce. [cite: 9]
param Min_Production {p in Products}, >=0, default 0;

# 'Max_Production': A *maximum* quantity of product 'p' that
# we *can* produce. This often represents market demand.
# [cite_start]'default 1e100' means "unlimited" if not specified. [cite: 10]
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'production': The quantity of each product 'p' to make.
# Note: The bounds (min/max) will be set by constraints
# [cite_start]instead of being applied directly to the variable here. [cite: 10]
var production {p in Products}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (limitations).
s.t.
# 'Material_Balance': (Upper Limit)
# The total amount of material 'r' consumed
# [cite_start]must be *less than or equal to* the amount in storage. [cite: 11]
Material_Balance {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] <= Storage[r];
s.t.
# 'Cons_Min_Usage': (Lower Limit)
# The total amount of material 'r' consumed
# [cite_start]must be *greater than or equal to* the 'Min_Usage' requirement. [cite: 12]
Cons_Min_Usage {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] >= Min_Usage[r];
s.t.
# 'Cons_Min_Production': (Lower Bound for Variable)
# The quantity produced for product 'p'
# [cite_start]must be *greater than or equal to* its 'Min_Production' level. [cite: 13]
Cons_Min_Production {p in Products}: production[p] >= Min_Production[p];
s.t.
# 'Cons_Max_Production': (Upper Bound for Variable)
# The quantity produced for product 'p'
# [cite_start]must be *less than or equal to* its 'Max_Production' level. [cite: 13]
Cons_Max_Production {p in Products}: production[p] <= Max_Production[p];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Revenue:'
# The solver's goal is to find the 'production' values
# that satisfy *all 4 constraints* and make the
# [cite_start]total revenue as large as possible. [cite: 14]
maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run.
solve;

# [cite_start]Print the final, maximized total revenue. [cite: 15]
printf "Total Revenue: %g\n", sum {p in Products} Revenue[p] * production[p];

# === 7. POST-SOLVE CALCULATIONS ===
# These parameters are calculated *after* the 'solve' command,
# using the optimal 'production' values.

# [cite_start]'Material_Consumed': Calculates the total consumption for each 'r'. [cite: 16]
param Material_Consumed {r in Raw_Materials} := sum {p in Products} Consumption_Rate[r,p] * production[p];

# [cite_start]'Material_Remained': Calculates the leftover amount for each 'r'. [cite: 17]
param Material_Remained {r in Raw_Materials} := Storage[r] - Material_Consumed[r];

# === 8. OUTPUT RESULTS ===

# [cite_start]This loop prints the optimal quantity for each product. [cite: 17]
for {p in Products}
{
	printf "Production of %s: %g\n", p, production[p];
}

# [cite_start]This loop prints the usage report for each material. [cite: 18]
for {r in Raw_Materials}
{
	printf "Usage of %s: %g, remaining: %g\n", r, Material_Consumed[r], Material_Remained[r];
}

# Marks the end of the model file.
end;