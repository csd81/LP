# === 1. SET DECLARATIONS ===
# These sets define the 'locations' in our model.

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

# 'Connections': This is a helper set that represents all
# possible shipping routes. It is the "Cartesian product"
# of Supplies and Demands (all (s,d) pairs).
set Connections := Supplies cross Demands;

# 'Cost': A 2D-array (matrix). 'Cost[s,d]' is the
# cost to ship *one unit* of goods on the connection (s,d).
param Cost {(s,d) in Connections}, >=0;

# 'check': This is a sanity check to ensure that the total
# amount *Available* is at least as much as the total *Required*.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATION ===
# This is the "decision" or "answer" the solver needs to find.

# 'tran' (for "transport"): This is our main decision variable.
# {(s,d) in Connections} creates one variable for each
# possible route in the 'Connections' set.
# This variable will hold the *quantity* of goods to send
# on that route. '>=0' means we can't ship a negative amount.
var tran {(s,d) in Connections}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (limitations).

s.t.
# 'Availability_at_Supply_Points': Creates one rule for each 's'.
# The total amount shipped *out* of supply location 's'
# (summed over all destinations 'd')
# must be *less than or equal to* the amount *Available* at 's'.
Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t.
# 'Requirement_at_Demand_Points': Creates one rule for each 'd'.
# The total amount shipped *into* demand location 'd'
# (summed over all sources 's')
# must be *greater than or equal to* the amount *Required* at 'd'.
Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The solver's goal is to find the solution
# with the *smallest* possible total cost.
#
# 'sum {(s,d) in Connections} tran[s,d] * Cost[s,d]'
# This calculates the total shipping cost by summing up
# (Amount shipped on route (s,d)) * (Cost of route (s,d))
# for every route in the 'Connections' set.
minimize Total_Costs: sum {(s,d) in Connections} tran[s,d] * Cost[s,d];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for the 'tran' variables.
solve;

# Print the final, minimized total cost.
printf "Optimal cost: %g.\n", Total_Costs;

# This 'for' loop iterates through all routes in 'Connections'
# *BUT* the condition 'tran[s,d] > 0' means it will
# *only* print the routes that are actually used in the
# optimal solution.
for {(s,d) in Connections: tran[s,d] > 0}
{
	# Prints a detailed line for each active shipping route.
	printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}

# Marks the end of the model file.
end;