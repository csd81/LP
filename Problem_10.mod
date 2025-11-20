# Problem 10.

# Solve the production problem, provided that for each raw material and each product, 
# a minimal and maximal total usage is also given that must be respected by the solution. 
# The usage of a raw material is the total amount consumed,
# and the usage of a product is the total amount produced. 

set PRODUCTS;
set MATERIALS;

param Available {MATERIALS} >=0;
param Revenue {PRODUCTS} >=0;
param NeededPerUnit {MATERIALS, PRODUCTS} >=0;

param MinProdUsage {PRODUCTS} >=0, default 0; 
param MaxProdUsage {PRODUCTS} >=0, default 9999999; 

param MinMatUsage {MATERIALS} >=0, default 0; 
param MaxMatUsage {MATERIALS} >=0, default 9999999; 

var produced{PRODUCTS}  >=0;

s.t. Material_Availability {m in MATERIALS}: 
    sum{p in PRODUCTS} produced[p] * NeededPerUnit[m,p] <= Available[m];

s.t. MaterialUsage_min {m in MATERIALS}: 
    sum {p in PRODUCTS} produced[p] * NeededPerUnit[m,p]  >= MinMatUsage[m];

s.t. MaterialUsage_max {m in MATERIALS}: 
    sum {p in PRODUCTS} produced[p] * NeededPerUnit[m,p]  <= MaxMatUsage[m];

    
s.t. ProductUsage_Min {p in PRODUCTS}: 
    produced[p] >= MinProdUsage[p];
    
s.t. ProductUsage_Max {p in PRODUCTS}: 
    produced[p] <= MaxProdUsage[p];    

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


param MinProdUsage: P1 0 P2 10 P3 0 ; 
param MaxProdUsage: P1 9999999 P2 9999999 P3 9999999 ;

param MinMatUsage: A 0 B 0 C 0 D 0 ;
param MaxMatUsage: A 9999999 B 9999999 C 9999999 D 9999999 ;

end;