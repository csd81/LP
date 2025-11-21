set RESOURCES;
set PRODUCTS;

param Total_resource {RESOURCES} >= 0;
param Price {PRODUCTS} >= 0;
param Needed {PRODUCTS,RESOURCES} >= 0;

var produced {PRODUCTS} >= 0, integer;

s.t. MustHaveEnoughResource {r in RESOURCES}:
    sum {p in PRODUCTS} produced[p] * Needed[p,r] <= Total_resource[r];

maximize Profit:
    sum {p in PRODUCTS}  produced[p] * Price[p];

solve;

printf "\n\nProfit: %.3f\n", Profit;

for {p in PRODUCTS} {
    printf (if produced[p] > 0 then "%s: %.3f\n" else ""), p, produced[p];
} 


data;
set RESOURCES:=
Wine 
Soda;

set PRODUCTS:=
Kisf 
Nagy 
Hoss 
Hazm 
Vice 
Krud 
Sohe 
Pusk;

param Needed:
     Wine Soda :=
Kisf 1 1 
Nagy 2 1 
Hoss 1 2 
Hazm 3 2 
Vice 2 3 
Krud 9 1 
Sohe 1 9 
Pusk 6 3 
;

param Price:=
Kisf 110
Nagy 200
Hoss 120
Hazm 260
Vice 200
Krud 800
Sohe 200
Pusk 550
;

param Total_resource:=
Wine 100 
Soda 150
;

end;