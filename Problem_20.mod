/*Problem 20.
    Solve Problem 18, a production problem example with arbitrary recipes, with the following modifications.
    * Maximum usages for raw materials are reset. Instead of 23000 units of A, 31000 units of B and 450000 units of C and 200 units of D, the new max usage limits are 50000 units of A, 120000 units of B, 1000000 units of C and 1500 units of D.
    * Initial funds are capped at 35000.
    * There are three available orders with the following properties.

    | | Ord1 | Ord2 | Ord3 |
    | :--- | :--- | :--- | :--- |
    | payment before | no | no | yes |
    | expense | 10000 | 10000 | |
    | income | | | 500 |
    | maximum count | 10 | 10 | 30 |
    | obtain A | 20000 | 15000 | 190 |
    | obtain B | 10000 | 10000 | 20 |
    | obtain C | 300000 | 400000 | 3000 |
    | obtain D | 500 | 500 | |
    | deliver P1 | 40 | 45 | 1 |
    | deliver P2 | 80 | 70 | |
    | deliver P3 | | | 6 |
*/

# === 1. SET DECLARATIONS ===
set Raws;
set Products;
set Recipes;
set Orders, default {};

check card(Raws inter Products)==0;

set Materials := Products union Raws;

# === 2. PARAMETER DECLARATIONS ===
param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
param Value {m in Materials}, >=0, default 0;
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
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

data;

set Raws := A B C D;
set Products := P1 P2 P3;
set Recipes := R_P1 R_P2 R_P3 R_P1P2 R_P2P3;
set Orders := Ord1 Ord2 Ord3;

# Market values
param Value :=
A 1.0
B 0.07
C 0.0013
D 8.0
P1 252
P2 89
P3 139;

# Modified max usage limits (from Problem 20 description)
param Max_Usage :=
A 50000
B 120000
C 1000000
D 1500
P1 999999
P2 999999
P3 10;

# Min usage limits (from Problem 18)
param Min_Usage :=
B 20000
D 200;

# Initial funds cap
param Initial_Funds := 35000;

# Recipe ratios (consumption for raws, production for products)
param Recipe_Ratio:
        A    B    C    D    P1   P2   P3 :=
R_P1    200  25   3200 1    1    0    0
R_P2    50   180  1000 1    0    1    0
R_P3    0    75   4500 1    0    0    1
R_P1P2  240  200  4400 2    1    1    0
R_P2P3  51   250  5400 2    0    1    1;

# Order material flows (positive = obtain raw/deliver product)
param Order_Material_Flow:
        A      B      C       D    P1  P2  P3 :=
Ord1    20000  10000  300000  500  40  80  0
Ord2    15000  10000  400000  500  45  70  0
Ord3    190    20     3000    0    1   0   6;

# Order cash flows (positive = income, negative = expense)
param Order_Cash_Flow :=
Ord1 -10000
Ord2 -10000
Ord3 500;

# Order payment timing (1 = before production, 0 = after production)
param Order_Pay_Before :=
Ord1 0
Ord2 0
Ord3 1;

# Maximum order counts
param Order_Count :=
Ord1 10
Ord2 10
Ord3 30;

end;