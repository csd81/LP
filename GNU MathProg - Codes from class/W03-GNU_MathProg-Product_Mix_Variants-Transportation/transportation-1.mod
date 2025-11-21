# transportation problem (from motiv. slides)

var a1, >=0, integer; # from warehouse A to market 1
var a2, >=0, integer; # ...
var a3, >=0, integer;
var b1, >=0, integer;
var b2, >=0, integer;
var b3, >=0, integer;

s.t. Supply_A:
	a1 + a2 + a3 <= 11; # = 11
s.t. Supply_B:
	b1 + b2 + b3 <= 10;

#s.t. ...: 	a1 + a2 + a3 + b1 + b2 + b3 <= 20;

s.t. Demand_1:
	a1 + b1 = 13; # >= 13
s.t. Demand_2:
	a2 + b2 = 5;
s.t. Demand_3:
	a3 + b3 = 2;

minimize Total_Transp_Costs:
	a1 * 235 + a2 * 57 + a3 * 340 +
	b1 * 130 + b2 *385 + b3 * 197;

solve;
#...
printf "a1 : %g\n", a1;
printf "a2 : %g\n", a2;
printf "a3 : %g\n", a3;
printf "b1 : %g\n", b1;
printf "b2 : %g\n", b2;
printf "b3 : %g\n", b3;

end;
