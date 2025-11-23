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

s.t. Eq1: 4 * x + (-2) * y +    3 * z +    0 * w +   0 * v = Rhs1;
s.t. Eq2: 0 * x +    0 * y + (-1) * z + (-1) * w +   0 * v = Rhs2;
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w +   0 * v = Rhs3;
s.t. Eq4: 4 * x + (-7) * y +    0 * z +    2 * w +   5 * v = Rhs4;
s.t. Eq5: 1 * x +    0 * y +    2 * z +    0 * w +   3 * v = Rhs5;

solve;

printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;

end;
