# Shortest path problem

set Nodes;
param StartNode, symbolic, in Nodes;
param EndNode, symbolic, in Nodes;

param Distance {a in Nodes, b in Nodes}, default 99999;

var flow {a in Nodes, b in Nodes}, >=-1, <=1;
var use {a in Nodes, b in Nodes}, binary;
	# 1: there is (positive) flow from a to b
	# 0: there is no flow (or negative flow) from a to b
	# Note: not symmetric: use[a,b] and use[b,a] are not related

# if use[a,b] = 0, then flow[a,b] <= 0

s.t. Use_constraint {a in Nodes, b in Nodes}:
	# flow[a,b] <= 0 + M * use[a,b]
	# M=1 (smallest possible, tends to be solved faster)
	flow[a,b] <= use[a,b];

s.t. Flow_symmetry_constraints {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;

s.t. Material_balance {n in Nodes}:
	sum {a in Nodes} flow[a,n] =
		if (n==StartNode) then (-1) else
		if (n==EndNode) then (+1) else
		0;

minimize Total_distance:
	#0.5 * sum {a in Nodes, b in Nodes} abs_flow[a,b] * min(Distance[a,b],Distance[b,a]);
	sum {a in Nodes, b in Nodes} use[a,b] * min(Distance[a,b],Distance[b,a]);
	
	# note min(Distance[a,b],Distance[b,a]) is the actual distance from a to b

solve;

printf "Total distance: %g\n", Total_distance;
for {a in Nodes, b in Nodes : flow[a,b] > 0}
{
	printf "%s -> %s : %g\n", a, b, flow[a,b];
}

data;

set Nodes := A B C D E F P Q;
param StartNode := P;
param EndNode := Q;

param Distance :=
	P	A	9
	P	C	2
	P	E	4
	A	B	8
	A	C	1
	B	C	5
	B	D	2
	B	Q	7
	C	D	2
	C	E	3
	D	E	4
	D	F	1
	E	F	6
	F	Q	9
	;

end;
