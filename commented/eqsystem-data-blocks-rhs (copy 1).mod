# === 1. Variable Declarations ===
# Declares the five unknown variables (x, y, z, w, v)
# that the solver needs to find.
var x;
var y;
var z;
var w;
var v;

# === 2. Parameter Declarations ===
# These parameters will hold the Right-Hand Side (RHS)
# constant values for each equation. These values are
# expected to be provided in a separate .dat file.
param Rhs1;
param Rhs2;
param Rhs3;
param Rhs4;
param Rhs5;

# === 3. Constraint Definitions ===
# "s.t." (subject to) introduces the system of equations.
# Note: The coefficients for x, y, z, w, v are fixed numbers.
# Only the value on the right (e.g., Rhs1) is a parameter.

# Equation 1:
s.t. Eq1: 4 * x + (-2) * y +    3 * z +    0 * w +   0 * v = Rhs1;

# Equation 2:
s.t. Eq2: 0 * x +    0 * y + (-1) * z + (-1) * w +   0 * v = Rhs2;

# Equation 3:
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w +   0 * v = Rhs3;

# Equation 4:
s.t. Eq4: 4 * x + (-7) * y +    0 * z +    2 * w +   5 * v = Rhs4;

# Equation 5:
s.t. Eq5: 1 * x +    0 * y +    2 * z +    0 * w +   3 * v = Rhs5;

# === 4. Solve Command ===
# Instructs the solver to find the numerical values for
# x, y, z, w, and v that satisfy all 5 equations, using
# the Rhs values provided by the data file.
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