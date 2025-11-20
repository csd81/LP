# === 1. SET DECLARATION ===
# 'Items' is a set that will hold the names of all the items
# we can choose from (e.g., 'gold', 'silver').
set Items;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data for our problem.

# 'Weight' is an array. For each item 'i', it stores
# the total weight of *100%* of that item.
param Weight {i in Items}, >=0;

# 'Gain' is an array. For each item 'i', it stores
# the total value or profit (gain) of *100%* of that item.
param Gain {i in Items}, >=0;

# 'Capacity' is a single number representing the maximum total
# weight the knapsack can hold.
param Capacity, >=0;

# === 3. VARIABLE DECLARATION ===
# This is the key difference for the "relaxed" problem.

# 'select' is an array of variables, one for each item 'i'.
#
# 'binary' (used in the 0/1 problem) is replaced with '>=0, <=1'.
# This means 'select[i]' is a *continuous* variable that
# can be any fraction between 0 (0%) and 1 (100%).
#   - select[i] = 1 means "take 100% of item i"
#   - select[i] = 0 means "take 0% of item i"
#   - select[i] = 0.5 means "take 50% of item i"
var select {i in Items}, >=0, <=1;

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules of the problem.

# 'Total_Weight:' is the name of our one constraint.
# 'sum {i in Items} select[i] * Weight[i]'
# This calculates the total weight. If select[i] is 0.5,
# it adds 50% of that item's full weight to the total.
#
# '<= Capacity'
# This ensures the total weight of selected items (and fractions
# of items) does not exceed the knapsack's capacity.
s.t. Total_Weight:
	sum {i in Items} select[i] * Weight[i] <= Capacity;

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Gain:' tells the solver to find the solution
# that gives the largest possible value for this expression.
# 'sum {i in Items} select[i] * Gain[i]'
# This calculates the total gain. If select[i] is 0.5,
# it adds 50% of that item's full gain to the total.
maximize Total_Gain:
	sum {i in Items} select[i] * Gain[i];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to find the optimal
# *fractional* values for 'select' that obey the 'Total_Weight'
# constraint and maximize the 'Total_Gain'.
solve;

# Print the final, maximum gain achieved.
# This value will be >= the optimal gain from the 0/1 version.
printf "Optimal Gain: %g\n", Total_Gain;

# Print the total weight of the items in the optimal solution.
# In the optimal solution, this will almost always be *exactly*
# equal to the 'Capacity'.
printf "Total Weight: %g\n",
	sum {i in Items} select[i] * Weight[i];

# This 'for' loop iterates through all items...
for {i in Items}
{
	# ...and prints the fraction of each item that was selected.
	# You will often see '1' (for 100%) and '0' (for 0%)
	# and at most *one* fractional value (e.g., '0.75').
	printf "%s: %g\n", i, select[i];
}

# Marks the end of the model file.
end;