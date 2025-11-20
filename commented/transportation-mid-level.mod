set Supplies;
set Centers;
set Demands;

param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;

set ConnectionsA := Supplies cross Centers;
set ConnectionsB := Centers cross Demands;

param CostA {(s,c) in ConnectionsA}, >=0;
param CostB {(c,d) in ConnectionsB}, >=0;
param EstablishCost {c in Centers}, >=0;

check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

var tranA {(s,c) in ConnectionsA}, >=0;
var tranB {(c,d) in ConnectionsB}, >=0;
var atCenter {c in Centers}, >=0;
var useCenter {c in Centers}, binary;

s.t. Availability_at_Supply_Points {s in Supplies}:
	sum {c in Centers} tranA[s,c] <= Available[s];

s.t. Total_To_Center {c in Centers}:
	atCenter[c] = sum {s in Supplies} tranA[s,c];

s.t. Total_From_Center {c in Centers}:
	atCenter[c] = sum {d in Demands} tranB[c,d];

s.t. Requirement_at_Demand_Points {d in Demands}:
	sum {c in Centers} tranB[c,d] >= Required[d];

param M := sum {s in Supplies} Available[s];

s.t. Zero_at_Center_if_Not_Established {c in Centers}:
	atCenter[c] <= M * useCenter[c];

minimize Total_Costs:
	sum {(s,c) in ConnectionsA} tranA[s,c] * CostA[s,c] +
	sum {(c,d) in ConnectionsB} tranB[c,d] * CostB[c,d] +
	sum {c in Centers} useCenter[c] * EstablishCost[c];

solve;

printf "Optimal cost: %g.\n", Total_Costs;
for {c in Centers: useCenter[c]}
{
	printf "Establishing center %s for %g.\n", c, EstablishCost[c];
}
for {(s,c) in ConnectionsA: tranA[s,c] > 0}
{
	printf "A: From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, c, tranA[s,c], tranA[s,c] * CostA[s,c], CostA[s,c];
}
for {(c,d) in ConnectionsB: tranB[c,d] > 0}
{
	printf "B: From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		c, d, tranB[c,d], tranB[c,d] * CostB[c,d], CostB[c,d];
}

end;
