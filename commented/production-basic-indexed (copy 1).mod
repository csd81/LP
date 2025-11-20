Here is the commented GMPL code.

This is a classic **Product Mix Problem**. The goal is to decide how much of each product to make to maximize revenue, given that you have a limited amount of raw materials.

```ampl
# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.
# They will be loaded from a data (.dat) file.

# 'Products': A set holding the names of the final products
# we can make and sell (e.g., 'chair', 'table').
set Products;

# 'Raw_Materials': A set holding the names of the materials
# we have in stock (e.g., 'wood', 'glue', 'screws').
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
# 'default 0' means if a product doesn't use a material,
# we don't have to specify '0' in the data file.
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;

# 'Revenue': An array. For each product 'p', this is the
# money we get for selling *one unit* of it.
param Revenue {p in Products}, >=0, default 0;

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'production': An array of variables, one for each product 'p'.
# This variable will hold the *quantity* of product 'p' to make
# (e.g., produce 10.5 chairs, produce 5 tables).
# '>=0' means we can't produce a negative amount.
var production {p in Products}, >=0;

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules (limitations)
# of the problem.

# 'Material_Balance': This is an indexed constraint.
# '{r in Raw_Materials}' means it creates *one rule*
# for *each* raw material.
#
# 'sum {p in Products} Consumption_Rate[r,p] * production[p]'
# This sum calculates the *total amount* of raw material 'r'
# that is consumed by *all* the production decisions.
#
# '<= Storage[r]'
# This says the total amount of material 'r' consumed
# must be *less than or equal to* the amount we have
# in storage.
s.t. Material_Balance {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] <= Storage[r];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Revenue:' tells the solver to find the solution
# that gives the *largest* possible value for this expression.
#
# 'sum {p in Products} Revenue[p] * production[p]'
# This calculates the total revenue by summing up
# (Revenue for one unit of 'p') * (Quantity of 'p' produced)
# for all products.
maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for the 'production' variables.
solve;

# Print the final, maximized total revenue.
# We can also just print the objective function's name: printf "... %g\n", Total_Revenue;
printf "Total Revenue: %g\n", sum {p in Products} Revenue[p] * production[p];

# This 'for' loop iterates through each product...
for {p in Products}
{
	# ...and prints how much of it we decided to produce.
	printf "Production of %s: %g\n", p, production[p];
}

# This 'for' loop iterates through each raw material...
for {r in Raw_Materials}
{
	# ...and prints a report showing how much was used
	# and how much is left over.
	printf "Usage of %s: %g, remaining: %g\n", r, sum {p in Products} Consumption_Rate[r,p] * production[p], Storage[r] - sum {p in Products} Consumption_Rate[r,p] * production[p];
}

# Marks the end of the model file.
end;
```