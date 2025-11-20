 
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

