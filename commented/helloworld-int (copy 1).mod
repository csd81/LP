# === 1. VARIABLE DECLARATIONS ===
# These lines declare the variables the solver needs to find.
# '>= 0' is a "bound" constraint.
#
# 'integer' is a new, very important constraint!
# It tells the solver that the final values for x, y, and z
# *must* be whole numbers (0, 1, 2, 3, etc.) and not
# fractions (like 0.5 or 2.5).
# This changes the problem from a Linear Program (LP)
# to a Mixed-Integer Program (MIP).
var x >= 0, integer;
var y >= 0, integer;
var z >= 0, integer;

# === 2. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the constraints, or "rules,"
# that the solution must follow. These are the same as before.

# Constraint 1: The sum of x and y must be less than or equal to 3.
s.t.
Con1: x + y <= 3;
# Constraint 2: The sum of x and z must be less than or equal to 5.
s.t. Con2: x + z <= 5;
# Constraint 3: The sum of y and z must be less than or equal to 7.
s.t. Con3: y + z <= 7;

# === 3. OBJECTIVE FUNCTION ===
# This is the "goal" of the model. We want to find the
# integer values of x, y, and z that satisfy all constraints
# AND make this expression as large as possible.
maximize Sum: x + y + z;

# === 4. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal
# *integer* solution.
solve;

# These 'printf' statements print the final results.
printf "Optimal (max) sum is: %g.\n", Sum;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;

# This comment shows the new optimal solution.
# Notice the total sum is 7, which is less than the 7.5
# from the non-integer version. The integer constraint
# "forced" the solution to a less-optimal (but valid) point.
# There can be multiple solutions that give the same optimal value.
# optimal: 7, for solutions (1,2,4), (0,3,4) and (0,2,5)

# Marks the end of the model file.
end;