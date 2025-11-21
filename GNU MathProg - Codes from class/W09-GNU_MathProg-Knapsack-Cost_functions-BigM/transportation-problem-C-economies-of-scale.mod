# Transportation problem
# (c) decreasing unit cost (economies of scale)
# -> no longer purely LP, but Mixed-Integer LP (MILP)

# There are two extra parameters, TH(reshold) and F(actor)
# If transported amount in any single direction is more than TH,
# Then the cost is multiplied by F for surplus units.

# Important note: 0 < F < 1 

# e.g. TH = 5, F = 2.5
# if I transport 7 units, then 5 units at original cost, +2 units at 2.5x cost. 

set Warehouses; # supply sites, sources
set Markets; # demand sites, targets
param Availability {w in Warehouses}; # available supply at site w
param Demand {m in Markets}, >=0; # required amount at site m
param Cost {w in Warehouses, m in Markets};

param Threshold;
param Factor, >0, <1;

param Total_Supply := sum {w in Warehouses} Availability[w];
printf "Total Supply = %g\n", Total_Supply;
param Total_Demand := sum {m in Markets} Demand[m];
printf "Total Demand = %g\n", Total_Demand;
check Total_Supply >= Total_Demand;
check {w in Warehouses} Availability[w] >= 0;

var trans {w in Warehouses, m in Markets}, >=0;
	# transported amount
var trans_below {w in Warehouses, m in Markets}, >=0, <=Threshold;
	# part of transported amount below threshold
var trans_above {w in Warehouses, m in Markets}, >=0;
	# part of transported amount below threshold

var reach_threshold {w in Warehouses, m in Markets}, binary;
	# 0: threshold NOT reached
	# 1: threshold reached

param M := 1000; # big-M, a large positive constant

# if threshold is reached, then "trans_below = Threshold"
s.t. Threshold_reached {w in Warehouses, m in Markets}:
	# trans_below[w,m] >= Threshold "if reach_threshold[w,m] == 1";
	trans_below[w,m] >= Threshold - M * (1 - reach_threshold[w,m]);
	# then, if reach==1, we have "trans_below[w,m] >= Threshold" -> so it is equal to Threshold
	# if reach==0, the constraint is redundant

# if threshold is NOT reached, then "trans_above = 0"
s.t. Threshold_NOT_reached{w in Warehouses, m in Markets}:
	# trans_above[w,m] <= 0 "if reach_threshold[w,m] == 0";
	trans_above[w,m] <= 0 + M * reach_threshold[w,m];
	# then if reach==0, we have "trans_above[w,m] <= 0" ->so it is equal to zero
	# if reach==1, the constraint is redundant
	
# trans = trans_below + trans_above
s.t. Split_Constraint {w in Warehouses, m in Markets}:
	trans[w,m] = trans_below[w,m] + trans_above[w,m];

s.t. Source_Availability {w in Warehouses}:
	sum {m in Markets} trans[w,m] <= Availability[w];
s.t. Market_Demands {m in Markets}:
	sum {w in Warehouses} trans[w,m] >= Demand[m];

minimize Total_Cost:
	sum {w in Warehouses, m in Markets}
		( trans_below[w,m] * Cost[w,m] +
		trans_above[w,m] * Cost[w,m] * Factor);

solve;

for {w in Warehouses, m in Markets}
{
	printf "Warehouse %s, Market %s = %2g = %g+%g\n",
		w, m, trans[w,m], trans_below[w,m], trans_above[w,m];
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

param Threshold := 3;

param Factor := 0.7;

end;
