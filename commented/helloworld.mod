var x >= 0;
var y >= 0;
var z >= 0;

s.t. Con1: x + y <= 3;
s.t. Con2: x + z <= 5;
s.t. Con3: y + z <= 7;

maximize Sum: x + y + z;

solve;

printf "Optimal (max) sum is: %g.\n", Sum;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;

# optimal: 7.5, at x=0.5, y=2.5, z=4.5

end;
