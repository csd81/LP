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
# 'Required': The *target* amount of goods for each demand 'd'.
param Required {d in Demands}, >=0;
# 'Connections': A helper set of all possible (s,d) shipping routes.
set Connections := Supplies cross Demands;

# 'Cost': The *variable cost* to ship *one unit* on route (s,d).
param Cost {(s,d) in Connections}, >=0;

# 'check': A sanity check. Not strictly necessary for a
# penalty model, but often good practice.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# 'ShortagePenalty': The *cost per unit* for *failing* to meet
# the 'Required' amount for a demand 'd'.
param ShortagePenalty, >=0;
# 'SurplusPenalty': The *cost per unit* (e.g., disposal fee)
# for *exceeding* the 'Required' amount for a demand 'd'.
param SurplusPenalty, >=0;

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver needs to find.

# 'tran': The *quantity* of goods to ship on route (s,d).
var tran {(s,d) in Connections}, >=0;
# 'satisfied': A helper variable to store the *total*
# amount of goods that 'd' *actually receives*.
var satisfied {d in Demands}, >=0;

# 'penalty': A variable to store the *total penalty cost*
# (either shortage or surplus) for demand 'd'.
var penalty {d in Demands}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.
s.t.
# 'Calculating_Demand_Satisfied': This constraint *defines*
# the 'satisfied' variable as the sum of all goods
# shipped *into* demand location 'd'.
Calculating_Demand_Satisfied {d in Demands}:
	satisfied[d] = sum {s in Supplies} tran[s,d];

s.t.
# 'Availability_at_Supply_Points': The total shipped *out*
# of a supply 's' cannot exceed what's available.
Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t.
# 'Shortage_Penalty_Constraint':
# 'penalty[d]' must be *at least* the shortage cost.
#   - If we have a shortage, (Required - satisfied) is *positive*.
#     This constraint becomes 'penalty[d] >= (positive cost)'.
#   - If we have a surplus, (Required - satisfied) is *negative*.
#     This constraint becomes 'penalty[d] >= (negative cost)',
#     which is non-binding (since penalty >= 0 anyway).
Shortage_Penalty_Constraint {d in Demands}:
	penalty[d] >= ShortagePenalty * (Required[d] - satisfied[d]);

s.t.
# 'Surplus_Penalty_Constraint':
# 'penalty[d]' must be *at least* the surplus cost.
#   - If we have a surplus, (satisfied - Required) is *positive*.
#     This constraint becomes 'penalty[d] >= (positive cost)'.
#   - If we have a shortage, (satisfied - Required) is *negative*.
#     This constraint becomes 'penalty[d] >= (negative cost)',
#     which is non-binding.
Surplus_Penalty_Constraint {d in Demands}:
	penalty[d] >= SurplusPenalty * (satisfied[d] - Required[d]);

# --- How the Penalty Constraints Work ---
# The 'minimize' objective will push 'penalty[d]' as low as
# possible. 'penalty[d]' will be set to the *maximum* of:
#   1. 0
#   2. The shortage cost (if any)
#   3. The surplus cost (if any)
# This effectively calculates the correct penalty.

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The solver's goal is to minimize the sum of two costs:
# 1. The standard shipping cost (tran * Cost).
# 2. The total penalty cost (the 'penalty[d]' variable).
minimize Total_Costs:
	sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
	sum {d in Demands} penalty[d];

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# This 'for' loop iterates through each demand location...
for {d in Demands}
{
	# ...and prints a report showing the target vs. the
	# actual amount satisfied, and the difference.
	printf "Required: %s, Satisfied: %g (%+g)\n",
		d, satisfied[d], satisfied[d]-Required[d];
}
# This 'for' loop iterates through all routes
# and prints *only* the ones that are actually used.
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}

# Marks the end of the model file.
end;