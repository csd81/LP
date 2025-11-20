# === Variable Declarations ===
# These lines declare the variables (the unknowns) that the model needs to solve for.
# We are looking for the numerical values of x, y, z, and w.
var x;
var y;
var z;
var w;

# === Constraint Definitions ===
# "s.t." stands for "subject to". This keyword introduces the constraints (the equations)
# that the variables must satisfy. We have a system of 4 linear equations
# and 4 variables.

# Constraint 1: 2 times (x minus y) must equal -5
s.t. Eq1: 2 * (x - y) = -5;

# Constraint 2: y minus z must equal w minus 5
s.t.
Eq2: y - z = w - 5;

# Constraint 3: 1 must equal y plus z
s.t. Eq3: 1 = y + z;

# Constraint 4: x plus 2 times w must equal 7 times y minus x
s.t.
Eq4: x + 2 * w = 7 * y - x;

# === Solve Command ===
# This command instructs the solver (like GLPK) to find the values of
# x, y, z, and w that simultaneously satisfy all the constraints (Eq1, Eq2, Eq3, Eq4).
solve;

# === Output Results ===
# After the solver finds a solution, these "printf" statements
# print the final values of the variables to the console.
# "%g" is a placeholder for a number (general format).
# "\n" means "new line", so each result is printed on its own line.
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;

# === Solution Verification ===
# This is a comment showing the expected solution.
# You can use this to check if your model and solver produced the correct answer.
# Solution: 0.5, 3, -2, 10

# === End of Model ===
# This statement marks the end of the model definition.
end;