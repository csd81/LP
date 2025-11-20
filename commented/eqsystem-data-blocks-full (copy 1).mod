# === 1. Variable Declarations ===
# Declares the five unknown variables the solver needs to find.
var x;
var y;
var z;
var w;
var v;

# === 2. Parameter Declarations ===
# These are placeholders for the data (constants and coefficients)
# that will be read from a .dat file.

# 'Rhs' parameters hold the Right-Hand Side constants for each equation.
param Rhs1;
param Rhs2;
param Rhs3;
param Rhs4;
param Rhs5;

# 'c' parameters hold the coefficients for the variables.
# The naming convention is c[EquationNumber][VariableName].
# For example, 'c1x' is the coefficient of 'x' in 'Eq1'.
#
# Coefficients for Equation 1:
param c1x; param c1y; param c1z; param c1w; param c1v;
# Coefficients for Equation 2:
param c2x; param c2y; param c2z; param c2w; param c2v;
# Coefficients for Equation 3:
param c3x; param c3y; param c3z; param c3w; param c3v;
# Coefficients for Equation 4:
param c4x; param c4y; param c4z; param c4w; param c4v;
# Coefficients for Equation 5:
param c5x; param c5y; param c5z; param c5w; param c5v;

# === 3. Constraint Definitions ===
# "s.t." (subject to) introduces the equations.
# Each equation is explicitly built by multiplying the
# variables (x, y, z, w, v) by their corresponding
# parameter coefficients (c1x, c1y, etc.) and setting
# the sum equal to the corresponding Rhs parameter.

s.t.
Eq1: c1x * x + c1y * y + c1z * z + c1w * w + c1v * v = Rhs1;
s.t. Eq2: c2x * x + c2y * y + c2z * z + c2w * w + c2v * v = Rhs2;
s.t. Eq3: c3x * x + c3y * y + c3z * z + c3w * w + c3v * v = Rhs3;
s.t. Eq4: c4x * x + c4y * y + c4z * z + c4w * w + c4v * v = Rhs4;
s.t. Eq5: c5x * x + c5y * y + c5z * z + c5w * w + c5v * v = Rhs5;

# === 4. Solve Command ===
# Instructs the solver to find the numerical values for
# x, y, z, w, and v that satisfy all 5 equations.
solve;

# === 5. Output Results ===
# Prints the final, solved values for each variable.
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;

# Marks the end of the model file.
end;