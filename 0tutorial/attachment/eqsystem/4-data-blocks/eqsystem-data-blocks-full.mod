var x;
var y;
var z;
var w;
var v;

param Rhs1;
param Rhs2;
param Rhs3;
param Rhs4;
param Rhs5;

param c1x; param c1y; param c1z; param c1w; param c1v;
param c2x; param c2y; param c2z; param c2w; param c2v;
param c3x; param c3y; param c3z; param c3w; param c3v;
param c4x; param c4y; param c4z; param c4w; param c4v;
param c5x; param c5y; param c5z; param c5w; param c5v;

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

end;
