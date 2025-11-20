# === 1. VARIABLE DECLARATIONS ===
# These lines declare the variables the solver needs to find.
# '>= 0' is a "bound" constraint, meaning the solver
# can only find solutions where x, y, and z are zero or positive.
var x >= 0;
var y >= 0;
var z >= 0;

# === 2. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the constraints, or "rules,"
# that the solution must follow.

# Constraint 1: The sum of x and y must be less than or equal to 3.
s.t. Con1: x + y <= 3;
s.t.
# Constraint 2: The sum of x and z must be less than or equal to 5.
Con2: x + z <= 5;
# Constraint 3: The sum of y and z must be less than or equal to 7.
s.t. Con3: y + z <= 7;

# === 3. OBJECTIVE FUNCTION ===
# This is the "goal" of the model. We want to find the
# values of x, y, and z that satisfy all the constraints
# AND make this expression as large as possible.

# 'maximize Sum:' defines the objective.
# 'Sum' is just a name for this objective function.
maximize Sum: x + y + z;

# === 4. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# values for x, y, z that satisfy Con1, Con2, Con3
# and maximize 'Sum'.
solve;

# These 'printf' statements are executed after the solver
# finishes. They print the final results to the console.
# '%g' is a placeholder for a number.
printf "Optimal (max) sum is: %g.\n", Sum;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;

# This is a comment showing the expected solution.
# You can use this to check if your model ran correctly.
# optimal: 7.5, at x=0.5, y=2.5, z=4.5

# Marks the end of the model file.
end;