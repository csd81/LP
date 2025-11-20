# Problem 16.
#    Solve the diet problem with the following data. There are five food types, named F1 to F5, and there are four nutrients under focus, named N1 to N4. The contents of unit amount of each food, the unit cost of each food, and the minimum requirement of each nutrient are shown in the following table.


    


set FOODS;
set NUTRIENTS;

param Nutrient_Requirement{NUTRIENTS} >= 0;
# Changed indices to match data table structure (Rows=Nutrients, Cols=Foods)
param Food_Nutrient_Ratio{NUTRIENTS, FOODS} >= 0; 
param Food_Cost{FOODS} >= 0;

var Diet{FOODS} >= 0;

# For each nutrient, the sum of nutrients from all foods must meet the requirement
s.t. Nutrient_Constraint {n in NUTRIENTS}:
    sum {f in FOODS} Diet[f] * Food_Nutrient_Ratio[n,f] >= Nutrient_Requirement[n];

minimize Total_Cost:
    sum {f in FOODS} Diet[f] * Food_Cost[f];

solve;

printf "\n";
for {f in FOODS} {
    printf "Amount of %s: %.2f\n", f, Diet[f];
}
printf "\nTotal Cost: %.2f\n", Total_Cost;

data;

set FOODS:=  F1  F2  F3  F4  F5;
set NUTRIENTS := N1 N2 N3 N4;

param Nutrient_Requirement:=
N1   2000 
N2  180 
N3  30 
N4  0.04 ;

 
param Food_Nutrient_Ratio:
        F1  F2  F3  F4  F5:=
    N1  30  20  25  13  19  
    N2  5.2  0.7  2  3.6  0.1  
    N3  0.2  0  0.1  0  0  
    N4  0.0001  0.0001  0.0001  0.0002  0.0009 
;
param Food_Cost:=
    F1 450
    F2 220
    F3 675
    F4 120
    F5 500;