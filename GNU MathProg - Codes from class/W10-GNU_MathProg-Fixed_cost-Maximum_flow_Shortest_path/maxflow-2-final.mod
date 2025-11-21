# Maximum flow problem

set Nodes;
param StartNode, symbolic, in Nodes;
param EndNode, symbolic, in Nodes;

param Capacity {a in Nodes, b in Nodes}, default 0;
# in this way, Capacity[a,b] only needs to be defined in either direction

var flow {a in Nodes, b in Nodes},
		>= - max(Capacity[a,b],Capacity[b,a]),
		<= + max(Capacity[a,b],Capacity[b,a]);

var throughput; # total throughput of the network

# flow[a,b] - flow[b,a] ?
s.t. Flow_symmetry_constraints {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;
	# or: flow[a,b] = - flow[b,a]

s.t. Material_balance {n in Nodes}:
	sum {a in Nodes} flow[a,n] =
		if (n==StartNode) then (-throughput) else
		if (n==EndNode) then (+throughput) else
		0;

maximize Total_throughput: throughput;

solve;

printf "Throughput: %g\n", throughput;
for {a in Nodes, b in Nodes : flow[a,b] > 0}
{
	printf "%s -> %s : %g\n", a, b, flow[a,b];
}

data;

set Nodes := A B C D E F P Q;
param StartNode := P;
param EndNode := Q;

param Capacity :=
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
