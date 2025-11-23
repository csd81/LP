set Supplies;
set Demands;

param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;

set Connections := Supplies cross Demands;

param Cost {(s,d) in Connections}, >=0;
param FixedCost {(s,d) in Connections}, >=0;

check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

var tran {(s,d) in Connections}, >=0;
var tranUsed {(s,d) in Connections}, binary;

s.t. Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t. Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

param M := sum {s in Supplies} Available[s];

s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
#	tran[s,d] <= M * tranUsed[s,d];
	tran[s,d] <= min(Available[s],Required[d]) * tranUsed[s,d];

minimize Total_Costs: sum {(s,d) in Connections} (tran[s,d] * Cost[s,d] + tranUsed[s,d] * FixedCost[s,d]);

solve;

printf "Optimal cost: %g.\n", Total_Costs;
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g amount for %g (unit cost: %g, fixed: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d] + FixedCost[s,d], Cost[s,d], FixedCost[s,d];
}

end;
