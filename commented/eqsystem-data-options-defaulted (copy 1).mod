# === 1. SET DECLARATIONS ===
# These sets define the 'shape' of the problem and will be
# loaded from a data (.dat) file.

# 'UnknownValues': A set holding the names of the variables.
# Example: {'x', 'y', 'z', 'w'}
set UnknownValues;

# 'Equations': A set holding the names of the equations.
# Example: {'Eq1', 'Eq2', 'Eq3', 'Eq4'}
set Equations;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the data (the numbers) that define the
# specific problem you want to solve.

# 'Rhs': A 1-dimensional array (or vector) that stores the
# Right-Hand Side constant for each equation.
# {e in Equations} means there is one 'Rhs' value for each
# item in the 'Equations' set.
param Rhs {e in Equations};

# 'Coef': A 2-dimensional array (or matrix) that stores the
# coefficients. {e in Equations, u in UnknownValues} means
# it's indexed by the equation (row) and the variable (column).
#
# 'default 0': This is very important. It means if the data
# file doesn't specify a coefficient for a variable in an
# equation, AMPL will automatically assume that coefficient is 0.
# This saves you from having to type '0' many times in your data.
param Coef {e in Equations, u in UnknownValues}, default 0;

# === 3. VARIABLE DECLARATION ===
# This is the "answer" the solver needs to find.

# 'value': We create one variable for each name in the
# 'UnknownValues' set.
# For example, if UnknownValues = {'x', 'y'}, this creates
# 'value['x']' and 'value['y']'.
var value {u in UnknownValues};

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the constraints (the equations).

# 'Cts {e in Equations}': This is a powerful feature. It
# creates *one constraint* for *each* item in the 'Equations' set.
# So if you have 4 equations, this block generates all 4 of them.
s.t. Cts {e in Equations}:
	# 'sum {u in UnknownValues} Coef[e,u] * value[u]'
	# This is the "left-hand side" (LHS) of the equation.
	# For a specific equation 'e', it loops through all unknown
	# variables 'u', multiplies the coefficient (Coef[e,u])
	# by the variable (value[u]), and adds them all up.
	# This is the standard "dot product" you see in linear algebra.
	sum {u in UnknownValues} Coef[e,u] * value[u]
	
	# '= Rhs[e]'
	# This sets the LHS equal to the Right-Hand Side constant
	# for that specific equation 'e'.
	= Rhs[e];

# === 5. SOLVE AND DISPLAY ===

# 'solve;': This command tells the solver (like GLPK) to
# find the values for the 'value' variables that make all
# the 'Cts' constraints true at the same time.
solve;

# This 'for' loop iterates through each variable name 'u'
# in the 'UnknownValues' set.
for {u in UnknownValues}
{
	# It prints the name of the variable (e.g., "x") and
	# the numerical solution (value[u]) found by the solver.
	# "%s" is a placeholder for a string (the name 'u').
	# "%g" is a placeholder for a number (the 'value[u]').
	printf "%s = %g\n", u, value[u];
}

# Marks the end of the model file.
end;