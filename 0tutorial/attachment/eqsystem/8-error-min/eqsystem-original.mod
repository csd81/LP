set UnknownValues;
set Equations;

param Rhs {e in Equations};

param Coef {e in Equations, u in UnknownValues}, default 0;

var value {u in UnknownValues};

s.t. Cts {e in Equations}:
	sum {u in UnknownValues} Coef[e,u] * value[u]
	= Rhs[e];

solve;

for {u in UnknownValues}
{
	printf "%s = %g\n", u, value[u];
}

end;
