/* Problem 17.
    Given a set of raw materials and a set of products. 
    There is also a set of recipes defined. 
    Each recipe describes the ratio in which it consumes raw materials, and produces products, 
    these are arbitrary nonnegative numbers. 
    Each recipe may be utilized in an arbitrary amount, which is named its volume. 
    There is a unit cost defined for each raw material, and a unit revenue for each product. 
    There can be minimal and maximal total consumption amounts defined for each raw material, 
    and minimal and maximal total production amounts defined for each product. 
    For practical purposes, the amounts of consumed raw materials are limited: 
    their total costs cannot exceed a given value, which is the initial funds available for raw material purchase. 
    Find the optimal production, where recipes are utilized in arbitrary volumes so that all the limits on consumption and production are satisfied, 
    and the total profit is maximal. 
    The total profit is the difference of the total revenue from products and the total costs of raw materials consumed. 
*/



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

# Helper variables (defined via constraints)
var Total_Material_Consumed {MATERIALS} >= 0;
var Total_Product_Produced {PRODUCTS} >= 0;
var Total_Cost >= 0;
var Total_Revenue >= 0;

# Definitions
s.t. Def_Total_Material_Consumed {m in MATERIALS}:
    Total_Material_Consumed[m] = sum {r in RECIPES} Recipe_Volume[r] * Recipe_Inputs[r, m];

s.t. Def_Total_Product_Produced {p in PRODUCTS}:
    Total_Product_Produced[p] = sum {r in RECIPES} Recipe_Volume[r] * Recipe_Outputs[r, p];

s.t. Def_Total_Cost:
    Total_Cost = sum {m in MATERIALS} Total_Material_Consumed[m] * Material_Cost[m];

s.t. Def_Total_Revenue:
    Total_Revenue = sum {p in PRODUCTS} Total_Product_Produced[p] * Product_Revenue[p];

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


end;
