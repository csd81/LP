# === 1. SET DECLARATIONS ===
# Sets are the basic building blocks, like lists of 'things'.

# 'Workers' is a set that will hold the names of the workers (e.g., 'Alice', 'Bob').
set Workers;

# 'Tasks' is a set that will hold the names of the tasks (e.g., 'Cleaning', 'Coding').
set Tasks;

# 'check' is a sanity check. card() gets the size (cardinality) of a set.
# This line ensures the model only runs if the number of workers
# equals the number of tasks, which is a requirement for this model structure.
check card(Workers)==card(Tasks);

# 'Assignments' is a set of all possible pairs (worker, task).
# It's the "Cartesian product" of Workers and Tasks.
# If you have 2 workers and 2 tasks, you get 4 possible assignments.
set Assignments := Workers cross Tasks;

# === 2. PARAMETER DECLARATIONS ===
# Parameters are the input data for the model.

# 'Cost' is the data. For each (worker, task) pair, there is a cost.
# The solver will try to minimize the sum of these costs.
param Cost {(w,t) in Assignments};

# 'Fixing' is an advanced parameter to "force" decisions.
# It can be 0, 1, or 2.
# 'in {0,1,2}' restricts the input values.
# 'default 2' means if the data file doesn't provide a value,
# it will automatically be 2.
#   - 1 means: "Force this assignment." (assign[w,t] MUST be 1)
#   - 0 means: "Forbid this assignment." (assign[w,t] MUST be 0)
#   - 2 means: "Let the solver decide." (This is the default)
param Fixing {(w,t) in Assignments}, in {0,1,2}, default 2;

# === 3. VARIABLE DECLARATION ===
# Variables are the "decisions" the solver needs to make.

# 'assign' is our main decision variable.
# '{(w,t) in Assignments}' means we have one variable for each possible pair.
# 'binary' means the variable can only be 0 or 1.
#   - assign[w,t] = 1 means "Worker w IS assigned to Task t"
#   - assign[w,t] = 0 means "Worker w IS NOT assigned to Task t"
var assign {(w,t) in Assignments}, binary;

# === 4. CONSTRAINT DEFINITIONS ===
# "s.t." (subject to) introduces the rules (constraints) of the problem.

# This constraint reads the 'Fixing' parameter.
# The '{(w,t) in Assignments: Fixing[w,t]!=2}' part means:
# "Only create this constraint for pairs where Fixing is NOT 2"
# (i.e., only for pairs we want to force to 0 or 1).
# The constraint 'assign[w,t] = Fixing[w,t]' then sets the variable
# equal to the 0 or 1 value we provided.
s.t. Fixing_Constraints {(w,t) in Assignments: Fixing[w,t]!=2}:
	assign[w,t] = Fixing[w,t];

# This constraint ensures that each worker gets exactly one task.
# '{w in Workers}' means this rule is created *once for each worker*.
# 'sum {t in Tasks} assign[w,t]' means:
# "For a single worker 'w', sum up their 'assign' variables across all tasks".
# '= 1' means this sum must equal 1.
s.t. One_Task_Per_Worker {w in Workers}:
	sum {t in Tasks} assign[w,t] = 1;

# This constraint ensures that each task is assigned to exactly one worker.
# '{t in Tasks}' means this rule is created *once for each task*.
# 'sum {w in Workers} assign[w,t]' means:
# "For a single task 't', sum up its 'assign' variables across all workers".
# '= 1' means this sum must equal 1.
s.t.
One_Worker_Per_Task {t in Tasks}:
	sum {w in Workers} assign[w,t] = 1;

# === 5. OBJECTIVE FUNCTION ===
# This is the goal of the model.

# 'minimize Total_Cost:' tells the solver to find the solution
# with the *lowest* possible value for this expression.
# 'sum {(w,t) in Assignments} assign[w,t] * Cost[w,t]'
# This calculates the total cost. It multiplies the cost of an
# assignment by its decision variable (0 or 1).
# Only the assignments that are "1" (chosen) will add their cost to the total.
minimize Total_Cost:
	sum {(w,t) in Assignments} assign[w,t] * Cost[w,t];

# === 6. SOLVE AND DISPLAY ===

# This command tells the solver to run and find the optimal solution.
solve;

# 'printf' statements are used to display the results nicely.
# '%g' is a placeholder for a number (the value of Total_Cost).
printf "Optimal Cost: %g\n", Total_Cost;

# This 'for' loop iterates through each worker...
for {w in Workers}
{
	# ...prints the worker's name.
	printf "%s->", w;
	
	# This inner loop iterates through all tasks...
	# ...BUT '{t in Tasks: assign[w,t]}' adds a condition.
	# It only loops for the task 't' where assign[w,t] is 1 (is true).
	# Since each worker only has one task, this loop will only run once.
	for {t in Tasks: assign[w,t]}
	{
		# Prints the task name and the cost of that specific assignment.
		printf "%s (%g)\n", t, Cost[w,t];
}
}

# Marks the end of the model file.
end;