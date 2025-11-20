# === 1. SET DECLARATIONS ===

# 'Node_List' will hold the raw data, where each member
# is a triplet: (node_name, x_coordinate, y_coordinate).
# 'dimen 3' tells AMPL to expect 3 values for each member.
set Node_List, dimen 3;

# 'Nodes' is a helper set that extracts just the 'name'
# from the 'Node_List'. This gives us a simple set of node names.
set Nodes := setof {(name,x,y) in Node_List} name;

# A safety check to ensure there are no duplicate node names.
check card(Nodes)==card(Node_List);

# === 2. PARAMETER DECLARATIONS ===

# These parameters extract the X and Y coordinates for each node 'n'
# from the 'Node_List' set. The 'sum' is a "trick" to
# look up the value associated with the name 'n'.
param X {n in Nodes} := sum {(n,x,y) in Node_List} x;
param Y {n in Nodes} := sum {(n,x,y) in Node_List} y;

# 'Start' is a parameter to hold the name of the starting node.
# It will be read from the data.
param Start, symbolic, in Nodes;

# 'W' is a 2D parameter that *calculates* the symmetric
# Euclidean distance (the cost/weight) between every
# pair of nodes 'a' and 'b'.
param W {a in Nodes, b in Nodes} := sqrt((X[a]-X[b])^2+(Y[a]-Y[b])^2);

# === 3. VARIABLE DECLARATIONS ===

# 'use[a,b]' is our main *decision variable*.
# 'binary' means it can only be 0 or 1.
#   - use[a,b] = 1 means our path *uses* the edge from 'a' to 'b'.
#   - use[a,b] = 0 means it does not.
var use {a in Nodes, b in Nodes}, binary;

# 'flow' is a continuous helper variable. It's part of the
# "subtour elimination" trick.
var flow {a in Nodes, b in Nodes};

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules of the problem.

# 'Path_In': This constraint ensures that every node 'b'
# has *exactly one* path segment *coming into it*.
subject to Path_In {b in Nodes}:
	sum {a in Nodes} use[a,b] = 1;

# 'Path_Out': This constraint ensures that every node 'a'
# has *exactly one* path segment *going out of it*.
#
# Together, 'Path_In' and 'Path_Out' guarantee that our
# 'use' edges will form one or more *disjoint cycles* (loops).
subject to Path_Out {a in Nodes}:
	sum {b in Nodes} use[a,b] = 1;

# --- Subtour Elimination Constraints ---
# The next three constraints work together to force the
# "disjoint cycles" from above into *one single cycle*
# that visits all nodes.

# 'Flow_Direction': A standard flow definition. Flow from
# a->b is the negative of the flow from b->a.
subject to Flow_Direction {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;

# 'Flow_On_Used': Flow can *only* exist (be non-zero) on an
# edge 'a'->'b' if that edge is *selected* (`use[a,b] = 1`).
# '(card(Nodes) - 1)' is a "big-M" value (a number
# larger than any possible flow).
subject to Flow_On_Used {a in Nodes, b in Nodes}:
	flow[a,b] <= use[a,b] * (card(Nodes) - 1);

# 'Material_Balance': This is the core subtour elimination.
# It sets up a flow system where:
#   1. Every node `x` (that is *not* Start) *supplies 1 unit*
#      of flow (`else 1`).
#   2. The `Start` node *demands* `(n-1)` units of flow
#      (`then (1-card(Nodes))`, which is negative).
#
# The *only way* to satisfy this (using only 'use'd edges)
# is to have a single path from *every* node back to `Start`.
# A separate, disconnected subtour (e.g., A->B->C->A)
# would "trap" the 1 unit of flow from A, B, and C,
# violating the constraint.
subject to Material_Balance {x in Nodes}:
	sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
	if (x==Start) then (1-card(Nodes)) else 1;

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'minimize Total_Weight:'
# The solver's goal is to find a set of `use` edges that
# satisfy all constraints and have the *minimum* possible
# total weight (distance).
minimize Total_Weight:
	sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal solution.
solve;

# Print the final, minimized total distance of the tour.
printf "Shortest Hamiltonian cycle: %g\n", Total_Weight;

# This 'for' loop iterates over all pairs (a,b) *but only*
# prints the ones where the solver set `use[a,b] = 1`.
# This prints the final path, edge by edge.
for {a in Nodes, b in Nodes: use[a,b]}
{
	printf "%s->%s (%g)\n", a, b, W[a,b];
}

# === 7. SVG VISUALIZATION ===
# The rest of the code is *not* optimization. It's a script
# within AMPL to *generate an .svg image file* of the solution.

# 'PX' and 'PY' are parameters to scale the (x,y) coordinates
# to fit nicely within a 500x500 pixel image.
param PX {n in Nodes} := 25 + 50 * X[n];
param PY {n in Nodes} := 475 - 50 * Y[n];

# 'SVGFILE' is the name of the output file.
param SVGFILE, symbolic, default "solution.svg";
# `>SVGFILE` *clears* the file, `>>SVGFILE` *appends* to it.
printf "" >SVGFILE;
# These lines print the standard XML/SVG header.
printf "<?xml version=""1.0"" standalone=""no""?>\n" >>SVGFILE;
printf "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1//EN"" " >>SVGFILE;
printf """http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"">\n" >>SVGFILE;
printf "<svg width=""500"" height=""500"" version=""1.0"" " >>SVGFILE;
printf "xmlns=""http://www.w3.org/2000/svg"">\n" >>SVGFILE;

# Draws a light-yellow background rectangle.
printf "<rect x=""0"" y=""0"" width=""500"" height=""500"" " &
		"stroke=""none"" fill=""rgb(255,255,208)""/>\n" >>SVGFILE;

# These loops draw the black background grid.
for {i in 0..9}
{
	printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
			"stroke=""black"" stroke-width=""1""/>\n",
			25+50*i, 475, 25+50*i, 25 >>SVGFILE;
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
			"stroke=""black"" stroke-width=""1""/>\n",
			25, 25+50*i, 475, 25+50*i >>SVGFILE;
}

# This loop draws the *solution path*.
# It iterates through the `use`d edges and draws a
# thick blue line for each one.
for {a in Nodes, b in Nodes: use[a,b]}
{
	printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
			"stroke=""blue"" stroke-width=""3""/>\n",
			PX[a], PY[a], PX[b], PY[b] >>SVGFILE;
}

# This loop draws a red circle for every node
# (except the Start node).
for {n in Nodes: n!=Start}
{
	printf "<circle cx=""%g"" cy=""%g"" r=""%g"" " &
			"stroke=""black"" stroke-width=""1.5"" fill=""red""/>\n",
			PX[n], PY[n], 8 >>SVGFILE;
}

# This draws a special green square to mark the `Start` node.
printf "<rect x=""%g"" y=""%g"" width=""16"" height=""16"" " &
		"stroke=""black"" stroke-width=""1.5"" fill=""green""/>\n",
		PX[Start]-8, PY[Start]-8 >>SVGFILE;

# Closes the SVG tag.
printf "</svg>\n" >>SVGFILE;

# Marks the end of the model file.
end;