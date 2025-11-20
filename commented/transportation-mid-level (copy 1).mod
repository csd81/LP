# === 1. SET DECLARATIONS ===
# These sets define the 'locations' in our model.

# 'Supplies': A set holding the names of the supply locations (e.g., factories).
set Supplies;
# 'Centers': A set of *potential* mid-level locations (e.g., warehouses).
set Centers;
# 'Demands': A set of the final demand locations (e.g., customers).
set Demands;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data (the numbers) for the problem.

# 'Available': The amount of goods available at each supply 's'.
param Available {s in Supplies}, >=0;
# 'Required': The amount of goods required at each demand 'd'.
param Required {d in Demands}, >=0;

# 'ConnectionsA': A helper set for the *first leg* of the journey
# (all routes from a Supply 's' to a Center 'c').
set ConnectionsA := Supplies cross Centers;
# 'ConnectionsB': A helper set for the *second leg* of the journey
# (all routes from a Center 'c' to a Demand 'd').
set ConnectionsB := Centers cross Demands;

# 'CostA': The cost to ship *one unit* on the first leg (s -> c).
param CostA {(s,c) in ConnectionsA}, >=0;
# 'CostB': The cost to ship *one unit* on the second leg (c -> d).
param CostB {(c,d) in ConnectionsB}, >=0;
# 'EstablishCost': The *one-time fixed cost* to *open*
# and *use* a center 'c'. This is the "facility location" part.
param EstablishCost {c in Centers}, >=0;

# 'check': A sanity check to ensure the problem is solvable.
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

# === 3. VARIABLE DECLARATIONS ===
# These are the "decisions" or "answers" the solver needs to find.

# 'tranA': The *quantity* of goods to ship on the first leg (s -> c).
var tranA {(s,c) in ConnectionsA}, >=0;
# 'tranB': The *quantity* of goods to ship on the second leg (c -> d).
var tranB {(c,d) in ConnectionsB}, >=0;

# 'atCenter': A helper variable. This will store the *total
# amount* of goods that *flows through* a center 'c'.
var atCenter {c in Centers}, >=0;

# 'useCenter': This is the *key decision variable*!
# 'binary' means it can only be 0 (NO) or 1 (YES).
#   - useCenter[c] = 1 means "YES, open Center 'c' (and pay the cost)"
#   - useCenter[c] = 0 means "NO, do not use Center 'c' at all"
var useCenter {c in Centers}, binary;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.
s.t.
# 'Availability_at_Supply_Points': The total amount shipped *out*
# of a supply 's' (to all centers) cannot exceed what's available.
Availability_at_Supply_Points {s in Supplies}:
	sum {c in Centers} tranA[s,c] <= Available[s];

s.t.
# 'Total_To_Center': This *defines* the 'atCenter' variable.
# It says the total flow *through* a center is equal to the
# sum of all goods shipped *into* it from all supplies.
Total_To_Center {c in Centers}:
	atCenter[c] = sum {s in Supplies} tranA[s,c];

s.t.
# 'Total_From_Center': This is the **Flow Conservation** rule.
# It says the total amount shipped *into* a center ('atCenter[c]')
# must be *equal* to the total amount shipped *out* of it.
# This ensures centers are just pass-through points.
Total_From_Center {c in Centers}:
	atCenter[c] = sum {d in Demands} tranB[c,d];

s.t.
# 'Requirement_at_Demand_Points': The total amount shipped *into*
# a demand 'd' (from all centers) must be at least what's required.
Requirement_at_Demand_Points {d in Demands}:
	sum {c in Centers} tranB[c,d] >= Required[d];

# 'M' is a "Big-M" constant: a number guaranteed to be
# larger than any possible flow through a center.
param M := sum {s in Supplies} Available[s];

s.t.
# 'Zero_at_Center_if_Not_Established': This is the "Big-M"
# constraint that links our *binary decision* ('useCenter')
# to our *flow variable* ('atCenter').
#
#   - If 'useCenter[c]' = 0 (center is CLOSED):
#     The constraint becomes 'atCenter[c] <= M * 0',
#     which forces 'atCenter[c] = 0'. (No flow allowed).
#
#   - If 'useCenter[c]' = 1 (center is OPEN):
#     The constraint becomes 'atCenter[c] <= M * 1'.
#     Since M is huge, this "switches on" the route,
#     and 'atCenter[c]' is only limited by supply/demand.
Zero_at_Center_if_Not_Established {c in Centers}:
	atCenter[c] <= M * useCenter[c];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

minimize Total_Costs:
	# Part 1: The total variable cost of shipping on leg A
	sum {(s,c) in ConnectionsA} tranA[s,c] * CostA[s,c] +
	# Part 2: The total variable cost of shipping on leg B
	sum {(c,d) in ConnectionsB} tranB[c,d] * CostB[c,d] +
	# Part 3: The total fixed cost of *opening* the centers.
	# (If 'useCenter[c]' is 1, it adds 'EstablishCost[c]';
	#  if 0, it adds 0).
	sum {c in Centers} useCenter[c] * EstablishCost[c];

# === 6. SOLVE AND DISPLAY ===
solve;

printf "Optimal cost: %g.\n", Total_Costs;
# This loop prints *only* the centers the solver decided to open.
for {c in Centers: useCenter[c]}
{
	printf "Establishing center %s for %g.\n", c, EstablishCost[c];
}
# This loop prints *only* the 'A' routes that are actually used.
for {(s,c) in ConnectionsA: tranA[s,c] > 0}
{
	printf "A: From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, c, tranA[s,c], tranA[s,c] * CostA[s,c], CostA[s,c];
}
# This loop prints *only* the 'B' routes that are actually used.
for {(c,d) in ConnectionsB: tranB[c,d] > 0}
{
	printf "B: From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		c, d, tranB[c,d], tranB[c,d] * CostB[c,d], CostB[c,d];
}

end;