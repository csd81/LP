/* We have a bakery, and we have to bake cakes to our customers. There are five different cake types, each requiring a different amount of the ingredients.
Cake #1 requires 300 grams of flour, 200 grams of butter, 100 grams of sugar and 3 eggs, and it has a price of 6€.
Cake #2 requires 400 grams of flour, 150 grams of butter, no sugar and 6 eggs, and it has a price of 7€.
Cake #3 requires 360 grams of flour, 250 grams of butter, 250 grams of sugar and 5 eggs, its price is 8€.
Cake #4 requires 550 grams of flour, 280 grams of butter, 280 grams of sugar, 6 eggs, its price is 9€.
Cake #5 requires 600 grams of flour, 300 grams of butter, 350 grams of sugar, 8 eggs, and its price is 11€.
We have a storage of 50 kgs of flour, 30 kgs of sugar, 5 kgs of butter and 100 eggs for this purpose. Of course, cakes require more ingrediends, but we may assume that those are available in unlimited amounts. We cannot gain more ingrediendts, and we don't care about leftovers.
What is the maximum of the total price of the baked cakes if we use these ingredients?
Note: Production amounts of cakes are integers, so we cannot bake "half a cake" for example. For this reason, the original model file must be changed, and the corresponding decision variables must have the "integer" limitation added. */

var x1, >=0, integer;
var x2, >=0, integer;
var x3, >=0, integer;
var x4, >=0, integer;
var x5, >=0, integer;

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
	  3 * x1 +   6 * x2 +   5 * x3 +   6 * x4 +   8 * x5 + remE = 100;

maximize Total_Price:
	  6 * x1 +   7 * x2  +   8 * x3 +   9 * x4 +  11 * x5;

solve;

printf "Total price: %g\n", Total_Price; # (!) omits constant terms!
printf "Cake #1: %g\n", x1;
printf "Cake #2: %g\n", x2;
printf "Cake #3: %g\n", x3;
printf "Cake #4: %g\n", x4;
printf "Cake #5: %g\n", x5;
printf "Remaining Flour: %g\n", 50000 - (300 * x1 + 400 * x2 + 360 * x3 + 550 * x4 + 600 * x5);
# printf "Remaining Flour: %g\n", 50000 - Available_Flour;
printf "Remaining Flour: %g\n", remF;
printf "Remaining Butter: %g\n", remB;
printf "Remaining Sugar: %g\n", remS;
printf "Remaining Eggs: %g\n", remE;

end;