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

# 'Cost': The *base* (more expensive) cost to ship *one unit*.
param Cost {(s,d) in Connections}, >=0;

# --- Tiered Cost Parameters ---
# These parameters define the "price drop" or "discount".

# 'CostThreshold': The *quantity* threshold. The *intention* is
# that any amount *above* this gets the discount.
param CostThreshold, >=0;
# 'CostDecPercent': The percentage discount (e.g., 20 for 20% off).
param CostDecPercent, >0, <=100;
# 'CostOverThreshold': This *calculates* the new, *cheaper*
# shipping cost for units above the threshold.
param CostOverThreshold {(s,d) in Connections} := Cost[s,d] * (1 - CostDecPercent / 100);

# 'check': A sanity check to ensure the problem is solvable.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATIONS ===
# These are the "decisions" the solver needs to find.

# 'tran': A helper variable to store the *total quantity*
# shipped on route (s,d).
var tran {(s,d) in Connections}, >=0;

# 'tranBase': The *intended* "bucket" for the first 0 to
# 'CostThreshold' units, to be billed at the high 'Cost'.
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;

# 'tranOver': The *intended* "bucket" for any units
# *above* the 'CostThreshold', to be billed at the
# cheaper 'CostOverThreshold'.
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
# 'Total_Transported': This links the total 'tran' to its
# two (intended) components.
Total_Transported {(s,d) in Connections}:
	tran[s,d] = tranBase[s,d] + tranOver[s,d];

# === 5. OBJECTIVE FUNCTION (LOGICAL FLAW) ===
# This is the "goal" of the model, and where the error is.

# 'minimize Total_Costs:'
# The objective is to minimize the sum of two parts:
# 1. (tranBase * Cost): The "expensive" bucket.
# 2. (tranOver * CostOverThreshold): The "cheap" bucket.
#
# !!! --- NAIVE MODEL FLAW --- !!!
# Because the solver's goal is to 'minimize' and
# 'CostOverThreshold' is *cheaper* than 'Cost',
# the solver will *always* fill 'tranOver' first.
# It will *never* put anything in 'tranBase' (the
# expensive bucket) unless it's forced to.
#
# As a result, 'tranBase' will always be 0, and this
# model *fails* to correctly represent the economy of
# scale. It simply uses the *discounted price* for
# all units, not just the ones "over threshold".
minimize Total_Costs: sum {(s,d) in Connections} (tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# The report will likely show 'tranBase' = 0 for all routes.
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g=%g+%g amount for %g (unit cost: %g/%g).\n",
		s, d, tran[s,d], tranBase[s,d], tranOver[s,d],
		(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]),
		Cost[s,d], CostOverThreshold[s,d];
}

# Marks the end of the model file.
end;