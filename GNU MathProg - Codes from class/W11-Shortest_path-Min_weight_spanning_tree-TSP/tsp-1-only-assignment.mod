# Travelling Salesman Problem (TSP)

set Nodes;
param CentralNode, symbolic, in Nodes;
param Distance {a in Nodes, b in Nodes}, default 99999;

# Assignment problem

var use {a in Nodes, b in Nodes}, binary;
# node b is assigned to node a: the path contains a->b link

# each node will have a single successor
# for each a, there will be a single b
s.t. Assignment_constraint_1 {a in Nodes}:
	sum {b in Nodes} use[a,b] = 1;

# each node will have a single predecessor
# for each b, there will be a single a
s.t. Assignment_constraint_2 {b in Nodes}:
	sum {a in Nodes} use[a,b] = 1;

minimize Travelled_Distance:
	sum {a in Nodes, b in Nodes}
		use[a,b] * min(Distance[a,b],Distance[b,a]);
# note: min(Distance[a,b],Distance[b,a]) is the actual distance from a to b

solve;

printf "Travelled distance: %g\n", Travelled_Distance;
for {a in Nodes, b in Nodes : use[a,b]}
{
	printf "%s -> %s (%g)\n",
		a, b, min(Distance[a,b],Distance[b,a]);
}

data;

set Nodes := A B C D E F P Q;
param CentralNode := P;
# param EndNode := Q;

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