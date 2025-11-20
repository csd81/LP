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
# 'Cost': The cost to ship *one unit* from 's' to 'd'.
param Cost {s in Supplies, d in Demands}, >=0;

# 'Max_Unit_Cost': This is our new business rule.
# We set a "cutoff" cost. 'default 7' sets this value
# to 7 if it's not provided in a data file.
# param Max_Unit_Cost := 7; # <-- (This is another way to hard-code it)
param Max_Unit_Cost, default 7;

# 'Connections': This is the *key* to this model.
# Instead of creating all (s,d) pairs, 'setof' creates a
# set *only* containing the (s,d) pairs where the
# shipping cost is *less than or equal to* our cutoff.
# This *pre-filters* our problem.
set Connections := setof {s in Supplies, d in Demands: Cost[s,d] <= Max_Unit_Cost} (s,d);

# 'check': A sanity check to ensure the problem is solvable
# (total supply >= total demand).
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'tran' (for "transport"): Our main decision variable.
#
# !! IMPORTANT !!
# '{(s,d) in Connections}' means 'tran' variables are
# *only* created for the low-cost routes we defined in the
# 'Connections' set. 'tran[s,d]' *does not even exist*
# for routes where Cost[s,d] > Max_Unit_Cost.
var tran {(s,d) in Connections}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s,t," (subject to) introduces the rules.
s.t.
# 'Availability_at_Supply_Points': Creates one rule for each 's'.
# The total amount shipped *out* of 's'
# (summing *only over allowed connections*)
# must be *less than or equal to* the amount *Available* at 's'.
Availability_at_Supply_Points {s in Supplies}:
	sum {(s,d) in Connections} tran[s,d] <= Available[s];

s.t.
# 'Requirement_at_Demand_Points': Creates one rule for each 'd'.
# The total amount shipped *into* 'd'
# (summing *only over allowed connections*)
# must be *greater than or equal to* the amount *Required* at 'd'.
Requirement_at_Demand_Points {d in Demands}:
	sum {(s,d) in Connections} tran[s,d] >= Required[d];

# --- Alternative (Less Efficient) Method ---
# The commented-out lines show another way to do this.
# We could have defined 'tran' for *all* routes, and then
# added this constraint to *force* the 'tran' on
# expensive routes to be 0.
# By pre-filtering the 'Connections' set, we create a
# smaller, simpler problem for the solver.
#s.t.
#Connections_Prohibited {s in Supplies, d in Demands: Cost[s,d] > Max_Unit_Cost}:
#	tran[s,d] = 0;

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The solver's goal is to find the solution
# with the *smallest* possible total cost.
# The sum is *only* over the allowed, low-cost routes.
minimize Total_Costs: sum {(s,d) in Connections} tran[s,d] * Cost[s,d];

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# This 'for' loop iterates through our allowed 'Connections'
# and prints any route where the optimal solution 'tran[s,d]' is > 0.
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}

# Marks the end of the model file.
end;