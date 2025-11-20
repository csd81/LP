# === 1. SET DECLARATIONS ===
# Standard generic setup for a system of equations.

# 'UnknownValues': A set holding the names of the variables (e.g., 'x', 'y').
set UnknownValues;
# 'Equations': A set holding the names of the equations (e.g., 'Eq1', 'Eq2').
set Equations;

# === 2. PARAMETER DECLARATIONS ===
# Standard data for the problem.

# 'Rhs': A 1D-array (vector) storing the Right-Hand Side
# constant for each equation.
param Rhs {e in Equations};

# 'Coef': A 2D-array (matrix) storing the coefficients.
# 'default 0' means any unspecified coefficient is assumed to be 0.
param Coef {e in Equations, u in UnknownValues}, default 0;

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver will find.

# 'value': The set of unknown variables (e.g., value['x'], value['y']).
var value {u in UnknownValues};

# 'maxError': This is the *key variable* for this model.
# It's a single, continuous variable that the solver will
# use to represent the *largest* error across all equations.
var maxError;

# === 4. CONSTRAINT DEFINITIONS ===
# This is where the "best-fit" logic happens.
# We replace the single, strict constraint 'LHS = RHS'
# with *two* "soft" inequality constraints.

# This constraint says the Left-Hand Side (LHS)
# cannot be *larger* than the Right-Hand Side (RHS)
# by more than 'maxError'.
s.t. Cts_Error_Up {e in Equations}:
	sum {u in UnknownValues} Coef[e,u] * value[u]
	<= Rhs[e] + maxError;

# This constraint says the Left-Hand Side (LHS)
# cannot be *smaller* than the Right-Hand Side (RHS)
# by more than 'maxError'.
s.t. Cts_Error_Down {e in Equations}:
	sum {u in UnknownValues} Coef[e,u] * value[u]
	>= Rhs[e] - maxError;

# By combining 'Cts_Error_Up' and 'Cts_Error_Down', we
# are enforcing 'abs(LHS - RHS) <= maxError' for *every*
# equation 'e'.

# === 5. OBJECTIVE FUNCTION ===
# This is the goal of the model.

# 'minimize maxOfAllErrors: maxError;'
# The solver's entire goal is to find a set of 'value's
# that allow 'maxError' to be as small as possible
# while still satisfying the 'Cts_Error_Up' and
# 'Cts_Error_Down' constraints for all equations.
minimize maxOfAllErrors: maxError;

# === 6. SOLVE AND DISPLAY ===

# Tell the solver to find the optimal solution.
solve;

# Print the final, smallest possible value for the worst error.
printf "Optimal error: %g\n", maxError;

# Print the "best-fit" values found for the variables.
printf "Variables:\n";
for {u in UnknownValues}
{
	printf "%s = %g\n", u, value[u];
}

# Print a detailed report for each equation.
printf "Equations:\n";
for {e in Equations}
{
	# This 'printf' shows:
	#   %5s: The equation name (e.g., 'Eq1')
	#   %10f: The original RHS value
	#   %10f: The final calculated LHS value (using the 'best-fit' variables)
	#   %10f: The final absolute error (abs(LHS - RHS)) for this equation.
	# This lets you see which equations were fit perfectly (error=0)
	# and which ones had the 'maxError'.
	printf "%5s: RHS=%10f, LHS=%10f, error=%10f\n",
		e, Rhs[e],
		sum {u in UnknownValues} Coef[e,u] * value[u],
		abs(sum {u in UnknownValues} Coef[e,u] * value[u] - Rhs[e]);
}

# Marks the end of the model file.
end;