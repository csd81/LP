var x;
var y;
var z;
var w;

s.t. Eq1: 2 * x + (-2) * y +    0 * z +    0 * w = -5;
s.t. Eq2: 0 * x +    1 * y + (-1) * z + (-1) * w = -5;
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w = 1;
s.t. Eq4: 2 * x + (-7) * y +    0 * z +    2 * w = 0;

solve;

printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;

# Solution: 0.5, 3, -2, 10

end;
