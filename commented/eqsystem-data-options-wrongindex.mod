set UnknownValues;
set Equations;

param Rhs {e in Equations};

param Coef {e in Equations, u in UnknownValues}, default 0;

var value {u in UnknownValues};

s.t. Cts {e in Equations}:
	sum {u in UnknownValues} Coef[u,e] * value[u]
	= Rhs[e];

solve;

for {u in UnknownValues}
{
	printf "%s = %g\n", u, value[u];
}

# Note that indices of Coef[u,e] in Cts are deliberately wrong, the correct order would be Coef[e,u].

end;
