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

# 'CostThreshold': The *quantity* threshold (e.g., 100 units).
param CostThreshold, >=0;
# 'CostDecPercent': The percentage discount (e.g., 20 for 20% off).
param CostDecPercent, >0, <=100;
# 'CostOverThreshold': This *calculates* the new, *cheaper*
# shipping cost for any units *above* the 'CostThreshold'.
param CostOverThreshold {(s,d) in Connections} := Cost[s,d] * (1 - CostDecPercent / 100);

# 'check': A sanity check to ensure the problem is solvable.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATIONS ===
# These are the "decisions" the solver needs to find.

# 'tran': A helper variable for the *total quantity* shipped.
var tran {(s,d) in Connections}, >=0;

# 'tranBase': The "bucket" for the first 0 to 'CostThreshold'
# units, billed at the high 'Cost'.
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;

# 'tranOver': The "bucket" for any units *above*
# 'CostThreshold', billed at the cheap 'CostOverThreshold'.
var tranOver {(s,d) in Connections}, >=0;

# 'isOver': This is the *key* variable that fixes the naive model.
# It's a binary (0 or 1) "switch".
#   - isOver[s,d] = 0 means "We are shipping *less than* the threshold"
#   - isOver[s,d] = 1 means "We are shipping *more than* the threshold"
var isOver {(s,d) in Connections}, binary;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.
s.t.
# 'Availability_at_Supply_Points': The *total* amount shipped *out*
# of 's' cannot exceed what's available.
Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t.
# 'Requirement_at_Demand_Points': The *total* amount shipped *into*
# 'd' must be at least what's required.
Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

s.t.
# 'Total_Transported': Links the total 'tran' to its two components.
Total_Transported {(s,d) in Connections}:
	tran[s,d] = tranBase[s,d] + tranOver[s,d];

# 'M' is a "Big-M" constant: a number guaranteed to be
# larger than any possible 'tranOver' value.
param M := sum {s in Supplies} Available[s];

s.t.
# 'Zero_Over_Threshold_if_Threshold_Not_Chosen':
# This is the first part of our "switch" logic.
#   - If 'isOver[s,d]' = 0 (switch is OFF):
#     The constraint becomes 'tranOver[s,d] <= M * 0',
#     which forces 'tranOver[s,d] = 0'.
#     (i.e., "No items allowed in the cheap bucket").
#   - If 'isOver[s,d]' = 1 (switch is ON):
#     The constraint becomes 'tranOver[s,d] <= M * 1'.
#     This is non-binding and allows 'tranOver' to be positive.
Zero_Over_Threshold_if_Threshold_Not_Chosen {(s,d) in Connections}:
	tranOver[s,d] <= M * isOver[s,d];

s.t.
# 'Full_Below_Threshold_if_Threshold_Chosen':
# This is the second part of our "switch" logic.
#   - If 'isOver[s,d]' = 1 (switch is ON):
#     The constraint becomes 'tranBase[s,d] >= CostThreshold * 1'.
#     This forces 'tranBase' to be *full* (equal to 'CostThreshold',
#     since it's also bounded by '<= CostThreshold').
#     (i.e., "You can't use the cheap bucket *until* the
#     expensive bucket is full").
#   - If 'isOver[s,d]' = 0 (switch is OFF):
#     The constraint becomes 'tranBase[s,d] >= 0',
#     which is non-binding.
Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
#	tranBase[s,d] >= CostThreshold - M * (1 - isOver[s,d]); # (Another way to write the same logic)
	tranBase[s,d] >= CostThreshold * isOver[s,d];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The objective is the same as the naive model. *However*,
# because of our 'isOver' variable and the constraints,
# the solver is *now forced* to fill 'tranBase' first
# (which is expensive) before it's *allowed* to use
# 'tranOver' (which is cheap). This correctly models the
# real-world cost.
minimize Total_Costs: sum {(s,d) in Connections} (tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# The report will now correctly show 'tranBase' being full
# (at CostThreshold) *before* 'tranOver' becomes positive.
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g=%g+%g amount for %g (unit cost: %g/%g).\n",
		s, d, tran[s,d], tranBase[s,d], tranOver[s,d],
		(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]),
		Cost[s,d], CostOverThreshold[s,d];
}

# Marks the end of the model file.
end;