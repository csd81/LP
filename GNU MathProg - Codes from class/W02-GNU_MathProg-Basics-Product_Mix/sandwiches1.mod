# Sandwiches 1

# 2 kinds: buttery, ham

var x1, >=0; # buttery
var x2, >=0; # ham

s.t. Available_Bread:
	2*x1 + 2*x2 <= 100;

maximize Revenue:
	3*x1 + 4*x2;

solve;
# Post-processing work

printf "  Revenue = %g\n", 3*x1 + 4*x2;
printf "  Buttery x %g\n", x1;
printf "  Ham x %g\n", x2;

end;
