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

# 'check': This is a sanity check. In this *penalty model*,
# it's not strictly necessary, as the model *can*
# handle cases where supply < demand (it will just
# incur a 'ShortagePenalty').
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
# 'surplus': A variable to store the amount *over* the
# 'Required' target (if 'satisfied' > 'Required').
var surplus {d in Demands}, >=0;
# 'shortage': A variable to store the amount *under* the
# 'Required' target (if 'satisfied' < 'Required').
var shortage {d in Demands}, >=0;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.

# 'Calculating_Demand_Satisfied': This constraint *defines*
# the 'satisfied' variable. It's the sum of all goods
# shipped *into* demand location 'd'.
s.t. Calculating_Demand_Satisfied {d in Demands}:
	satisfied[d] = sum {s in Supplies} tran[s,d];

s.t.
# 'Availability_at_Supply_Points': The total shipped *out*
# of a supply 's' cannot exceed what's available.
Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t.
# 'Calculating_Exact_Demands': This is the core logic.
# It links the target ('Required'), the actual ('satisfied'),
# and the deviation ('shortage', 'surplus').
#
# 'Required[d] - shortage[d] + surplus[d] = satisfied[d]'
#
# Because all variables are '>=0', the solver will never
# have both 'shortage' and 'surplus' be positive at the
# same time.
Calculating_Exact_Demands {d in Demands}:
	Required[d] - shortage[d] + surplus[d] = satisfied[d];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Costs:'
# The solver's goal is to minimize the sum of *three* costs:
# 1. The standard shipping cost (tran * Cost).
# 2. The total shortage penalty (shortage * ShortagePenalty).
# 3. The total surplus penalty (surplus * SurplusPenalty).
minimize Total_Costs:
	sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
	sum {d in Demands} (shortage[d] * ShortagePenalty + surplus[d] * SurplusPenalty);

# === 6. SOLVE AND DISPLAY ===
solve;

# Print the final, minimized total cost.
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