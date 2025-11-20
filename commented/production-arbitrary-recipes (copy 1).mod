# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.

# 'Raws': The set of all raw materials we can *buy*
# (e.g., 'wood', 'ore', 'water').
set Raws;

# 'Products': The set of all finished products we can *sell*
# (e.g., 'chair', 'iron', 'soda').
set Products;

# 'Recipes': The set of all production processes we can run
# (e.g., 'make_chair_recipe', 'make_soda_recipe').
set Recipes;

# This 'check' is a safety guard. It ensures that no item
# is listed as *both* a raw material and a product.
# 'inter' means "intersection".
check card(Raws inter Products) == 0;

# 'Materials': A single, large set containing *everything*
# (all raw materials AND all products).
set Materials := Products union Raws;

# === 2. PARAMETER DECLARATIONS ===
# These are the input data (numbers) for the problem.

# 'Min_Usage': The *minimum* amount of a material we *must*
# use (if raw) or produce (if product).
# 'default 0' means it's zero unless specified otherwise.
param Min_Usage {m in Materials}, >=0, default 0;

# 'Max_Usage': The *maximum* amount of a material we *can*
# use or produce. This can represent market demand (for products)
# or supplier limits (for raws). 'default 1e100' means
# it's "unlimited" unless specified otherwise.
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;

# 'Value': This is a crucial parameter.
#   - If 'm' is a Raw: 'Value[m]' is the *cost* to buy one unit.
#   - If 'm' is a Product: 'Value[m]' is the *revenue* from selling one unit.
param Value {m in Materials}, >=0, default 0;

# 'Recipe_Ratio': This is the core of the model. It's a matrix
# that defines what each recipe does.
#   - If 'm' is a Raw: 'Recipe_Ratio[c,m]' is the amount of 'm'
#     *consumed* to run recipe 'c' *once*.
#   - If 'm' is a Product: 'Recipe_Ratio[c,m]' is the amount of 'm'
#     *produced* when running recipe 'c' *once*.
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;

# 'Initial_Funds': A limit on how much we can spend on raw materials.
param Initial_Funds, >=0, default 1e100;

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver needs to find.

# 'volume': How many times do we run each recipe?
# This is the main decision. (e.g., run 'make_chair' 10.5 times).
var volume {c in Recipes}, >=0;

# 'usage': A helper variable to store the *total* amount
# of each material that is used (if raw) or produced (if product).
# The bounds '>=Min_Usage[m], <=Max_Usage[m]' are applied here.
var usage {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];

# 'total_costs': A helper variable for total cost.
# It is constrained to be no more than our available funds.
var total_costs, <=Initial_Funds;

# 'total_revenue': A helper variable for total revenue.
var total_revenue;

# 'profit': A helper variable for the final profit.
var profit;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules of the model.

# 'Material_Balance': This is the most important constraint.
# It links 'usage' and 'volume'.
# It says: The total 'usage' of a material 'm' must equal
# the sum of (what each recipe 'c' uses/produces of 'm') *
# (how many times we run that recipe 'c').
s.t. Material_Balance {m in Materials}: usage[m] = sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

# 'Total_Costs_Calc': This calculates the 'total_costs' variable.
# It sums up (cost of each raw material 'r') *
# (total 'usage' of that raw material 'r').
s.t. Total_Costs_Calc: total_costs = sum {r in Raws} Value[r] * usage[r];

# 'Total_Revenue_Calc': This calculates the 'total_revenue' variable.
# It sums up (revenue of each product 'p') *
# (total 'usage' (production) of that product 'p').
s.t.
Total_Revenue_Calc: total_revenue = sum {p in Products} Value[p] * usage[p];

# 'Profit_Calc': This defines profit as revenue minus costs.
s.t. Profit_Calc: profit = total_revenue - total_costs;

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Profit: profit;'
# The solver's goal is to find the 'volume' for each recipe
# that satisfies all the constraints AND makes the 'profit'
# variable as large as possible.
maximize Profit: profit;

# === 6. SOLVE AND DISPLAY ===

# Tell the solver to run and find the optimal solution.
solve;

# Print a summary of the results.
printf "Total Costs: %g\n", total_costs;
printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;

# Print the optimal volume for each recipe.
for {c in Recipes}
{
	printf "Volume of recipe %s: %g\n", c, volume[c];
}
# Print the total consumption of each raw material.
for {r in Raws}
{
	printf "Consumption of raw %s: %g\n", r, usage[r];
}
# Print the total production of each product.
for {p in Products}
{
	printf "Production of product %s: %g\n", p, usage[p];
}

# Marks the end of the model file.
end;