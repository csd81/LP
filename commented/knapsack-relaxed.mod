set Items;

param Weight {i in Items}, >=0;
param Gain {i in Items}, >=0;

param Capacity, >=0;

var select {i in Items}, >=0, <=1;

s.t. Total_Weight:
	sum {i in Items} select[i] * Weight[i] <= Capacity;

maximize Total_Gain:
	sum {i in Items} select[i] * Gain[i];

solve;

printf "Optimal Gain: %g\n", Total_Gain;
printf "Total Weight: %g\n",
	sum {i in Items} select[i] * Weight[i];
for {i in Items}
{
	printf "%s: %g\n", i, select[i];
}

end;
