# === 1. VARIABLE DECLARATIONS ===
# These are our "decision variables". The solver's job is to
# find the best possible values for these.
# 'P1', 'P2', 'P3' represent the *quantity* to produce
# of Product 1, Product 2, and Product 3.
# '>=0' means we cannot produce a negative amount.
var P1, >=0;
var P2, >=0;
var P3, >=0;

# === 2. CONSTRAINT DEFINITIONS ===
# "s.t." stands for "subject to". These are the rules
# (limitations) that our solution must follow.
# Each constraint represents one limited raw material.
s.t.
# The total amount of Raw Material A consumed by production
# (200 for each P1, 50 for each P2) must be
# less than or equal to our total storage of 23000 units.
Raw_material_A:  200 * P1 +   50 * P2 +    0 * P3 <= 23000;
s.t. Raw_material_B:   25 * P1 +  180 * P2 +   50 * P3 <= 31000;
s.t. Raw_material_C: 3200 * P1 + 1000 * P2 + 4500 * P3 <= 450000;
s.t.
# Raw_material_D might represent a total production limit,
# like "total units must not exceed 200".
Raw_material_D:    1 * P1 +    1 * P2 +    1 * P3 <= 200;

# === 3. OBJECTIVE FUNCTION ===
# This is the "goal" of the model. We want to find the
# values of P1, P2, and P3 that satisfy all the constraints
# AND make this expression as large as possible.
#
# (Note: The name 'Raw_material' is confusing and likely a typo.
# It should be named something like 'Total_Revenue'.)
#
# We get 252 revenue for each P1, 89 for each P2, and 139 for each P3.
maximize Raw_material: 252 * P1 +   89 * P2 +  139 * P3;

# === 4. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for P1, P2, and P3.
solve;

# These 'printf' statements print the final results after
# the solution is found. '%g' is a placeholder for a number.
printf "Total Revenue: %g\n", ( 252 * P1 +   89 * P2 +  139 * P3);
printf "Production of P1: %g\n", P1;
printf "Production of P2: %g\n", P2;
printf "Production of P3: %g\n", P3;

# The following lines print a report of material usage.
printf "Usage of A: %g, remaining: %g\n", ( 200 * P1 +   50 * P2 +    0 * P3), 23000  - ( 200 * P1 +   50 * P2 +    0 * P3);

# !!! --- POTENTIAL ERROR --- !!!
# Note that the constraint 'Raw_material_B' uses '50 * P3'.
# This 'printf' statement uses '75 * P3'.
# This is a common bug in hard-coded models!
# The report will show a different usage number than
# the constraint was based on.
printf "Usage of B: %g, remaining: %g\n", (  25 * P1 +  180 * P2 +   75 * P3), 31000  - (  25 * P1 +  180 * P2 +   75 * P3);
printf "Usage of C: %g, remaining: %g\n", (3200 * P1 + 1000 * P2 + 4500 * P3), 450000 - (3200 * P1 + 1000 * P2 + 4500 * P3);
printf "Usage of D: %g, remaining: %g\n", (   1 * P1 +    1 * P2 +    1 * P3), 200    - (   1 * P1 +    1 * P2 +    1 * P3);

# This comment shows the expected answer for verification.
# Solution: 33388.98, with productions of 91.34, 94.65, and 14.02 units of P1, P2 and P3.

# Marks the end of the model file.
end;