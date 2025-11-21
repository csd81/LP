# x, y, z non-negative real numbers
# we know that x+y<=3, x+z<=4, y+z<=5
# what is the maximal possible value of x+y+z?

# Variables
var x;
var y;
var z;

# Constraints
s.t. Con1: x + y <= 3;
s.t. Con2: x + z <= 4;
s.t. Con3: y + z <= 5;

maximize Obj: x + y + z;

solve;

printf "Objective: %g\n", x+y+z;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;

end;
