# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.
# They will be loaded from a data (.dat) file.

# 'FoodTypes': A set holding the names of all the foods
# we can choose to buy (e.g., 'apples', 'broccoli', 'chicken').
set FoodTypes;

# 'Nutrients': A set holding the names of all the nutritional
# requirements we must meet (e.g., 'Vitamin C', 'Protein', 'Calories').
set Nutrients;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Food_Cost': An array. For each food 'f', this is the
# cost for *one unit* of that food.
param Food_Cost {f in FoodTypes}, >=0, default 0;

# 'Content': A 2D-array (matrix) that stores the nutritional
# information for each food.
# 'Content[f,n]' is the amount of nutrient 'n' in
# *one unit* of food 'f'.
param Content {f in FoodTypes, n in Nutrients}, >=0, default 0;

# 'Requirement': An array. For each nutrient 'n', this
# is the *minimum amount* of that nutrient we must get.
param Requirement {n in Nutrients}, >=0, default 0;

# === 3. VARIABLE DECLARATIONS ===
# These are the "decisions" or "answers" the solver needs to find.

# 'eaten': An array of variables, one for each food 'f'.
# This variable will hold the *quantity* of food 'f' to buy.
# '>=0' means we can't "un-buy" food.
var eaten {f in FoodTypes}, >=0;

# 'total_costs': A helper variable to store the final
# cost of our diet.
var total_costs;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (limitations).

# 'Nutrient_Requirements': This is an indexed constraint.
# '{n in Nutrients}' means it creates *one rule*
# for *each* nutrient.
#
# 'sum {f in FoodTypes} Content[f,n] * eaten[f]'
# This sum calculates the *total amount* of nutrient 'n'
# we get from *all* the food we decided to eat.
#
# '>= Requirement[n]'
# This says the total amount of nutrient 'n' we consume
# must be *greater than or equal to* our minimum requirement.
s.t. Nutrient_Requirements {n in Nutrients}: sum {f in FoodTypes} Content[f,n] * eaten[f] >= Requirement[n];

# 'Total_Costs_Calc': This is a simple constraint to
# calculate the 'total_costs' variable.
# It sums up (Cost of food 'f') * (Amount of food 'f' eaten)
# for all foods.
s.t. Total_Costs_Calc: total_costs = sum {f in FoodTypes} Food_Cost[f] * eaten[f];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs: total_costs;'
# The solver's goal is to find a valid solution (one
# that meets all 'Nutrient_Requirements') that makes
# the 'total_costs' variable as *small* as possible.
minimize Total_Costs: total_costs;

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for the 'eaten' variables.
solve;

# Print the final, minimized total cost.
printf "Total Costs: %g\n", total_costs;

# This is a *post-solve* parameter calculation.
# It's calculated *after* the 'solve' command, using
# the optimal 'eaten[f]' values.
# 'Nutrient_Intake' stores the final calculated intake
# for each nutrient 'n' in the optimal diet.
param Nutrient_Intake {n in Nutrients} := sum {f in FoodTypes} Content[f,n] * eaten[f];

# This 'for' loop iterates through each food type...
for {f in FoodTypes}
{
	# ...and prints how much of it we decided to eat.
	printf "Eaten of %s: %g\n", f, eaten[f];
}

# This 'for' loop iterates through each nutrient...
for {n in Nutrients}
{
	# ...and prints a report showing the requirement vs.
	# the actual amount we are getting in the optimal diet.
	# 'Nutrient_Intake[n]' will always be >= 'Requirement[n]'.
	printf "Requirement %g of nutrient %s done with %g\n", Requirement[n], n, Nutrient_Intake[n];
}

# Marks the end of the model file.
end;