set Node_List, dimen 3;
set Nodes := setof {(name,x,y) in Node_List} name;
check card(Nodes)==card(Node_List);
param X {n in Nodes} := sum {(n,x,y) in Node_List} x;
param Y {n in Nodes} := sum {(n,x,y) in Node_List} y;

param Start, symbolic, in Nodes;

param W {a in Nodes, b in Nodes} := sqrt((X[a]-X[b])^2+(Y[a]-Y[b])^2);

var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};

subject to Path_In {b in Nodes}:
	sum {a in Nodes} use[a,b] = 1;

subject to Path_Out {a in Nodes}:
	sum {b in Nodes} use[a,b] = 1;

subject to Flow_Direction {a in Nodes, b in Nodes}:
	flow[a,b] + flow[b,a] = 0;

subject to Flow_On_Used {a in Nodes, b in Nodes}:
	flow[a,b] <= use[a,b] * (card(Nodes) - 1);

subject to Material_Balance {x in Nodes}:
	sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
	if (x==Start) then (1-card(Nodes)) else 1;

minimize Total_Weight:
	sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];

solve;

printf "Shortest Hamiltonian cycle: %g\n", Total_Weight;
for {a in Nodes, b in Nodes: use[a,b]}
{
	printf "%s->%s (%g)\n", a, b, W[a,b];
}

param PX {n in Nodes} := 25 + 50 * X[n];
param PY {n in Nodes} := 475 - 50 * Y[n];

param SVGFILE, symbolic, default "solution.svg";
printf "" >SVGFILE;
printf "<?xml version=""1.0"" standalone=""no""?>\n" >>SVGFILE;
printf "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1//EN"" " >>SVGFILE;
printf """http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"">\n" >>SVGFILE;
printf "<svg width=""500"" height=""500"" version=""1.0"" " >>SVGFILE;
printf "xmlns=""http://www.w3.org/2000/svg"">\n" >>SVGFILE;

printf "<rect x=""0"" y=""0"" width=""500"" height=""500"" " &
		"stroke=""none"" fill=""rgb(255,255,208)""/>\n" >>SVGFILE;

for {i in 0..9}
{
	printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
			"stroke=""black"" stroke-width=""1""/>\n",
			25+50*i, 475, 25+50*i, 25 >>SVGFILE;
	printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
			"stroke=""black"" stroke-width=""1""/>\n",
			25, 25+50*i, 475, 25+50*i >>SVGFILE;
}

for {a in Nodes, b in Nodes: use[a,b]}
{
	printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
			"stroke=""blue"" stroke-width=""3""/>\n",
			PX[a], PY[a], PX[b], PY[b] >>SVGFILE;
}

for {n in Nodes: n!=Start}
{
	printf "<circle cx=""%g"" cy=""%g"" r=""%g"" " &
			"stroke=""black"" stroke-width=""1.5"" fill=""red""/>\n",
			PX[n], PY[n], 8 >>SVGFILE;
}

printf "<rect x=""%g"" y=""%g"" width=""16"" height=""16"" " &
		"stroke=""black"" stroke-width=""1.5"" fill=""green""/>\n",
		PX[Start]-8, PY[Start]-8 >>SVGFILE;

printf "</svg>\n" >>SVGFILE;

end;
