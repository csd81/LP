# === 1. SET DECLARATIONS ===

# 'Items' is a set that will hold the names of all the items
# we need to assign (e.g., 'item1', 'item2').
set Items;

# 'Weight' is an array. For each item 'i', it stores
# the weight of that item.
param Weight {i in Items}, >=0;

# 'Knapsack_Count' is a single number (e.g., 3) that
# specifies how many knapsacks we have.
param Knapsack_Count, integer;

# 'Knapsacks' is a set created from the count, e.g., {1, 2, 3}.
set Knapsacks := 1 .. Knapsack_Count;

# === 2. VARIABLE DECLARATIONS ===
# These are the "decisions" and "helper values" the solver will determine.

# 'select' is our main decision variable.
# {i in Items, k in Knapsacks} creates a variable for
# every (item, knapsack) pair.
# 'binary' means it can only be 0 or 1.
#   - select[i,k] = 1 means "Item 'i' IS put in Knapsack 'k'"
#   - select[i,k] = 0 means "Item 'i' IS NOT put in Knapsack 'k'"
var select {i in Items, k in Knapsacks}, binary;

# 'weight' is a helper variable to store the total weight of *each* knapsack.
var weight {k in Knapsacks};

# 'min_weight' will be forced by the solver to hold the
# weight of the *lightest* knapsack in the solution.
var min_weight;

# 'max_weight' will be forced by the solver to hold the
# weight of the *heaviest* knapsack in the solution.
var max_weight;

# === 3. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules of the problem.

# 'Partitioning': This rule ensures every item is assigned
# to *exactly one* knapsack.
# '{i in Items}' means this rule is created *once for each item*.
# 'sum {k in Knapsacks} select[i,k]' sums up the 'select'
# variable for item 'i' across all knapsacks.
# '= 1' forces this sum to be 1 (i.e., it's in knapsack 1, OR 2, OR 3, etc.).
s.t.
Partitioning {i in Items}:
	sum {k in Knapsacks} select[i,k] = 1;

# 'Total_Weights': This constraint calculates the total weight
# for each knapsack 'k' and stores it in our helper variable.
# 'weight[k] = sum {i in Items} select[i,k] * Weight[i]'
# This sums the weights of *only* the items 'i'
# where 'select[i,k]' is 1 (i.e., assigned to this knapsack 'k').
s.t.
Total_Weights {k in Knapsacks}:
	weight[k] = sum {i in Items} select[i,k] * Weight[i];

# This links 'min_weight' to the 'weight' of all knapsacks.
# By forcing 'min_weight' to be *less than or equal to*
# every individual knapsack's weight, the solver (when
# it minimizes the *difference*) will push 'min_weight'
# up to be equal to the smallest 'weight[k]'.
s.t. Total_Weight_from_Below {k in Knapsacks}:
	min_weight <= weight[k];

# This links 'max_weight' to the 'weight' of all knapsacks.
# By forcing 'max_weight' to be *greater than or equal to*
# every individual knapsack's weight, the solver (when
# it minimizes the *difference*) will push 'max_weight'
# down to be equal to the largest 'weight[k]'.
s.t.
Total_Weight_from_Above {k in Knapsacks}:
	max_weight >= weight[k];

# === 4. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Difference:' tells the solver to find the solution
# with the *smallest* possible value for this expression.
# 'max_weight - min_weight' is the gap between the
# heaviest and lightest knapsacks. Minimizing this
# makes the knapsack weights as "balanced" as possible.
minimize Difference: max_weight - min_weight;

# === 5. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal solution.
solve;

# Print a summary of the solution.
printf "Smallest difference: %g (%g - %g)\n",
	Difference, max_weight, min_weight;

# This 'for' loop iterates through each knapsack 'k'...
for {k in Knapsacks}
{
	# ...prints the knapsack number (e.g., "1:").
	printf "%d:", k;
	
	# This inner loop iterates through all items 'i'
	# *BUT* only for those where 'select[i,k]' is 1 (is true).
for {i in Items: select[i,k]}
	{
		# Prints the name of the item.
		printf " %s", i;
	}
	# Prints the total calculated weight for this knapsack.
	printf " (%g)\n", weight[k];
}

# Marks the end of the model file.
end;