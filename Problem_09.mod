/* Problem 9.
 We have a manufacturing plant, which is capable of producing three different products, named P1, P2 and P3. 
 There are four raw materials that are required for production, named A, B, C and D. 
 We have exact data for the following.
 
    * Amount of each raw material required for producing 1 unit of each product.
    * Available amount of each raw material that can be used for production.
    * Revenue for 1 unit of each product.
    These can be viewed in a single table, as shown below.

    | | P1 | P2 | P3 | Available |
    | :--- | :--- | :--- | :--- | :--- |
    | A (electricity) | 200 kWh | 50 kWh | 0 kWh | 23000 kWh |
    | B (working time) | 25 h | 180 h | 75 h | 31000 h |
    | C (materials) | 3200 kg | 1000 kg | 4500 kg | 450000 kg |
    | D (production quota) | 1 | 1 | 1 | 200 |


    Determine the optimal amount of P1, P2 and P3 to be produced, 
    so that raw material availability is respected, and the total revenue after products is maximized. 
*/

set PRODUCTS;
set MATERIALS;

param Available {MATERIALS} >=0;
param Revenue {PRODUCTS} >=0;
param NeededPerUnit {MATERIALS, PRODUCTS} >=0;

var produced{PRODUCTS}  >=0;

s.t. Material_Availability {m in MATERIALS}: 
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] <= Available[m];


maximize Total_Revenue:
    sum{p in PRODUCTS} produced[p] * Revenue[p];

solve;

printf "\n\nTotal Revenue: %.2f\n\n", Total_Revenue;

for {p in PRODUCTS}
    printf "product %s produced: %.2f\n", p, produced[p];

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
end;