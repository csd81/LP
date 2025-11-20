# === 1. PARAMETER DECLARATIONS ===
# These parameters define the size of the grid.
# They are expected to be set in a .dat file or a 'data' block.
param Height, integer, >=1;
param Width, integer, >=1;

# === 2. SET DECLARATIONS ===
# These sets are built from the Height and Width parameters.

# 'Rows' is the set {1, 2, ..., Height}.
# 'Cols' is the set {1, 2, ..., Width}.
set Rows := 1 .. Height;
set Cols := 1 .. Width;

# 'Cells' is the set of all (row, column) coordinate pairs
# that make up the grid.
set Cells := Rows cross Cols;

# 'CellsOf' defines the shape of our "cross" tile.
# For any given cell (r,c), it defines the *set of 5 cells*
# that form a cross *centered* at (r,c).
# This includes the center, one up, one down, one left, one right.
set CellsOf {(r,c) in Cells} :=
	{(r,c),(r+1,c),(r-1,c),(r,c+1),(r,c-1)};

# 'Tiles' is the set of *valid center locations*.
# A cell (r,c) can be the *center* of a cross *only if*
# its entire 5-cell shape (CellsOf[r,c]) is fully
# 'within' the grid.
# This cleverly excludes all cells on the 1-cell border,
# e.g., (1,1), (1,2), etc.
set Tiles, within Cells :=
	setof {(r,c) in Cells: CellsOf[r,c] within Cells} (r,c);

# === 3. VARIABLE DECLARATIONS ===
# These are the "answers" the solver needs to find.

# 'covered' is a helper variable.
# 'binary' means it can only be 0 or 1.
#   - covered[r,c] = 1 means cell (r,c) *is* covered by a cross.
#   - covered[r,c] = 0 means cell (r,c) *is not* covered.
var covered {(r,c) in Cells}, binary;

# 'place' is our main *decision variable*.
# It only exists for the valid center locations in the 'Tiles' set.
# 'binary' means it can only be 0 or 1.
#   - place[r,c] = 1 means "YES, place a cross centered at (r,c)"
#   - place[r,c] = 0 means "NO, do not place a cross here"
var place {(r,c) in Tiles}, binary;

# === 4. CONSTRAINT DEFINITION ===
# "s.t." (subject to) introduces the rules.

# 'No_Overlap' is the key constraint that makes this work.
# It is created *for every cell* (r,c) on the grid.
#
# 'covered[r,c] = ...'
# This constraint *defines* the 'covered' variable.
#
# 'sum {(x,y) in Tiles: (r,c) in CellsOf[x,y]} place[x,y]'
# This sum is the "magic". For a given cell (r,c), it looks
# at all possible tile *centers* (x,y). It checks if our
# cell (r,c) is *part of* the cross centered at (x,y).
# If it is, it adds 'place[x,y]' (0 or 1) to the sum.
#
# Because 'covered[r,c]' *must* be binary (0 or 1),
# this sum is also *forced* to be 0 or 1. This means
# a cell (r,c) can only be covered by *at most one* tile.
s.t. No_Overlap {(r,c) in Cells}: covered[r,c] =
	sum {(x,y) in Tiles: (r,c) in CellsOf[x,y]} place[x,y];

# === 5. OBJECTIVE FUNCTION ===
# This is the "goal" of the model.

# 'maximize Number_of_Crosses:'
# The solver's goal is to find a valid, non-overlapping
# placement plan that makes the total number of
# placed crosses ('sum ... place[r,c]') as large as possible.
maximize Number_of_Crosses:
	sum {(r,c) in Tiles} place[r,c];

# === 6. SOLVE AND DISPLAY ===

# Tell the solver to run and find the optimal solution.
solve;

# Print a summary.
printf "Max. Cross Tiles (%dx%d): %g\n",
	Height, Width, Number_of_Crosses;

# This complex loop prints a visual map of the solution.
for {r in Rows}
{
	for {c in Cols}
	{
		# printf "%s", ... This prints a single character...
		printf "%s",
			# If the cell is not covered, print "."
			if (!covered[r,c]) then "."
# If it *is* covered, check if it's a valid tile center...
else if ((r,c) in Tiles) then (if (place[r,c]) then "#" else "+")
			# ...if it's a center AND we placed a tile: print "#" (center)
			# ...if it's a center AND we didn't place: print "+" (arm)
			# If it's covered but *not* a center: print "+" (arm)
			else "+";
	}
	# Go to the next line after finishing a row.
	printf "\n";
}

# Marks the end of the model file.
end;