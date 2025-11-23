param Height, integer, >=1;
param Width, integer, >=1;

set Rows := 1 .. Height;
set Cols := 1 .. Width;
set Cells := Rows cross Cols;

set CellsOf {(r,c) in Cells} :=
	{(r,c),(r+1,c),(r-1,c),(r,c+1),(r,c-1)};

set Tiles, within Cells :=
	setof {(r,c) in Cells: CellsOf[r,c] within Cells} (r,c);

var covered {(r,c) in Cells}, binary;
var place {(r,c) in Tiles}, binary;

s.t. No_Overlap {(r,c) in Cells}: covered[r,c] =
	sum {(x,y) in Tiles: (r,c) in CellsOf[x,y]} place[x,y];

maximize Number_of_Crosses:
	sum {(r,c) in Tiles} place[r,c];

solve;

printf "Max. Cross Tiles (%dx%d): %g\n",
	Height, Width, Number_of_Crosses;

for {r in Rows}
{
	for {c in Cols}
	{
		printf "%s",
			if (!covered[r,c]) then "."
			else if ((r,c) in Tiles) then (if (place[r,c]) then "#" else "+")
			else "+";
	}
	printf "\n";
}

end;
