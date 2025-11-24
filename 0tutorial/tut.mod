set UnknownValues;
set Equations;

param Rhs {e in Equations};

param Coef {e in Equations, u in UnknownValues}, default 0;

var value {u in UnknownValues};

s.t. Cts {e in Equations}:
    sum {u in UnknownValues} Coef[e,u] * value[u] = Rhs[e];

solve;

for {u in UnknownValues}
{
    printf "%s = %g\n", u, value[u];
}

data;

set UnknownValues := x y z w v;
set Equations := Eq1 Eq2 Eq3 Eq4 Eq5;

param Rhs :=
    Eq1 -5
    Eq2 -5
    Eq3 1.5
    Eq4 0
    Eq5 -0.5
    ;

param Coef :=
	Eq1	x	4
	Eq1	y	-2
	Eq1	z	3
	Eq2	z	-1
	Eq2	w	-1
	Eq3	y	1
	Eq3	z	1
	Eq4	x	4
	Eq4	y	-7
	Eq4	w	2
	Eq4	v	5
	Eq5	x	1
	Eq5	z	2
	Eq5	v	3
	;

end;