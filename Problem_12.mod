/*Problem 12.
    The minimum production in a production problem refers to the product from which the least amount is produced. 
    Maximize the minimum production while problem data are the same. 
*/

set PRODUCTS;
set MATERIALS;

param Available {MATERIALS} >=0;
param Revenue {PRODUCTS} >=0;
param NeededPerUnit {MATERIALS, PRODUCTS} >=0;

var produced{PRODUCTS} >=0;
var min_production >=0;  # Auxiliary variable representing the minimum production

# Material availability constraints
s.t. Material_Availability {m in MATERIALS}: 
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] <= Available[m];

# Ensure min_production is less than or equal to all product productions
s.t. Min_Production_Constraint {p in PRODUCTS}:
    min_production <= produced[p];

# Maximize the minimum production
maximize Minimum_Production:
    min_production;

solve;

printf "\n\nMaximized Minimum Production: %.2f\n\n", Minimum_Production;

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

end;
