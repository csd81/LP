#	1	1	1	| 50
#	2	0	5	| 60
#	1	2	0	| 25
#	1	0	2	| 30
# ----------------------------
#	12	8	15	|

# Variables
var x1, >=0;
var x2, >=0;
var x3, >=0;

# Constraints
s.t. Con1:	1*x1 +	1*x2 +	1*x3 <= 50;
s.t. Con2:	2*x1 +	0*x2 +	5*x3 <= 60;
s.t. Con3: x1 + 2*x2 <= 25;
s.t. Con4: x1 + 2*x3 <= 30;

maximize Obj: x1*12+x2*8+x3*15;

solve;

printf "Objective: %g\n", x1*12+x2*8+x3*15;
printf "x1 = %g\n", x1;
printf "x2 = %g\n", x2;
printf "x3 = %g\n", x3;

end;
