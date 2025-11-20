set FoodTypes;
set Nutrients;

param Food_Cost {f in FoodTypes}, >=0, default 0;
param Content {f in FoodTypes, n in Nutrients}, >=0, default 0;
param Requirement {n in Nutrients}, >=0, default 0;

var eaten {f in FoodTypes}, >=0;
var total_costs;

s.t. Nutrient_Requirements {n in Nutrients}: sum {f in FoodTypes} Content[f,n] * eaten[f] >= Requirement[n];
s.t. Total_Costs_Calc: total_costs = sum {f in FoodTypes} Food_Cost[f] * eaten[f];

minimize Total_Costs: total_costs;

solve;

printf "Total Costs: %g\n", total_costs;

param Nutrient_Intake {n in Nutrients} := sum {f in FoodTypes} Content[f,n] * eaten[f];

for {f in FoodTypes}
{
	printf "Eaten of %s: %g\n", f, eaten[f];
}

for {n in Nutrients}
{
	printf "Requirement %g of nutrient %s done with %g\n", Requirement[n], n, Nutrient_Intake[n];
}

end;
