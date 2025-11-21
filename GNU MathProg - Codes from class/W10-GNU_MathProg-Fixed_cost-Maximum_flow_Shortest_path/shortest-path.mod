# Shrotest path problem

set Nodes;
param StartNode, symbolic, in Nodes;
param EndNode, symbolic, in Nodes;

param Distance {a in Nodes, b in Nodes}, default 99999;

var flow {a in Nodes, b in Nodes}, >=-1, <=1;
var abs_flow {a in Nodes, b in Nodes};
	# denotes a lower bound for the absolute (positive) flow in a pipe

s.t. Absolute_flow_constraints {a in Nodes, b in Nodes}:
	abs_flow[a,b] >= flow[a,b];

s.t. Absolute_flow_symmetry {a in Nodes, b in Nodes}:
	abs_flow[a,b] = abs_flow[b,a];

s.t. Flow_symmetry_constraints {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;

s.t. Material_balance {n in Nodes}:
	sum {a in Nodes} flow[a,n] =
		if (n==StartNode) then (-1) else
		if (n==EndNode) then (+1) else
		0;

minimize Total_distance:
	0.5 * sum {a in Nodes, b in Nodes} abs_flow[a,b] * min(Distance[a,b],Distance[b,a]);

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
