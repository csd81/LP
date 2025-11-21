# Assignment problem
# asymmetric case: more workers than jobs (each job has to be done (exactly once))
# 1 worker can do more jobs (at most 3)

# 7 workers, 5 jobs, costs for each pair:
#		J1	J2	J3	J4	J5
#	W1	6	7	4	4	4
#	W2	1	2	4	2	4
#	W3	3	3	2	1	3
#	W4	4	1	0	7	2
#	W5	8	8	3	6	3
#	W6	1	2	2	2	1
#	W7	2	3	9	2	9
# minimum total cost?
# (each worker can have 0-3 jobs)

set Jobs;
set Workers;
param Cost {w in Workers, j in Jobs};

# check card(Jobs) <= card(Workers); # cardinality
# check sum {j in Jobs} 1 <= sum {w in Workers} 1;

var a {w in Workers, j in Jobs}, binary;
	# a[w,j] = 1 -> worker w is assigned to job j
	# a[w,j] = 0 -> worker w is not assigned to job j
	# binary: 0 or 1, integer, so: >=0, <=1, integer;

var max_worker_cost; # maximum total cost (time) of any single worker

s.t. Workers_have_at_most_one_job {w in Workers}:
	sum {j in Jobs} a[w,j] <= 3; # <= instead of =
s.t. Jobs_have_exactly_one_worker {j in Jobs}:
	sum {w in Workers} a[w,j] = 1;

s.t. Max_worker_cost_constraint
	{w in Workers}:
	sum {j in Jobs} a[w,j] * Cost[w,j] <= max_worker_cost;
	# works as long as Cost[w,j] is non-negative, so:
check {w in Workers, j in Jobs} Cost[w,j] >= 0;

minimize Max_Worker_Cost:
	max_worker_cost;

solve;

printf "Max worker cost: %g\n", max_worker_cost;
for {w in Workers, j in Jobs : a[w,j]}
{
	printf "%s -> %s\n", w, j;
}

data;

# 5 workers, 5 jobs, costs for each pair:
#		J1	J2	J3	J4	J5
#	W1	6	7	4	4	4 -> rests
#	W2	1*	2	4	2	4
#	W3	3	3	2	1*	3
#	W4	4	1*	0*	7	2
#	W5	8	8	3	6	3 -> rests
#	W6	1	2	2	2	1*
#	W7	2	3	9	2	9 -> rests
# minimum total cost?
# (each worker can be assigned to exactly 1 job and vice versa)

set Jobs := J1 J2 J3 J4 J5;
set Workers := W1 W2 W3 W4 W5 W6 W7;
param Cost:
		J1	J2	J3	J4	J5 :=
	W1	6	7	4	4	4
	W2	1	2	4	2	4
	W3	3	3	2	1	3
	W4	4	1	0	7	2
	W5	8	8	3	6	3
	W6	1	2	2	2	1
	W7	2	3	9	2	9
	;

end;
