# === 1. SET DECLARATIONS ===
# These sets define the 'shape' of the problem. They will be
# filled with data from a .dat file.

# 'UnknownValues': A set holding the names of the variables
# (the 'x' vector), e.g., {'x', 'y', 'z'}.
set UnknownValues;

# 'Equations': A set holding the names of the equations
# (the rows), e.g., {'Eq1', 'Eq2', 'Eq3'}.
set Equations;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the data (the numbers) that define the
# specific problem you want to solve.

# 'Rhs': A 1-dimensional array (or vector) that stores the
# Right-Hand Side constant for each equation (the 'b' vector).
param Rhs {e in Equations};

# 'Coef': A 2-dimensional array (or matrix) that stores the
# coefficients (the 'A' matrix).
# {e in Equations, u in UnknownValues} means it's indexed by
# the equation (row) and the variable (column).
#
# 'default 0': This is very important. It means if the data
# file doesn't specify a coefficient for a variable,
# AMPL will automatically assume that coefficient is 0.
param Coef {e in Equations, u in UnknownValues}, default 0;

# === 3. VARIABLE DECLARATION ===
# This is the "answer" the solver needs to find.

# 'value': We create one variable for each name in the
# 'UnknownValues' set (e.g., value['x'], value['y']).
# This represents the 'x' vector in Ax = b.
var value {u in UnknownValues};

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the constraints (the equations).

# 'Cts {e in Equations}': This is an indexed constraint.
# It creates *one equation* for *each* item in the 'Equations' set.
s.t. Cts {e in Equations}:
	# 'sum {u in UnknownValues} Coef[e,u] * value[u]'
	# This is the "left-hand side" (LHS) of the equation.
	# For a specific equation 'e', it loops through all variables 'u',
	# multiplies the coefficient (Coef[e,u]) by the
	# variable (value[u]), and adds them all up.
	# This is the matrix-vector multiplication (Ax).
	sum {u in UnknownValues} Coef[e,u] * value[u]
	
	# '= Rhs[e]'
	# This sets the LHS equal to the Right-Hand Side constant
	# for that specific equation 'e' (the 'b' vector element).
	= Rhs[e];

# === 5. SOLVE AND DISPLAY ===

# 'solve;': This command tells the solver (like GLPK) to
# find the numerical values for the 'value' variables that
# satisfy all the 'Cts' constraints.
solve;

# This 'for' loop iterates through each variable name 'u'
# in the 'UnknownValues' set after the solution is found.
for {u in UnknownValues}
{
	# It prints the name of the variable (e.g., "x") and
	# its calculated numerical solution (value[u]).
	printf "%s = %g\n", u, value[u];
}

# Marks the end of the model file.
end;