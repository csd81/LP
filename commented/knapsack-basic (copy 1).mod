# === 1. SET DECLARATION ===
# 'Items' is a set that will hold the names of all the items
# we can choose from (e.g., 'gold', 'silver', 'bronze').
set Items;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data for our problem.

# 'Weight' is an array. For each item 'i' in the 'Items' set,
# it stores the weight of that item. '>=0' ensures weight is positive.
param Weight {i in Items}, >=0;

# 'Gain' is an array. For each item 'i', it stores the
# value or profit (gain) of that item. '>=0' ensures gain is positive.
param Gain {i in Items}, >=0;

# 'Capacity' is a single number representing the maximum total
# weight the knapsack can hold.
param Capacity, >=0;

# === 3. VARIABLE DECLARATION ===
# This is the "decision" the solver needs to make.

# 'select' is an array of variables, one for each item 'i'.
# 'binary' means this variable can *only* be 0 or 1.
#   - select[i] = 1 means "YES, we put item 'i' in the knapsack"
#   - select[i] = 0 means "NO, we leave item 'i' out"
var select {i in Items}, binary;

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules of the problem.

# 'Total_Weight:' is the name of our one constraint.
# 'sum {i in Items} select[i] * Weight[i]'
# This calculates the total weight of the items we *selected*.
# If select[i] is 0, it adds 0 * Weight[i].
# If select[i] is 1, it adds 1 * Weight[i].
#
# '<= Capacity'
# This ensures the total weight of selected items does not
# exceed the knapsack's capacity.
s.t. Total_Weight:
	sum {i in Items} select[i] * Weight[i] <= Capacity;

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Total_Gain:' tells the solver to find the solution
# that gives the largest possible value for this expression.
# 'sum {i in Items} select[i] * Gain[i]'
# This calculates the total gain (value) of the items we *selected*.
# It only adds the gain of an item if select[i] is 1.
maximize Total_Gain:
	sum {i in Items} select[i] * Gain[i];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to find the optimal
# 0/1 values for 'select' that obey the 'Total_Weight'
# constraint and maximize the 'Total_Gain'.
solve;

# Print the final, maximum gain achieved.
printf "Optimal Gain: %g\n", Total_Gain;

# Print the total weight of the items in the optimal solution.
# This should be less than or equal to 'Capacity'.
printf "Total Weight: %g\n",
	sum {i in Items} select[i] * Weight[i];

# This 'for' loop iterates through all items...
for {i in Items}
{
	# ...and prints the item's name, followed by " SELECTED"
	# *only if* the solver chose 'select[i]' to be 1.
	printf "%s:%s\n", i, if (select[i]) then " SELECTED" else "";
}

# Marks the end of the model file.
end;