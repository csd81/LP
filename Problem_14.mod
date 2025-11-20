/* Problem 13.
    Solve the production problem, but now instead of optimizing for revenue, optimize for profit.       
    The profit is the difference between total revenue from products, 
    and total costs of raw materials consumed for production. 
    The cost for each raw material is proportional to the material consumed, and is independent of which product it is used for. 
    A single unit cost for each raw material is given. 
Problem 14.
    Solve the production problem with the objective of maximized profit, where problem data are the following, with unit costs of raw materials added.

    | | P1 | P2 | P3 | Available | Cost |
    | :--- | :--- | :--- | :--- | :--- | :--- |
    | A | 200 kWh | 50 kWh | 0 kWh | 23000 kWh | 1$ |
    | B | 25 h | 180 h | 75 h | 31000 h | 0.07 $ |
    | C | 3200 kg | 1000 kg | 4500 kg | 450000 kg | 0.0013 $ |
    | D | 1 | 1 | 1 | 200 | 8$ |
    | Revenue | 252 $ | 89$ | 139 $ | | |

    Also, there are three limitations, as before.
    * Use at least 20000 h of working time (raw material B).
    * Fill the production quota: produce at least 200 units (raw material D), which is actually also the maximum for that raw material.
    * Produce at most 10 units of P3. 

*/


set PRODUCTS;
set MATERIALS;

param Revenue {PRODUCTS} >=0;
param NeededPerUnit {MATERIALS, PRODUCTS} >=0; 
param Available {MATERIALS} >=0;
param MaterialCost {MATERIALS} >=0;

var produced {PRODUCTS} >=0;

# Material availability constraints
s.t. Material_Availability {m in MATERIALS}:
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] <= Available[m];

# Maximize profit (revenue - material costs)
maximize Profit:
    sum{p in PRODUCTS} produced[p] * Revenue[p] 
    - sum{m in MATERIALS, p in PRODUCTS} produced[p] * MaterialCost[m] * NeededPerUnit[m,p];

solve;

printf "\n\nMaximized Profit: %.2f\n\n", Profit;

for {p in PRODUCTS} {
    printf "product %s produced: %.2f\n", p, produced[p]; 
}

printf "\n\n";

data;
set PRODUCTS:= P1 P2 P3;
set MATERIALS:= A B C D;

param Available:=
A 23000
B 31000
C 450000
D 200
;

param Revenue:=
P1 252 
P2 89
P3 139
;

param NeededPerUnit:
   P1 P2 P3 :=
A  200 50 0
B  25 180  75  
C  3200  1000  4500 
D  1 1 1 
;

# Material unit costs (example values - adjust as needed)
param MaterialCost:=
A 1
B 0.07
C 0.0013
D 8
;

end;

