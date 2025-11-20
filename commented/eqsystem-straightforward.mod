var x;
var y;
var z;
var w;

s.t. Eq1: 2 * (x - y) = -5;
s.t. Eq2: y - z = w - 5;
s.t. Eq3: 1 = y + z;
s.t. Eq4: x + 2 * w = 7 * y - x;

solve;

printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;

# Solution: 0.5, 3, -2, 10

end;
