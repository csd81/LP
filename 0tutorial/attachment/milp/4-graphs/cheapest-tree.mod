set Nodes;
param Sink, symbolic, in Nodes;

param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);

var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};

subject to Flow_Direction {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;

subject to Flow_On_Used {a in Nodes, b in Nodes}:
	flow[a,b] <= use[a,b] * (card(Nodes) - 1);

subject to Material_Balance {x in Nodes}:
	sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
	if (x==Sink) then (1-card(Nodes)) else 1;

minimize Total_Weight:
	sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];

solve;

printf "Cheapest spanning tree: %g\n", Total_Weight;
for {a in Nodes, b in Nodes: use[a,b]}
{
	printf "%s<-%s (%g)\n", a, b, W[a,b];
}

end;
