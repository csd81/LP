# === 1. VARIABLE DECLARATIONS ===
# These lines declare the five unknown variables (x, y, z, w, v)
# that the solver needs to find.
var x;
var y;
var z;
var w;
var v;

# === 2. PARAMETER INITIALIZATION ===
# 'param' declares a parameter (a named constant).
# ':=' is the initialization operator. It gives the
# parameter a value directly in this file, so no
# .dat file is needed for these.
param Rhs1 := -5;
param Rhs2 := -5;
param Rhs3 := 1.5;
param Rhs4 := 0;
param Rhs5 := -0.5;

# === 3. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the system of equations.
# The coefficients are typed directly as numbers, but the
# right side of the '=' uses the parameters defined above.

s.t.
Eq1: 4 * x + (-2) * y +    3 * z +    0 * w +   0 * v = Rhs1;
s.t. Eq2: 0 * x +    0 * y + (-1) * z + (-1) * w +   0 * v = Rhs2;
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w +   0 * v = Rhs3;
s.t. Eq4: 4 * x + (-7) * y +    0 * z +    2 * w +   5 * v = Rhs4;
s.t. Eq5: 1 * x +    0 * y +    2 * z +    0 * w +   3 * v = Rhs5;

# === 4. SOLVE COMMAND ===
# Instructs the solver to find the numerical values for
# x, y, z, w, and v that satisfy all 5 equations.
solve;

# === 5. OUTPUT RESULTS ===
# Prints the final, solved values for each variable.
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;

# A comment showing the expected answer for verification.
# Solution: 2, 3.5, -2, 7, 0.5

# Marks the end of the model file.
end;