set Nodes;
param Start, symbolic, in Nodes;
param Finish, symbolic, in Nodes;
check Start!=Finish;

param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);

var flow {a in Nodes, b in Nodes}, binary;

subject to Material_Balance {x in Nodes}:
	sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
	if (x==Start) then -1 else if (x==Finish) then 1 else 0;

minimize Total_Weight:
	sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b];

solve;

printf "Distance %s-%s: %g\n", Start, Finish, Total_Weight;
for {a in Nodes, b in Nodes: flow[a,b]}
{
	printf "%s->%s (%g)\n", a, b, W[a,b];
}

end;
