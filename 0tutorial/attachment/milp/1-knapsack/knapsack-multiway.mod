set Items;

param Weight {i in Items}, >=0;

param Knapsack_Count, integer;
set Knapsacks := 1 .. Knapsack_Count;

var select {i in Items, k in Knapsacks}, binary;
var weight {k in Knapsacks};
var min_weight;
var max_weight;

s.t. Partitioning {i in Items}:
	sum {k in Knapsacks} select[i,k] = 1;

s.t. Total_Weights {k in Knapsacks}:
	weight[k] = sum {i in Items} select[i,k] * Weight[i];

s.t. Total_Weight_from_Below {k in Knapsacks}:
	min_weight <= weight[k];

s.t. Total_Weight_from_Above {k in Knapsacks}:
	max_weight >= weight[k];

minimize Difference: max_weight - min_weight;

solve;

printf "Smallest difference: %g (%g - %g)\n",
	Difference, max_weight, min_weight;
for {k in Knapsacks}
{
	printf "%d:", k;
	for {i in Items: select[i,k]}
	{
		printf " %s", i;
	}
	printf " (%g)\n", weight[k];
}

end;
