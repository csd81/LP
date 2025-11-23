
**Advanced Modeling Techniques: “Redundant” Variables**
Using “redundant” variables to make models more readable and intuitive

**Prerequisites**
Linear Programming: first steps
Advanced GMPL techniques: data/logic decoupling

---

### Motivational example

I spent a couple of months working in Oujda, Morocco. During that time, I decided to visit my friend Jacques in Cape Town. Since I hadn’t traveled much in Africa before, I chose to go by car so I could see more of the continent. A friend, Alae-Eddine, kindly lent me his car, so all I had to pay for was the fuel. Naturally, I wanted to minimize the total fuel cost, so I planned ahead where and how much to refuel.

The trip was 11,000 km long, and there were 22 gas stations along the way, each selling fuel at different prices. The table below lists the stations, their distance from Oujda, and the price per liter.

**Petrol station | Distance from Oujda (km) | Price of petrol (Dh/l)**
Algeria1 — 320 — 100
Algeria2 — 840 — 90
Algeria3 — 1350 — 70
Algeria4 — 2000 — 80
Algeria5 — 2580 — 100
Algeria6 — 3170 — 90
Niger1 — 3560 — 120
Niger2 — 4080 — 130
Nigeria1 — 4660 — 140
Nigeria2 — 5180 — 120
Cameroon — 5500 — 150
Gabon — 5950 — 160
Congo1 — 6749 — 110
Congo2 — 6990 — 130
Angola1 — 7440 — 120
Angola2 — 7960 — 130
Angola3 — 8410 — 120
Namibia1 — 8730 — 140
Namibia2 — 9250 — 150
Namibia3 — 9770 — 130
SouthAfrica1 — 10350 — 140
SouthAfrica2 — 10670 — 120

The fuel tank could hold at most 70 liters, and the car consumed an average of 7.5 liters per 100 km.

Although I wanted to reduce costs, I also wanted to stay safe, meaning I didn’t want to arrive at a station with an empty tank. My safety rule was always having enough fuel for at least 50 additional kilometers. Also, when leaving Oujda, the tank was full.

**The question is simple:**
Where and how much fuel should I buy to reach Cape Town with minimal total cost?

---

## The first mathematical model

### Sets and parameters

The problem has one main set: the gas stations.

```
set Stations;
```

Next, two parameters defined for each station:

```
param petrolPrice{Stations};
param distance{Stations};
```

And several global parameters describing the trip:

```
param initialTank;
param tankCapacity;
param totalDistance;
param fuelConsumption;
```

---

### Variables

We need just one true decision variable: how much fuel to buy at each station.

```
var fill{Stations} >= 0;
```

---

### Constraints

#### Fuel + safety requirement

We must ensure the fuel accumulated so far (initial fuel + all previous refills) is enough to reach each station plus the safety buffer:

```
s.t. Has_to_meet_safety_measure {s in Stations}:
  (initialTank
   + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2])
   * (100 / fuelConsumption)
   >= distance[s] + safetyMeasure;
```

Here,
`initialTank + sum(...)` = fuel accumulated so far,
multiplied by `100 / fuelConsumption` converts fuel to travelable distance.

The `distance[s2] < distance[s]` filter ensures only earlier stations are included.

#### Final destination requirement

We must also have enough total fuel to reach Cape Town:

```
s.t. Need_to_reach_final_destination:
  (initialTank + sum {s in Stations} fill[s]) * (100 / fuelConsumption) >= totalDistance;
```

#### Cannot exceed tank capacity

```
s.t. Can_not_overfill{s in Stations}:
  initialTank
  + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
  - distance[s] * (fuelConsumption / 100)
  + fill[s]
  <= tankCapacity;
```

The left-hand side represents the fuel level when leaving station *s*.

---

### Objective function

Simply minimize total fuel cost:

```
minimize TotalCost:
  sum{s in Stations} fill[s] * fuelPrice[s];
```

---

### Fancy output

```
printf "Total cost: %g\n\n",TotalCost;

for{s in Stations}
{
  printf "%14s  (%5g km, %3g Dh/l): %5.2g + %5.2g ---> %5.2g l\n",
    s, distance[s], fuelPrice[s],
    initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
        - distance[s] * (fuelConsumption / 100),
    fill[s],
    initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
        - distance[s] * (fuelConsumption / 100) + fill[s];
}
```

