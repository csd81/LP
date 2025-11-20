set Products;
set Raw_Materials;

param Storage {r in Raw_Materials}, >=0;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;

var production {p in Products}, >=0;

s.t. Material_Balance {r in Raw_Materials}: sum {p in Products} Consumption_Rate[r,p] * production[p] <= Storage[r];

maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];

solve;

printf "Total Revenue: %g\n", sum {p in Products} Revenue[p] * production[p];

param Material_Consumed {r in Raw_Materials} := sum {p in Products} Consumption_Rate[r,p] * production[p];
param Material_Remained {r in Raw_Materials} := Storage[r] - Material_Consumed[r];

for {p in Products}
{
	printf "Production of %s: %g\n", p, production[p];
}

for {r in Raw_Materials}
{
	printf "Usage of %s: %g, remaining: %g\n", r, Material_Consumed[r], Material_Remained[r];
}

end;
