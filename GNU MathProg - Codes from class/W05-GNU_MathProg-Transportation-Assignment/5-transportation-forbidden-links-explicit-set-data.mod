# Transportation problem

set Warehouses; # supply sites, sources
set Markets; # demand sites, targets
param Availability {w in Warehouses}; # available supply at site w
param Demand {m in Markets}, >=0; # required amount at site m
param Cost {w in Warehouses, m in Markets};

set Forbidden_Links within Warehouses cross Markets;

# Total supply : S
# Total demand : D
# S > D : can be solved, leftover amounts
# S = D : can be solved, no leftovers possible (everything is an equality)
# S < D : no solution

param Total_Supply := sum {w in Warehouses} Availability[w];
printf "Total Supply = %g\n", Total_Supply;
param Total_Demand := sum {m in Markets} Demand[m];
printf "Total Demand = %g\n", Total_Demand;

check Total_Supply >= Total_Demand;

check {w in Warehouses} Availability[w] >= 0;

var trans {w in Warehouses, m in Markets}, >=0, integer;

s.t. Source_Availability {w in Warehouses}:
	sum {m in Markets} trans[w,m] = Availability[w];
s.t. Market_Demands {m in Markets}:
	sum {w in Warehouses} trans[w,m] = Demand[m];

#s.t. Forbidden_Links_Constraint
#	{w in Warehouses, m in Markets : (w,m) in Forbidden_Links}:
#		trans[w,m] = 0;

s.t. Forbidden_Links_Constraint {(w,m) in Forbidden_Links}:
	trans[w,m] = 0;

minimize Total_Cost:
	sum {w in Warehouses, m in Markets}
		trans[w,m] * Cost[w,m];

solve;

for {w in Warehouses, m in Markets : trans[w,m] > 0}
{
	printf "Warehouse %s, Market %s = %g\n",
		w, m, trans[w,m];
}

printf "Total cost = %g\n", Total_Cost;

data;

#	1	2	9	7	4	|	10
#	1	2	5	4	2	|	10
#	1	7	9	5	6	|	15
#	4	4	5	6	2	|	10
# ---
#	20	5	5	5	10

set Warehouses := S1 S2 S3 S4 S5;
set Markets := T1 T2 T3 T4;

param Availability := # availability at a given warehouse
	S1	20
	S2	5
	S3	5
	S4	5
	S5	10
	;

param Demand := # demand at a given market
	T1	10
	T2	10
	T3	15
	T4	10
	;

param Cost (tr):
		S1	S2	S3	S4	S5	:=
	T1	1	2	9	7	4
	T2	1	2	5	4	2
	T3	1	7	9	5	6
	T4	4	4	5	6	2
	;

set Forbidden_Links :=
	S1	T3
#	S1	T4
#	S1	T2
	S4	T2
	;

end;
