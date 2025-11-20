var x;
var y;
var z;
var w;
var v;

s.t. Eq1: 4 * x + (-2) * y +    3 * z +    0 * w +   0 * v = -5;
s.t. Eq2: 0 * x +    0 * y + (-1) * z + (-1) * w +   0 * v = -5;
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w +   0 * v = 1.5;
s.t. Eq4: 4 * x + (-7) * y +    0 * z +    2 * w +   5 * v = 0;
s.t. Eq5: 1 * x +    0 * y +    2 * z +    0 * w +   3 * v = -0.5;

solve;

printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;

# Old Solution: 0.5, 3, -2, 10
# Modifications:
# - change coefficient of x where it is 2 to 4.
# - add z in Eq1 with a coefficient of 3
# - delete y from Eq2
# - change the RHS of Eq3 to 1.5
# - add a fifth variable v with no bounds
# - add the equation x + 3v + 0.5 = -2z as 'Eq5'
# - introduce v in Eq4 with a coefficient of 5
# - print out the newly introduced variable after the solve statement

# Solution: 2, 3.5, -2, 7, 0.5

end;
