# === 1. Variable Declarations ===
# These lines declare the four unknown variables (x, y, z, w)
# that the solver needs to find the values for.
var x;
var y;
var z;
var w;

# === 2. Constraint Definitions ===
# "s.t." stands for "subject to". This section defines the system
# of linear equations. Notice how all variables are on the
# left-hand side and the constant is on the right-hand side.
# The use of '0 * z' etc., helps align the code visually
# so you can easily see the coefficients for each variable.

# Constraint 1: 2*x - 2*y = -5
# (This is the same as the original 2*(x-y) = -5)
s.t. Eq1: 2 * x + (-2) * y +    0 * z +    0 * w = -5;

# Constraint 2: y - z - w = -5
# (This is the same as the original y - z = w - 5)
s.t. Eq2: 0 * x +    1 * y + (-1) * z + (-1) * w = -5;

# Constraint 3: y + z = 1
# (This was already in standard form)
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w = 1;

# Constraint 4: 2*x - 7*y + 2*w = 0
# (This is the same as the original x + 2*w = 7*y - x)
s.t. Eq4: 2 * x + (-7) * y +    0 * z +    2 * w = 0;

# === 3. Solve Command ===
# This command instructs the solver (like GLPK) to find the
# single unique solution (the values of x, y, z, w) that
# satisfies all four equations at the same time.
solve;

# === 4. Output Results ===
# These 'printf' statements will print the final values
# found by the solver.
# "%g" is a placeholder for a number. "\n" creates a new line.
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;

# This is a comment for human use. It shows the expected
# correct answer, so you can verify the model is working.
# Solution: 0.5, 3, -2, 10

# === 5. End of Model ===
# This marks the end of the model file.
end;