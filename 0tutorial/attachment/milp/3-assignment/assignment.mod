set Workers;
set Tasks;
check card(Workers)==card(Tasks);
set Assignments := Workers cross Tasks;

param Cost {(w,t) in Assignments};

param Fixing {(w,t) in Assignments}, in {0,1,2}, default 2;

var assign {(w,t) in Assignments}, binary;

s.t. Fixing_Constraints {(w,t) in Assignments: Fixing[w,t]!=2}:
	assign[w,t] = Fixing[w,t];

s.t. One_Task_Per_Worker {w in Workers}:
	sum {t in Tasks} assign[w,t] = 1;

s.t. One_Worker_Per_Task {t in Tasks}:
	sum {w in Workers} assign[w,t] = 1;

minimize Total_Cost:
	sum {(w,t) in Assignments} assign[w,t] * Cost[w,t];

solve;

printf "Optimal Cost: %g\n", Total_Cost;
for {w in Workers}
{
	printf "%s->", w;
	for {t in Tasks: assign[w,t]}
	{
		printf "%s (%g)\n", t, Cost[w,t];
	}
}

end;
