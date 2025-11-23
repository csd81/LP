set Products;
set Raw_Materials;

param Storage {r in Raw_Materials}, >=0;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;
param Min_Usage {r in Raw_Materials}, >=0, default 0;
param Min_Production {p in Products}, >=0, default 0;
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;
var min_production;

s.t. Usage_Calc {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];
s.t. Total_Revenue_Calc: total_revenue = sum {p in Products} Revenue[p] * production[p];
s.t. Minimum_Production_Calc {p in Products}: min_production <= production[p];

maximize Minimum_Production: min_production;

solve;

printf "Total Revenue: %g\n", total_revenue;
printf "Minimum Production: %g\n", min_production;

for {p in Products}
{
	printf "Production of %s: %g\n", p, production[p];
}

for {r in Raw_Materials}
{
	printf "Usage of %s: %g, remaining: %g\n", r, usage[r], Storage[r] - usage[r];
}

end;
