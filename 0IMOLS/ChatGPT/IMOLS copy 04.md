**GMPL/GLPK Basics**
An overview of tools and languages for (MI)LP problems, with a brief introduction to GLPK and GMPL

---

### **Prerequisites**

**Linear Programming: first steps**

---

### **(MI)LP Description Languages and Solvers**

Since MILP and LP models are widely used in practice, the algorithms that solve them are already well-developed. Therefore, there’s no need to implement the simplex algorithm ourselves. In fact, it’s better not to do so unless for coding practice. Modern solvers are quite complex, and there are small but important details (such as floating-point rounding) that must be carefully managed to ensure numerical stability. Even then, the resulting implementation would not come close to the efficiency of the established solvers listed below. These solvers use numerous theoretical enhancements (e.g., LU decomposition), implementation tricks (e.g., sparse representation), and many heuristic optimizations.

There are several options for solving MILP/LP problems. A few are listed below with brief notes:


| **Solver**  | **License**                        | **Problem Classes** |
| ------------- | ------------------------------------ | --------------------- |
| lp_solve    | LGPL                               | MILP                |
| GLPK        | GPL                                | MILP                |
| COIN-OR CLP | EPL                                | LP                  |
| COIN-OR CBC | EPL                                | MILP                |
| Gurobi      | Proprietary – Gurobi Optimization | MIQP, etc.          |
| CPLEX       | Proprietary – IBM                 | MIQP, etc.          |
| LINGO       | Proprietary – Lindo Systems Inc.  | MILP, MINLP         |

As this selective list shows, there are plenty of options to choose from — and many more beyond these.

In terms of performance, the proprietary tools significantly outperform the open-source alternatives. Among open-source options, the COIN-OR project provides the fastest solvers. Ultimately, the best choice depends on the situation. For example, I use (or would use):

* **GLPK standalone solver** for teaching — it’s very simple to install and use, and it’s completely free.
* **COIN-OR API** for scientific software that needs to solve MILP subproblems.
* **Gurobi/CPLEX and COIN-OR CBC** for performance comparisons in academic papers.
* **Gurobi/CPLEX** in industrial environments where efficiency is essential.

Of course, these are just recommendations; each case is different. Note that academic licenses are available for most proprietary tools.

Once you’ve chosen a solver, you can either use its API directly from your code or run the standalone solver with a model file. Different solvers support APIs for different programming languages, but we’ll focus on the standalone model-file approach for now. There are many languages for describing MILP models, and most solvers support several of them. The table below lists some common formats:


| **Format Name** | **File Extension** | **Description / Notes**                                                        |
| ----------------- | -------------------- | -------------------------------------------------------------------------------- |
| AMPL            | .mod, .dat, .run   | A Mathematical Programming Language; general and versatile, widely used.       |
| GMPL            | .mod, .dat         | GNU Mathematical Programming Language; a subset of AMPL, default for GLPK.     |
| MPS             | .mod, .dat         | Mathematical Programming System; an old but widely supported legacy format.    |
| GAMS            | (varies)           | General Algebraic Modeling System; a full modeling ecosystem with IDE and API. |
| CPLEX           | .lp                | Default CPLEX format; also supported by other solvers.                         |
| Lingo           | .lng               | Used exclusively by LINGO.                                                     |

Below is the same example expressed in several formats for comparison.

---

### **Mathematical Model**

**MPS (fixed)**
**MPS (free)**
**CPLEX**
**GMPL**
**Lingo**

```gmpl
var x >= 0;
var y >= 0;

s.t. Constraint1:
  x + 2*y <= 15;

s.t. Constraint2:
  3*x + y <= 20;

maximize Objective: x + y;
```

On this site, we’ll use the **GMPL** format and the **glpsol** solver.
If you need your model in another format, you can also use **glpsol** to convert it using the `--wmps`, `--wfreemps`, or `--wlp` options.

---

### **GMPL Basics**

As discussed earlier, a model can be divided into three parts: **variable declarations**, **constraints**, and the **objective function**. We’ll introduce the basic GMPL syntax in this order.
A detailed GMPL reference can be found by downloading the GLPK package from its official website.

---

### **Variables**

Variables are defined with the keyword `var`, followed by the variable name, domain restrictions, and a semicolon.

**Examples:**


