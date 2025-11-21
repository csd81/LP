# any leftover resource is 0.01€ per g, or 0.1€ per egg
# adjust the total price of cakes with leftover price of resources!

var x1, >=0, integer;
var x2, >=0, integer;
var x3, >=0, integer;
var x4, >=0, integer;
var x5, >=0, integer;

# auxiliary variables
# (in this case, slack variables in simplex algorithm)
var remF, >=0;
var remB, >=0;
var remS, >=0;
var remE, >=0;

s.t. Available_Flour:
	300 * x1 + 400 * x2 + 360 * x3 + 550 * x4 + 600 * x5 + remF = 50000;
s.t. Available_Butter:
	200 * x1 + 150 * x2 + 250 * x3 + 280 * x4 + 300 * x5 + remB = 30000;
s.t. Available_Sugar:
	100 * x1 +   0 * x2 + 250 * x3 + 280 * x4 + 350 * x5 + remS = 5000;
s.t. Available_Eggs:
	  3 * x1 +   6 * x2 +   5 * x3 +   6 * x4 +   8 * x5 + remE = 10000;

maximize Total_Price:
	  6 * x1 +   7 * x2  +   8 * x3 +   9 * x4 +  11 * x5 +
	  remF * 0.01 + remB * 0.01 + remS * 0.01 + remE * 0.1;

solve;

printf "Total price: %g\n", Total_Price; # (!) omits constant terms!
printf "Cake #1: %g\n", x1;
printf "Cake #2: %g\n", x2;
printf "Cake #3: %g\n", x3;
printf "Cake #4: %g\n", x4;
printf "Cake #5: %g\n", x5;
# printf "Remaining Flour: %g\n", 50000 - (300 * x1 + 400 * x2 + 360 * x3 + 550 * x4 + 600 * x5);
# printf "Remaining Flour: %g\n", 50000 - Available_Flour;
printf "Remaining Flour: %g\n", remF;
printf "Remaining Butter: %g\n", remB;
printf "Remaining Sugar: %g\n", remS;
printf "Remaining Eggs: %g\n", remE;

end;
