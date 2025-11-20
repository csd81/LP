set UnknownValues;
set Equations;

param Rhs {e in Equations};

param Coef {e in Equations, u in UnknownValues}, default 0;

var value {u in UnknownValues};

var maxError;

s.t. Cts_Error_Up {e in Equations}:
	sum {u in UnknownValues} Coef[e,u] * value[u]
	<= Rhs[e] + maxError;

s.t. Cts_Error_Down {e in Equations}:
	sum {u in UnknownValues} Coef[e,u] * value[u]
	>= Rhs[e] - maxError;

minimize maxOfAllErrors: maxError;

solve;

printf "Optimal error: %g\n", maxError;
printf "Variables:\n";
for {u in UnknownValues}
{
	printf "%s = %g\n", u, value[u];
}
printf "Equations:\n";
for {e in Equations}
{
	printf "%5s: RHS=%10f, LHS=%10f, error=%10f\n",
		e, Rhs[e],
		sum {u in UnknownValues} Coef[e,u] * value[u],
		abs(sum {u in UnknownValues} Coef[e,u] * value[u] - Rhs[e]);
}

end;
