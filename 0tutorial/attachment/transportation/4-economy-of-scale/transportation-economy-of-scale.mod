set Supplies;
set Demands;

param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;

set Connections := Supplies cross Demands;

param Cost {(s,d) in Connections}, >=0;

param CostThreshold, >=0;
param CostDecPercent, >0, <=100;

param CostOverThreshold {(s,d) in Connections} := Cost[s,d] * (1 - CostDecPercent / 100);

check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

var tran {(s,d) in Connections}, >=0;
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;
var tranOver {(s,d) in Connections}, >=0;
var isOver {(s,d) in Connections}, binary;

s.t. Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t. Requirement_at_Demand_Points {d in Demands}:
	sum {s in Supplies} tran[s,d] >= Required[d];

s.t. Total_Transported {(s,d) in Connections}:
	tran[s,d] = tranBase[s,d] + tranOver[s,d];

param M := sum {s in Supplies} Available[s];

s.t. Zero_Over_Threshold_if_Threshold_Not_Chosen {(s,d) in Connections}:
	tranOver[s,d] <= M * isOver[s,d];

s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
#	tranBase[s,d] >= CostThreshold - M * (1 - isOver[s,d]);
	tranBase[s,d] >= CostThreshold * isOver[s,d];

minimize Total_Costs: sum {(s,d) in Connections} (tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);

solve;

printf "Optimal cost: %g.\n", Total_Costs;
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g=%g+%g amount for %g (unit cost: %g/%g).\n",
		s, d, tran[s,d], tranBase[s,d], tranOver[s,d],
		(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]),
		Cost[s,d], CostOverThreshold[s,d];
}

end;
