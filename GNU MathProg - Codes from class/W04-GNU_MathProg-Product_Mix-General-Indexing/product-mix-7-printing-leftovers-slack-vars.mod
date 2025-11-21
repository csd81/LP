# Extra: printing leftover amounts of each resource
# ... but now with introducing the slack variables (remaining amounts) explicitly in our model

# data declaration
set Products; # e.g. cakes
set Resources; # e.g. ingredients

param Price {p in Products}; # price of each product
param Availability {r in Resources}; # available amount of each resource
param ReqAmount {p in Products, r in Resources}; # required amount of each resource r when producing 1 unit of product p

# variables
var x {p in Products}, >=0, integer; # amount to be produced of product p
var sl {r in Resources}, >=0; # remaining amount of resource r

# constraints

s.t. Availability_Constraint {r in Resources}:
	sum {p in Products} ReqAmount[p,r] * x[p] + sl[r] = Availability[r];

maximize Total_Price:
	sum {p in Products} Price[p] * x[p];

solve;

printf "Total price: %g\n", Total_Price; # (!) omits constant terms!
printf "Produced amounts:\n";
for {p in Products}
{
	printf "Product %s: %g\n", p, x[p];
}
printf "Leftover resources:\n";
for {r in Resources}
{
	printf "Leftover %s -> %g\n", r, sl[r];
}

data;

# description of the problem instance (actual data)
set Products := Cake1 Cake2 Cake3 Cake4 Cake5;
set Resources := Flour Butter Sugar Eggs;
param Price :=
	Cake1	3
	Cake2	7
	Cake3	8
	Cake4	9
	Cake5	11
	;
param Availability :=
	Flour	50000
	Butter	30000
	Sugar	5000
	Eggs	100
	;
param ReqAmount (tr):
			Cake1	Cake2	Cake3	Cake4	Cake5 :=
	Flour	300		400		360		550		900
	Butter	200		150		250		280		300
	Sugar	100		0		250		280		350
	Eggs	3		6		5		6		8
	;

end;
