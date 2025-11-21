# Transportation problem
# (A) linear cost

set Warehouses; # supply sites, sources
set Markets; # demand sites, targets
param Availability {w in Warehouses}; # available supply at site w
param Demand {m in Markets}, >=0; # required amount at site m
param Cost {w in Warehouses, m in Markets};

param Total_Supply := sum {w in Warehouses} Availability[w];
printf "Total Supply = %g\n", Total_Supply;
param Total_Demand := sum {m in Markets} Demand[m];
printf "Total Demand = %g\n", Total_Demand;

check Total_Supply >= Total_Demand;

check {w in Warehouses} Availability[w] >= 0;

var trans {w in Warehouses, m in Markets}, >=0;

s.t. Source_Availability {w in Warehouses}:
	sum {m in Markets} trans[w,m] <= Availability[w];
s.t. Market_Demands {m in Markets}:
	sum {w in Warehouses} trans[w,m] >= Demand[m];

minimize Total_Cost:
	sum {w in Warehouses, m in Markets}
		trans[w,m] * Cost[w,m];

solve;

for {w in Warehouses, m in Markets}
{
	printf "Warehouse %s, Market %s = %g\n",
		w, m, trans[w,m];
}

printf "Total cost = %g\n", Total_Cost;

data;

# Transportation costs per unit
#		T1	T2	T3
# SA	235	57	340
# SB	130	385	197

# Available amounts: SA: 11 units, SB: 10 units.
# Target amounts: T1: 5 units, T2: 13 units, T3: 2 units.

set Warehouses := A B;
set Markets := T1 T2 T3;

param Availability := # availability at a given warehouse
	A	11
	B	10
	;

param Demand := # demand at a given market
	T1	5
	T2	13
	T3	2
	;

param Cost:
		T1	T2	T3 :=
	A	235	57	340
	B	130	385	197
	;

end;
