# General model
# (big jump): sets, indexing expressions, and the data section now contains the whole model instance

# data declaration
set Products; # e.g. cakes
set Resources; # e.g. ingredients

param Price {p in Products}; # price of each product
param Availability {r in Resources}; # available amount of each resource
param ReqAmount {p in Products, r in Resources}; # required amount of each resource r when producing 1 unit of product p

# variables
var x {p in Products}, >=0, integer; # amount to be produced of product p

# constraints

s.t. Availability_Constraint {r in Resources}:
	sum {p in Products} ReqAmount[p,r] * x[p] <= Availability[r];

maximize Total_Price:
	sum {p in Products} Price[p] * x[p];

solve;

printf "Total price: %g\n", Total_Price; # (!) omits constant terms!
for {p in Products}
{
	printf "Product %s: %g\n", p, x[p];
}

data;

# description of the problem instance (actual data)
set Products := Cake1 Cake2 Cake3 Cake4 Cake5;
set Resources := Flour Butter Sugar Eggs;
param Price :=
	Cake1	6
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
param ReqAmount :=
	Cake1	Flour	300
	Cake1	Butter	200
	Cake1	Sugar	100
	Cake1	Eggs	3
	Cake2	Flour	400
	Cake2	Butter	150
	Cake2	Sugar	0
	Cake2	Eggs	6
	Cake3	Flour	360
	Cake3	Butter	250
	Cake3	Sugar	250
	Cake3	Eggs	5
	Cake4	Flour	550
	Cake4	Butter	280
	Cake4	Sugar	280
	Cake4	Eggs	6
	Cake5	Flour	900
	Cake5	Butter	300
	Cake5	Sugar	350
	Cake5	Eggs	8
	;

end;