---

## The complete model

*(structure preserved exactly)*

```
param totalDistance; #km
param fuelConsumption; # l / 100 km 
param tankCapacity; # l
param initialTank, default tankCapacity; # l
param safetyMeasure; # km

set Stations;
param distance{Stations}; # km
param fuelPrice{Stations}; # Dh / l

var fill{Stations} >= 0;

s.t. Has_to_meet_safety_measure {s in Stations}:
  (initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2])
      * (100 / fuelConsumption)
      >= distance[s] + safetyMeasure;

s.t. Can_not_overfill{s in Stations}:
  initialTank
    + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
    - distance[s] * (fuelConsumption / 100)
    + fill[s]
    <= tankCapacity;

s.t. Need_to_reach_final_destination:
  (initialTank + sum {s in Stations} fill[s]) * (100 / fuelConsumption) >= totalDistance;

minimize TotalCost:
  sum{s in Stations} fill[s] * fuelPrice[s];

solve;

printf "Total cost: %g\n\n",TotalCost;

for{s in Stations}
{
  printf "%14s  (%5g km, %3g Dh/l): %5.2g + %5.2g ---> %5.2g l\n",
    s, distance[s], fuelPrice[s],
    initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
        - distance[s] * (fuelConsumption / 100),
    fill[s],
    initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
        - distance[s] * (fuelConsumption / 100) + fill[s];
}
```

---

## Data file

*(fully preserved)*

```
param totalDistance := 11000;
param fuelConsumption := 7.5;
param tankCapacity := 70;
param safetyMeasure := 50;

set Stations :=
  Algeria1 Algeria2 Algeria3 Algeria4 Algeria5 Algeria6
  Niger1 Niger2 Nigeria1 Nigeria2 Cameroon Gabon
  Congo1 Congo2 Angola1 Angola2 Angola3
  Namibia1 Namibia2 Namibia3 SouthAfrica1 SouthAfrica2;

param: distance fuelPrice :=
Algeria1      320       100
Algeria2      840        90
Algeria3      1350       70
Algeria4      2000       80
Algeria5      2580      100
Algeria6      3170       90
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
```

---

## The solution

*(exact output preserved, wording adjusted)*

```
Total cost: 84572.7

      Algeria1  (  320 km, 100 Dh/l):    46 +     0 --->    46 l
      Algeria2  (  840 km,  90 Dh/l):     7 +    35 --->    42 l
      Algeria3  ( 1350 km,  70 Dh/l):   3.8 +    66 --->    70 l
      Algeria4  ( 2000 km,  80 Dh/l):    21 +    49 --->    70 l
      Algeria5  ( 2580 km, 100 Dh/l):    26 +    21 --->    48 l
      Algeria6  ( 3170 km,  90 Dh/l):   3.7 +    66 --->    70 l
        Niger1  ( 3560 km, 120 Dh/l):    41 +    29 --->    70 l
        Niger2  ( 4080 km, 130 Dh/l):    31 +    39 --->    70 l
      Nigeria1  ( 4660 km, 140 Dh/l):    26 +    16 --->    43 l
      Nigeria2  ( 5180 km, 120 Dh/l):   3.8 +    66 --->    70 l
      Cameroon  ( 5500 km, 150 Dh/l):    46 +    24 --->    70 l
         Gabon  ( 5950 km, 160 Dh/l):    36 +   7.2 --->    43 l
        Congo1  ( 6479 km, 110 Dh/l):   3.8 +    66 --->    70 l
        Congo2  ( 6990 km, 130 Dh/l):    32 +   5.8 --->    38 l
       Angola1  ( 7440 km, 120 Dh/l):   3.8 +    66 --->    70 l
       Angola2  ( 7960 km, 130 Dh/l):    31 +   6.5 --->    38 l
       Angola3  ( 8410 km, 120 Dh/l):   3.8 +    66 --->    70 l
      Namibia1  ( 8730 km, 140 Dh/l):    46 +    24 --->    70 l
      Namibia2  ( 9250 km, 150 Dh/l):    31 +    12 --->    43 l
      Namibia3  ( 9770 km, 130 Dh/l):   3.7 +    66 --->    70 l
  SouthAfrica1  (10350 km, 140 Dh/l):    26 +   1.2 --->    28 l
  SouthAfrica2  (10670 km, 120 Dh/l):   3.7 +    21 --->    25 l
```

