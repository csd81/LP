/* Problem 18.
    Production problem with joint production options.
    
    Products can be produced individually (P1, P2, P3) or jointly (P1+P2, P2+P3).
    Joint production has different resource consumption rates.
    
    Constraints:
    - Use at least 20000 h of working time (raw material B)
    - Fill the production quota: produce at least 200 units (raw material D), max 200
    - Produce at most 10 units of P3
    
    Optimize for profit (revenue - material costs).
*/

set MATERIALS;
set PRODUCTS;

param Available {MATERIALS} >= 0;
param Revenue {PRODUCTS} >= 0;
param MaterialCost {MATERIALS} >= 0;

# Individual production requirements
param NeededPerUnit {MATERIALS, PRODUCTS} >= 0;

# Joint production requirements
param Joint_P1P2_Needed {MATERIALS} >= 0;
param Joint_P2P3_Needed {MATERIALS} >= 0;

param MinMatUsage {MATERIALS} >= 0, default 0;
param MaxMatUsage {MATERIALS} >= 0, default 999999;

param MinProdUsage {PRODUCTS} >= 0, default 0;
param MaxProdUsage {PRODUCTS} >= 0, default 999999;

# Variables for individual production
var produced {PRODUCTS} >= 0;

# Variables for joint production
var joint_P1P2 >= 0;  # Units of P1+P2 produced jointly
var joint_P2P3 >= 0;  # Units of P2+P3 produced jointly

# Total production of each product (individual + joint)
var total_P1 >= 0;
var total_P2 >= 0;
var total_P3 >= 0;

# Define total production
s.t. Def_Total_P1:
    total_P1 = produced['P1'] + joint_P1P2;

s.t. Def_Total_P2:
    total_P2 = produced['P2'] + joint_P1P2 + joint_P2P3;

s.t. Def_Total_P3:
    total_P3 = produced['P3'] + joint_P2P3;

# Material availability constraints
s.t. Material_Availability {m in MATERIALS}:
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] 
    + joint_P1P2 * Joint_P1P2_Needed[m]
    + joint_P2P3 * Joint_P2P3_Needed[m]
    <= Available[m];

# Material usage constraints
s.t. MaterialUsage_min {m in MATERIALS}:
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p]
    + joint_P1P2 * Joint_P1P2_Needed[m]
    + joint_P2P3 * Joint_P2P3_Needed[m]
    >= MinMatUsage[m];

s.t. MaterialUsage_max {m in MATERIALS}:
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p]
    + joint_P1P2 * Joint_P1P2_Needed[m]
    + joint_P2P3 * Joint_P2P3_Needed[m]
    <= MaxMatUsage[m];

# Product usage constraints (on total production)
s.t. ProductUsage_Min_P1:
    total_P1 >= MinProdUsage['P1'];

s.t. ProductUsage_Min_P2:
    total_P2 >= MinProdUsage['P2'];

s.t. ProductUsage_Min_P3:
    total_P3 >= MinProdUsage['P3'];

s.t. ProductUsage_Max_P1:
    total_P1 <= MaxProdUsage['P1'];

s.t. ProductUsage_Max_P2:
    total_P2 <= MaxProdUsage['P2'];

s.t. ProductUsage_Max_P3:
    total_P3 <= MaxProdUsage['P3'];

# Maximize profit (revenue - material costs)
maximize Total_Profit:
    # Revenue from all products
    total_P1 * Revenue['P1'] + total_P2 * Revenue['P2'] + total_P3 * Revenue['P3']
    # Minus material costs
    - sum{m in MATERIALS} (
        sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] * MaterialCost[m]
        + joint_P1P2 * Joint_P1P2_Needed[m] * MaterialCost[m]
        + joint_P2P3 * Joint_P2P3_Needed[m] * MaterialCost[m]
    );

solve;

printf "\n\n=== RESULTS ===\n";
printf "Total Profit: $%.2f\n\n", Total_Profit;

printf "Individual Production:\n";
for {p in PRODUCTS} {
    printf "  %s: %.2f units\n", p, produced[p];
}

printf "\nJoint Production:\n";
printf "  P1+P2 jointly: %.2f units\n", joint_P1P2;
printf "  P2+P3 jointly: %.2f units\n", joint_P2P3;

printf "\nTotal Production:\n";
printf "  P1 total: %.2f units\n", total_P1;
printf "  P2 total: %.2f units\n", total_P2;
printf "  P3 total: %.2f units\n", total_P3;

printf "\nMaterial Usage:\n";
for {m in MATERIALS} {
    printf "  %s: %.2f (Available: %.2f)\n", m, 
        sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] 
        + joint_P1P2 * Joint_P1P2_Needed[m]
        + joint_P2P3 * Joint_P2P3_Needed[m],
        Available[m];
}
printf "\n";

data;

set PRODUCTS := P1 P2 P3;
set MATERIALS := A B C D;

param Available :=
A 23000
B 31000
C 450000
D 200;

param Revenue :=
P1 252 
P2 89
P3 139;

param MaterialCost :=
A 1.0
B 0.07
C 0.0013
D 8.0;

# Individual production requirements
param NeededPerUnit:
   P1  P2  P3 :=
A  200 50  0
B  25  180 75  
C  3200 1000 4500 
D  1   1   1;

# Joint production P1+P2 (produces 1 unit of each)
param Joint_P1P2_Needed :=
A 240
B 200
C 4400
D 2;

# Joint production P2+P3 (produces 1 unit of each)
param Joint_P2P3_Needed :=
A 51
B 250
C 5400
D 2;

# Constraints
param MinMatUsage := 
A 0 
B 20000 
C 0 
D 200;

param MaxMatUsage := 
A 23000 
B 31000 
C 450000 
D 200;

param MinProdUsage := 
P1 0 
P2 0 
P3 0;

param MaxProdUsage := 
P1 999999 
P2 999999 
P3 10;

end;
