# === 1. SET DECLARATIONS ===
# These sets define the 'locations' in our model.

# 'Supplies': A set holding the names of the supply locations.
set Supplies;
# 'Demands': A set holding the names of the demand locations.
set Demands;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Available': The amount of goods available at each supply 's'.
param Available {s in Supplies}, >=0;
# 'Required': The amount of goods required at each demand 'd'.
param Required {d in Demands}, >=0;
# 'Connections': A helper set of all possible (s,d) shipping routes.
set Connections := Supplies cross Demands;

# 'Cost': The *variable cost* to ship *one unit* on route (s,d).
param Cost {(s,d) in Connections}, >=0;
# 'FixedCost': The *one-time fee* to use route (s,d) *at all*.
# You pay this if tran[s,d] > 0, and you don't pay it if tran[s,d] = 0.
param FixedCost {(s,d) in Connections}, >=0;

# 'check': A sanity check to ensure the problem is solvable.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATIONS ===
# These are the "decisions" the solver needs to find.

# 'tran': The *quantity* of goods to ship on route (s,d).
# This is a continuous variable (e.g., 10.5 units).
var tran {(s,d) in Connections}, >=0;

# 'tranUsed': This is the *key variable* for the fixed-cost logic.
# It's a 'binary' (0 or 1) variable.
#   - tranUsed[s,d] = 1 means "YES, we *are* using this route"
#   - tranUsed[s,d] = 0 means "NO, we are *not* using this route"
var tranUsed {(s,d) in Connections}, binary;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.

# 'Availability_at_Supply_Points': The total shipped *out*
# of a supply 's' cannot exceed what's available.
s.t. Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t.
# 'Requirement_at_Demand_Points': The total shipped *into*
# a demand 'd' must be at least what's required.
Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

# This 'param M' is a "Big-M" constant. It's a number that
# is *guaranteed* to be larger than any possible 'tran[s,d]'.
# The total supply in the system is a good, safe value.
# (The commented-out line in the constraint shows its use).
param M := sum {s in Supplies} Available[s];

s.t.
# 'Zero_Transport_If_Fix_Cost_Not_Paid': This is the "Big-M"
# constraint that links our two variables.
#
#   - If 'tranUsed[s,d]' = 0 (we don't pay the fee):
#     The constraint becomes 'tran[s,d] <= ... * 0',
#     which forces 'tran[s,d] = 0'.
#
#   - If 'tranUsed[s,d]' = 1 (we *do* pay the fee):
#     The constraint becomes 'tran[s,d] <= ... * 1'.
#     This "activates" the route, allowing 'tran' to be
#     any positive value up to the max (the "Big-M" value).
#
# Note: The line `min(Available[s],Required[d])` is a *tighter*
# "Big-M" value than just 'M', which is more efficient for
# the solver. It says you can't ship more than the
# supply 's' has or demand 'd' needs.
Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
#	tran[s,d] <= M * tranUsed[s,d];
	tran[s,d] <= min(Available[s],Required[d]) * tranUsed[s,d];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The total cost is the sum of two parts for *every* route:
# 1) (tran[s,d] * Cost[s,d]): The *variable cost* (quantity * unit cost).
# 2) (tranUsed[s,d] * FixedCost[s,d]): The *fixed cost*.
#    (This adds 0 if 'tranUsed' is 0, and 'FixedCost' if 1).
# The solver will try to set 'tranUsed[s,d]' to 0 whenever
# possible to avoid paying the fixed cost.
minimize Total_Costs: sum {(s,d) in Connections} (tran[s,d] * Cost[s,d] + tranUsed[s,d] * FixedCost[s,d]);

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# This 'for' loop iterates through all routes
# and prints *only* the ones where 'tran[s,d] > 0'.
for {(s,d) in Connections: tran[s,d] > 0}
{
	# Prints a detailed report for each active route,
	# showing both the variable and fixed costs.
	printf "From %s to %s, transport %g amount for %g (unit cost: %g, fixed: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d] + FixedCost[s,d], Cost[s,d], FixedCost[s,d];
}

# Marks the end of the model file.
end;