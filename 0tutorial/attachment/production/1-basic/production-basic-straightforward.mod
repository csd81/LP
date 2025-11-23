var P1, >=0;
var P2, >=0;
var P3, >=0;

s.t. Raw_material_A:  200 * P1 +   50 * P2 +    0 * P3 <= 23000;
s.t. Raw_material_B:   25 * P1 +  180 * P2 +   50 * P3 <= 31000;
s.t. Raw_material_C: 3200 * P1 + 1000 * P2 + 4500 * P3 <= 450000;
s.t. Raw_material_D:    1 * P1 +    1 * P2 +    1 * P3 <= 200;

maximize Raw_material: 252 * P1 +   89 * P2 +  139 * P3;

solve;

printf "Total Revenue: %g\n", ( 252 * P1 +   89 * P2 +  139 * P3);

printf "Production of P1: %g\n", P1;
printf "Production of P2: %g\n", P2;
printf "Production of P3: %g\n", P3;

printf "Usage of A: %g, remaining: %g\n", ( 200 * P1 +   50 * P2 +    0 * P3), 23000  - ( 200 * P1 +   50 * P2 +    0 * P3);
printf "Usage of B: %g, remaining: %g\n", (  25 * P1 +  180 * P2 +   75 * P3), 31000  - (  25 * P1 +  180 * P2 +   75 * P3);
printf "Usage of C: %g, remaining: %g\n", (3200 * P1 + 1000 * P2 + 4500 * P3), 450000 - (3200 * P1 + 1000 * P2 + 4500 * P3);
printf "Usage of D: %g, remaining: %g\n", (   1 * P1 +    1 * P2 +    1 * P3), 200    - (   1 * P1 +    1 * P2 +    1 * P3);

# Solution: 33388.98, with productions of 91.34, 94.65, and 14.02 units of P1, P2 and P3.

end;
