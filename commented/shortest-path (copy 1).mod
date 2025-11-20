# === 1. SET DECLARATIONS ===

# 'Nodes' is the set of all points (vertices) in our graph
# (e.g., 'CityA', 'CityB', 'CityC').
set Nodes;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data for the problem.

# 'Start' is the name of the node where the path begins.
param Start, symbolic, in Nodes;
# 'Finish' is the name of the node where the path ends.
param Finish, symbolic, in Nodes;
# A quick check to make sure the start and end are not the same node.
check Start!=Finish;

# 'Infty' is a very large number used as a default weight
# for pairs of nodes that are *not* connected by an edge.
param Infty, default 99999;

# 'Weight' holds the *asymmetric* weights (costs) of directed edges.
# 'Weight[a,b]' could be different from 'Weight[b,a]'.
# If no weight is given in the data, it defaults to 'Infty'.
param Weight {a in Nodes, b in Nodes}, >0, default Infty;

# 'W' creates a *symmetric* weight for an undirected edge.
# For any two nodes 'a' and 'b', it takes the *minimum* of the
# weight from a->b and b->a. This is the cost we will use
# for traveling *between* 'a' and 'b' in either direction.
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);

# === 3. VARIABLE DECLARATION ===
# This is the "decision" the solver needs to make.

# 'flow' is a set of binary variables.
#   - flow[a,b] = 1 means "YES, our path uses the edge from 'a' to 'b'"
#   - flow[a,b] = 0 means "NO, our path does not use this edge"
var flow {a in Nodes, b in Nodes}, binary;

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules of the problem.

# 'Material_Balance' is the core of this model. It's an indexed
# constraint, meaning it creates one rule *for each node 'x'*.
# 'sum {a in Nodes} flow[a,x]' is the total flow *INTO* node 'x'.
# 'sum {b in Nodes} flow[x,b]' is the total flow *OUT OF* node 'x'.
subject to Material_Balance {x in Nodes}:
	sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
	# The 'if' statement defines the rules:
	#
	# if (x==Start) then -1:
	#   For the Start node: (IN - OUT = -1) or (OUT - IN = 1).
	#   This means the Start node *must send out* 1 more unit
	#   of flow than it receives. It is the "source" of 1 unit.
	#
	# else if (x==Finish) then 1:
	#   For the Finish node: (IN - OUT = 1).
	#   This means the Finish node *must receive* 1 more unit
	#   of flow than it sends out. It is the "sink" of 1 unit.
	#
	# else 0:
	#   For all other nodes: (IN - OUT = 0) or (IN = OUT).
	#   This is a "flow conservation" rule. Any flow that
	#   enters a middle node must also leave it.
	if (x==Start) then -1 else if (x==Finish) then 1 else 0;

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Weight:' tells the solver to find the solution
# with the *lowest* possible value for this expression.
#
# 'sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b]'
# This calculates the total weight of the path. It multiplies
# the weight of each edge 'W[a,b]' by its flow variable (0 or 1).
# Only the edges that are "used" (flow[a,b]=1) will add
# their weight to the total.
minimize Total_Weight:
	sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for the 'flow' variables.
solve;

# Print the final, minimized total weight.
printf "Distance %s-%s: %g\n", Start, Finish, Total_Weight;

# This 'for' loop iterates over all pairs of nodes (a, b)
# *BUT* only for those where the solver decided 'flow[a,b]' = 1.
# This filters to show only the edges included in the final path.
for {a in Nodes, b in Nodes: flow[a,b]}
{
	# Prints one step of the path, e.g., "CityA->CityC (10.5)"
	printf "%s->%s (%g)\n", a, b, W[a,b];
}

# Marks the end of the model file.
end;