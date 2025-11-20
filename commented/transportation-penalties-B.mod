set Supplies;
set Demands;

param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;

set Connections := Supplies cross Demands;

param Cost {(s,d) in Connections}, >=0;

check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];

param ShortagePenalty, >=0;
param SurplusPenalty, >=0;

var tran {(s,d) in Connections}, >=0;
var satisfied {d in Demands}, >=0;
var surplus {d in Demands}, >=0;
var shortage {d in Demands}, >=0;

s.t. Calculating_Demand_Satisfied {d in Demands}:
	satisfied[d] = sum {s in Supplies} tran[s,d];

s.t. Availability_at_Supply_Points {s in Supplies}:
	sum {d in Demands} tran[s,d] <= Available[s];

s.t. Calculating_Exact_Demands {d in Demands}:
	Required[d] - shortage[d] + surplus[d] = satisfied[d];

minimize Total_Costs:
	sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
	sum {d in Demands} (shortage[d] * ShortagePenalty + surplus[d] * SurplusPenalty);

solve;

printf "Optimal cost: %g.\n", Total_Costs;
for {d in Demands}
{
	printf "Required: %s, Satisfied: %g (%+g)\n",
		d, satisfied[d], satisfied[d]-Required[d];
}
for {(s,d) in Connections: tran[s,d] > 0}
{
	printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
		s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}

end;
