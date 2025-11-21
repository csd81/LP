# Knapsack problem

# Items: A B C D E F G H I J
# Weights: 1.2 3.3 4.2 0.9 5.5 3.4 2.2 2.9 4.4 5.0 (kg)
# Gains: 10 30 41 8 45 36 29 22 61 71 ($)
# Maximum total weight: 10 (kg)

# What items to select, to maximize total gain,
# but remain within total weight limit?

# instance data:
set Items;
param Weight {i in Items};
param MaxAmount {i in Items}, default 1;
param Gain {i in Items};
param Max_Weight;

# variables (decisions):
# var select {i in Items}, >=0, <=1; # trivial
# var select {i in Items}, binary; # NP-hard
var select {i in Items}, integer, >=0, <=MaxAmount[i];
	# same problem (but technically different implementation)

s.t. Constraint_for_max_total_weight:
	sum {i in Items} select[i] * Weight[i] <= Max_Weight;

maximize Total_Gain:
	sum {i in Items} select[i] * Gain[i];

solve;

printf "Total Gain: %g\n", Total_Gain;
for {i in Items}
{
	printf "[%s] -> %g (ratio: %g)\n", i, select[i], Gain[i]/Weight[i];
}
printf "Selected:";
for {i in Items : select[i]}
{
	printf " %sx%d", i, select[i];
}
printf "\nNot selected";
for {i in Items : select[i]==0}
{
	printf " %s", i;
}
printf "\n";

data;

# Items: A B C D E F G H I J
# Weights: 1.2 3.3 4.2 0.9 5.5 3.4 2.2 2.9 4.4 5.0 (kg)
# Gains: 10 30 41 8 45 36 29 22 61 71 ($)
# Maximum total weight: 10 (kg)

set Items := A B C D E F G H I J;
param Weight :=
	A	1.2
	B	3.3
	C	4.2
	D	0.9
	E	5.5
	F	3.4
	G	2.2
	H	2.9
	I	4.4
	J	5.0
	;
param MaxAmount :=
	J	3
	;
param Gain :=
	A	10
	B	30
	C	41
	D	8
	E	45
	F	36
	G	29
	H	22
	I	61
	J	71
	;
param Max_Weight := 20;

end;
