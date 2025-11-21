# Modifications: data section (for parameters)

var x1, >=0, integer;
var x2, >=0, integer;
var x3, >=0, integer;
var x4, >=0, integer;
var x5, >=0, integer;

param Av_Flour;
param Av_Butter;
param Av_Sugar;
param Av_Eggs;

s.t. Available_Flour:
	300 * x1 + 400 * x2 + 360 * x3 + 550 * x4 + 900 * x5 <= Av_Flour;
s.t. Available_Butter:
	200 * x1 + 150 * x2 + 250 * x3 + 280 * x4 + 300 * x5 <= Av_Butter;
s.t. Available_Sugar:
	100 * x1 +   0 * x2 + 250 * x3 + 280 * x4 + 350 * x5 <= Av_Sugar;
s.t. Available_Eggs:
	  3 * x1 +   6 * x2 +   5 * x3 +   6 * x4 +   8 * x5 <= Av_Eggs;

maximize Total_Price:
	  6 * x1 +   7 * x2  +   8 * x3 +   9 * x4 +  11 * x5;

solve;

printf "Total price: %g\n", Total_Price; # (!) omits constant terms!
printf "Cake #1: %g\n", x1;
printf "Cake #2: %g\n", x2;
printf "Cake #3: %g\n", x3;
printf "Cake #4: %g\n", x4;
printf "Cake #5: %g\n", x5;
printf "Remaining Flour: %g\n", Av_Flour - (300 * x1 + 400 * x2 + 360 * x3 + 550 * x4 + 600 * x5);
printf "Remaining Flour: %g\n", Av_Flour - Available_Flour;

data;

param Av_Flour := 50000;
param Av_Butter := 30000;
param Av_Sugar := 5000;
param Av_Eggs := 100;

end;
