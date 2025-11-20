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

# 'Cost': The *base* (cheapest) cost to ship *one unit* on route (s,d).
param Cost {(s,d) in Connections}, >=0;

# --- Tiered Cost Parameters ---
# These parameters define the "price jump".

# 'CostThreshold': The *quantity* threshold. Any amount
# shipped *up to* this quantity is charged the base 'Cost'.
param CostThreshold, >=0;
# 'CostIncPercent': The percentage increase for the higher rate.
param CostIncPercent, >0;
# 'CostOverThreshold': This *calculates* the new, higher
# shipping cost for any quantity *above* the 'CostThreshold'.
param CostOverThreshold {(s,d) in Connections} := Cost[s,d] * (1 + CostIncPercent / 100);

# 'check': A sanity check to ensure the problem is solvable.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATIONS ===
# These are the "decisions" the solver needs to find.

# 'tran': A helper variable to store the *total quantity*
# shipped on route (s,d).
var tran {(s,d) in Connections}, >=0;

# 'tranBase': The portion of 'tran' that is billed at the
# *base cost*. Note ' <= CostThreshold'. The solver can't
# put more than 'CostThreshold' quantity in this "bucket".
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;

# 'tranOver': The portion of 'tran' that is billed at the
# *higher, increased cost*. This is any amount
# *above* the 'CostThreshold'.
var tranOver {(s,d) in Connections}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.

s.t.
# 'Availability_at_Supply_Points': The *total* amount shipped *out*
# of a supply 's' (using 'tran') cannot exceed what's available.
Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t.
# 'Requirement_at_Demand_Points': The *total* amount shipped *into*
# a demand 'd' (using 'tran') must be at least what's required.
Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

s.t.
# 'Total_Transported': This is the key logic constraint.
# It says the *total* transport 'tran' on a route
# is the sum of its two "buckets": the base part + the over-threshold part.
Total_Transported {(s,d) in Connections}:
	tran[s,d] = tranBase[s,d] + tranOver[s,d];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The total cost is the sum of the two cost "buckets":
# 1. (tranBase * Cost): The quantity in the cheap bucket * the cheap rate.
# 2. (tranOver * CostOverThreshold): The quantity in the expensive
#    bucket * the expensive rate.
#
# Because 'CostOverThreshold' > 'Cost', the 'minimize'
# objective will *force* the solver to fill up 'tranBase'
# *first* before putting any amount in 'tranOver'.
minimize Total_Costs: sum {(s,d) in Connections} (tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# This 'for' loop iterates through all routes
# and prints *only* the ones that are actually used.
for {(s,d) in Connections: tran[s,d] > 0}
{
	# Prints a detailed report showing the total amount and
	# its breakdown into the 'tranBase' and 'tranOver' parts.
	printf "From %s to %s, transport %g=%g+%g amount for %g (unit cost: %g/%g).\n",
		s, d, tran[s,d], tranBase[s,d], tranOver[s,d],
		(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]),
		Cost[s,d], CostOverThreshold[s,d];
}

# Marks the end of the model file.
end;