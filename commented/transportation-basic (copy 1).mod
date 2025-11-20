# === 1. SET DECLARATIONS ===
# These sets define the 'locations' in our model.
# They will be loaded from a data (.dat) file.

# 'Supplies': A set holding the names of the supply locations
# (e.g., 'Factory_A', 'Warehouse_B').
set Supplies;

# 'Demands': A set holding the names of the demand locations
# (e.g., 'Customer_1', 'Store_2').
set Demands;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Available': An array. For each supply location 's',
# this is the *maximum amount* of goods it can send.
param Available {s in Supplies}, >=0;

# 'Required': An array. For each demand location 'd',
# this is the *minimum amount* of goods it must receive.
param Required {d in Demands}, >=0;

# 'Cost': A 2D-array (matrix). 'Cost[s,d]' is the
# cost to ship *one unit* of goods from supply 's'
# to demand 'd'.
param Cost {s in Supplies, D in Demands}, >=0;

# 'check': This is a sanity check to make sure the problem
# is solvable. It ensures that the total amount *Available*
# in the system is at least as much as the total amount *Required*.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'tran' (for "transport"): This is our main decision variable.
# {s in Supplies, D in Demands} creates one variable for
# *every possible shipping route* (e.g., tran['Factory_A', 'Store_2']).
# This variable will hold the *quantity* of goods to send
# on that route. '>=0' means we can't ship a negative amount.
var tran {s in Supplies, D in Demands}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (limitations).

# 'Availability_at_Supply_Points': An indexed constraint.
# '{s in Supplies}' means it creates *one rule* for *each*
# supply location 's'.
#
# 'sum {d in Demands} tran[s,d]'
# This sum calculates the *total amount* of goods being
# shipped *out* of supply location 's' (to all destinations 'd').
#
# '<= Available[s]'
# This says the total amount shipped *out* of 's'
# must be *less than or equal to* the amount *Available* at 's'.
s.t. Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

# 'Requirement_at_Demand_Points': An indexed constraint.
# '{d in Demands}' means it creates *one rule* for *each*
# demand location 'd'.
#
# 'sum {s in Supplies} tran[s,d]'
# This sum calculates the *total amount* of goods being
# shipped *into* demand location 'd' (from all sources 's').
#
# '>= Required[d]'
# This says the total amount shipped *into* 'd'
# must be *greater than or equal to* the amount *Required* at 'd'.
s.t. Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:' tells the solver to find the solution
# with the *smallest* possible value for this expression.
#
# 'sum {s in Supplies, d in Demands} tran[s,d] * Cost[s,d]'
# This calculates the total shipping cost. It loops through
# *every possible route*, multiplies the *amount shipped* on that
# route (tran[s,d]) by the *cost per unit* for that route (Cost[s,d]),
# and adds them all up.
minimize Total_Costs: sum {s in Supplies, d in Demands} tran[s,d] * Cost[s,d];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for the 'tran' variables.
solve;

# Print the final, minimized total cost.
printf "Optimal cost: %g.\n", Total_Costs;

# This 'for' loop iterates through all possible routes (s, d)...
# ...*BUT* the condition 'tran[s,d] > 0' means it will
# *only* print the routes that are actually used in the
# optimal solution.
for {s in Supplies, d in Demands: tran[s,d] > 0}
{
	# Prints a detailed line for each active shipping route.
	printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}

# Marks the end of the model file.
end;