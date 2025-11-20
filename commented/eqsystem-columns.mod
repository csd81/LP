set UnknownValues;
set Equations;

check 'RHS' !in UnknownValues;

set Columns := UnknownValues union {'RHS'};

param EqConstants {e in Equations, u in Columns}, default 0;

var value {u in UnknownValues};

s.t. ImplementingEquations {e in Equations}:
	sum {u in UnknownValues} EqConstants[e,u] * value[u]
	= EqConstants[e,'RHS'];

solve;

for {u in UnknownValues}
{
	printf "%s = %g\n", u, value[u];
}

end;
