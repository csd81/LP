# This model is designed to find the Minimum Spanning Tree (MST) of a graph. It uses a clever but advanced technique that models the problem as a network flow problem. The goal is to select a set of edges (use) with the minimum total weight (W) that connects all nodes.

# === 1. SET DECLARATIONS ===

# 'Nodes' is the set of all points (vertices) in our graph.
set Nodes;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data for the model.

# 'Sink' defines one special node that will act as the "root"
# or destination for our flow model. 'symbolic' means it's a
# name (like 'NodeA') rather than a number. 'in Nodes'
# ensures the specified sink is a valid member of the Nodes set.
param Sink, symbolic, in Nodes;

# 'Infty' is a very large number used as a default weight
# for pairs of nodes that are *not* connected by an edge.
param Infty, default 99999;

# 'Weight' holds the *asymmetric* weights (costs) of directed edges.
# 'Weight[a,b]' could be different from 'Weight[b,a]'.
# If no weight is given in the data, it defaults to 'Infty'.
param Weight {a in Nodes, b in Nodes}, >0, default Infty;

# 'W' creates a *symmetric* weight for undirected edges.
# For any two nodes a and b, it takes the *minimum* of the
# weight from a to b and from b to a. This is the cost
# we will use for selecting an edge *between* a and b.
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);

# === 3. VARIABLE DECLARATIONS ===
# Variables are the "decisions" the solver needs to make.

# 'use' is a binary decision variable.
#   - use[a,b] = 1 means "we select the edge between a and b"
#   - use[a,b] = 0 means "we do not select the edge"
var use {a in Nodes, b in Nodes}, binary;

# 'flow' is a continuous variable used to model a network flow.
# This is part of a "trick" to ensure the selected edges form
# a connected tree. We will send "material" from every node
# to the 'Sink' node.
var flow {a in Nodes, b in Nodes};

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (constraints) of the problem.

# This constraint says that flow from a to b is the
# *negative* of the flow from b to a. This is a standard
# way to define flow on an undirected edge, where 'flow[a,b]'
# being positive means flow goes a->b, and 'flow[b,a]'
# would then be negative.
subject to Flow_Direction {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;

# This constraint links our 'flow' and 'use' variables.
# It says flow *can only exist* on an edge (flow[a,b] > 0)
# if that edge is *selected* (use[a,b] = 1).
# (card(Nodes) - 1) is a "big-M" value: a number large enough
# to be bigger than any possible flow. If use[a,b] is 0,
# flow[a,b] is forced to be <= 0.
subject to Flow_On_Used {a in Nodes, b in Nodes}:
	flow[a,b] <= use[a,b] * (card(Nodes) - 1);

# This is the core "material balance" constraint that forces
# the model to create a connected tree.
# We set up a flow system where:
#   1. Every node *except* the sink (x != Sink) *supplies* 1 unit of flow (the 'else 1').
#   2. The 'Sink' node (x == Sink) *demands* (card(Nodes) - 1) units
#      of flow (the 'then (1-card(Nodes))', which is negative).
# The 'sum {a in Nodes} flow[a,x]' is all flow *INTO* node x.
# The 'sum {b in Nodes} flow[x,b]' is all flow *OUT OF* node x.
# To satisfy this, the solver *must* find a path (using 'use' edges)
# from every node to the sink, forcing all selected edges
# to be part of one single, connected component.
subject to Material_Balance {x in Nodes}:
	sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
	if (x==Sink) then (1-card(Nodes)) else 1;

# === 5. OBJECTIVE FUNCTION ===
# This is the goal of the model.

# 'minimize Total_Weight:' tells the solver to find the solution
# with the *lowest* possible value for this expression.
# 'sum {a in Nodes, b in Nodes} use[a,b] * W[a,b]'
# This calculates the total weight. It multiplies the symmetric
# weight 'W[a,b]' by the decision variable 'use[a,b]' (0 or 1).
# Only the edges that are "used" (use[a,b]=1) will add
# their weight to the total.
minimize Total_Weight:
	sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal solution.
solve;

# Print the final, minimized total weight.
printf "Cheapest spanning tree: %g\n", Total_Weight;

# This loop iterates over all pairs of nodes (a, b)
# *BUT* only for those where the solver decided 'use[a,b]' = 1.
# This filters to show only the edges included in the final tree.
for {a in Nodes, b in Nodes: use[a,b]}
{
	# Prints the edge and its weight.
	printf "%s<-%s (%g)\n", a, b, W[a,b];
}

# Marks the end of the model file.
end;