# Sandwiches 3

# double ham sandwich: 3 slices of bread instead of 2
# -> optimal LP solution -> not integer

var x1, >=0, integer; # buttery
var x2, >=0, integer; # ham
var x3, >=0, integer; # double ham

s.t. Available_Bread: # subject to
	2*x1 + 2*x2 + 3*x3 <= 100;

s.t. Available_Ham:
	x2 + 2*x3 <= 30;

maximize Revenue:
	3*x1 + 4*x2 + 7*x3;

solve;
# Post-processing work

printf "  Revenue = %g\n", 3*x1 + 4*x2 + 7*x3;
printf "  Buttery x %g\n", x1;
printf "  Ham x %g\n", x2;
printf "  Double ham x %g\n", x3;

end;
