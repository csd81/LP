var x;
var y;
var z;
var w;
var v;

param Rhs1 := -5;
param Rhs2 := -5;
param Rhs3 := 1.5;
param Rhs4 := 0;
param Rhs5 := -0.5;

param c1x := 4; param c1y := -2; param c1z :=  3; param c1w :=  0; param c1v :=  0;
param c2x := 0; param c2y :=  0; param c2z := -1; param c2w := -1; param c2v :=  0;
param c3x := 0; param c3y :=  1; param c3z :=  1; param c3w :=  0; param c3v :=  0;
param c4x := 4; param c4y := -7; param c4z :=  0; param c4w :=  2; param c4v :=  5;
param c5x := 1; param c5y :=  0; param c5z :=  2; param c5w :=  0; param c5v :=  3;

s.t. Eq1: c1x * x + c1y * y + c1z * z + c1w * w + c1v * v = Rhs1;
s.t. Eq2: c2x * x + c2y * y + c2z * z + c2w * w + c2v * v = Rhs2;
s.t. Eq3: c3x * x + c3y * y + c3z * z + c3w * w + c3v * v = Rhs3;
s.t. Eq4: c4x * x + c4y * y + c4z * z + c4w * w + c4v * v = Rhs4;
s.t. Eq5: c5x * x + c5y * y + c5z * z + c5w * w + c5v * v = Rhs5;

solve;

printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;

# Solution: 2, 3.5, -2, 7, 0.5

end;