| **Mathematical Notation** | **GMPL Code**         |
| --------------------------- | ----------------------- |
| ( x \in [0, \infty[ )     | `var x >= 0;`         |
| ( x \in [0, 8] )          | `var x >= 0, <= 8;`   |
| ( y \in {0,1} )           | `var y binary;`       |
| ( y \in \mathbb{Z} )      | `var y integer;`      |
| ( y \in \mathbb{N} )      | `var y integer >= 0;` |

---

### **Constraints**

Constraints follow the structure
`s.t. CNAME: LHS OP RHS;`
where **CNAME** is a descriptive constraint name, **LHS** and **RHS** are the left- and right-hand sides, and **OP** is one of `<=`, `>=`, or `=`.
The name itself has no computational meaning but helps make the model more readable and maintainable. Always include the colon after the name and the semicolon at the end.

**Examples:**


| **Mathematical Notation**              | **GMPL Code**                                         |
| ---------------------------------------- | ------------------------------------------------------- |
| ( x_1 + x_2 \le 10 )                   | `s.t. SumBound: x1 + x2 <= 10;`                       |
| ( y_1 + y_2 + y_3 + y_5 \ge 1 )        | `s.t. Stratovarius: y1 + y2 + y3 + y5 >= 1;`          |
| ( 1x_{KF} + 2x_{NF} + 1x_{HL} = 1000 ) | `s.t. UseUpAllTheWine: 1*xKF + 2*xNF + 1*xHL = 1000;` |

---

### **Objective Function**

The syntax is similar to constraints:
`[minimize | maximize] ONAME: EXPRESSION;`
where **ONAME** names the objective function, and **EXPRESSION** defines it.

**Examples:**


| **Mathematical Notation**                      | **GMPL Code**                                        |
| ------------------------------------------------ | ------------------------------------------------------ |
| ( y_1 + y_2 + y_3 + y_4 + y_5 \to \min )       | `minimize VisitedFestivals: y1 + y2 + y3 + y4 + y5;` |
| ( 110x_{KF} + 200x_{NF} + 120x_{HL} \to \max ) | `maximize TotalIncome: 110*xKF + 200*xNF + 120*xHL;` |

**Tip:**
If your model compiles correctly, intentionally introduce a few syntax errors and study the resulting compiler messages. They’re not always descriptive, but this is a great way to learn to recognize error patterns.

---

### **Using GLPK**

The examples below assume you run **glpsol** from the command line.

If you use **GUSEK** on Windows:

1. Always save your model with the `.mod` extension so the editor recognizes it as a GMPL file.
2. Before pressing **F5** or **Go**, enable “Generate output file on go” in the **Tools** menu.

The basic command to solve a model is:
`glpsol -m model.m -o output.txt`
This reads `model.m`, writes results to `output.txt`, and displays process info in the console.

Example output when running the sample model:

```text
bash$ glpsol -m helloworld.m -o output.txt
GLPSOL: GLPK LP/MIP Solver, v4.57
Parameter(s) specified in the command line:
 -m helloworld.m -o output.txt
Reading model section from helloworld.m...
helloworld.m:10: warning: unexpected end of file; missing end statement inserted
10 lines were read
Generating Constraint1...
Generating Constraint2...
Generating Objective...
Model has been successfully generated
GLPK Simplex Optimizer, v4.57
3 rows, 2 columns, 6 non-zeros
Preprocessing...
2 rows, 2 columns, 4 non-zeros
Scaling...
 A: min|aij| = 1.000e+00  max|aij| = 3.000e+00  ratio = 3.000e+00
Problem data seem to be well scaled
Constructing initial basis...
Size of triangular part is 2
*     0: obj =  -0.000000000e+00 inf =   0.000e+00 (2)
*     2: obj =   1.000000000e+01 inf =   0.000e+00 (0)
OPTIMAL LP SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (102269 bytes)
Writing basic solution to 'output.txt'...
bash$
```

The key line here is:
`OPTIMAL LP SOLUTION FOUND` — meaning the solver found an optimal solution.
For MILP models, it will read:
`INTEGER OPTIMAL SOLUTION FOUND.`

If you get messages indicating **no feasible solution** or **unbounded problem**, your model is likely over- or under-constrained, respectively.

---

### **Example Output File**

```text
Problem:    helloworld
Rows:       3
Columns:    2
Non-zeros:  6
Status:     OPTIMAL
Objective:  Objective = 10 (MAXimum)

   No.   Row name   St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 Constraint1  NU            15                          15           0.4 
     2 Constraint2  NU            20                          20           0.2 
     3 Objective    B             10                           

   No. Column name  St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 x            B              5             0             
     2 y            B              5             0             

Karush-Kuhn-Tucker optimality conditions:

KKT.PE: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.PB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.DE: max.abs.err = 0.00e+00 on column 0
        max.rel.err = 0.00e+00 on column 0
        High quality

KKT.DB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

End of output
```

The **Status: OPTIMAL** line confirms that everything ran successfully and the solver found an optimal solution.
The **Objective** value shows the optimal result (10 in this case).
To see *how* this result is achieved, check the **Activity** column in the second table — these are the optimal variable values. Here, both `x` and `y` equal 5.

---

### **Final Notes**

There are many ways to formulate (MI)LP models and many solvers capable of handling them.
**Gurobi** and **CPLEX** are the leading proprietary solvers, while **COIN-OR** offers the best open-source alternative.
For educational purposes, we use **GLPK** and the **GMPL** language due to their simplicity and accessibility.
As model complexity increases, we’ll continue exploring additional GMPL features to express more sophisticated problems effectively.
