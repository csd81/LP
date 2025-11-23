Here is the full text, fully preserved in structure, paragraphs, math, tables, and data — rewritten in clear American English:

---

## GMPL Model of Motivational Examples

Simple GMPL models based on the motivational examples

### Prerequisites

* GMPL/GLPK basics
* Linear Programming: first steps

---

## Festivals Example

The final mathematical model for the Festivals example looked like this:

$$
y_1, y_2, y_3, y_4, y_5 \in {0,1}

$$

$$
\begin{aligned}
y_1 + y_3 + y_4 &\ge 1 \\
y_1 + y_2 + y_3 + y_5 &\ge 1 \\
y_1 + y_2 + y_4 + y_5 &\ge 1 \\
y_3 + y_4 &\ge 1 \\
y_4 &\ge 1 \\
y_2 + y_3 + y_4 + y_5 &\ge 1 \\
y_3 + y_5 &\ge 1 \\
y_1 + y_2 + y_3 + y_4 + y_5 &\to \min \\
\end{aligned}

$$

Let’s go through how to implement this step by step in GMPL:

### Mathematical notation → GMPL code

**Variables**

$$
y_1, y_2, y_3, y_4, y_5 \in {0,1}

$$

```gmpl
var y1 binary;
var y2 binary;
var y3 binary;
var y4 binary;
var y5 binary;
```

**Constraints**

$$
y_1 + y_3 + y_4 \ge 1

$$

```gmpl
s.t. Haggard: y1 + y3 + y4 >= 1;
```

$$
y_1 + y_2 + y_3 + y_5 \ge 1

$$

```gmpl
s.t. Stratovarius: y1 + y2 + y3 + y5 >= 1;
```

$$
y_1 + y_2 + y_4 + y_5 \ge 1

$$

```gmpl
s.t. Epica: y1 + y2 + y4 + y5 >= 1;
```

$$
y_3 + y_4 \ge 1

$$

```gmpl
s.t. Dalriada: y3 + y4 >= 1;
```

$$
y_4 \ge 1

$$

```gmpl
s.t. Apocalyptica: y4 >= 1;
```

$$
y_2 + y_3 + y_4 + y_5 \ge 1

$$

```gmpl
s.t. Liva: y2 + y3 + y4 + y5 >= 1;
```

$$
y_3 + y_5 \ge 1

$$

```gmpl
s.t. Eluveitie: y3 + y5 >= 1;
```

**Objective function**

$$
y_1 + y_2 + y_3 + y_4 + y_5 \to \min

$$

```gmpl
minimize NumberOfFestivals: y1 + y2 + y3 + y4 + y5;
```

---

### Output

```
Problem:    froccs
Rows:       8
Columns:    5 (5 integer, 5 binary)
Non-zeros:  25
Status:     INTEGER OPTIMAL
Objective:  NumberOfFestivals = 2 (MINimum)
```

```
No.   Row name        Activity     Lower bound   Upper bound
1     Haggard                     2             1
2     Stratovarius                1             1
3     Epica                       1             1
4     Dalriada                    2             1
5     Apocalyptica                1             1
6     Liva                        2             1
7     Eluveitie                   1             1
8     NumberOfFestivals           2
```

```
No. Column name       Activity   Lower bound   Upper bound
1   y1           *        0           0            1
2   y2           *        0           0            1
3   y3           *        1           0            1
4   y4           *        1           0            1
5   y5           *        0           0            1
```

KKT tests (all high quality).

---

From the line **Status: INTEGER OPTIMAL** we know the solver found the optimal solution.
From **Objective: NumberOfFestivals = 2**, we see the minimum is 2 festivals.

Scrolling to the table shows that **y3 = 1** and **y4 = 1**, while all other variables are zero.
So we only need to attend festivals 3 and 4.

---

## Fröccs Example

Similarly, we had already built the following LP model for the fröccs problem:

