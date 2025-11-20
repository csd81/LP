set Raws;
set Products;
set Recipes;

check card(Raws inter Products) == 0;
set Materials := Products union Raws;

param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
param Value {m in Materials}, >=0, default 0;
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
param Initial_Funds, >=0, default 1e100;

var volume {c in Recipes}, >=0;
var usage {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;

s.t. Material_Balance {m in Materials}: usage[m] = sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];
s.t. Total_Costs_Calc: total_costs = sum {r in Raws} Value[r] * usage[r];
s.t. Total_Revenue_Calc: total_revenue = sum {p in Products} Value[p] * usage[p];
s.t. Profit_Calc: profit = total_revenue - total_costs;

maximize Profit: profit;

solve;

printf "Total Costs: %g\n", total_costs;
printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;

for {c in Recipes}
{
	printf "Volume of recipe %s: %g\n", c, volume[c];
}
for {r in Raws}
{
	printf "Consumption of raw %s: %g\n", r, usage[r];
}
for {p in Products}
{
	printf "Production of product %s: %g\n", p, usage[p];
}

end;
