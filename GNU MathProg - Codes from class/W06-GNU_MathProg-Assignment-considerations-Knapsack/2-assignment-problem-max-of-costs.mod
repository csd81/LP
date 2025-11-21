# Assignment problem

# alternative: minimize the maximum of the chosen costs!
# min-max objective (or max-min objective)

# 5 workers, 5 jobs, costs for each pair:
#		J1	J2	J3	J4	J5
#	W1	6	7	4	4	4
#	W2	1	2	4	2	4
#	W3	3	3	2	1	3
#	W4	4	1	0	7	2
#	W5	8	8	3	6	3

set Jobs;
set Workers;
param Cost {w in Workers, j in Jobs};

check card(Jobs) = card(Workers); # cardinality
# check sum {j in Jobs} 1 = sum {w in Workers} 1;

var a {w in Workers, j in Jobs}, binary;
	# a[w,j] = 1 -> worker w is assigned to job j
	# a[w,j] = 0 -> worker w is not assigned to job j
	# binary: 0 or 1, integer, so: >=0, <=1, integer;

var max_cost;

s.t. Workers_have_exactly_one_job {w in Workers}:
	sum {j in Jobs} a[w,j] = 1;
s.t. Jobs_have_exactly_one_worker {j in Jobs}:
	sum {w in Workers} a[w,j] = 1;

# We would like to do this, but it is not a linear expression:
# minimize Max_Cost:
	# max {w in Workers, j in Jobs : a[w,j] } Cost[w,j]

s.t. Maximum_of_Costs
	{w in Workers, j in Jobs}:
	a[w,j] * Cost[w,j] <= max_cost;
	# this works, as long as all costs are non-negative!
	
check {w in Workers, j in Jobs}
	Cost[w,j] >= 0;

# but this is possible:
minimize Max_Cost:
	max_cost;

solve;

printf "Max cost: %g\n", max_cost;
for {w in Workers, j in Jobs : a[w,j]}
{
	printf "%s -> %s\n", w, j;
}

data;

# 5 workers, 5 jobs, costs for each pair:
#		J1	J2	J3	J4	J5
#	W1	6	7	4	4	4*
#	W2	1*	2	4	2	4
#	W3	3	3	2	1*	3
#	W4	4	1*	0	7	2
#	W5	8	8	3*	6	3
# minimum total cost?
# (each worker can be assigned to exactly 1 job and vice versa)

set Jobs := J1 J2 J3 J4 J5;
set Workers := W1 W2 W3 W4 W5;
param Cost:
		J1	J2	J3	J4	J5 :=
	W1	6	7	4	4	4
	W2	1	2	4	2	4
	W3	3	3	2	1	3
	W4	4	1	0	7	2
	W5	8	8	3	6	3
	;

end;
