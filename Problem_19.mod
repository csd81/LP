/*Problem 19.
    Solve Problem 17, the production problem with arbitrary recipes, where production goes as usual, but there are orders we may acquire. Orders are optional but can only be acquired (and subsequently fulfilled) completely, not partially. Each order consists of the following.
    * A fixed amounts of raw materials and products. If a raw material is in an order, it means that by acquiring the order, we obtain that raw material in the given amount before production. If a product is in an order, it means that we deliver it after produced, in the given amount.
    * Price of the order. It can either be a gain or a payment. Payment happens either before or after the production takes place.
    * Maximum count. An order can be acquired multiple times, with an upper limit.

    Raw materials must either be purchased from the market, as usual, or purchased via acquiring an order. Leftover raw materials after production took place are lost without compensation. Products must either be sold on the market, or delivered via an order. The only way of obtaining products is by producing it. Fulfilling orders is mandatory once acquired. Minimum and maximum usage limitations still apply as before. Limitations correspond to the total amounts that are in possession at the same time. The total costs include incomes and expenses of those orders for which the payment is due before production, plus the total costs of raw materials that are purchased from the market in the ordinary way. The total costs are limited: there is a fixed amount of initial funds which we cannot exceed. The total revenue includes incomes and expenses of those orders for which the payment is due after production, plus the total revenue from selling products at the market in the ordinary way. Optimize for profit, which is the difference of the total revenue and total costs. 

*/
# === 1. SET DECLARATIONS ===
# These sets define the 'things' in our model.

# 'Raws': The set of all raw materials we can *buy*
# (e.g., 'wood', 'ore', 'water').
set Raws;
# 'Products': The set of all finished products we can *sell*
# (e.g., 'chair', 'iron', 'soda').
set Products;
# 'Recipes': Production processes (e.g., 'make_chair').
set Recipes;
# 'Orders': A set of special contracts or deals we can
# choose to accept. 'default {}' allows the model to
# run even if there are no orders.
set Orders, default {};


check card(Raws inter Products)==0;

set Materials := Products union Raws;

# === 2. PARAMETER DECLARATIONS ===
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
param Initial_Funds, >=0, default  1e100;

# Order parameters
param Order_Material_Flow {o in Orders, m in Materials}, default 0;
param Order_Cash_Flow {o in Orders}, default 0;
param Order_Count {o in Orders}, >=0, integer, default 1;
param Order_Pay_Before {o in Orders}, binary, default 1;

# === 3. VARIABLE DECLARATIONS ===
var volume {c in Recipes}, >= 0;
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;

var ordcnt {o in Orders}, integer, >=0, <=Order_Count[o];

var usage_orders {m in Materials}, >=0;
var usage_market {m in Materials}, >=0;

# 'usage_production': Total materials *consumed* (Raws) or
# *produced* (Products) by our recipes.
var usage_production {m in Materials}, >= 0;
var usage_leftover {r in Raws}, >= 0;
var usage_total {m in Materials}, >= Min_Usage[m], <= Max_Usage[m];

# === 4. CONSTRAINTS ===

# Calculate production amounts based on recipe volumes
s.t. Material_Balance_Production {m in Materials}: 
    usage_production[m] = sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

# Calculate order material flows
s.t. Material_Balance_Orders {m in Materials}: 
    usage_orders[m] = sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];

# Raw materials: What we get (orders + market) = What we use (production + leftover)
s.t. Material_Balance_Raws_Inflow {r in Raws}: 
    usage_orders[r] + usage_market[r] = usage_production[r] + usage_leftover[r];

# Raw materials total usage tracked
s.t. Material_Balance_Raws_Total {r in Raws}: 
    usage_total[r] = usage_production[r] + usage_leftover[r];

# Products: What we make (production) = What we deliver (orders + market)
s.t. Material_Balance_Products_Outflow {p in Products}: 
    usage_production[p] = usage_orders[p] + usage_market[p];

# Products total usage tracked
s.t. Material_Balance_Products_Total {p in Products}: 
    usage_total[p] = usage_orders[p] + usage_market[p];

# Total costs: market purchases + pre-production order payments
s.t. Total_Costs_Calc: 
    total_costs = sum {r in Raws} Value[r] * usage_market[r] 
                + sum {o in Orders: Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

# Total revenue: market sales + post-production order payments
s.t. Total_Revenue_Calc: 
    total_revenue = sum {p in Products} Value[p] * usage_market[p] 
                  + sum {o in Orders: !Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

# Profit calculation
s.t. Profit_Calc: 
    profit = total_revenue - total_costs;

maximize Profit: profit;

solve;