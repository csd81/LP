/*
Problem 15.
    Given a set of food types, and a set of nutrients. 
    Each food consists of a given, fixed ratio of the nutrients. 
    We aim to arrange a diet, which is any combination of the set of food types, in any amounts. 
    
    
    However, for each nutrient, there is a minimum requirement that the diet must satisfy in order to be healthy. 
    Also, each food has its own proportional cost. 
    Find the healthy diet with the lowest total cost of food involved. 
*/


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

set FOODS :=
    milk
    bread
    meat
    fish;

set NUTRIENTS :=
    protein
    carbs
    fats
    vitamins
    minerals;

param Nutrient_Requirement:=
    protein 100
    carbs 100
    fats 100
    vitamins 100
    minerals 100;

param Food_Nutrient_Ratio:
           milk     bread     meat     fish:=
    protein 10       10        10       10
    carbs   10       10        10       10
    fats    10       10        10       10
    vitamins 10      10        10       10
    minerals 10      10        10       10
    ;
 
param Food_Cost:=
    milk 2
    bread 4
    meat 6
    fish 7;
end;