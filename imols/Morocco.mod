param totalDistance;
param fuelConsumption;
param tankCapacity;
param initialTank, default tankCapacity;
param safetyMeasure;

set Stations;
param distance{Stations};
param fuelPrice{Stations};

var fill{Stations} >= 0;

s.t. Has_to_meet_safety_measure {s in Stations}:
  (initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]) * (100 / fuelConsumption) >= distance[s]+safetyMeasure;

s.t. Can_not_overfill{s in Stations}:
  initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2] - distance[s] * (fuelConsumption / 100) + fill[s] <= tankCapacity;

s.t. Need_to_reach_final_destination:
  (initialTank + sum {s in Stations} fill[s]) * (100 / fuelConsumption) >= totalDistance;

minimize TotalCost:
  sum{s in Stations} fill[s]*fuelPrice[s];



solve;

printf "Total cost: %g\n\n",TotalCost;

for{s in Stations}
{
  printf "%14s  (%5g km, %3g Dh/l): %5.2g + %5.2g ---> %5.2g l\n",s,distance[s],fuelPrice[s],
  initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2] - distance[s] * (fuelConsumption / 100),
  fill[s],
  initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2] - distance[s] * (fuelConsumption / 100) + fill[s]
  ; 
}

data;

param totalDistance := 11000;

param fuelConsumption := 7.5;

param tankCapacity := 70;

param safetyMeasure := 50;

set Stations:= Algeria1 Algeria2 Algeria3 Algeria4 Algeria5 Algeria6 Niger1 Niger2 Nigeria1 Nigeria2 Cameroon Gabon Congo1 Congo2 Angola1 Angola2 Angola3 Namibia1 Namibia2 Namibia3 SouthAfrica1 SouthAfrica2;

param:        distance  fuelPrice:=
Algeria1      320       100
Algeria2      840       90
Algeria3      1350      70
Algeria4      2000      80
Algeria5      2580      100
Algeria6      3170      90
Niger1        3560      120
Niger2        4080      130
Nigeria1      4660      140
Nigeria2      5180      120
Cameroon      5500      150
Gabon         5950      160
Congo1        6479      110
Congo2        6990      130
Angola1       7440      120
Angola2       7960      130
Angola3       8410      120
Namibia1      8730      140
Namibia2      9250      150
Namibia3      9770      130
SouthAfrica1  10350     140
SouthAfrica2  10670     120
;

end;    
