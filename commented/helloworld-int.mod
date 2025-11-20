var x >= 0, integer;
var y >= 0, integer;
var z >= 0, integer;

s.t. Con1: x + y <= 3;
s.t. Con2: x + z <= 5;
s.t. Con3: y + z <= 7;

maximize Sum: x + y + z;

solve;

printf "Optimal (max) sum is: %g.\n", Sum;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;

# optimal: 7, for solutions (1,2,4), (0,3,4) and (0,2,5)

end;