$$
x_{KF}, x_{NF}, x_{HL}, x_{HM}, x_{VHM}, x_{KrF}, x_{SF}, x_{PF} \in [0, \infty[

$$

**Wine constraint**

$$
1x_{KF} + 2x_{NF} + 1x_{HL} + 3x_{HM} + 2x_{VHM} + 9x_{KrF} + 1x_{SF} + 6x_{PF} \le 1000

$$

**Soda constraint**

$$
1x_{KF} + 1x_{NF} + 2x_{HL} + 2x_{HM} + 3x_{VHM} + 1x_{KrF} + 9x_{SF} + 3x_{PF} \le 1500

$$

**Objective**

$$
110x_{KF} + 200x_{NF} + 120x_{HL} + 260x_{HM} + 200x_{VHM} + 800x_{KrF} + 200x_{SF} + 550x_{PF} \to \max

$$

---

### Mathematical notation → GMPL code

**Variables**

```gmpl
var xKF >=0;
var xNF >=0;
var xHL >=0;
var xHM >=0;
var xVHM >=0;
var xKrF >=0;
var xSF >=0;
var xPF >=0;
```

**Constraints**

```gmpl
s.t. Wine: 1*xKF + 2*xNF + 1*xHL + 3*xHM + 2*xVHM + 9*xKrF + 1*xSF + 6*xPF <= 1000;
s.t. Soda: 1*xKF + 1*xNF + 2*xHL + 2*xHM + 3*xVHM + 1*xKrF + 9*xSF + 3*xPF <= 1500;
```

**Objective**

```gmpl
maximize TotalIncome:
    110*xKF + 200*xNF + 120*xHL + 260*xHM + 200*xVHM
    + 800*xKrF + 200*xSF + 550*xPF;
```

---

### Output

```
Problem:    froccs
Rows:       3
Columns:    8
Non-zeros:  24
Status:     OPTIMAL
Objective:  TotalIncome = 115625 (MAXimum)
```

```
Row name   Activity   Upper bound   Marginal
Wine          1000      1000        98.75
Soda          1500      1500        11.25
TotalIncome 115625
```

```
Column  Activity   Marginal
xKF      937.5
xNF      0         -8.75
xHL      0         -1.25
xHM      0         -58.75
xVHM     0         -31.25
xKrF     0         -100
xSF      62.5
xPF      0         -76.25
```

KKT tests (all high quality).

---

From **Status: OPTIMAL**, we know the solver found the optimal LP solution.
Since the model has no integer variables, there is no “INTEGER” tag.

From **TotalIncome = 115625**, we know the maximum achievable income.

The variable table shows the optimal mix:

* **937.5** portions of **kisfröccs**
* **62.5** portions of **sóherfröccs**

---

## Let’s Make Mistakes!

Regardless of the programming or modeling language, beginners and experienced users often make small syntax errors. The difference is that experienced users can fix them quickly, while beginners may waste a lot of time on them instead of focusing on the model’s logic.

Parsers generally provide helpful error messages, but sometimes the message feels unrelated to the actual issue.

A good way to learn is to intentionally introduce mistakes into a correct file and observe which error messages appear. This helps you associate message types with mistake types. The bonus: you know you introduced exactly one mistake, so you don’t get multiple confusing errors caused by cascading issues.

Common mistakes to try:

* Missing semicolon after variable declaration / constraint / objective
* Missing `s.t.` or typing it incorrectly (e.g., `st..`)
* Using a decimal comma instead of a dot
* Using `<` instead of `<=`
* Declaring variables in one line: `var x1,x2 >= 0;`
* Using `;` instead of `:` or vice versa
* Forgetting the colon after constraint or objective name, or using `=` instead
* Using non-ASCII characters or variable names starting with numbers
* Checking whether the language is case-sensitive
* Misspelling a variable in a constraint

…

---

## Final Notes

We’ve looked at how to implement the LP/MILP models of the motivational examples in GMPL and how to interpret GLPK’s output.

---

If you want, I can also reformat the math into LaTeX, convert tables to Markdown, or generate a clean PDF-ready version.
