# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.

# 'Raws': Raw materials (e.g., 'wood', 'ore').
set Raws;
# 'Products': Finished goods (e.g., 'chair', 'iron').
set Products;
# 'Recipes': Production processes (e.g., 'make_chair').
set Recipes;
# 'Orders': A set of special contracts or deals we can
# choose to accept. 'default {}' allows the model to
# run even if there are no orders.
set Orders, default {};

# Safety check: No item can be both a raw material and a product.
check card(Raws inter Products) == 0;
# 'Materials': A helper set combining all Raws and Products.
set Materials := Products union Raws;

# === 2. PARAMETER DECLARATIONS ===
# These are the input data (numbers) for the problem.

# 'Min_Usage'/'Max_Usage': Overall limits on how much
# of a material we can use or produce (e.g., market demand).
param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
# 'Value': Market cost (for Raws) or market revenue (for Products).
param Value {m in Materials}, >=0, default 0;
# 'Recipe_Ratio': Defines the recipes.
#   - For Raws: amount *consumed* per recipe run.
#   - For Products: amount *produced* per recipe run.
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
# 'Initial_Funds': Our starting budget.
param Initial_Funds, >=0, default 1e100;

# --- Order-Specific Parameters ---

# 'Order_Material_Flow': Defines the "bill of materials" for one
# unit of an order.
#   - For Raws: 'Order_Material_Flow[o,r]' is the amount of 'r'
#     we *get* from accepting order 'o' once.
#   - For Products: 'Order_Material_Flow[o,p]' is the amount of 'p'
#     we *must supply* for order 'o' once.
param Order_Material_Flow {o in Orders, m in Materials}, >=0, default 0;

# 'Order_Cash_Flow': The money exchanged for one unit of order 'o'.
#   - Positive value: We *pay* this amount (a cost).
#   - Negative value: We *are paid* this amount (a revenue).
param Order_Cash_Flow {o in Orders}, default 0;

# 'Order_Count': The *maximum* number of times we can accept order 'o'.
param Order_Count {o in Orders}, >=0, integer, default 1;

# 'Order_Pay_Before': A flag.
#   - 1 (true): The cash flow affects our 'Initial_Funds' (a cost).
#   - 0 (false): The cash flow affects our 'Total_Revenue'.
param Order_Pay_Before {o in Orders}, binary, default 1;

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver needs to find.

# 'volume': How many times to run each production recipe.
var volume {c in Recipes}, >=0;
# 'total_costs': Helper variable, limited by our budget.
var total_costs, <=Initial_Funds;
# 'total_revenue', 'profit': Helper variables.
var total_revenue;
var profit;

# 'ordcnt': Our *other* main decision variable.
# How many times (as an *integer*) do we accept each order?
var ordcnt {o in Orders}, integer, >=0, <=Order_Count[o];

# --- Material Flow Helper Variables ---
# These variables break down the flow of materials to make
# the constraints easier to read.
#
# 'usage_orders': Total material flow from *all accepted orders*.
var usage_orders {m in Materials}, >=0;
# 'usage_market': Total materials *bought from* (Raws) or
# *sold to* (Products) the open market.
var usage_market {m in Materials}, >=0;
# 'usage_production': Total materials *consumed* (Raws) or
# *produced* (Products) by our recipes.
var usage_production {m in Materials}, >=0;
# 'usage_leftover': A variable to track any unused raw materials.
var usage_leftover {r in Raws}, >=0;
# 'usage_total': The final net usage, bounded by Min/Max_Usage.
var usage_total {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules.

# --- Material Calculation Constraints ---
# These calculate the values for the helper variables.
s.t. Material_Balance_Production {m in Materials}: usage_production[m] = sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];
s.t. Material_Balance_Orders {m in Materials}: usage_orders[m] = sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];

# --- Material Balance Constraints (The Core Logic) ---

# For RAW MATERIALS:
# Source of Raws = Use of Raws
# (From Orders) + (From Market) = (Used in Production) + (Left Over)
s.t. Material_Balance_Total_Raws_1 {r in Raws}: usage_total[r] = usage_orders[r] + usage_market[r];
s.t. Material_Balance_Total_Raws_2 {r in Raws}: usage_total[r] = usage_production[r] + usage_leftover[r];

# For PRODUCTS:
# Source of Products = Use of Products
# (From Production) = (Used for Orders) + (Sold to Market)
s.t. Material_Balance_Total_Products_1 {p in Products}: usage_total[p] = usage_production[p];
s.t. Material_Balance_Total_Products_2 {p in Products}: usage_total[p] = usage_orders[p] + usage_market[p];


# --- Financial Constraints ---

# 'total_costs' = (Cost of raws from market) + (Cost of orders paid *before* production)
# Note: If an order *pays us* (negative cost), it *reduces* our initial costs.
s.t. Total_Costs_Calc: total_costs = sum {r in Raws} Value[r] * usage_market[r] + sum {o in Orders: Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

# 'total_revenue' = (Revenue from products sold to market) + (Net revenue from orders paid *after* production)
# Note the '-' sign. If Order_Cash_Flow is *negative* (a payment to us),
# '- (-payment)' becomes *positive* revenue.
s.t. Total_Revenue_Calc: total_revenue = sum {p in Products} Value[p] * usage_market[p] - sum {o in Orders: !Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];
s.t. Profit_Calc: profit = total_revenue - total_costs;

# === 5. OBJECTIVE FUNCTION ===
# The goal is to maximize the final profit.
maximize Profit: profit;

# === 6. SOLVE AND DISPLAY ===
solve;

# --- Report Section ---
# Print a summary of the optimal solution.
printf "Total Costs: %g\n", total_costs;
printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;

# Print the key decisions.
for {o in Orders}
{
	printf "Acquiring order %s: %dx\n", o, ordcnt[o];
}
for {c in Recipes}
{
	printf "Volume of recipe %s: %g\n", c, volume[c];
}

# Print the material flow reports.
printf "Raw materials (orders + market -> production + leftover):\n";
for {r in Raws}
{
	printf "Consumption of raw %s: %g + %g -> %g + %g (total: %g)\n", r, usage_orders[r], usage_market[r], usage_production[r], usage_leftover[r], usage_total[r];
}
printf "Products (production -> orders + market):\n";
for {p in Products}
{
	printf "Production of product %s: %g -> %g + %g (total: %g)\n", p, usage_production[p], usage_orders[p], usage_market[p], usage_total[p];
}

# Marks the end of the model file.
end;