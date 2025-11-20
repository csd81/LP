# === 1. SET DECLARATIONS ===
# These sets will be loaded from the data file (.dat)

# 'UnknownValues' will hold the *names* of the variables.
# For example: {'x', 'y', 'z', 'w'}
set UnknownValues;

# 'Equations' will hold the *names* of the equations.
# For example: {'Eq1', 'Eq2', 'Eq3', 'Eq4'}
set Equations;

# This 'check' ensures that 'RHS' (Right-Hand Side) is not
# accidentally used as a variable name, as we reserve it
# for the constant values of the equations.
check 'RHS' !in UnknownValues;

# 'Columns' is a helper set. It's the set of all variables
# *plus* the 'RHS' column. This makes it easy to define
# our big data matrix in the next step.
set Columns := UnknownValues union {'RHS'};

# === 2. PARAMETER DECLARATION ===

# 'EqConstants' is the main data parameter. It's a 2D table (a matrix)
# that holds all the coefficients for the equations.
# {e in Equations, u in Columns} means it's indexed by equation (row)
# and by (variable + RHS) (column).
# 'default 0' is important: it means if a coefficient isn't
# specified in the data file, it's assumed to be zero.
param EqConstants {e in Equations, u in Columns}, default 0;

# === 3. VARIABLE DECLARATION ===

# 'value' is our set of decision variables.
# '{u in UnknownValues}' means we create one variable for each
# name in the 'UnknownValues' set (e.g., value['x'], value['y'], etc.).
# These are the numbers the solver will find.
var value {u in UnknownValues};

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules.

# This single, indexed constraint *generates all the equations*.
# '{e in Equations}' means this rule is repeated *once for each equation*.
#
# 'sum {u in UnknownValues} EqConstants[e,u] * value[u]'
# This is the "left-hand side" of the equation. For a given equation 'e',
# it multiplies each variable 'value[u]' by its corresponding
# coefficient 'EqConstants[e,u]' and sums them up.
#
# '= EqConstants[e,'RHS']'
# This sets the left-hand side equal to the "right-hand side"
# constant stored in the 'RHS' column for that equation.
s.t.
ImplementingEquations {e in Equations}:
	sum {u in UnknownValues} EqConstants[e,u] * value[u]
	= EqConstants[e,'RHS'];

# === 5. SOLVE AND DISPLAY ===

# This command tells the solver to find the values
# for the 'value' variables that satisfy all the
# 'ImplementingEquations' constraints.
solve;

# This 'for' loop iterates through each variable name
# in the 'UnknownValues' set.
for {u in UnknownValues}
{
	# It prints the name of the variable (e.g., "x") and
	# the numerical solution (value[u]) found by the solver.
	printf "%s = %g\n", u, value[u];
}

# Marks the end of the model file.
end;