---

## A different modeling approach

A software engineer reading the above model might find the repeated expression

```
initialTank + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
```

to be inelegant. A programmer would extract this into a function.

In modeling, we can mimic this idea: introduce extra variables representing intermediate values derived from the true decision variables. They are not actual decisions — they’re computed.

```
var fuelAtArrival{Stations};
```

These represent the amount of fuel in the tank upon arriving at each station. They are defined by equalities:

```
s.t. set_fuelAtArrival{s in Stations}:
  fuelAtArrival[s]
    = initialTank
      + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
      - distance[s] / 100 * fuelConsumption;
```

These are “redundant variables.”

Now constraints simplify:

```
s.t. Has_to_meet_safety_measure {s in Stations}:
  fuelAtArrival[s] * (100 / fuelConsumption) >= safetyMeasure;

s.t. Can_not_overfill{s in Stations}:
  fuelAtArrival[s] + fill[s] <= tankCapacity;
```

Pretty printing also becomes cleaner:

```
printf "%14s ... %g + %g -> %g", fuelAtArrival[s], fill[s], ...
```

We can even replace the safety constraint with a lower bound:

```
var fuelAtArrival{Stations} >= safetyMeasure / 100 * fuelConsumption;
```

---

## Final version

*(fully preserved)*

```
param totalDistance; #km
param fuelConsumption; # l / 100 km 
param tankCapacity; # l
param initialTank, default tankCapacity; # l
param safetyMeasure; # km

set Stations;
param distance{Stations}; # km
param fuelPrice{Stations}; # Dh / l

var fill{Stations} >= 0;
var fuelAtArrival{Stations} >= safetyMeasure / 100 * fuelConsumption;

s.t. set_fuelAtArrival{s in Stations}:
      fuelAtArrival[s]
        = initialTank
          + sum {s2 in Stations: distance[s2] < distance[s]} fill[s2]
          - distance[s] / 100 * fuelConsumption;

s.t. Can_not_overfill{s in Stations}:
  fuelAtArrival[s] + fill[s] <= tankCapacity;

s.t. Need_to_reach_final_destination:
  (initialTank + sum {s in Stations} fill[s]) * (100 / fuelConsumption) >= totalDistance;

minimize TotalCost:
  sum{s in Stations} fill[s] * fuelPrice[s];

solve;

printf "Total cost: %g\n\n",TotalCost;

for{s in Stations}
{
  printf "%14s  (%5g km, %3g Dh/l): %6.3f + %6.3f ---> %6.3f l\n",
    s, distance[s], fuelPrice[s],
    fuelAtArrival[s], fill[s], fuelAtArrival[s] + fill[s];
}
```

Same data file, same output.

---

## Readability vs. performance?

Someone may argue this version is worse — more variables, slightly larger model. Theoretically true, but:

* A few continuous variables rarely make an LP noticeably harder.
* Modern solvers often detect and eliminate redundant relationships.
* Some languages (e.g., AMPL) explicitly support defined variables.
* For models with complex logic, clarity matters more than tiny performance gains.
* If the model grows later, these variables often become extremely useful.

---

## Exercise

You can rewrite the model so that:

**fuelAtArrival[s] = fuelAtDeparture at previous station – fuel consumed since then.**

To do this cleanly, rewrite the data like:

```
param stationCount;
set Stations := 1..stationCount;
param stationName{Stations} symbolic;
```

Data:

```
param stationCount := 22;

param:
      stationName   distance  fuelPrice :=
  1   Algeria1      320       100
  2   Algeria2      840        90
  3   Algeria3      1350       70
  4   Algeria4      2000       80
  ...
```

---

## Final notes

The goal of this lesson was to introduce a modeling technique that often makes models much clearer and easier to maintain.

