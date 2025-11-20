
set MATERIALS;
set PRODUCTS;
set RECIPES;

# Parameters for Recipes
param Recipe_Inputs {RECIPES, MATERIALS} >= 0, default 0;
param Recipe_Outputs {RECIPES, PRODUCTS} >= 0, default 0;

# Parameters for Costs and Revenues
param Material_Cost {MATERIALS} >= 0;
param Product_Revenue {PRODUCTS} >= 0;

# Constraints on Materials
param Min_Material_Usage {MATERIALS} >= 0, default 0;
param Max_Material_Usage {MATERIALS} >= 0, default 999999;

# Constraints on Products
param Min_Product_Production {PRODUCTS} >= 0, default 0;
param Max_Product_Production {PRODUCTS} >= 0, default 999999;

# Budget Constraint
param Budget >= 0;

# Variable: Volume of each recipe used
var Recipe_Volume {RECIPES} >= 0;

# Helper expressions for clarity
var Total_Material_Consumed {m in MATERIALS} = 
    sum {r in RECIPES} Recipe_Volume[r] * Recipe_Inputs[r, m];

var Total_Product_Produced {p in PRODUCTS} = 
    sum {r in RECIPES} Recipe_Volume[r] * Recipe_Outputs[r, p];

var Total_Cost = 
    sum {m in MATERIALS} Total_Material_Consumed[m] * Material_Cost[m];

var Total_Revenue = 
    sum {p in PRODUCTS} Total_Product_Produced[p] * Product_Revenue[p];

# Constraints
s.t. Material_Min_Constraint {m in MATERIALS}:
    Total_Material_Consumed[m] >= Min_Material_Usage[m];

s.t. Material_Max_Constraint {m in MATERIALS}:
    Total_Material_Consumed[m] <= Max_Material_Usage[m];

s.t. Product_Min_Constraint {p in PRODUCTS}:
    Total_Product_Produced[p] >= Min_Product_Production[p];

s.t. Product_Max_Constraint {p in PRODUCTS}:
    Total_Product_Produced[p] <= Max_Product_Production[p];

s.t. Budget_Limit:
    Total_Cost <= Budget;

# Objective: Maximize Profit
maximize Profit: Total_Revenue - Total_Cost;

solve;

# Output results
printf "\n--- Results ---\n";
printf "Maximized Profit: %.2f\n", Profit;
printf "Total Revenue: %.2f\n", Total_Revenue;
printf "Total Cost: %.2f (Budget: %.2f)\n\n", Total_Cost, Budget;

printf "Recipe Volumes:\n";
for {r in RECIPES} {
    printf "  %s: %.2f\n", r, Recipe_Volume[r];
}

printf "\nProduct Production:\n";
for {p in PRODUCTS} {
    printf "  %s: %.2f (Min: %g, Max: %g)\n", p, Total_Product_Produced[p], Min_Product_Production[p], Max_Product_Production[p];
}

printf "\nMaterial Consumption:\n";
for {m in MATERIALS} {
    printf "  %s: %.2f (Min: %g, Max: %g)\n", m, Total_Material_Consumed[m], Min_Material_Usage[m], Max_Material_Usage[m];
}
printf "\n";

data;

set MATERIALS := Flour Sugar Eggs Chocolate;
set PRODUCTS := Cake Cookies Brownies;
set RECIPES := Cake_Recipe Cookie_Recipe Brownie_Recipe;

param Budget := 5000;

param Material_Cost :=
    Flour 0.5
    Sugar 0.8
    Eggs 0.2
    Chocolate 2.0;

param Product_Revenue :=
    Cake 15
    Cookies 5
    Brownies 8;

param Recipe_Inputs:
                     Flour Sugar Eggs Chocolate :=
    Cake_Recipe      2     1     3    0
    Cookie_Recipe    1     0.5   1    0.2
    Brownie_Recipe   1.5   1.5   2    1.5;

param Recipe_Outputs:
                     Cake Cookies Brownies :=
    Cake_Recipe      1    0       0
    Cookie_Recipe    0    6       0
    Brownie_Recipe   0    0       4;

# Optional constraints
param Min_Product_Production :=
    Cake 10;

param Max_Material_Usage :=
    Chocolate 500;

end;
