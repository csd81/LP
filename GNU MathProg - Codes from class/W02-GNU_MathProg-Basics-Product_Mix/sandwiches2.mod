# Sandwiches 2

# + new resource (ham, <=30)

var x1, >=0; # buttery
var x2, >=0; # ham

s.t. Available_Bread: # subject to
	2*x1 + 2*x2 <= 100;

s.t. Available_Ham:
	x2 <= 30;

maximize Revenue:
	3*x1 + 4*x2;

solve;
# Post-processing work

printf "  Revenue = %g\n", 3*x1 + 4*x2;
printf "  Buttery x %g\n", x1;
printf "  Ham x %g\n", x2;

end;
