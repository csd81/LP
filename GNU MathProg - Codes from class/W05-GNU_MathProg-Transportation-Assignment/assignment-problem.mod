# Assignment problem

# 5 workers, 5 jobs, costs for each pair:
#		J1	J2	J3	J4	J5
#	W1	6	7	4	4	4
#	W2	1	2	4	2	4
#	W3	3	3	2	1	3
#	W4	4	1	0	7	2
#	W5	8	8	3	6	3
# minimum total cost?
# (each worker can be assigned to exactly 1 job and vice versa)

set Jobs;
set Workers;
param Cost {w in Workers, j in Jobs};

check card(Jobs) = card(Workers); # cardinality
# check sum {j in Jobs} 1 = sum {w in Workers} 1;

var a {w in Workers, j in Jobs}, binary;
	# a[w,j] = 1 -> worker w is assigned to job j
	# a[w,j] = 0 -> worker w is not assigned to job j
	# binary: 0 or 1, integer, so: >=0, <=1, integer;

s.t. Workers_have_exactly_one_job {w in Workers}:
	sum {j in Jobs} a[w,j] = 1;
s.t. Jobs_have_exactly_one_worker {j in Jobs}:
	sum {w in Workers} a[w,j] = 1;

minimize Total_Cost:
	sum {w in Workers, j in Jobs}
		a[w,j] * Cost[w,j];

solve;

printf "Total cost: %g\n", Total_Cost;
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
