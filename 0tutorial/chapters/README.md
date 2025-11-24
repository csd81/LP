

## 4.5 Indexing

At this point, we are able to completely separate the model logic and the problem data—at least for the case of systems of linear equations. However, one might argue that this did not actually help much. While the model section including all the constraints does not need to be touched, the parameter definition part of the model, and also their values in a data section, require even *more* code to be written. Modifying the problem data is still very complicated.

Not to mention that the number of variables and the number of equations cannot be altered solely by redefining parameters. A new variable or a new equation would require many additional parameters.

However, we can understand the logic behind systems of linear equations: we know the exact way a system with any number of variables and any number of equations can be implemented. The model formulation is redundant: model elements are defined very similarly, and much of the code can be copy-pasted. It seems the model implementation does not exploit the underlying logic of systems of linear equations.

First, let's try to express how the solution of a system of linear equations generally works:

1.  There are **variables**. The number of variables is not known. These are all reals with no bounds.
2.  There are **equations**. The number of equations is not known.
3.  All equations have a single **right-hand side value**. This means there exists a parameter for all equations that defines these RHS constants.
4.  All the equations have a **left-hand side** where we add all the variables up, each with a single **coefficient**, which is a parameter. This means there exists a parameter for all equations **AND** all variables that defines the coefficients. Note that here "AND" means for all pairs of equations and variables. That implies, if there are $n$ equations and $k$ variables, there are a total of $nk$ parameters.
5.  After the `solve` statement, we simply write a `printf` statement individually for all variables to print their values found by the solution algorithm.

You can see that the **"for all"** parts of the logic are where redundancy is introduced into the model file and the data section. The reason is that in these cases, code must be reused many times. We need a uniform way to tell the solver that we actually want to do many similar things at once. For example, to write `var` and `printf` statements for all variables in the system; `s.t.` statements and `param` statements denoting RHS constants for all equations in the system. Also, to define `param` statements for all equations and variables that describe the coefficients, and to appropriately implement each of these constraints that involve summing up a particular coefficient multiplied by the particular variable, for all variables.

In GNU MathProg, this can be achieved by **indexing expressions**, which also requires the concept of **sets**.

**Sets** contain many different elements (possibly zero, in which case we have an empty set). There are many ways sets can be defined in the language. Note that there are also literals that denote sets. For example, `1..10` denotes the set of integers from 1 to 10. However, in this example, we define our own sets with the **`set`** statement.

There are two sets needed in our model. One is for the variables, and one is for the equations:

```
set UnknownValues;
set Equations;
```

The set **`UnknownValues`** corresponds to the variables of the system of linear equations. In our previous example, they were $x, y, z, w,$ and $v$. The set **`Equations`** corresponds to the equations in the system; they were Eq1, Eq2, Eq3, Eq4, and Eq5.

We used the name `UnknownValues` to differentiate the variables of the system of linear equations to be solved (these are the "unknown values") from the variables defined in the GNU MathProg model by a `var` statement. These are in a one-to-one correspondence in this particular model: for each unknown value in the system of equations, there will be exactly one GNU MathProg model variable defined. Just remember that these are different concepts.

At this point, the contents of the sets are **not defined**. The reason is exactly the same as when parameters are only given values in the data section. The actual content of the sets is not part of the model logic, as the set of unknown values and equations may both vary. The procedure for assigning values to sets is the same as for parameters defined by the `param` statement. They can be given a value at definition or only afterward in a data section. In this case, we choose the latter.

Now, let us define the parameters in our model with the following code:

```ampl
param Rhs {e in Equations};
param Coef {e in Equations, u in UnknownValues};
```

This is the first time we use **indexing expressions**. They are denoted by the curly braces. In the first example, `Equations` is the set providing the possible indices for the parameter `Rhs`. The line literally means that we define a parameter named `Rhs` for all $e$, where $e$ is an element of the `Equations` set. This means that whatever the number of equations is, there is an individual parameter for each of these equations.

Note that we could also legally provide a value for the parameter `Rhs`, just as we did for the individual parameters before. We do not want that now, as the constants at the RHS are not part of the model logic; they are represented in the data section. Note that we have much more freedom regarding indexing expressions, which we won't discuss here; refer to the GNU MathProg language manual for the possibilities.

The parameter **`Coef`** is defined similarly, but there are **two indices** separated by a comma. This literally means that a parameter is defined for all $(e, u)$ ordered pairs, where $e$ is an equation and $u$ is an unknown value. In other words, we define a parameter for each element in the **Cartesian product** of the two sets. There can be many indices in an indexing expression; the maximum is currently 20. They always mean the same: the index set is obtained by all possible combinations of the individual indices. We also call the number of indices the **number of dimensions** of a set. The parameter `Rhs` has a one-dimensional index, while `Coef` has a two-dimensional index.

Now we can define the variables in the model:

```
var value {u in UnknownValues};
```

There is only one variable in this model, introducing the "unknown values" to be found in the system of linear equations. We define each model variable to be found, for each unknown value in the system of equations. The name of the model variable will be **`value`**.

Note that index names like $u$ for `UnknownValues` can be arbitrary each time we refer to the same set, but it is strongly recommended that they are consistent throughout the model section for readability purposes. Here we use $e$ for equations and $u$ for unknown values.

Also note that the variables fortunately have consistently no bounds; they all can take arbitrary real values.

Now that we have defined the required parameters and variables in the model, we can express the constraints:

```
s.t. Cts {e in Equations}:
   sum {u in UnknownValues} Coef[e,u] * value[u] = Rhs[e];
```

Now let's look at the parts of this implementation one by one. Whitespace characters, including newlines, are used for better readability. Note that this is a **single constraint statement** in GNU MathProg, named `Cts`, but due to the indexing, it will generate a **set of individual equations** in the model.

First, there must be exactly one constraint written for each equation in the system. This is established by the first indexing expression before the colon, **`e in Equations`**. This not only determines the number of equation constraints to be generated, but it also introduces $e$ as a constant that we can refer to in the definition part.

The **RHS** of the constraint is simpler, as it is the `Rhs` parameter itself. But here we can see how indexing works for parameters. When `Rhs` was defined, it was defined for all equations. That means, for example, if there are three equations in the system named Eq1, Eq2, and Eq3, then exactly one parameter is defined in the model for each of these. They can be referred to as `Rhs['Eq1']`, `Rhs['Eq2']`, and `Rhs['Eq3']`, respectively. Remember that these are three different parameters. However, we do not write something like `Rhs['Eq1']` in the model section because the exact equation name is not part of the model logic; it is rather arbitrarily given in a data section. Instead, we refer to **`Rhs[e]`**. Remember that $e$ denotes the current element of the `Equations` set we are writing a constraint for. The result is that in each constraint, the RHS is the `Rhs` parameter for the corresponding equation.

The **LHS** of the constraint is more complicated because it contains a summation of an undetermined number of terms. Note that the logic is that for each unknown value, we multiply the variable by the corresponding coefficient of the system, and these terms are added up. The **`sum` operator** does exactly this job for us. It involves an indexing expression, where we denote that we want to sum up terms for all unknown values $u$, and the term to be summed follows. The `sum` operator in GNU MathProg has lower precedence than multiplication, so there is no need to use parentheses. `Coef[e,u] * value[u]` is the term that is summed up for all $u$. Each of these terms refers to the variable of the corresponding unknown value $u$, which is `value[u]`. The term also refers to **`Coef[e,u]`**, which is the coefficient parameter for the equation $e$ and the unknown value $u$.

Note that inside the scope of the `sum` operator, the $u$ index is also available, just as $e$ is available inside the whole indexed constraint. However, $u$ would not be available outside the `sum`—for example, in the RHS. It would not even make sense because $u$ is introduced only to define the terms of the sum.

Now that we have a single `s.t.` constraint statement describing the model of systems of linear equations, the `solve` statement may come, after which we can print the values of the variables. Again, we do not know the exact set of variables, but indexing can be used to do something for all variables:

```
for {u in UnknownValues}
{
   printf "%s = %g\n", u, value[u];
}
```

The **`for` statement** requires an indexing expression and effectively repeats the statements written inside the block following it, throughout the given index set. Note that the statements allowed in a `for` block are limited, but they include `printf` and another `for`, which are enough for very complex tasks to be implemented simply. The `for` statement cannot be used to define model elements like parameters, variables, constraints, or the objective, but it is useful for displaying information.

Now, for each $u$ unknown value, we want to print out the corresponding value in the solution of the system of equations. Therefore, the `printf` statement refers to $u$ itself, the name of the variable of the system of equations, and its value, which is `value[u]`.

At this point, the model section is ready. This means any system of linear equations can be translated into a data section, and if done with the correct syntax, can be solved without altering the model file. Now, let us translate the previous problem instance into a well-formed data section.

```ampl

data;
set UnknownValues := x y z w v;
set Equations := Eq1 Eq2 Eq3 Eq4 Eq5;
```

The sets are assigned values here. That means the names of the unknown values and equations are given one by one. Note that in the data section, there is **no need for apostrophes**. If we wanted to hard-code a set definition into the model section, we would need apostrophes or quotation marks to denote string constraints.

One of the parameters that requires values to be given is the RHS constants.

```ampl
param Rhs :=
  Eq1 -5
  Eq2 -5
  Eq3 1.5
  Eq4 0
  Eq5 -0.5
  ;
```

There are multiple ways parameter data can be provided; refer to the GNU MathProg language manual for more details [1]. The simplest is shown here. The index and value pairs are simply enumerated, delimited by whitespace. One row for each pair is just a recommendation for readability. Note that here we must refer to the equation names we gave for the `Equations` set.

This similar format can also be applied if the index has more dimensions, as with `Coef`.

```ampl
param Coef :=
    Eq1 x 4
    Eq1 y -2
    Eq1 z 3
    Eq1 w 0
    Eq1 v 0
    Eq2 x 0
    Eq2 y 0
    Eq2 z -1
    Eq2 w -1
    Eq2 v 0
    Eq3 x 0
    Eq3 y 1
    Eq3 z 1
    Eq3 w 0
    Eq3 v 0
    Eq4 x 4
    Eq4 y -7
    Eq4 z 0
    Eq4 w 2
    Eq4 v 5
    Eq5 x 1
    Eq5 y 0
    Eq5 z 2
    Eq5 w 0
    Eq5 v 3
    ;
```

The scheme is the same. Pairs of indices and their corresponding values are enumerated. However, each such pair now actually consists of three elements, because the first part of the index is for the equation and the second is for the unknown variable. Again, here we must refer to the names we provided in the set definitions in the data block.

And now we are ready. The model section has attained its most general form. From now on, the solution of any system of linear equations can be done solely by writing a well-formed data section. This data section may come after the model section in the model file itself, or, more practically, it can be put in a separate file. Typically, each problem instance (in this case, each system of linear equations to be solved) can be implemented in a single data file containing the data section.

The complete model file and one possible data section are shown below. The solution is again exactly the same as before: $x = 2$, $y = 3.5$, $z = -2$, $w = 7$, and $v = 0.5$.

```
set UnknownValues;
set Equations;

param Rhs {e in Equations};
param Coef {e in Equations, u in UnknownValues};

var value {u in UnknownValues};

s.t. ImplementingEquations {e in Equations}:
   sum {u in UnknownValues} Coef[e,u] * value[u] = Rhs[e];

solve;

for {u in UnknownValues}
{
   printf "%s = %g\n", u, value[u];
}

end;
```

```
data;

set UnknownValues := x y z w v;
set Equations := Eq1 Eq2 Eq3 Eq4 Eq5;

param Rhs :=
    Eq1 -5
    Eq2 -5
    Eq3 1.5
    Eq4 0
    Eq5 -0.5
    ;

param Coef :=
    Eq1 x 4
    Eq1 y -2
    Eq1 z 3
    Eq1 w 0
    Eq1 v 0
    Eq2 x 0
    Eq2 y 0
    Eq2 z -1
    Eq2 w -1
    Eq2 v 0
    Eq3 x 0
    Eq3 y 1
    Eq3 z 1
    Eq3 w 0
    Eq3 v 0
    Eq4 x 4
    Eq4 y -7
    Eq4 z 0
    Eq4 w 2
    Eq4 v 5
    Eq5 x 1
    Eq5 y 0
    Eq5 z 2
    Eq5 w 0
    Eq5 v 3
    ;

end;
```

-----

## 4.6 Other Options for Data

Although we now have a single model file suitable for all possible systems of linear equations regardless of variable and equation count, there are other tricks in GNU MathProg that further help us by allowing shorter and/or more readable implementation of data sections. Two of these options are presented here: **default values** and **matrix data format**. A common modeling error, the **out of domain error**, is also demonstrated here.

We have already mentioned that parameters (and also sets) used in the model need a value to be provided. This value is either calculated on the spot or not given in the model at all so that it can be provided separately in a data section. If a parameter has a calculated value hard-coded in the model, then providing data for it is forbidden, but if it is not hard-coded, there must be a value in the data sections.

However, we see that many of the coefficients in the system of linear equations can be zero. This is actually a kind of default behavior: an equation might only refer to a subset of the variables. If an equation does not refer to a variable, then it still has a zero coefficient due to the modeling logic. But we do not want to provide these zero parameters for all variables each time we write a new equation. Instead, we want to only provide those parameter values that are **different from this default zero**.

This can be achieved by indicating a **default value** for a given parameter in the model section. In this case, the model parameter does not have a hard-coded calculated value but a given default value instead. If there is a value provided in a data section, that value is used. If no value is provided, then the default value is used. Note that default values can also be given for sets. However, they cannot be given for variables, as variables are determined by the optimization procedure, so it does not make sense to provide default values for them.

To add a default value to a parameter, we must do the following:

```
param Coef {e in Equations, u in UnknownValues}, default 0;
```

Note that the default value in this example is zero, but in general, it could be any expression that can be calculated on the spot. For instance, it can depend on $e$ and $u$, the indices of the parameter.

After the default value of zero is given for `Coef`, all entries in the data section that indicate a value of zero can be omitted, significantly trimming the size of the data section.

```
param Coef :=
    Eq1 x 4
    Eq1 y -2
    Eq1 z 3
    Eq2 z -1
    Eq2 w -1
    Eq3 y 1
    Eq3 z 1
    Eq4 x 4
    Eq4 y -7
    Eq4 w 2
    Eq4 v 5
    Eq5 x 1
    Eq5 z 2
    Eq5 v 3
    ;
```

Note that, while maintaining the code of this data section, care must be taken when adding a new index to a parameter data set, as it may already be there. Duplicate indices are forbidden in the data section, as common sense dictates.

Another trick that may help in designing shorter and more readable data sections is the **matrix data format**. It works in many situations where two-dimensional data must be provided—like in this case. Values for parameter `Coef` can be implemented in matrix format in the following way:

```
param Coef: 
      x  y  z  w  v :=
  Eq1 4 -2  3  .  .
  Eq2 .  . -1 -1  .
  Eq3 .  1  1  .  .
  Eq4 4 -7  .  2  5
  Eq5 1  .  2  .  3
  ;
```

Note that the colon (`:`) and the assignment operator (`:=`) denote the matrix data format; whitespace indentation is optional. It is recommended for readability that the data is indented similarly to the way shown. The rows of the matrix correspond to the values of the first index, while the columns correspond to the second index. Each entry in the matrix gives a value for the parameter identified by the row and the column.

Note that in such a matrix, we do not have to mention all possible rows and columns. Those parameter indices for which we do not give a value will be defaulted. Also, using the period character (`.`) instead of a value in the matrix makes that particular value be defaulted.

If one wants to refer to the first indices by the columns and the second indices by the rows, it is also possible: it is called the **transposed matrix format**, and it is simply obtained by inserting `(tr)` before the colon.

There are more advanced data description formats in GNU MathProg, which are not mentioned here. For example, it is possible to give multi-dimensional data by describing several different matrices one after another.

An important issue about indexing is the **out of domain error**. For all parameters and variables that are indexed, there is a well-described index set. If at any time, a parameter or variable is referred to with an index that is **not** in its defined index set, then—not surprisingly—an error occurs.

Let us demonstrate this by changing the $u$ and $e$ indices in the constraint where the `Coef` parameter is indexed. The following message is obtained, and the model cannot be processed:

```
Generating Cts...
eqsystem-indexing-matrix-ERROR-outofdomain.mod:10: Coef[x,Eq1] out of domain
MathProg model processing error
```

This is an error because the correct indexing would be `Coef[Eq1,x]`, not `Coef[x,Eq1]`. The latter is not a valid index for parameter `Coef`, because $x$ is not in the set `Equations` and Eq1 is not in the set `UnknownValues`. The same error message may be reported if we do not use the indices properly in the data section.

This example suggests an important source of error: **indexing must be done properly**. In this case, the "out of domain" error is raised, and the mistake could be corrected easily. However, the situation can be much worse; for example, if a wrong indexing would actually mean a valid index in the index set. In that case, the error remains unnoticed, and the wrong model is solved. This is especially dangerous if the two indices are from the same set, as they can be switched by mistake. For example, in a directed graph of vertices A, B, and C, the arc AB is different from BA, but both describe an arc and are valid if implemented in GNU MathProg.

In our example, the two indices are from two different sets, so it is unlikely that a wrong indexing is not reported. However, it may be the case if the two sets have common elements. For example, if both the variables are labeled from 1 to 5, and all the equations are labeled also from 1 to 5, there is nothing that forbids this. The correspondingly edited data section is the following:

```
data;

set UnknownValues := 1 2 3 4 5;
set Equations := 1 2 3 4 5;

param Rhs :=
    1 -5
    2 -5
    3 1.5
    4 0
    5 -0.5
    ;

param Coef: 
     1  2  3  4  5 :=
  1  4 -2  3  .  .
  2  .  . -1 -1  .
  3  .  1  1  .  .
  4  4 -7  .  2  5
  5  1  .  2  .  3
  ;

end;
```

Now, if this is the data section, and it is paired with the wrongly indexed model section we presented before, there are **no out of domain errors**, as all wrong indices are actually valid. So a wrong model is solved now, which has a substantially different result than the original: $4.8$, $-20.6$, $-67.5$, $-10.3$, and $17$. Remember that the original result was $2, 3.5, -2, 7, 0.5$. Conclusion: always pay special care for indexing, use meaningful and unique names even in the data sections, and always validate the result of the model solution.

A valid question arises: what was the problem that the wrongly indexed model had solved? We leave it up to the reader, with a small hint: if the two indices are switched, then we effectively **transpose the data matrix**.

-----

## 4.7 General Columns

We have seen some capabilities of the GNU MathProg language with which we can make compact and more readable data sections. Now we will show how the already available techniques can be utilized to further decrease the redundancy in a data section.

There is still a bit of redundancy in the rows of the equations. The RHS of the equations is provided as a separate parameter where all the equation names must appear. The coefficient matrix for the system of equations is described by another parameter, now in matrix format, but the rows must start with the equation names again. It would be nice if these two kinds of data could appear in a single data matrix.

We can easily solve this in GNU MathProg. Now, a common **`EqConstants`** parameter is introduced which works as follows. Its indices are the **columns of the problem in general**. Each column can correspond to a variable (unknown value) in the system of equations, or the RHS of the equation. We can implement this with the following code:

```
set UnknownValues;
set Equations;

set Columns := UnknownValues union {'RHS'};

param EqConstants {e in Equations, u in Columns}, default 0;
```

Note that `Columns` is a set just like `UnknownValues` and `Equations`. However, this set is not provided by a data section but instead calculated on the spot. `Columns` is the set `UnknownValues`, with the string `'RHS'` added to it.

```
var value {u in UnknownValues};

s.t. ImplementingEquations {e in Equations}:
   sum {u in UnknownValues} EqConstants[e,u] * value[u]
   = EqConstants[e,'RHS'];
```

The rest of the model is basically the same, but instead of the `Rhs` parameter, we refer to the **`EqConstants`** parameter with either the index of an unknown value $u$ to access the coefficients, or the string `'RHS'` to access the RHS constant in the given equation.

The data section is the following. The only parameter is `EqConstants`. Note that the solution shall be exactly the same as before; the modifications only affected the format of the data section, but the data content remained the same.

```
data;

set UnknownValues := x y z w v;
set Equations := Eq1 Eq2 Eq3 Eq4 Eq5;

param EqConstants: 
      x  y  z  w  v  RHS :=
  Eq1 4 -2  3  .  .  -5
  Eq2 .  . -1 -1  .  -5
  Eq3 .  1  1  .  .   1.5
  Eq4 4 -7  .  2  5   0
  Eq5 1  .  2  .  3  -0.5
  ;

end;
```

Note that this implementation does not work in one extreme situation: where one of the unknown values is named `'RHS'`. In that case, it becomes interchangeable with the string `'RHS'` denoting the right-hand side column instead of ordinary variables in the system. So, for this model, the usage of the keyword `'RHS'` is forbidden for unknown values in the data section. But this restriction is a fair trade for the more compact data section we get in return.

We can make our model foolproof by establishing this rule with a **`check` statement**. It works like an assertion: a logical expression is evaluated, and if the result is false, the model generation is aborted.

In this example, we state that `UnknownValues` shall not contain the string `'RHS'`. In other words, no variables in the system of equations shall be named `RHS`. The statement is best positioned soon after the definition of the `UnknownValues` set.

```
check 'RHS' !in UnknownValues;
```

Note that the `check` statement can also be indexed, which is an effective way of testing multiple logical statements at once.

The evaluation of a `check` statement is also reported in the output generated by `glpsol` as follows:

```
Checking (line 4)...
```

Checking is used to rule out wrong data by reporting it. Identifying bugs caused by unreported data errors can be substantially more difficult.

-----

## 4.8 Minimizing Error

After implementing a model for arbitrary systems of linear equations, let us consider a slightly different problem: solving a system of equations **"as well as we can."**

Although we do not focus on mathematical proofs here, it is worth mentioning that a system of linear equations may have 0, 1, or infinitely many different solutions. This is related to the number of variables and equations in the system in the following way. Note these rules are not general, as there are important exceptions that can be precisely characterized, but they are typical if the coefficients and RHS values in the equations are random or unrelated:

  * **Infinitely many solutions** is the typical case when there are **fewer equations than variables**.
  * A **unique solution** is typically caused by having the **same number of equations and variables**. Note that this was the case in all of the previous examples in this section.
  * If there are **more equations than variables**, the system is **overspecified**, and the resulting problem is usually **infeasible**. This can be demonstrated as follows.

**Problem 6.**

Append a sixth equation, $x + y + z + w + v = 0$, to Problem 5 and solve it.

Now that we have the complete model, Problem 6 can be implemented in a single data section. A new element, `Eq6`, is added to the set `Equations`, and the corresponding RHS and coefficients are also introduced. Note that the original model and data section format is used, where parameters `Rhs` and `Coef` are not merged.

```
data;

set UnknownValues := x y z w v;
set Equations := Eq1 Eq2 Eq3 Eq4 Eq5 Eq6;

param Rhs :=
    Eq1 -5
    Eq2 -5
    Eq3 1.5
    Eq4 0
    Eq5 -0.5
    Eq6 0
    ;

param Coef: 
      x  y  z  w  v :=
  Eq1 4 -2  3  .  .
  Eq2 .  . -1 -1  .
  Eq3 .  1  1  .  .
  Eq4 4 -7  .  2  5
  Eq5 1  .  2  .  3
  Eq6 1  1  1  1  1
  ;

end;
```

We already know the original solution for Problem 5 with the system of just the first five equations: $x = 2$, $y = 3.5$, $z = -2$, $w = 7$, and $v = 0.5$. This literally means that the first five equations imply that the sum $x+y+z+w+v$ equals $2 + 3.5 + (-2) + 7 + 0.5 = 11$. The result, $11$, contradicts the sixth equation, $x + y + z + w + v = 0$, in Problem 6. In short, if the first five equations hold true, the sixth cannot. Not surprisingly, the overspecified model turns out to be **infeasible**.

Here is the solver output:

```
GLPSOL: GLPK LP/MIP Solver, v4.65
Parameter(s) specified in the command line:
-m eqsystem-original.mod -d eqsystem-overspecified.dat --log
→ eqsystem-overspecified-original.log
Reading model section from eqsystem-original.mod...
21 lines were read
Reading data section from eqsystem-overspecified.dat...
30 lines were read
Generating Cts...
Model has been successfully generated
GLPK Simplex Optimizer, v4.65
6 rows, 5 columns, 19 non-zeros
Preprocessing...
6 rows, 5 columns, 19 non-zeros
Scaling...
A: min|aij| = 1.000e+00 max|aij| = 7.000e+00 ratio = 7.000e+00
Problem data seem to be well scaled
Constructing initial basis...
Size of triangular part is 4
0: obj = 0.000000000e+00 inf = 8.500e+00 (2)
1: obj = 0.000000000e+00 inf = 3.667e+00 (1)
LP HAS NO PRIMAL FEASIBLE SOLUTION
glp_simplex: unable to recover undefined or non-optimal solution
Time used: 0.0 secs
Memory used: 0.1 Mb (118495 bytes)
```

However, there is still an interesting question when faced with an overspecified system of equations: Instead of finding a perfect solution, can we find a solution for which the error in the equations is kept **minimal**? More precisely, the **maximum of the errors**.

**Problem 7.**

Given a system of linear equations, find a solution that minimizes the maximum error across all equations. The error for a specific equation is defined as the absolute value of the difference between the Left-Hand Side (LHS) and the Right-Hand Side (RHS).

(The LHS of the equation consists of the sum of the variables multiplied by their coefficients, while the RHS is a constant. Use the same data description method as before.)

This is no longer a feasibility problem. To be precise, all possible variable values now provide a feasible solution; strictly speaking, the objective value (maximum error) simply varies between solutions. Therefore, this is an optimization problem.

Solving this efficiently requires a modeling trick: minimizing the maximum objective. This can be considered a "design pattern" in mathematical programming.

The first part of this concept involves introducing the objective—the maximum error itself—into the model as an individual variable, as follows:

```
var maxError;

minimize maxOfAllErrors: maxError;
```

At this point, the objective is simply an independent variable that can be set freely. Our goal is to find a way to enforce this `maxError` variable to effectively represent the maximum error of the equations.

Suppose that $L$ and $R$ are the left-hand side and right-hand side values of an equation for certain variable values. Ideally, $L = R$, and the error is zero. Otherwise, the error is $|L - R|$, which is not a linear function of the variables. Even if it were, finding the maximum of these values would still be problematic because the "maximum" function itself is not linear.

This leads to our second idea. Instead of representing the errors themselves in the model, we use an upper bound for the error. Suppose that $E$ is a valid upper bound for the error between $L$ and $R$, meaning $|L - R| \le E$. This can now be expressed as linear constraints as follows:

```
L - R <= E
L - R >= -E           (11)
```

Note that $E$ must be nonnegative, as the errors themselves are nonnegative. Alternatively, we could state $R - E \le L \le R + E$. In any case, these represent two linear inequalities.

Now, what would be a good candidate for an upper bound on the error in any equation? Naturally, the maximum of the errors, which is denoted by `maxError`. Therefore, we define two constraints so that the two sides of the equations differ at most by the value of `maxError`.

```
s.t. Cts_Error_Up {e in Equations}:
  sum {u in UnknownValues} Coef[e,u] * value[u]
  <= Rhs[e] + maxError;

s.t. Cts_Error_Down {e in Equations}:
  sum {u in UnknownValues} Coef[e,u] * value[u]
  >= Rhs[e] - maxError;
```

This is achieved by duplicating the original constraint and including `maxError`. The constraints must have unique names; here, `Cts_Error_Up` and `Cts_Error_Down` were chosen.

Surprisingly, our model is complete. Let us now try to understand what happens when it is solved.
Due to the constraints, `maxError` is forced to act as a valid upper bound for the errors of all equations simultaneously. Meanwhile, `maxError` is an objective to be minimized. Consequently, these factors combined will effectively find the smallest possible `maxError` value for which all equations can be satisfied.

Below is the full model section, with some `printf` statements added to provide meaningful output.

```
set UnknownValues;
set Equations;

param Rhs {e in Equations};
param Coef {e in Equations, u in UnknownValues}, default 0;

var value {u in UnknownValues};
var maxError;

s.t. Cts_Error_Up {e in Equations}:
  sum {u in UnknownValues} Coef[e,u] * value[u]
  <= Rhs[e] + maxError;

s.t. Cts_Error_Down {e in Equations}:
  sum {u in UnknownValues} Coef[e,u] * value[u]
  >= Rhs[e] - maxError;

minimize maxOfAllErrors: maxError;

solve;

printf "Optimal error: %g\n", maxError;
printf "Variables:\n";
for {u in UnknownValues}
{
  printf "%s = %g\n", u, value[u];
}

printf "Equations:\n";
for {e in Equations}
{
  printf "%5s: RHS=%10f, actual=%10f, error=%10f\n",
  e, Rhs[e],
  sum {u in UnknownValues} Coef[e,u] * value[u],
  abs(sum {u in UnknownValues} Coef[e,u] * value[u] - Rhs[e]);
}
end;
```

If we solve it, we get the following results:

```
Optimal error: 0.478261
Variables:
x = -3.42029
y = -1.21884
z = 2.24058
w = 3.23768
v = -0.36087
Equations:
  Eq1: RHS= -5.000000, LHS= -4.521739, error= 0.478261
  Eq2: RHS= -5.000000, LHS= -5.478261, error= 0.478261
  Eq3: RHS=  1.500000, LHS=  1.021739, error= 0.478261
  Eq4: RHS=  0.000000, LHS= -0.478261, error= 0.478261
  Eq5: RHS= -0.500000, LHS= -0.021739, error= 0.478261
  Eq6: RHS=  0.000000, LHS=  0.478261, error= 0.478261
```

If we manually investigate the results, we can verify that all the variables are multiples of $1/690$; they are not trivial values.

It is interesting to note that the error is the same for all six equations. Perhaps this is a general rule when the number of equations is one greater than the number of variables? This leads to another mathematical problem.

## 4.9 Equation Systems – Summary

We have learned the basic skills in GNU MathProg required to implement linear mathematical models: using parameters, separating the model and data sections, and, most importantly, indexing expressions. We also solved a simple yet non-trivial optimization problem regarding minimizing errors in equations.

Note that the coding effort was minimal in GNU MathProg—and mathematical programming in general—compared to solution algorithms we would otherwise have to implement ourselves.

From now on, it is recommended that for each subsequent optimization problem, you implement a single general model file containing the model section but no problem data. Each problem instance for which the model needs to be solved can be implemented in a separate data file containing the entire data section. Therefore, there should be as many data files as there are problem instances.
-----

# Chapter 5: Production Problem

This chapter explores a **fundamental Linear Programming (LP) problem** in terms of model implementation: the **production problem**. This problem involves determining which products to manufacture to achieve the **maximum profit** when resources are limited. It is also referred to as the **product mix problem** or **production planning problem**.

The production problem is one of the oldest problems in **Operations Research**, and numerous tutorials use it as an introduction to mathematical programming (see, for example, [11, 12]). We will also present the **diet problem**, which seeks to find the least expensive combination of foods that meets all nutritional requirements. A common generalization of these two problems is also shown. The final section includes an overview of **integer programming**, where "packages" of raw materials and products can be bought and sold all at once.

The chapter focuses on how a single model can be extended to incorporate various circumstances one by one. We begin with a simple exercise that can even be solved manually and conclude with a very general and complex optimization model.

-----

## 5.1 Basic Production Problem

The simplest version of the production problem can be generally described as follows.

**Problem 8.**

Given a set of **products** and a set of **raw materials** needed for their production. Production is linear and can occur in any amount, with fixed **consumption rates** of raw materials: we know exactly how much of each raw material is consumed to produce **one unit** of each product. We have a fixed amount of each raw material available and a fixed unit revenue for each product.

**Determine the optimal amounts of all products to be manufactured** such that the consumption of each raw material does not exceed its availability, and the **total revenue** from all products is maximized.

This definition might be a little challenging to grasp. It primarily outlines the **model logic** and will be implemented in a model file. Let's look at a specific example of the production problem with supporting data.

**Problem 9.**

We have a manufacturing plant capable of producing three different products, named **P1, P2, and P3**. Four raw materials are required for production, named **A, B, C, and D**. We have precise data for the following:

  * Amount of each raw material required for producing 1 unit of each product.
  * Available amount of each raw material that can be used for production.
  * Revenue for 1 unit of each product.

This information can be viewed in a single table, as shown below.

| | **P1** | **P2** | **P3** | **Available** |
| :--- | :--- | :--- | :--- | :--- |
| **A** (electricity) | 200 kWh | 50 kWh | 0 kWh | 23000 kWh |
| **B** (working time) | 25 h | 180 h | 75 h | 31000 h |
| **C** (materials) | 3200 kg | 1000 kg | 4500 kg | 450000 kg |
| **D** (production quota) | 1 | 1 | 1 | 200 |
| **Revenue (per unit)** | **$252** | **$89** | **$139** | |

Note that any amount of each product can be produced, and the raw material requirements are **exactly proportional**. There is no other limitation than the **total availability** of each raw material. Amounts can also be fractional.

**Determine the optimal amount of P1, P2, and P3 to be produced** such that raw material availability is respected, and the total revenue from the products is maximized.

(Note that problem data are entirely fictional.)

Compared to "pure mathematical" models like the system of linear equations we saw previously, the problem data here includes **units**. However, **GNU MathProg** does not have a built-in feature to track the quantities or currencies of model elements (variables, parameters, constraints). We must work only with **scalars**. The general approach for handling units is to convert all data corresponding to the same quantity to the **same unit** and treat them consistently throughout the model. This must always be kept in mind during model formulation.

However, understanding the units in the problem is recommended because it helps us avoid mistakes by reminding us that **only scalars of the same unit should ever be added together**. For example, amounts in kWh and kg cannot be added. If adding them appears necessary, it means either the operation is wrong entirely, or we are missing one or more factors that would bring these quantities to the same dimension and unit.

Let's begin formulating the model. The first step is selecting the **decision variables**. The goal of optimization is to determine the values of these variables. Each solution obtained describes a decision on how the plant will be operated. Of course, not all solutions are feasible, and the revenues are also usually different. Therefore, we seek the **feasible solution with the highest revenue**.

The decision variables can be read directly from the problem description. The **amounts of each product to be determined** are the decision variables; these must definitely be determined by the optimization. The question is, should there be more variables? If we only know the amounts produced, we can calculate everything relevant in the plant: the exact amounts consumed of each raw material and the total revenue. Therefore, at this point, we do not need any more variables in our optimization model.

The **objective function** is easy to determine. The production amount of each product must be multiplied by its **unit revenue**, and the total revenue is the sum of these products.

What remains are the **constraints** and **variable bounds**. In general, the only requirement is that production can be zero or a positive number, but it definitely **cannot be negative**. So, each variable must be **nonnegative**; this is a **lower bound**. There is no upper bound, as any production amount is considered feasible as long as there is sufficient raw material for it. This brings us to the **only constraint**, which is about **raw material availability**. Based on the amounts produced (which are denoted by the variables), we can easily calculate how much of each raw material is used per product and in total. This total usage must not be greater than the availability of that particular raw material.

We have defined the variables, the objective, constraints, and bounds, so we are ready to implement our model in **GNU MathProg**. First, we will not use indexing and will implement it in the most straightforward way.

The variables denote production amounts. By convention, these are all in **dollars ($)**.

```
var P1, >=0;
var P2, >=0;
var P3, >=0;
```

Constraints are formulated next. For each production amount, it must be multiplied by the coefficient that describes **raw material consumption per product unit**. These must be summed for all three products to obtain the total consumption for a given raw material.

Note how the tabular data of the problem correspond to the implementation of constraints.

```
s.t. Raw_material_A:  200 * P1 +   50 * P2 +    0 * P3 <= 23000;
s.t. Raw_material_B:   25 * P1 +  180 * P2 +   75 * P3 <= 31000;
s.t. Raw_material_C: 3200 * P1 + 1000 * P2 + 4500 * P3 <= 450000;
s.t. Raw_material_D:    1 * P1 +    1 * P2 +    1 * P3 <= 200;
```

Finally, the objective can also be defined based on production amounts. Note that each constraint is within its own unit for the raw material, and the objective is in the **$** unit. From now on, we use units consistently and will not refer to them.

```
maximize Raw_material: 252 * P1 + 89 * P2 + 139 * P3;
```

A `solve` statement can be inserted in the model, after which some additional post-processing work can be done to print the solution. The full code is below. We print the total revenue (the objective), the production of each product (the variables), and the usage of each raw material. In the usage part, we print both the total amount consumed for production and the amount remaining available.

```
var P1, >=0;
var P2, >=0;
var P3, >=0;

s.t. Raw_material_A:   200 * P1 +   50 * P2 +    0 * P3 <= 23000;
s.t. Raw_material_B:    25 * P1 +  180 * P2 +   75 * P3 <= 31000;
s.t. Raw_material_C:  3200 * P1 + 1000 * P2 + 4500 * P3 <= 450000;
s.t. Raw_material_D:     1 * P1 +    1 * P2 +    1 * P3 <= 200;

maximize Raw_material: 252 * P1 +   89 * P2 +  139 * P3;

solve;

printf "Total Revenue: %g\n", ( 252 * P1 + 89 * P2 + 139 * P3);

printf "Production of P1: %g\n", P1;
printf "Production of P2: %g\n", P2;
printf "Production of P3: %g\n", P3;

printf "Usage of A: %g, remaining: %g\n",
            ( 200 * P1 + 50 * P2 + 0 * P3),
    23000 - ( 200 * P1 + 50 * P2 + 0 * P3);

printf "Usage of B: %g, remaining: %g\n",
            ( 25 * P1 + 180 * P2 + 75 * P3),
    31000 - ( 25 * P1 + 180 * P2 + 75 * P3);

printf "Usage of C: %g, remaining: %g\n",
             (3200 * P1 + 1000 * P2 + 4500 * P3),
    450000 - (3200 * P1 + 1000 * P2 + 4500 * P3);

printf "Usage of D: %g, remaining: %g\n",
            ( 1 * P1 + 1 * P2 + 1 * P3),
      200 - ( 1 * P1 + 1 * P2 + 1 * P3);
end;
```

In this model file, there is **no data section at all**; the data is **hard-coded** into the model. Therefore, we can solve it with `glpsol` without providing any additional data files, yielding the following result (showing only our `printf` results).

```
Total Revenue: 33389
Production of P1: 91.3386
Production of P2: 94.6457
Production of P3: 14.0157
Usage of A: 23000, remaining: -3.63798e-12
Usage of B: 20370.9, remaining: 10629.1
Usage of C: 450000, remaining: -5.82077e-11
Usage of D: 200, remaining: 0
```

We interpret the solutions as follows: **$33,389** is the **maximum revenue** that can be obtained. To achieve this, we produce **91.34 units of P1**, **94.65 units of P2**, and **14.02 units of P3**. Note that, in this case, it is allowed to produce **fractional amounts** of a product—this can occur in practice if the products and raw materials are chemicals, fluids, heat, electricity, or other divisible quantities.

Production consumes **all of A, C, and D**, but there is a **surplus of B** that is not used up. Some remaining amounts are reported as extremely small positive numbers. These are actually tiny **numerical errors** from the actual value of zero in the optimal solution because `glpsol` uses floating-point arithmetic, which isn't perfect. If this output is inconvenient, we can use the format specifier `%f` instead of `%g`, or alternatively, explicitly round down the numbers to be printed in the model using the built-in `floor()` function.

Another option is to add `--xcheck` as a command-line argument to `glpsol`. This forces the final solution to be recalculated with **exact arithmetic**, eliminating rounding errors.

```
glpsol -m model.mod -d data.dat --xcheck
```

One interesting observation about the solution is that **three of the remaining amounts are zero**. If we varied the problem data and solved the model repeatedly, it would turn out that, from the seven values printed (three production amounts and four remaining amounts), there are almost always **three zeroes**. Generally, the number of zeroes is the number of products, and the number of non-zeroes is the number of raw materials. (Exceptions occur in some special cases.) This is a beautiful property of production problems that is better understood by knowing how the solution algorithms (particularly the **simplex method**) work for LP problems. However, we are not focusing on the algorithms here, only the model implementations. Nevertheless, understanding what a good solution looks like is a very valuable skill.

We now have a working implementation for the specific production problem described. However, we know this solution is not very general. If we encounter a different production problem, we must understand and **tamper with the code** describing the model logic. Also, notice that the exact expressions describing the total consumption of each raw material appear **three times**: once in the constraints and twice in the post-processing work. This level of **redundancy** is typically considered bad code design, regardless of the programming language.

Our next task is to create a more general, **indexed model** that requires only a properly formatted data section to solve any production problem.

In the production problem, two sets are relevant: the set of **products** and the set of **raw materials**.

```
set Products;
set Raw_Materials;
```

We can also identify three important **parameters**. One for the production ratios, defined for each pair of raw materials and products; we'll call it `Consumption_Rate`. One for availability, defined for each raw material; we name it `Storage`. The name "storage" captures the logic of how raw materials work from a modeling perspective: they are present in a given amount beforehand, like physically stored material, and no more than this amount can be used for production. Another parameter is `Revenue`, defined for each product.

```
param Storage {r in Raw_Materials}, >=0;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;
```

Notice how **indexing** is used so that each `param` statement refers not just to a single scalar but to a **collection of values**. For `Consumption_Rate` and `Revenue`, we also provide a default value of **zero**. This means if we do not provide data, we assume no raw material need or revenue for that particular case.

Also, in GNU MathProg, we can define **bounds and other value restrictions for parameters**. In this case, all three parameters are forced to be **nonnegative** by the `>=0` restriction. This is generally good practice if we do not expect specific values for a given parameter. If a restriction is violated by a value provided for the parameter (for example, in the data section or calculated on the spot), model processing terminates with an error describing the situation. It's much easier to notice and correct errors this way than to allow a wrong parameter value in the model, which could lead to an invalid solution. It is typically difficult to debug a model once it can be processed, so explicitly checking data is highly recommended.

The variables can now be defined. They denote production amounts, and each must be nonnegative.

```
var production {p in Products}, >=0;
```

Finally, all the constraints can be described by one general `s.t.` statement. The logic is as follows: There is a single inequality for each raw material: its **total consumption cannot exceed its availability**. The availability is simply described as a parameter, but the total consumption is obtained by a **summation**. We must sum, for each product, its amount multiplied by the consumption rate of that particular raw material.

```
s.t. Material_Balance {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p]
    <= Storage[r];
```

The objective is obtained as a **sum** for all products, where the amounts must be multiplied by the unit revenues.

```
maximize Total_Revenue:
    sum {p in Products} Revenue[p] * production[p];
```

Finally, we can implement a general post-processing routine to print the total revenue, production amounts, and raw material usages. The full model file is below.

```
set Products;
set Raw_Materials;

param Storage {r in Raw_Materials}, >=0;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;

var production {p in Products}, >=0;

s.t. Material_Balance {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p]
    <= Storage[r];

maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];

solve;

printf "Total Revenue: %g\n", sum {p in Products} Revenue[p] * production[p];

for {p in Products}
{
    printf "Production of %s: %g\n", p, production[p];
}

for {r in Raw_Materials}
{
  printf "Usage of %s: %g, remaining: %g\n",
      r, sum {p in Products} Consumption_Rate[r,p] * production[p],
      Storage[r] - sum {p in Products} Consumption_Rate[r,p] * production[p];
}
end;
```

If the corresponding data file is implemented as follows, we should get the same result as with the straightforward implementation.

```
data;
set Products := P1 P2 P3;
set Raw_Materials := A B C D;

param Storage :=
  A 23000
  B 31000
  C 450000
  D 200
  ;

param Consumption_Rate:
      P1   P2   P3 :=
  A  200   50    0
  B   25  180   75
  C 3200 1000 4500
  D    1    1    1
;

param Revenue :=
  P1 252
  P2 89
  P3 139
  ;
end;
```

Although the model is very general and compact, it still contains some **redundancy**. The total consumed amount of each raw material is still represented three times in the code. At least we don't have to rewrite that code ever again if another problem's data is given; we only have to modify the data section. However, we still want to eliminate this redundancy.

Remember that we can introduce parameters in the model section and calculate values on the spot. If we are after the `solve` statement, then even variable values can be referred to, as their values have already been determined by the solver. We introduce `Material_Consumed` and `Material_Remained` to denote the total amount consumed and the amount remaining for each material.

```
param Material_Consumed {r in Raw_Materials} :=
    sum {p in Products} Consumption_Rate[r,p] * production[p];

param Material_Remained {r in Raw_Materials} :=
    Storage[r] - Material_Consumed[r];

for {p in Products}
{
    printf "Production of %s: %g\n", p, production[p];
}

for {r in Raw_Materials}
{
    printf "Usage of %s: %g, remaining: %g\n",
    r, Material_Consumed[r], Material_Remained[r];
}
```

The solution should be exactly the same as before for the same data file. But now, some of the redundancy has been eliminated from the model section. Unfortunately, the parameter for the total amounts consumed **cannot be used** in the constraints where it appears first. More on that later.

-----

## 5.2 Introducing Limits

Now that we have a working implementation for arbitrary production problems, let's change the problem description itself.

**Problem 10.**

Solve the **production problem**, provided that for each **raw material** and each **product**, a **minimum** and **maximum** total **usage** is also given that must be respected by the solution.

The usage of a raw material is the total amount consumed, and the usage of a product is the total amount produced.

These are **additional restrictions** on the production mix. Let's see how this affects the model formulation. The problem remains almost the same; we just need to exclude additional solutions from the **feasible set**—namely, those where any newly introduced restriction is violated.

The change only added new restrictions, so the **variables**, the **objective function**, and even the existing **constraints** and **bounds** can remain the same. The new limits must be implemented by new constraints and/or bounds. We also need to provide new options in the **data sections** where these limits can be given as **parameter** values.

There are four limits altogether:

  * **Upper limit on production amount.** The production amount for any product $p$ appears as the $production[p]$ variable in the model. A constant upper limit for this value can easily be implemented as a **linear constraint**, but an even easier way is to implement it as an **upper bound** of the $production$ variable.
  * **Lower limit on production amount.** The same applies here. Just note that there is already a non-negativity bound defined for the variables, and defining two lower or two upper bounds on the same variable is forbidden in **GNU MathProg**.
  * **Upper limit on raw material consumption.** The total consumption of each raw material is already represented in the model as an **expression**. Actually, the only constraint in the production problem so far defines an upper limit for this expression as $Storage[r]$ for any raw material $r$. Therefore, there's no need to further define upper bounds. If one wants to give an extra upper limitation for total consumption, it can be done without modifying the **model section**, simply by decreasing the appropriate $Storage$ parameter value in the **data section**.
  * **Lower limit on raw material consumption.** As we noted before, the expression already appears in a constraint. We need to implement another constraint with exactly the same expression, but expressing a **minimum limit** instead of the maximum.

First, we have to add the extra parameters to describe the limits.

```
param Storage {r in Raw_Materials}, >=0, default 1e100;

param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;

param Revenue {p in Products}, >=0, default 0;

param Min_Usage {r in Raw_Materials}, >=0, <=Storage[r], default 0;

param Min_Production {p in Products}, >=0, default 0;

param Max_Production {p in Products}, >=Min_Production[p], default 1e100;
```

The new $Min\_Usage$ is for the **minimum** total consumption for each raw material, while parameters $Min\_Production$ and $Max\_Production$ are for the **lower and upper limits** of production for each product. The fourth limit parameter is the original $Storage$, for the **upper limit** of raw material consumption. All these limit parameters now have sensible bounds and default values. Lower limits default to $0$, while upper limits default to $10^{100}$, a massive number that we **expect not to appear** in problem data. Also, lower limits must **not be larger** than upper limits. Meanwhile, all limits must be **non-negative**. Remember that these restrictions on parameter values are valuable to **prevent mistakes in data sections**, but we don't expect them to contribute to generating and solving the model once satisfied. This is in contrast to **variable bounds**, which are part of the model formulation and may affect solutions.

The variables and the objective function remain the same. However, we must add **three additional constraints** to tighten the search space of the model. Each of the four constraints corresponds to one of the four limits mentioned. The $Material\_Balance$ constraint is for the upper limit of total consumption of raw materials; this one was originally there and was left unchanged.

```
var production {p in Products}, >=0;

s.t. Material_Balance {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p]
    <= Storage[r];

s.t. Cons_Min_Usage {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p]
    >= Min_Usage[r];

s.t. Cons_Min_Production {p in Products}:
    production[p] >= Min_Production[p];

s.t. Cons_Max_Production {p in Products}:
    production[p] <= Max_Production[p];

maximize Total_Revenue: sum {p in Products} Revenue[p] * production[p];
```

The **post-processing work** to print out solution data may remain the same as for the original model. Now, our **model section** is ready.

To demonstrate how it works, consider the following production problem with limits.

**Problem 11.**

Solve the **production problem** described in Problem 9, but with the following restrictions added:

  * Use at least $20,000$ hours of working time (**raw material B**).
  * Fill the production quota: produce at least $200$ units (**raw material D**), which is also the maximum for that raw material.
  * Produce at most $10$ units of **P3**.

Since the problem is simply an "**extension**" of the original one, its implementation can be done by just extending the **data section** with the aforementioned limits. Note that each parameter is indexed with the set of all raw materials and all products. Those that do not appear in the data section will simply default to $0$ for lower limits and $10^{100}$ for upper limits, effectively making the limits redundant. In that case, they don't modify the search space of the model because those limits are true anyway for any otherwise feasible solution.

```
param Min_Usage :=
    B 21000
    D 200
    ;

param Min_Production :=
    P2 100
    ;

param Max_Production :=
    P3 10
    ;
```

The solution to the problem is now slightly different due to the newly defined bounds.

```
Total Revenue: 32970
Production of P1: 90
Production of P2: 100
Production of P3: 10
Usage of A: 23000, remaining: -7.27596e-12
Usage of B: 21000, remaining: 10000
Usage of C: 433000, remaining: 17000
Usage of D: 200, remaining: 0
```

This means that **$90$ units of P1, $100$ units of P2, and $10$ units of P3** are produced. We can verify that all limitations are met. It's interesting to note that all variables in this solution are **integers**, even though they aren't forced to be. This means that if the problem were changed to consider only integer solutions (e.g., if the product must be produced in whole numbers), this solution would still be valid. Moreover, it would also be the **optimal solution**, because restricting variables to only integer values just makes the model's search space tighter. So, if a solution is optimal even in the original model—meaning there are no better solutions—then there shouldn't be better solutions in the more restrictive **integer counterpart** either.

Now, our implementation for limits is complete. But we can still improve the model implementation by making it a bit more **readable** and less **redundant**. First, there's a neat feature in **GNU MathProg**: if a **linear expression** can be bounded by both an upper and a lower value, and both limits are constants, they can be defined in a **single constraint** instead of two. Using this, we can reduce the number of `s.t.` statements from four to two in our model section, as follows. All other parts of the model, the data, and the solution remain the same.

```
s.t. Material_Balance {r in Raw_Materials}: Min_Usage[r] <=
    sum {p in Products} Consumption_Rate[r,p] * production[p]
    <= Storage[r];

s.t. Production_Limits {p in Products}:
    Min_Production[p] <= production[p] <= Max_Production[p];
```

There is another thing we can improve, which is actually a **modeling technique** rather than a language feature: we can introduce **auxiliary variables** for linear expressions. The variables, constraints, and objective function will look like this:

```
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;

s.t. Usage_Calc {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];

s.t. Total_Revenue_Calc: total_revenue =
    sum {p in Products} Revenue[p] * production[p];

maximize Total_Revenue: total_revenue;
```

Observe the newly introduced variable `usage`. We intend for this variable to denote the total consumption of a raw material. Therefore, we add the `Usage_Calc` constraint to ensure this. We now have that variable throughout the model to denote this value. We also do this for the total revenue, denoted by the variable `total_revenue`, calculated in the `Total_Revenue_Calc` constraint, and then used in the objective function. The objective function is actually the `total_revenue` variable itself.

Now, notice that all the expressions we have to limit are actually variables, and all the limits are constants. This means the constraints for the limits can be converted to **bounds** of these variables, specifically `production` and `usage`. This way, we effectively got rid of all the previously defined constraints and converted them into bounds, but we needed two more constraints (`Usage_Calc` and `Total_Revenue_Calc`) to calculate the values of `usage` and `total_revenue`.

You might think the main importance of introducing the new variable is the possibility of using bounds instead of `s.t.` statements, making our implementation shorter. This is just one example of its usefulness. The key point is that if some expression is used more than once in our model, we can simply introduce a **new variable** for it, define a new constraint so that the variable equals that expression, and then use the variable instead of that expression everywhere.

Think about this: does adding auxiliary variables change the **search space**? Formally, yes. The search space has a different **dimension**. There are more variables, so in a solution to the new problem, we have to decide more values. However, note that feasible solutions of the new model will be in a **one-to-one correspondence** with the original ones. For a solution feasible to the original problem, we can introduce the auxiliary variable with the corresponding value of the expression and get a feasible solution for the extended problem. Conversely, each feasible solution in the extended problem must have its auxiliary variable equal to the expression it is defined for, so it can be substituted back into the model to return to a feasible solution of the original model.

In short, the search space formally changes, but the (feasible) solutions for the problem **logically remain the same**.

An important question arises: how does introducing auxiliary variables change the course of the algorithms and **solver performance**? The general answer is that we don't know. There are more variables, so computational performance might be slightly worse, but this is often **negligible** because the main difficulty of solving a model in practice comes from the complexity of the search space, which is logically unchanged. Of course, if there are magnitudes more auxiliary variables than ordinary variables and constraints, it might cause technical problems. Also note that, in theory, the solver has the right to substitute out auxiliary variables, effectively reverting back to the original problem formulation, but we generally cannot be sure that it does so. The solver doesn't see which of our variables are intended to be "auxiliary." If there is an equation constraint in the model, the solver might use that equation to express one of the variables appearing in it and perform a substitution, even if we hadn't considered it auxiliary.

In short, the course of the solution algorithm may differ, and the computational performance might change, but this is usually negligible.

Also note that we previously introduced some new values in the post-processing work so we didn't have to write the total consumption expression twice. That was done by introducing a new parameter, not a variable, and only worked **after** the `solve` statement because it involved variable values only available when the model is solved. However, now with an auxiliary variable introduced for total consumption, we can use it **both before and after** the `solve` statement. Therefore, we write this expression down in code only once, and that redundancy is finally completely gone.

The ultimate model code for the limits is below. Note that the data section and solution remain the same as before. Also note that we didn't have to introduce new parameters after the `solve` statement, as the auxiliary variables do the work.

```
set Products;
set Raw_Materials;

param Storage {r in Raw_Materials}, >=0, default 1e100;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;
param Min_Usage {r in Raw_Materials}, >=0, <=Storage[r], default 0;
param Min_Production {p in Products}, >=0, default 0;
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;

var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;

s.t. Usage_Calc {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];

s.t. Total_Revenue_Calc: total_revenue =
    sum {p in Products} Revenue[p] * production[p];

maximize Total_Revenue: total_revenue;

solve;

printf "Total Revenue: %g\n", total_revenue;

for {p in Products}
{
    printf "Production of %s: %g\n", p, production[p];
}

for {r in Raw_Materials}
{
    printf "Usage of %s: %g, remaining: %g\n",
        r, usage[r], Storage[r] - usage[r];
}

end;
```

-----

## 5.3. Maximizing minimum production

In the previous sections, we saw a complete implementation for the production problem where total raw material consumption and production can be limited by constants. Now, let's modify the optimization goal to **maximize the minimum production**. The exact definition is as follows.

**Problem 12.**

The problem requires us to **maximize the minimum production** amount among all products, while keeping the problem data the same. The minimum production refers to the product for which the least amount is manufactured.

Whether we start with the simple model or the one with added limitations, this problem only requires us to modify the **objective function**. This means the **feasible solutions** and search space remain exactly the same.

This also makes the **revenue parameter** irrelevant, because we are no longer interested in the total monetary value of the products, but only the production amounts (specifically, the minimum of those amounts).

We have already solved a similar problem with the system of linear equations (Problem 7 from Section 4.8), where the objective was to minimize the maximum error across all equations. Here, we need to maximize the minimum production. The required **modeling technique** is indeed similar.

The idea is to introduce a new **variable** to represent the minimum of all production amounts. Specifically, this variable will denote a **lower bound** for all individual production amounts. This lower bound also serves as a lower bound for the minimum of those amounts. If this variable is **maximized**, the optimization process will eventually increase its value as much as possible until it reaches the true minimum of the production amounts.

Using this modeling trick, we can ensure that the final optimal solution found will correspond to the maximal possible value of the minimum production amount. This is a general method that works for any set of linear expressions where either the minimum must be maximized or the maximum must be minimized.

In the implementation, parameters and post-processing work remain the same, as do the existing variables, bounds, and constraints from the extended model (including `Min_Production`, `Max_Production`, and auxiliary variables for usage and revenue):

```
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;

s.t. Usage_Calc {r in Raw_Materials}:
  sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];

s.t. Total_Revenue_Calc: total_revenue =
  sum {p in Products} Revenue[p] * production[p];
```

The change is that, instead of maximizing total revenue, we set the minimum production as the new objective. This requires introducing a new variable, `min_production`, to denote a lower bound for all production amounts, and a constraint to ensure that the variable is, in fact, a lower bound. Then, this new variable is maximized as the objective function.

```
var min_production;

s.t. Minimum_Production_Calc {p in Products}:
  min_production <= production[p];

maximize Minimum_Production: min_production;
```

The post-processing code can be the same as before, so we print the same data as we did for the total revenue objective. We only add a `printf` statement to emphasize the minimum production amount, which is our current objective.

```
printf "Minimum Production: %g\n", min_production;
```

Note that in our code, `min_production` is the name of the **variable**, and `Minimum_Production` is the name of the **objective function**. In GNU MathProg, we could use both as values. However, be cautious when referring to the objective by its name because constant terms in the objective are omitted. Constant terms do not affect the selection of the optimal solution, only the value of the objective. Therefore, it is recommended to refer to the objective function value using the variable `min_production` instead.

We can now run our model to solve two problems.

**Example 1: Ignoring Production/Usage Limits**

In the first example, all the limits (`Min_Usage`, `Min_Production`, `Max_Production`) are ignored, except for the `Storage` capacity. Note that in the data section, we can begin rows with a hash mark (`#`). This turns the row into a **comment**, effectively excluding it from processing. The data section looks like this:

```
data;

set Products := P1 P2 P3;
set Raw_Materials := A B C D;

param Storage :=
    A 23000
    B 31000
    C 450000
    D 200
    ;

param Consumption_Rate:
       P1    P2    P3 :=
  A   200    50     0
  B    25   180    75
  C  3200  1000  4500
  D     1     1     1
  ;

param Revenue :=
    P1 252
    P2 89
    P3 139
    ;

param Min_Usage :=
    # B 21000
    # D 200
    ;

param Min_Production :=
    # P2 100
    ;

param Max_Production :=
    # P3 10
    ;

end;
```

Note that revenue data are not strictly necessary in this model, but it is not an error to assign them values, as long as the parameter is represented in the model section.

The solution to the problem results in a minimum production amount of **51.72**.

```
Total Revenue: 24827.6
Minimum Production: 51.7241
Production of P1: 51.7241
Production of P2: 51.7241
Production of P3: 51.7241
Usage of A: 12931, remaining: 10069
Usage of B: 14482.8, remaining: 16517.2
Usage of C: 450000, remaining: 0
Usage of D: 155.172, remaining: 44.8276
```

It turns out that production is **balanced** to the edge to achieve this solution. All resources are distributed evenly, and all three products are produced in an **equal amount**. If we consider the objective, this isn't surprising. Why would we produce any product amount above the minimum if it offers no advantage to the objective function, but represents a disadvantage in terms of raw materials consumed?

It looks like raw material **C is the bottleneck** in this problem. We call a factor a **bottleneck** if changing it has a visible impact on the final solution while other factors remain the same—for example, the most scarce resource. If there were slightly less or more of raw materials A, B, and D, the solution would be the same because all of C is completely used up and distributed evenly. This knowledge can be fundamental in real-world optimization because it informs decision-makers that improving some factors is unnecessary. On the other hand, slightly more or less of C would likely result in slightly more or less production (likely, because there could be other limitations we do not see). For this reason, raw material **C is the bottleneck** in this particular production problem.

**Example 2: With Constraints** (Excluding $P3 \le 10$)

In the second example, **Problem 11** is used but without the constraint on $P3$. This means all limitations are now included, except for the restriction that $P3$ is maximized at 10 units. Note that if this constraint were enabled, the optimal solution would obviously be 10 units, as the former solution we already know produces exactly 10 units of $P3$, and there cannot be more.

In short, we only get a meaningful new problem if we **omit** the constraint maximizing $P3$ at 10 units.

```
Total Revenue: 27142.1
Minimum Production: 43.8596
Production of P1: 43.8596
Production of P2: 112.281
Production of P3: 43.8596
Usage of A: 14386, remaining: 8614.04
Usage of B: 24596.5, remaining: 6403.51
Usage of C: 450000, remaining: 0
Usage of D: 200, remaining: 0
```

The solution is slightly different here. Now, only **P1 and P3 are produced in equal amounts**, both at the minimum production amount of **43.86**. Also, not only C but **D is also totally used up**. Note that a much larger amount of P2 is needed because all 200 units of D must be used up in this problem. This answers a former question: why is it advantageous to produce products above the minimum limit? Because it might help satisfy the minimum production and/or minimum consumption constraints.

Note that the objective in this case is slightly **worse** than that of the first example problem, where the objective was 51.72. This is a natural consequence of differences in the data. In the second example, the data were the same except for **additional constraints** on consumption and production. If a problem is more constrained, we can only get an optimal solution with the **same, or a worse, objective value**.

Generally, if only the objective is changed in a model, the set of **feasible solutions remains the same**, because the objective only guides the selection of the most suitable solution, not which solutions are feasible. In this case, the new objective function involved a new variable, `min_production`, which served as a lower bound and was maximized.

Note that, in theory, `min_production` does not need any lower bound and can even be allowed to be zero or negative. The solution would still be feasible. However, such solutions are not reported because they are not optimal. Therefore, only those feasible solutions are interesting for which `min_production` is not only a valid lower bound on production amounts but is actually **strict**—that is, it equals the minimum production amount.

Among these interesting solutions, `min_production` works just like an **auxiliary variable**. Each optimal solution where `min_production` is a strict bound corresponds to a feasible solution of the original problem where revenues were maximized, and vice versa.

-----

## 5.4 Raw Material Costs and Profit

We have seen an example where only the objective was changed. Now let's look at another example, which is a more natural extension to the problem. From now on, raw materials are no longer considered **"free"**: they must be produced, purchased, stored, etc. In general, they have **costs**. Just as there is a revenue for each product per unit produced, there is now a **cost for each raw material per unit consumed**.

**Problem 13.**

Solve the production problem, but now instead of optimizing for revenue, optimize for **profit**. The profit is defined as the difference between the **total revenue** from products and the **total cost** of raw materials consumed for production. The cost for each raw material is proportional to the material consumed and is independent of which product it is used for. A single **unit cost** for each raw material is given.

This is the general description of the problem. We will again use an example for demonstration, which includes costs for raw materials. The other data for the example problem remain the same as before.

**Problem 14.**

Solve the production problem with the objective of **maximized profit**, using the following problem data, with unit costs of raw materials added.

| | **P1** | **P2** | **P3** | **Available** | **Cost (per unit)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **A** (electricity) | 200 kWh | 50 kWh | 0 kWh | 23000 kWh | **$1** |
| **B** (working time) | 25 h | 180 h | 75 h | 31000 h | **$0.07** |
| **C** (materials) | 3200 kg | 1000 kg | 4500 kg | 450000 kg | **$0.013** |
| **D** (production quota) | 1 | 1 | 1 | 200 | **$8** |
| **Revenue (per unit)** | **$252** | **$89** | **$139** | | |

Additionally, there are three limitations, as before:

  * Use at least **20,000 h** of working time (raw material B).
  * Fill the production quota: produce at least **200 units** (raw material D), which also happens to be the maximum for that raw material.
  * Produce at most **10 units of P3**.

Again, we want to write a general model and a separate, corresponding data section for the particular example problem. The starting point is the model and data sections we obtained by solving **Problem 11** (where limits were introduced), as both are almost ready; we only need to implement some modifications.

First, we definitely need a new parameter that describes the costs. Let's call this parameter `Material_Cost`. We can simply add it to the model section. No other data is needed.

Before proceeding, let's observe what happens when material costs are zero. This means our problem is the same as the original, where raw materials were free. This means the current problem with raw material costs is a **generalization** of the original problem. In other words, the original problem is a **special case** of the current problem where all raw material costs are zero. For this reason, it is sensible to give a **zero default value** to material costs. This makes data files implemented for the original problem compatible with our new model as well.

```
param Material_Cost {r in Raw_Materials}, >=0, default 0;
```

We also know the corresponding data, which can be implemented in the data section. Each raw material has a nonzero cost.

```
param Material_Cost :=
  A  1
  B  0.07
  C  0.013
  D  8
  ;
```

Beyond the data, the only difference in the model is the **objective value**. We could simply change the objective line and our model would be complete. However, for better readability, we will introduce an **auxiliary variable** for the profit and use it instead. The modified part of the model section is below. Only three lines of code changed: the `profit` variable was introduced, the objective changed, and the `Profit_Calc` constraint was added to ensure that the `profit` variable obtains the corresponding value. We also print it after the `solve` statement.

```
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;
var profit;

s.t. Usage_Calc {r in Raw_Materials}:
    sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];

s.t. Total_Revenue_Calc: total_revenue =
    sum {p in Products} Revenue[p] * production[p];

s.t. Profit_Calc: profit = total_revenue - 
    sum {r in Raw_Materials} Material_Cost[r] * usage[r];

maximize Profit: profit;

solve;

printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;
```

Now both the model and the data sections are ready. If we optimize for profit now, we get the following result.

```
Total Revenue: 22453.9
Profit: 1577.45
Production of P1: 25.4839
Production of P2: 164.516
Production of P3: 10
Usage of A: 13322.6, remaining: 9677.42
Usage of B: 31000, remaining: 0
Usage of C: 291065, remaining: 158935
Usage of D: 200, remaining: 0
```

Now let's examine this solution briefly. Logically, the **search space** did not change: exactly the same solutions are **feasible** in both the original problem (maximizing revenue) and the current problem (maximizing profit). This explains the difference in total revenues. In the original problem, the optimal total revenue was **$32,970**, achieved by producing 90 units of P1, 100 units of P2, and 10 units of P3. However, optimizing for **profit** yields a total revenue of **$22,453.87**, which is worse. The profit in this case is much smaller, **$1,577.45**, meaning most of the revenue is consumed by raw material costs. The production is also slightly different: 25.48 units of P1, 164.52 units of P2, and 10 units of P3 are now produced.

Although revenue is significantly higher for the original solution, we can now be certain that the profit would be no more than **$1,577.45** in that case either.

-----

## 5.5 Diet Problem

We have seen several versions of the production problem. Now, we consider a seemingly unrelated problem called the **diet problem** [13, 14], or the **nutrition problem**.

**Problem 15.**

Given a set of **food types** and a set of **nutrients**. Each food consists of a given, fixed ratio of the nutrients.

We aim to arrange a **diet**, which is any combination of the set of food types, in any amount. However, for each nutrient, there is a **minimum requirement** that the diet must satisfy to be healthy. Also, each food has its own proportional **cost**.

**Find the healthy diet with the lowest total cost of food involved.**

After the general problem definition, let's look at a specific example.

**Problem 16.**

Solve the diet problem with the following data. There are five food types, named **F1 to F5**, and four nutrients under focus, named **N1 to N4**. The contents of a unit amount of each food, the unit cost of each food, and the minimum requirement of each nutrient are shown below.

| | **N1** | **N2** | **N3** | **N4** | **Cost (per unit)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **F1** | 30 | 5.2 | 0.2 | 0.0001 | **450** |
| **F2** | 20 | 0 | 0.7 | 0.0001 | **220** |
| **F3** | 25 | 2 | 0.1 | 0.0001 | **675** |
| **F4** | 13 | 3.6 | 0 | 0.0002 | **120** |
| **F5** | 19 | 0.1 | 0 | 0.0009 | **500** |
| **Required** | **2000** | **180** | **30** | **0.04** | |

The diet problem is regarded as one of the first problems that led to the field of **Operations Research**.

Note that the underlying dimensions are slightly different in the diet problem and the production problem. We omitted fictional physical dimensions here, but the scale of each nutrient suggests which data belong to a single dimension. In this table, each column corresponds to a single nutrient and has its own unit of measure. The last column shows unit costs.

Usually, when implementing a model, the first things we must decide are: how our **freedom of choice** will be implemented as **decision variables**, how the **search space** can be described by **constraints**, and how the **objective** can be calculated. These steps are essential for deciding whether a mathematical programming approach is even suitable for a real-world problem.

However, we will instead start by defining all the data available in the problem and then proceed with the steps above. This makes defining the variables, constraints, and objectives easier afterward. So, the first part of modeling in GNU MathProg is defining the **sets and parameters**. These are either calculated on the spot or provided later in a data section.

Two sets appear in the problem: one for **food types** and one for **nutrients**.

```
set FoodTypes;
set Nutrients;
```

There are three parameters available. One denotes **food costs**, defined for each food type. One denotes the **minimum required amount of nutrients**, defined for each nutrient. Finally, one parameter denotes the **contents of food**, given by a unit amount for each pair of food type and nutrient. For example, each unit of F2 contains 20 units of N1, 0.7 units of N3, and 0.0001 units of N4. The default values are all set to zero, and all these parameters are nonnegative.

```
param Food_Cost {f in FoodTypes}, >=0, default 0;
param Content {f in FoodTypes, n in Nutrients}, >=0, default 0;
param Requirement {n in Nutrients}, >=0, default 0;
```

Now that all data are defined as sets and variables, we must identify our freedom of choice. The **amounts of each food used** are clearly under our decision. If we know these amounts, we can easily calculate total cost and nutrient contents, determining if the diet is healthy and how much it costs. This means we should define a variable denoting **food consumption** for each food type, and no other variables are needed.

We introduce a variable named `eaten` to denote the amount of each food included in the diet. This variable is nonnegative and indexed over the set of food types. We also introduce the auxiliary variable `total_costs` so it can be printed more easily.

```
var eaten {f in FoodTypes}, >=0;
var total_costs;
```

There is one significant factor restricting which diets are acceptable: the **total nutritional content**. This translates into a constraint for each nutrient. The total amount contained in the selected diet must be summed up, and this total must be **no less than** the minimal requirement for that nutrient.

Additionally, there is another constraint for calculating the auxiliary variable denoting total food costs.

```
s.t. Nutrient_Requirements {n in Nutrients}:
    sum {f in FoodTypes} Content[f,n] * eaten[f] >= Requirement[n];

s.t. Total_Costs_Calc: total_costs =
    sum {f in FoodTypes} Food_Cost[f] * eaten[f];
```

With the auxiliary `total_costs` variable, defining the objective is straightforward.

```
minimize Total_Costs: total_costs;
```

After the `solve` statement, we can write our own printing code to show the solution found. This time, we show the amount of each food in the diet, as well as the total consumption per nutrient alongside the lower limit. Our model section is now ready.

```
set FoodTypes;
set Nutrients;

param Food_Cost {f in FoodTypes}, >=0, default 0;
param Content {f in FoodTypes, n in Nutrients}, >=0, default 0;
param Requirement {n in Nutrients}, >=0, default 0;

var eaten {f in FoodTypes}, >=0;
var total_costs;

s.t. Nutrient_Requirements {n in Nutrients}:
    sum {f in FoodTypes} Content[f,n] * eaten[f] >= Requirement[n];

s.t. Total_Costs_Calc: total_costs =
    sum {f in FoodTypes} Food_Cost[f] * eaten[f];

minimize Total_Costs: total_costs;

solve;

printf "Total Costs: %g\n", total_costs;

param Nutrient_Intake {n in Nutrients} :=
    sum {f in FoodTypes} Content[f,n] * eaten[f];

for {f in FoodTypes}
{
    printf "Eaten of %s: %g\n", f, eaten[f];
}

for {n in Nutrients}
{
    printf "Requirement %g of nutrient %s done with %g\n",
    Requirement[n], n, Nutrient_Intake[n];
}

end;
```

Now we implement the specific problem mentioned. It is described in a single data section as follows.

```
data;
set FoodTypes := F1 F2 F3 F4 F5;
set Nutrients := N1 N2 N3 N4;

param Food_Cost :=
    F1 450
    F2 220
    F3 675
    F4 120
    F5 500
    ;

param Content:
      N1  N2  N3     N4 := 
    F1 30 5.2 0.2 0.0001
    F2 20   . 0.7 0.0001
    F3 25   2 0.1 0.0001
    F4 13 3.6   . 0.0002
    F5 19 0.1   . 0.0009
    ;

param Requirement :=
    N1 2000
    N2 180
    N3 30
    N4 0.04
    ;
end;
```

Solving the problem gives the following result:

```
Total Costs: 29707.2
Eaten of F1: 0
Eaten of F2: 42.8571
Eaten of F3: 0
Eaten of F4: 49.2014
Eaten of F5: 28.7489
Requirement 2000 of nutrient N1 done with 2042.99
Requirement 180 of nutrient N2 done with 180
Requirement 30 of nutrient N3 done with 30
Requirement 0.04 of nutrient N4 done with 0.04
```

The optimal objective is **$29,707.2**. This literally means that any diet containing at least 2,000 units of N1, 180 units of N2, 30 units of N3, and 0.04 units of N4, using foods F1 through F5, would cost at least **$29,707.2**, and there exists a solution to obtain exactly this number.

The optimal solution only uses **F2, F4, and F5**. This means that if F1 and F3 were omitted from the problem data altogether, the optimal solution would be exactly the same. Introducing a new food type only **increases freedom** in the model, leaving any previously feasible solutions feasible, and potentially adding new ones. We can also observe that **N1 is the only nutrient** for which consumption in the optimal diet is **more than** the minimal requirement (2,042.99 units vs. 2,000). For the other three nutrients, there is exactly enough. This suggests the solution shows a diet that is **balanced to the edge** to meet minimum requirements while optimizing cost.

 
-----

## 5.6 Arbitrary Recipes

The implementations of the **diet problem** and the **production problem** are surprisingly similar. This similarity extends to the number of sets, parameters, variables, constraints, the content of those constraints, and the objective. In this section, we will show how the diet problem can be viewed as a production problem. Finally, we will demonstrate a production problem with **arbitrary recipes** that generalizes both problems simultaneously.

There are two ways to represent a diet problem as a production problem.

1.  **Products are Food Types, Raw Materials are Nutrients.** This makes sense from a real-world perspective as well. You can think of food as being "produced" from its constituent nutrients in specific ratios. When dieting, we consume products and break them down into nutrients, so the process is simply reversed in time. The products have costs, like foods, and the amounts exactly define the solution. The only difference is that instead of "storage" amounts for raw materials, which serve as an **upper bound** for usage, we have a **lower bound** because each nutrient must be consumed in a minimal total amount for a healthy diet. However, this feature is already implemented in the limits extension (Problem 10). Another detail is that food "production" should be **minimized** instead of maximized, but we can easily achieve this by representing food costs as **negative revenues** in the model. Technically, rewriting our diet problem into a production problem with limits and negative unit revenues is straightforward if we consider **food types as the products** and **nutrients as the raw materials**.

2.  **Products are Nutrients, Raw Materials are Food Types.** This matches the timeline: foods are the "inputs" available first, and the products are the nutrients we want to obtain through the process. However, there are more differences in this representation that might make it feel unnatural. There are no upper or lower limits for foods, but there is a lower limit for nutrients, which implies a minimum production amount for each product in the production problem context. There are no costs for the nutrients, only for the foods, meaning the production problem would have costs only for raw materials and **zero revenues** for all products.

The most significant difference, which prevents us from directly using the standard production model in this second representation, is that the **logic of production is reversed**. In the standard production problem, **many raw materials produce a single product** in given ratios. In the diet problem context, a **single raw material (food) produces many products (nutrients)** in given ratios.

At this point, we could say the second representation is flawed and stick to the first one. Technically, nothing stops us from doing that. However, the second representation suggests a valuable generalization for the production problem itself: **What if we relax the rule that there is only a single product in each production step?** This leads us to the **production problem with arbitrary recipes**.

A **recipe** describes a process that consumes several **inputs** at once and produces several **outputs** at once, in specific amounts. Each recipe can be utilized in any volume, and both inputs and outputs scale proportionally according to this volume.

This concept of recipes can describe both the production problem and the diet problem:

  * In the **production problem**, there is one recipe for each product. That recipe produces only that particular product as **output** but can consume any given combination of raw materials as **inputs**.
  * In the **diet problem**, there is one recipe for each food type. That recipe consumes only that particular food type as an **input** but can produce any given combination of nutrients as **outputs**.
  * Furthermore, there may be other problems involving **many inputs and many outputs** simultaneously in a single recipe. Neither the standard production nor the diet problem covers these cases alone.

We can now define the production problem with arbitrary recipes as follows.

-----

**Problem 17.**

Given a set of **raw materials** and a set of **products**, there is also a set of **recipes** defined.

Each recipe describes the ratio in which it **consumes raw materials** and **produces products**; these ratios are arbitrary nonnegative numbers. Each recipe may be utilized in an arbitrary amount, referred to as its **volume**.

  * There is a **unit cost** defined for each raw material and a **unit revenue** for each product.
  * There can be **minimal and maximal total consumption** amounts defined for each raw material, and **minimal and maximal total production** amounts defined for each product.
  * For practical purposes, the total cost of consumed raw materials is limited: it **cannot exceed a given value**, which represents the initial funds available for purchasing raw materials.

Find the optimal production plan, where recipes are utilized in arbitrary volumes, such that all consumption and production limits are satisfied, and the **total profit is maximal**. Total profit is the difference between total revenue from products and the total cost of raw materials consumed.

-----

**Model Implementation**

Let's start by implementing this problem without a specific example. You'll find its implementation very similar to the original production problem. The first step is to "read" all available data for future use. For this reason, the model includes three sets: raw materials, products, and recipes.

```
set Raws;
set Products;
set Recipes;
```

Note that the problem definition doesn't exclude the possibility that the **same material acts as both a raw material and a product** in different recipes. This is natural in real-world scenarios: a material produced by one recipe might be consumed by another. However, considering this would raise questions regarding **timing**. For instance, if a material is consumed as a raw material in a second recipe, it must first be produced by the first recipe. This implies a sequence where the first recipe executes before the second. Alternatively, the production could describe an equilibrium where amounts must be maintained, making timing irrelevant. Given the complexity of these possibilities, we won't go into details here. For simplicity, we assume that **raw materials and products are distinct**.

To ensure that raw materials are indeed distinct from products, we introduce a `check` statement. We explicitly state that the **intersection** of the set of raw materials and the set of products must contain exactly zero elements. If this condition isn't met, model construction fails immediately, as it should.

```
check card(Raws inter Products) == 0;
```

For each recipe, there are ratios for both raw materials and products. Since these are two different sets, defining them would typically require two different parameters: one for raw material ratios and one for product ratios. This would apply to other parameters as well.

Instead, we introduce the concept of **materials** in our model. We simply group raw materials and products together as "materials." In GNU MathProg, it is legal to introduce a set that is calculated on the spot based on other sets.

```
set Materials := Products union Raws;
```

Since we assumed no material is both a product and a raw material, we can assume each raw material and product is represented exactly once in the union, and they are all distinct. Now, with this new set, we can define the necessary parameters compactly.

```
param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
param Value {m in Materials}, >=0, default 0;
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
param Initial_Funds, >=0, default 1e100;
```

The parameters **`Min_Usage`** and **`Max_Usage`** denote the lower and upper bounds for each material in the model. These parameters are indexed over the `Materials` set. For raw materials, `Min_Usage` and `Max_Usage` represent limits for **total consumption**. For products, they represent limits for **total production**. Because each raw material and product appears exactly once in the `Materials` set, this definition unambiguously describes all limits for both. Note that the default limits are **0** for the lower bound and a very large number, **$10^{100}$**, for the upper limit. Technically, this means there is no limit by default.

The **`Value`** parameter works similarly; it represents **raw material costs** for raw materials and **revenues** for products. Both are nonnegative and default to zero.

The **`Recipe_Ratio`** parameter describes the recipes. The only data needed are the exact amounts of inputs consumed and outputs produced. With the common `Materials` set, we can do this with a single parameter. `Recipe_Ratio` is defined for all recipes and all materials. If the material is raw, it describes the **consumption amount**; if it is a product, it describes the **production amount**. We call this parameter "ratio" because it corresponds to the amounts consumed and produced when utilizing the recipe with a **volume of 1**. Generally, since inputs and outputs are proportional, the ratio must be multiplied by the volume to get the actual amounts consumed or produced.

Finally, there is a single numeric parameter, **`Initial_Funds`**. This serves as an **upper limit for raw material costs**. In practice, you generally cannot invest unlimited amounts into raw materials; there is usually a cap. Without such a restriction (and without upper limits for consumption or production), it might be possible to gain unlimited profit by consuming unlimited raw materials to produce at least one product in unlimited amounts. By default, `Initial_Funds` is set to the extreme value of **$10^{100}$** so that it does not restrict the model unless specified.

Now that all parameters and sets are defined, let's look at the freedom in our model. We have to decide the **volume for each recipe utilized**. This is slightly different than before because decisions correspond to a given recipe rather than a particular product or raw material. If recipe volumes are defined, the solution is fully determined, and all other information—including raw material usage, production amounts, costs, revenues, profit, and limitations—can be calculated.

```
var volume {c in Recipes}, >=0;
var usage {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;
```

In our implementation, **`volume`** is the variable denoting the volume at which each recipe is utilized. This is a nonnegative value but can be zero or even fractional, as usual. While this single variable would be sufficient for formulation, we introduce a few **auxiliary variables** to write a compact and readable model.

The variable **`usage`** represents the total "usage" of each material. It is indexed over the `Materials` set and works similarly to the parameters: it has a slightly different meaning for raw materials and products, but for simplicity, a single variable handles both. For raw materials $r$, `usage[r]` is the **total consumption**, while for products $p$, `usage[p]` is the **total production** amount. We can use `Min_Usage[m]` and `Max_Usage[m]` as bounds for this variable, implementing the limitations in our problem.

There is also a variable named **`total_costs`** denoting total costs of consumed raw materials, a variable **`total_revenue`** for total revenue from products, and finally, a variable **`profit`** for the difference (our objective function). We set `Initial_Funds` as an upper bound for `total_costs`, implementing the maximum usage limitation.

Constraints are implemented next.

```
s.t. Material_Balance {m in Materials}: usage[m] =
    sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

s.t. Total_Costs_Calc: total_costs = 
    sum {r in Raws} Value[r] * usage[r];

s.t. Total_Revenue_Calc: total_revenue =
    sum {p in Products} Value[p] * usage[p];

s.t. Profit_Calc: profit = 
    total_revenue - total_costs;
```

Although this model is intended to generalize both the production problem and the diet problem, supporting most features mentioned so far, there is only one key constraint: the **material balance** established by recipe utilization. This constraint states that the usage of each material—whether raw material or product—is calculated by summing the volume of each recipe multiplied by the ratio of that material in the recipe. This is exactly the same logic used in both the original production problem and the diet problem.

We also define three additional constraints to calculate the values of the auxiliary variables `total_costs`, `total_revenue`, and `profit`. Note that even though parameters and variables (here `Value` and `usage`) are indexed over the `Materials` set, it is valid in GNU MathProg to index those parameters and variables over a **smaller set**. Using the original `Raws` and `Products` sets, we can sum up only for raw materials or only for products. Be careful: you can only index over the original domain or its subset; otherwise, you will get an out-of-domain error (and the model is guaranteed to be logically wrong).

The objective is straightforward: the profit itself.

```
maximize Profit: profit;
```

After solving the problem, we can print out the auxiliary variables, the utilization volumes for each recipe, and the total consumption and production amounts for each material. The full model section is ready as follows.

```
set Raws;
set Products;
set Recipes;

check card(Raws inter Products) == 0;

set Materials := Products union Raws;

param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
param Value {m in Materials}, >=0, default 0;
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
param Initial_Funds, >=0, default 1e100;

var volume {c in Recipes}, >=0;
var usage {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;

s.t. Material_Balance {m in Materials}: usage[m] =
    sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

s.t. Total_Costs_Calc: total_costs = 
    sum {r in Raws} Value[r] * usage[r];

s.t. Total_Revenue_Calc: total_revenue =
    sum {p in Products} Value[p] * usage[p];

s.t. Profit_Calc: profit = 
    total_revenue - total_costs;

maximize Profit: profit;

solve;

printf "Total Costs: %g\n", total_costs;
printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;

for {c in Recipes}
{
printf "Volume of recipe %s: %g\n", c, volume[c];
}

for {r in Raws}
{
printf "Consumption of raw %s: %g\n", r, usage[r];
}

for {p in Products}
{
printf "Production of product %s: %g\n", p, usage[p];
}

end;
```

Although the model for arbitrary recipes is similar in nature to previous models, we implemented it all at once. The question arises: how can you implement a large, complex model in GNU MathProg from scratch? Or, generally, in any mathematical programming language?

**Guide to Complex Model Implementation**

There is no universal guide for modeling, but there are good **rules of thumb** to follow. Here is a recommendation, specifically for GNU MathProg:

1.  **Feasibility Assessment:** First, decide whether the problem can be effectively solved by **LP (or MILP)** models. Many problems simply cannot be solved this way (or only with complicated workarounds), or there might be a much more suitable algorithm. This is the hardest part: you essentially have to determine the **decision variables** and how to define the appropriate **search space** by adding constraints and other variables. If you are sure you can implement an LP (or MILP) model, proceed to implementing the model file.
2.  **Data Collection and Parameter Definition:** Collect all available and necessary data. Define **sets and parameters** that will be provided by the data sections. You can implement data files at this point if example problem instances are available. If data is missing or must be calculated afterward, you can always introduce other sets and parameters and calculate data within the model file.
3.  **Define Decision Variables:** Define the decision variables. Keep in mind that the values of all variables should **exactly determine** the real-world outcome. Specifically, you must be able to calculate the objective and decide whether each restriction is violated based on these variables.
4.  **Implement Constraints and Bounds:** Implement all possible rules as **constraints or bounds**. Be aware of two potential mistakes: a problem may be **under-constrained** or **over-constrained** (or both).
      * In **under-constrained** problems, solutions remain in the search space that are infeasible in reality but feasible in the model. These may be found by the solver and reported as fake optimal solutions. You must define additional constraints to exclude these or make existing constraints more restrictive.
      * In **over-constrained** problems, valid, interesting solutions are excluded from the search space and won't be found by the solver. This means some constraints or bounds are too restrictive; you must reformulate or remove them. Remember, you can always introduce new auxiliary variables in the model.
5.  **Define the Objective:** Define the objective function.
6.  **Reporting:** After the `solve` statement, report the relevant details of the found solution in the desired format.

Complex models may have several dozen constraints, so how can you be sure you haven't forgotten any rules? One idea is to focus on **parameters or variables**. Often, parameters are used only once in the model. Even if not, you can list all the roles the parameter or variable must play in the model (as a bound, constraint, objective term, etc.). This makes it easier to spot anything you've missed.

***Applications of the Arbitrary Recipe Model***

Now that our model for arbitrary recipes is ready, we will demonstrate how it works for all the problems mentioned so far in this chapter (except for the maximum-of-minimum production amounts case).

***1. Production Problem with Costs (Problem 14)***

First, we solve **Problem 14**, which introduced raw material costs. Since this is a pure production problem in the original sense, we introduce a recipe to produce each product. All limits are implemented by the `Min_Usage` parameter, while raw material costs and product revenues are implemented by the `Value` parameter. Here is the data section:

```
data;

set Raws := A B C D;
set Products := P1 P2 P3;
set Recipes := MakeP1 MakeP2 MakeP3;

param Min_Usage :=
  B 21000
  D 200
  P2 100
  ;

param Max_Usage :=
  A 23000
  B 31000
  C 450000
  D 200
  P3 10
  ;

param Value :=
  A 1
  B 0.07
  C 0.013
  D 8
  P1 252
  P2 89
  P3 139
  ;

param Recipe_Ratio:
         A   B    C  D P1 P2 P3 := 
MakeP1 200  25 3200  1  1  0  0
MakeP2  50 180 1000  1  0  1  0
MakeP3   0  75 4500  1  0  0  1
;

end;
```

Solving this yields exactly the same result as the original model with raw costs. The optimal profit is **$1,577.45**, with production of 25.48 units of P1, 164.52 units of P2, and 10 units of P3. The output follows:

```
Total Costs: 20876.4
Total Revenue: 22453.9
Profit: 1577.45
Volume of recipe MakeP1: 25.4839
Volume of recipe MakeP2: 164.516
Volume of recipe MakeP3: 10
Consumption of raw A: 13322.6
Consumption of raw B: 31000
Consumption of raw C: 291065
Consumption of raw D: 200
Production of product P1: 25.4839
Production of product P2: 164.516
Production of product P3: 10
```

**2. Diet Problem (Problem 16)**

The second application is the **diet problem**. We solve the exact same problem instance as in **Problem 16**. Here, food types are the **raw materials**, and nutrients are the **products** we want to obtain. Unlike the original production problem (several inputs, one output per recipe), here we have one input (a food type) per recipe producing several nutrients with given ratios.

```
data;
set Raws := F1 F2 F3 F4 F5;
set Products := N1 N2 N3 N4;
set Recipes := EatF1 EatF2 EatF3 EatF4 EatF5;
param Min_Usage :=
N1 2000
N2 180
N3 30
N4 0.04
;
param Value :=
  F1 450
  F2 220
  F3 675
  F4 120
  F5 500
  ;

param Recipe_Ratio:
      F1 F2 F3 F4 F5  N1  N2   N3      N4 :=
EatF1  1  0  0  0  0  30 5.2  0.2  0.0001
EatF2  0  1  0  0  0  20   .  0.7  0.0001
EatF3  0  0  1  0  0  25   2  0.1  0.0001
EatF4  0  0  0  1  0  13 3.6    .  0.0002
EatF5  0  0  0  0  1  19 0.1    .  0.0009
;


end;
```

The solution matches the original diet problem exactly: an optimal cost of 29,707.2, with food consumption amounts of 42.86 for F2, 49.20 for F4, and 28.75 for F5. Note that the objective reported by the solver is -29,707.2 because the profit is determined solely by food costs (revenue is zero, so profit = $0 - \text{Total Costs}$).

```
Total Costs: 29707.2
Total Revenue: 0
Profit: -29707.2
Volume of recipe EatF1: 0
Volume of recipe EatF2: 42.8571
Volume of recipe EatF3: 0
Volume of recipe EatF4: 49.2014
Volume of recipe EatF5: 28.7489
Consumption of raw F1: 0
Consumption of raw F2: 42.8571
Consumption of raw F3: 0
Consumption of raw F4: 49.2014
Consumption of raw F5: 28.7489
Production of product N1: 2042.99
Production of product N2: 180
Production of product N3: 30
Production of product N4: 0.04
```

Recall that we mentioned two ways to represent a diet problem as a production problem. We just implemented the second way (food types as raw materials, nutrients as products). But how could we implement the first case (food types as products, nutrients as raw materials)?

Surprisingly, this **arbitrary recipe model** can handle that as well, simply by **exchanging the roles of products and raw materials**. This highlights the high degree of **symmetry** in the production problem with arbitrary recipes. There are minimum and maximum usages for both raw materials and products. The cost of a raw material is the counterpart to the revenue of a product. Looking at the recipes, there is no fixed "source-target" relationship between raw materials and products; the roles are **interchangeable**. The only slight difference breaking perfect symmetry is the **`Initial_Funds`** feature (an upper limit for total raw material costs). Symmetry would be perfect if `Initial_Funds` were infinite or if we introduced a counterpart feature like maximal revenue.

Finally, let's look at a new example problem to further demonstrate the capabilities of the arbitrary recipe model. We will start with **Problem 14** (production with raw material costs) but add a few modifications.

**Problem 18.**

Solve **Problem 14**, the original production problem, using the exact same data, but with two additional production options.

  * **P1** and **P2** can be produced jointly with slightly different consumption amounts than when produced separately. Producing one unit of both products requires **240 units** of raw material $\text{A}$ (vs. 250 separately), **200 units** of raw material $\text{B}$ (vs. 205 separately), **4,400 units** of raw material $\text{C}$ (slightly more than 4,200 separately), and **2 units** of raw material $\text{D}$ (same as separately).

  * Similarly, **P2** and **P3** can be produced jointly. The costs are **51 units** of raw material $\text{A}$ (slightly more than 50 separately), **250 units** of raw material $\text{B}$ (vs. 255 separately), **5,400 units** of raw material $\text{C}$ (vs. 5,500 separately), and **2 units** of raw material $\text{D}$ (same as separately).

We can solve this by manipulating the data section of the original problem. We add two extra *recipes* to the **Recipes** set, then two rows to the **Recipe\_Ratios** parameter to describe these new recipes. The data section and results are as follows:

```
data;
set Raws := A B C D;
set Products := P1 P2 P3;
set Recipes := MakeP1 MakeP2 MakeP3 Comp1 Comp2;

param Min_Usage :=
  B 21000
  D 200
  P2 100
  ;

param Max_Usage :=
  A 23000
  B 31000
  C 450000
  D 200
  P3 10
  ;

param Value :=
  A 1
  B 0.07
  C 0.013
  D 8
  P1 252
  P2 89
  P3 139
  ;

param Recipe_Ratio:
             A      B       C   D    P1  P2  P3 :=
    MakeP1 200     25    3200   1    1   0   0
    MakeP2  50    180    1000   1    0   1   0
    MakeP3   0     75    4500   1    0   0   1
    Comp1  240    200    4400   2    1   1   0
    Comp2   51    250    5400   2    0   1   1
    ;

end;
```

-----

```
Total Costs: 30495
Total Revenue: 32460.6
Profit: 1965.62
Volume of recipe MakeP1: 0
Volume of recipe MakeP2: 6.25
Volume of recipe MakeP3: 0
Volume of recipe Comp1: 86.875
Volume of recipe Comp2: 10
Consumption of raw A: 21672.5
Consumption of raw B: 21000
Consumption of raw C: 442500
Consumption of raw D: 200
Production of product P1: 86.875
Production of product P2: 103.125
Production of product P3: 10
```

-----

The optimal solution is **$1,965.62$**, which is slightly better than the original **$1,577.45$**. This makes sense because adding new production opportunities widened the search space. We can see that **Comp1** and **Comp2**, the recipes for joint production, are used instead of the original options. However, a small amount (6.25 units) of **P2** is still produced alone. The total production mix has also shifted slightly, with **86.88 units** of $\text{P1}$, **103.13 units** of $\text{P2}$, and **10 units** of $\text{P3}$.

-----

## 5.7 Order Fulfillment

We now have a complete model for the production problem with arbitrary recipes, allowing us to easily implement and solve a wide range of problems, including the diet problem. We will further extend this model with a new, practical feature: **orders**. Orders allow materials to be bought and sold in bulk. This can be more lucrative but requires an "all-or-nothing" decision—orders must be accepted entirely or ignored completely.

Until now, the production problems involved only **real-valued variables**, making them **Linear Programming (LP)** models. Now, we introduce **integer variables**, turning the model into a **Mixed Integer Linear Programming (MILP)** model. While MILP models are easy to implement, solving them can take an unacceptably long time if there are too many **binary variables**. The limit on what constitutes "too many" varies by problem: sometimes dozens are too many, while other times hundreds or thousands work fine. Regardless, this limit is definitely lower than for ordinary real-valued variables in LP models. Unfortunately, **integer programming** is an **NP-Complete problem**, so limitations can often only be slightly improved by better hardware, solvers, or modeling techniques. Nevertheless, integer variables are powerful tools that significantly expand the range of problems solvable by MILP compared to LP.

We will demonstrate how to extend a **GNU MathProg** model with new features while maintaining compatibility with old data files. We will also show how to use a filter within an indexing expression in **GNU MathProg**.

An **order** is a fixed amount of several raw materials (purchased) and/or products (sold when ready). An order can cost money or generate income, and payment may happen before or after production. The same order may be fulfilled multiple times.

Here is the general problem definition for arbitrary recipes with order fulfillment.

**Problem 19.**

Solve **Problem 17**, the production problem with arbitrary recipes, where production proceeds as usual but now includes **orders**. Orders are **optional** but must be acquired (and fulfilled) **completely**, not partially. Each order has the following characteristics:

  * **Fixed Material and Product Amounts:** If a raw material is included, acquiring the order means we **obtain** that material *before* production. If a product is included, acquiring the order means we must **deliver** that product *after* it is produced.
  * **Order Price (Cash Flow):** This can be a cash **gain (revenue)** or a **payment (cost)**. Payment occurs either **before** or **after** production.
  * **Maximum Count:** An order can be acquired and fulfilled multiple times, up to a specified limit.

Raw materials must be purchased from the market (as usual) or obtained via orders. Any **leftover** raw materials after production are **lost** without compensation.

Products must be sold on the market or delivered via an order. Products can only be obtained by producing them. Fulfilling acquired orders is **mandatory**.

Minimum and maximum usage limitations apply as before, corresponding to the **total amounts** of materials/products in possession at one time.

**Total Costs** include expenses/incomes from orders where payment is due *before* production, plus the cost of raw materials purchased from the market. Total Costs are limited by a fixed amount of **initial funds**.

**Total Revenue** includes expenses/incomes from orders where payment is due *after* production, plus revenue from selling products on the market.

The objective is to optimize **Profit**, the difference between Total Revenue and Total Costs.

-----

**Model Analysis and Compatibility**

First, observe that if we assume there are **no orders**, we revert exactly to the production problem with arbitrary recipes.

Without orders, raw materials come solely from market purchases, and revenue comes solely from market sales. We would purchase exactly the raw materials needed and sell all products produced, with no potential loss of materials or alternatives.

Therefore, the new model is designed to work with data files from the "old" arbitrary recipes model, ensuring **backward compatibility**.

-----

**Data Implementation for Orders**

Let's see how to implement the extra data for orders using sets and parameters:

```
set Orders, default {};

param Order_Material_Flow {o in Orders, m in Materials}, >=0, default 0;
param Order_Cash_Flow {o in Orders}, default 0;
param Order_Count {o in Orders}, >=0, integer, default 1;
param Order_Pay_Before {o in Orders}, binary, default 1;
```

  * The additional set **Orders** uses a default value of `{}` (an empty one-dimensional set in GNU MathProg). This ensures original data files (which don't mention `Orders`) still work.
  * **`Order_Material_Flow`**: Similar to `Recipe_Ratio`. If material $m$ is a **raw material**, the order denotes a **purchase** (input). If $m$ is a **product**, it denotes a **delivery** (output). Default is zero.
  * **`Order_Cash_Flow`**: Denotes the cash flow for the order. This is the **only parameter that can be negative**.
      * **Positive value:** A **cost** (payment) for acquiring the order.
      * **Negative value:** A **revenue** (cash gain) from the order.
      * Zero is relevant (e.g., an exchange of materials/products without immediate cash impact).
      * *Note*: A zero material flow with non-zero cash flow represents an investment, though the current model only implements cash flow once (before or after production).
  * **`Order_Count`**: Maximum number of times an order can be acquired. Since orders multiply flows and prices, this must be a non-negative **integer** ($\ge 0$, `integer` keyword). Default is **1** (acquire once or not at all).
  * **`Order_Pay_Before`**: A **binary** parameter (0 or 1) specifying payment timing.
      * **1 (True)**: Payment is due **before** production (contributes to Total Costs).
      * **0 (False)**: Payment occurs **after** production (contributes to Total Revenue).
      * Default is **1**.
  * *Note*: The `binary` and `integer` keywords restrict values for parameters and variables similarly.

-----

**Decision Variables**

We define the following variables, including a new one for order acquisition:

```
var volume {c in Recipes}, >=0;
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;
var ordcnt {o in Orders}, integer, >=0, <=Order_Count[o];
```

  * The main recipe variable (`volume`) and auxiliary variables (`total_costs`, `total_revenue`, `profit`) remain unchanged.
  * **`ordcnt`**: A new variable denoting how many times an order is acquired. Constrained by `Order_Count`, it must be an **integer** (`integer` keyword). This is the **only variable** changing the model from LP to **MILP**. Since orders cannot be partially fulfilled, `ordcnt` must take whole number values (0, 1, 2, ...).

-----

**Material Usage Variables**

Material flow is now more complicated as materials come from/go to different sources. We introduce several usage variables:

  * **Raw Materials** come from market/orders, are used in production, or become leftover (wasted).
  * **Products** come from production and go to market/orders. Leftovers aren't modeled for products (no incentive to keep them vs. selling).
  * Usage refers to the **total amount** in possession at one time.

<!-- end list -->

```
var usage_orders {m in Materials}, >=0;
var usage_market {m in Materials}, >=0;
var usage_production {m in Materials}, >=0;
var usage_leftover {r in Raws}, >=0;
var usage_total {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];
```

All variables are set as $\ge 0$ to ensure quantities are non-negative.

-----

**Material Balance Constraints**

Constraints define relationships between the new usage variables.

**1. Production and Order Calculations**

These calculate amounts flowing through production and orders based on decision variables (`volume` and `ordcnt`).

```
s.t. Material_Balance_Production {m in Materials}: usage_production[m] =
    sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

s.t. Material_Balance_Orders {m in Materials}: usage_orders[m] =
    sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];
```

**2. Total Usage and Balance for Raw Materials**

For raw materials, total amount obtained must equal total amount consumed (production + leftover).

```
s.t. Material_Balance_Total_Raws_1 {r in Raws}:
    usage_total[r] = usage_orders[r] + usage_market[r]; 
    // Total amount obtained = (From Orders) + (From Market)

s.t. Material_Balance_Total_Raws_2 {r in Raws}:
    usage_total[r] = usage_production[r] + usage_leftover[r];
    // Total amount used = (Consumed by Production) + (Leftover)
```

  * `usage_market` and `usage_leftover` are "free" variables the model selects to satisfy balance equations, given the calculated `usage_orders` and `usage_production`.

**3. Total Usage and Balance for Products**

For products, total amount obtained must equal total amount sold/delivered.

```
s.t. Material_Balance_Total_Products_1 {p in Products}:
    usage_total[p] = usage_production[p];
    // Total available amount = (Amount Produced)

s.t. Material_Balance_Total_Products_2 {p in Products}:
    usage_total[p] = usage_orders[p] + usage_market[p];
    // Total disposed = (Delivered to Orders) + (Sold on Market)
```

  * The first constraint sets auxiliary variable `usage_total[p]` equal to `usage_production[p]`. The second ensures this total is covered by deliveries to orders and market sales (`usage_market[p]` is the "free" variable).

-----

**Cost, Revenue, and Profit Calculation**

These constraints calculate financial variables, incorporating order cash flow timing.

```
s.t. Total_Costs_Calc: total_costs =
    sum {r in Raws} Value[r] * usage_market[r] +
    sum {o in Orders: Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

s.t. Total_Revenue_Calc: total_revenue =
    sum {p in Products} Value[p] * usage_market[p] -
    sum {o in Orders: !Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

s.t. Profit_Calc: profit = 
    total_revenue - total_costs;
```

**Order Cash Flow Logic:**

The sign of `Order_Cash_Flow` represents cost (positive) or revenue (negative).

1.  **Payment due BEFORE production (`Order_Pay_Before[o]` is 1):** Cash flow adds to `total_costs`.

      * **Expense** (`Order_Cash_Flow > 0`): `Cost` increases.
      * **Income** (`Order_Cash_Flow < 0`): `Cost` decreases (increasing available funds).
      * Term: `sum Order_Cash_Flow[o] * ordcnt[o]`.

2.  **Payment due AFTER production (`!Order_Pay_Before[o]` is 1):** Cash flow subtracts from `total_revenue`.

      * **Income** (`Order_Cash_Flow < 0`): Subtracting a negative increases `Revenue`.
      * **Expense** (`Order_Cash_Flow > 0`): `Revenue` decreases (treated as negative revenue).
      * Term: `-sum Order_Cash_Flow[o] * ordcnt[o]`.

**Filtering in GNU MathProg**

We use a **filter** in the summation's indexing expression for selective addition:

  * `sum {o in Orders: Order_Pay_Before[o]} ...` iterates only over orders $o$ where `Order_Pay_Before[o]` is true (1).
  * `!Order_Pay_Before[o]` iterates over orders where the parameter is false (0).
  * GNU MathProg allows filtering on all indexing expressions (e.g., `param`, `set`, `var`, `s.t.`, `for`). Summing over an empty set evaluates to zero.

-----

**Complete Model Section and Output**

The final model maximizes profit:

```
set Raws;
set Products;
set Recipes;
set Orders, default {};

check card(Raws inter Products) == 0;
set Materials := Products union Raws;

param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
param Value {m in Materials}, >=0, default 0;
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
param Initial_Funds, >=0, default 1e100;
param Order_Material_Flow {o in Orders, m in Materials}, >=0, default 0;
param Order_Cash_Flow {o in Orders}, default 0;
param Order_Count {o in Orders}, >=0, integer, default 1;
param Order_Pay_Before {o in Orders}, binary, default 1;

var volume {c in Recipes}, >=0;
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;
var ordcnt {o in Orders}, integer, >=0, <=Order_Count[o];
var usage_orders {m in Materials}, >=0;
var usage_market {m in Materials}, >=0;
var usage_production {m in Materials}, >=0;
var usage_leftover {r in Raws}, >=0;
var usage_total {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];

s.t. Material_Balance_Production {m in Materials}: usage_production[m] =
sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];
s.t. Material_Balance_Orders {m in Materials}: usage_orders[m] =
sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];
s.t. Material_Balance_Total_Raws_1 {r in Raws}:
usage_total[r] = usage_orders[r] + usage_market[r];
s.t. Material_Balance_Total_Raws_2 {r in Raws}:
usage_total[r] = usage_production[r] + usage_leftover[r];
s.t. Material_Balance_Total_Products_1 {p in Products}:
usage_total[p] = usage_production[p];
s.t. Material_Balance_Total_Products_2 {p in Products}:
usage_total[p] = usage_orders[p] + usage_market[p];
s.t. Total_Costs_Calc: total_costs =
sum {r in Raws} Value[r] * usage_market[r] +
sum {o in Orders: Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];
s.t. Total_Revenue_Calc: total_revenue =
sum {p in Products} Value[p] * usage_market[p] -
sum {o in Orders: !Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];
s.t. Profit_Calc: profit = total_revenue - total_costs;

maximize Profit: profit;

solve;

printf "Total Costs: %g\n", total_costs;
printf "Total Revenue: %g\n", total_revenue;
printf "Profit: %g\n", profit;
for {o in Orders}
{
printf "Acquiring order %s: %dx\n", o, ordcnt[o];
}
for {c in Recipes}
{
printf "Volume of recipe %s: %g\n", c, volume[c];
}
printf "Raw materials (orders + market -> production + leftover):\n";
for {r in Raws}
{
printf "Consumption of raw %s: %g + %g -> %g + %g (total: %g)\n",
r, usage_orders[r], usage_market[r], usage_production[r],
usage_leftover[r], usage_total[r];
}
printf "Products (production -> orders + market):\n";
for {p in Products}
{
printf "Production of product %s: %g -> %g + %g (total: %g)\n",
p, usage_production[p], usage_orders[p],
usage_market[p], usage_total[p];
}
end;
```

The order of variable and constraint declarations doesn't affect the solution, but a logical flow aids understanding:

1.  **Decision on Orders:** Set `ordcnt`.
2.  **Calculate Order Flows:** Determine `usage_orders`.
3.  **Decision on Production:** Set `volume`.
4.  **Calculate Production Flows:** Determine `usage_production`.
5.  **Adjust Market/Total Flows:** Set `usage_market` and calculate `usage_total` to satisfy material balance.
6.  **Calculate Leftovers:** Determine `usage_leftover`.
7.  **Calculate Financials:** Determine `total_costs`, `total_revenue`, and `profit`.

-----

**Example 1: Problem 14 Data (No Orders)**

The first example uses data from **Problem 14** (arbitrary recipes with costs) but doesn't define the `Orders` set.

```
data;

set Raws := A B C D;
set Products := P1 P2 P3;
set Recipes := MakeP1 MakeP2 MakeP3;

param Min_Usage :=
  B 21000
  D 200
  P2 100
  ;

param Max_Usage :=
  A 23000
  B 31000
  C 450000
  D 200
  P3 10
  ;

param Value :=
  A 1
  B 0.07
  C 0.013
  D 8
  P1 252
  P2 89
  P3 139
  ;

param Recipe_Ratio:
             A      B      C      D    P1  P2  P3 :=
    MakeP1 200     25   3200      1    1   0   0
    MakeP2  50    180   1000      1    0   1   0
    MakeP3   0     75   4500      1    0   0   1
    ;

end;
```

**Results:** The optimal solution matches the original: **$1,577.45$** profit, production of 25.48 P1, 164.52 P2, and 10 P3.

```
Total Costs: 20876.4
Total Revenue: 22453.9
Profit: 1577.45
Volume of recipe MakeP1: 25.4839
Volume of recipe MakeP2: 164.516
Volume of recipe MakeP3: 10
Raw materials (orders + market -> production + leftover):
Consumption of raw A: 0 + 13322.6 -> 13322.6 + 0 (total: 13322.6)
Consumption of raw B: 0 + 31000 -> 31000 + 0 (total: 31000)
Consumption of raw C: 0 + 291065 -> 291065 + 0 (total: 291065)
Consumption of raw D: 0 + 200 -> 200 + 0 (total: 200)
Products (production -> orders + market):
Production of product P1: 25.4839 -> 0 + 25.4839 (total: 25.4839)
Production of product P2: 164.516 -> 0 + 164.516 (total: 164.516)
Production of product P3: 10 -> 0 + 10 (total: 10)
```

*The model works even without orders defined, demonstrating compatibility.*

-----

**Example 2: Problem 18 Data (No Orders, Explicit Empty Sets)**

The second example uses data from **Problem 18** (arbitrary recipes with joint production), but explicitly defines order-related parameters and sets as empty.

```
data;
set Raws := A B C D;
set Products := P1 P2 P3;
set Recipes := MakeP1 MakeP2 MakeP3 Comp1 Comp2;

param Min_Usage :=
  B 21000
  D 200
  P2 100
  ;

param Max_Usage :=
  A 23000
  B 31000
  C 450000
  D 200
  P3 10
  ;

param Value :=
  A 1
  B 0.07
  C 0.013
  D 8
  P1 252
  P2 89
  P3 139
  ;

param Recipe_Ratio:
         A      B      C      D    P1  P2  P3 :=
  MakeP1 200    25     3200   1    1   0   0
  MakeP2 50     180    1000   1    0   1   0
  MakeP3 0      75     4500   1    0   0   1
  Comp1  240    200    4400   2    1   1   0
  Comp2  51     250    5400   2    0   1   1
  ;

param Initial_Funds :=;

set Orders :=;
param Order_Material_Flow :=;
param Order_Cash_Flow :=;
param Order_Count :=;
param Order_Pay_Before :=;


end;
```

**Results:** The optimal solution is again the same: **$1,965.63$** profit, utilizing joint production options `Comp1` and `Comp2`.

```
Total Costs: 30495
Total Revenue: 32460.6
Profit: 1965.63
Volume of recipe MakeP1: 0
Volume of recipe MakeP2: 6.25
Volume of recipe MakeP3: 0
Volume of recipe Comp1: 86.875
Volume of recipe Comp2: 10
Raw materials (orders + market -> production + leftover):
Consumption of raw A: 0 + 21672.5 -> 21672.5 + 0 (total: 21672.5)
Consumption of raw B: 0 + 21000 -> 21000 + 0 (total: 21000)
Consumption of raw C: 0 + 442500 -> 442500 + 0 (total: 442500)
Consumption of raw D: 0 + 200 -> 200 + 0 (total: 200)
Products (production -> orders + market):
Production of product P1: 86.875 -> 0 + 86.875 (total: 86.875)
Production of product P2: 103.125 -> 0 + 103.125 (total: 103.125)
Production of product P3: 10 -> 0 + 10 (total: 10)
```

*The model successfully handles the empty order definition.*

-----

**Problem 20.**

Solve **Problem 18** (production with arbitrary recipes) with these modifications:

  * **Raw Material Limits:** Reset to **50,000 A**, **120,000 B**, **1,000,000 C**, and **1,500 D**.
  * **Initial Funds:** Capped at **35,000**.
  * **Available Orders:** Three orders are available with the following properties:

| | **Ord1** | **Ord2** | **Ord3** |
|:---|:---:|:---:|:---:|
| **Payment Before** | no | no | yes |
| **Expense** | 10,000 | 10,000 | — |
| **Income** | — | — | 500 |
| **Maximum Count** | 10 | 10 | 30 |
| **Obtain A** | 20,000 | 15,000 | 190 |
| **Obtain B** | 10,000 | 10,000 | 20 |
| **Obtain C** | 300,000 | 400,000 | 3,000 |
| **Obtain D** | 500 | 500 | — |
| **Deliver P1** | 40 | 45 | 1 |
| **Deliver P2** | 80 | 70 | — |
| **Deliver P3** | — | 6 | — |

The data section implementation and the solution output are as follows:

```glp
data;

set Raws := A B C D;
set Products := P1 P2 P3;
set Recipes := MakeP1 MakeP2 MakeP3 Comp1 Comp2;

param Min_Usage :=
    B 21000
    D 200
    P2 100
    ;

param Max_Usage :=
    A 50000
    B 120000
    C 1000000
    D 1500
    P3 10
    ;

param Value :=
    A 1
    B 0.07
    C 0.013
    D 8
    P1 252
    P2 89
    P3 139
    ;

param Recipe_Ratio:
              A   B    C  D  P1 P2 P3 :=
      MakeP1 200  25 3200  1  1  0  0
      MakeP2  50 180 1000  1  0  1  0
      MakeP3   0  75 4500  1  0  0  1
      Comp1  240 200 4400  2  1  1  0
      Comp2   51 250 5400  2  0  1  1
      ;

param Initial_Funds := 35000;

set Orders := Ord1 Ord2 Ord3;

param Order_Material_Flow:
            A     B      C   D  P1  P2  P3 :=
    Ord1 20000 10000 300000 500  40  80  0 
    Ord2 15000 10000 400000 500  45  70  6
    Ord3   190    20   3000   0   1   0  0
    ;

param Order_Cash_Flow := # negative means income
    Ord1 10000
    Ord2 10000
    Ord3 -500
    ;

param Order_Count :=
    Ord1 10
    Ord2 10
    Ord3 30
    ;

param Order_Pay_Before :=
    Ord1 0
    Ord2 0
    Ord3 1
    ;

end;
```

```
Total Costs: 26497.3
Total Revenue: 47202.7
Profit: 20705.4
Acquiring order Ord1: 1x
Acquiring order Ord2: 0x
Acquiring order Ord3: 30x
Volume of recipe MakeP1: 0
Volume of recipe MakeP2: 553.716
Volume of recipe MakeP3: 0
Volume of recipe Comp1: 89.1554
Volume of recipe Comp2: 10
Raw materials (orders + market -> production + leftover):
Consumption of raw A: 25700 + 23893.1 -> 49593.1 + 0 (total: 49593.1)
Consumption of raw B: 10600 + 109400 -> 120000 + 0 (total: 120000)
Consumption of raw C: 390000 + 610000 -> 1e+06 + 0 (total: 1e+06)
Consumption of raw D: 500 + 252.027 -> 752.027 + 0 (total: 752.027)
Products (production -> orders + market):
Production of product P1: 89.1554 -> 70 + 19.1554 (total: 89.1554)
Production of product P2: 652.872 -> 80 + 572.872 (total: 652.872)
Production of product P3: 10 -> 0 + 10 (total: 10)
```

The larger raw material limits and generally profitable production lead to a significant objective increase. Orders are also being utilized.

The **optimal profit is 20,705.4**. Total production is **89.16 P1**, **553.72 P2**, and **10 P3**. We acquire **Ord1 once** and **Ord3 30 times** (maximum). Ord3 is a lucrative way to produce and deliver P1. Significant raw materials come from orders, with the rest purchased from the market, resulting in **no leftovers**. Some products are delivered via orders, but amounts are sold on the market in all three cases.

Let's run an experiment to check the integer nature of this model. Since order decisions require integer variables, this is an **MILP** model. However, `glpsol` has a `--nomip` option to relax all integer variables.

**Relaxing** means variables aren't forced to be integers, only constrained by their lower/upper bounds. Relaxing all integer variables converts an MILP into its **LP (Linear Programming) relaxation**.

```bash
glpsol -m model.mod -d data.dat --nomip
```

The model is treated as an LP, which solves much faster, but integer variables can take fractional values (making the solution **infeasible in reality**). Using this option yields:

```
Total Costs: 12163
Total Revenue: 33560
Profit: 21397
Acquiring order Ord1: 1x
Acquiring order Ord2: 0x
Acquiring order Ord3: 30x
Volume of recipe MakeP1: 0
Volume of recipe MakeP2: 550
Volume of recipe MakeP3: 0
Volume of recipe Comp1: 90
Volume of recipe Comp2: 10
Raw materials (orders + market -> production + leftover):
Consumption of raw A: 35700 + 13910 -> 49610 + 0 (total: 49610)
Consumption of raw B: 15600 + 103900 -> 119500 + 0 (total: 119500)
Consumption of raw C: 540000 + 460000 -> 1e+06 + 0 (total: 1e+06)
Consumption of raw D: 750 + 0 -> 750 + 0 (total: 750)
Products (production -> orders + market):
Production of product P1: 90 -> 90 + 0 (total: 90)
Production of product P2: 650 -> 120 + 530 (total: 650)
Production of product P3: 10 -> 0 + 10 (total: 10)
```

The LP relaxation optimal profit is **21,397**, which is **better** than the MILP's 20,705.4. This is natural because the LP relaxation has a wider search space. The LP relaxation is important for the solution process: it solves fast and guarantees an **upper bound** for the MILP optimal solution.

Though the LP relaxation solution looks oddly "integer," the different objective value confirms at least one integer variable is fractional. In fact, **Ord1 is acquired 1.5 times**. This wasn't reported because the order count was printed with `%d`, rounding the value. Using `%f` or `%g` would have revealed the fraction.

-----

## 5.8 Production Problem – Summary

We started with the simplest production problem: deciding the production mix to maximize revenue given limited raw materials. We showed how to add production/consumption limits, optimize different objectives, and factor in raw material costs.

The **diet problem**—satisfying nutritional needs with specific foods—resulted in a very similar implementation. Both can be seen as special cases of a general production problem where recipes involve multiple inputs and outputs.

Finally, we introduced **orders** in the chapter's ultimate model, giving the problem an **integer nature** (orders must be fulfilled completely). This extension adds new supply/demand possibilities while keeping the problem linear. Additional data files, from basic to complex, can be easily implemented and solved with the same single model file.

-----

# Chapter 6: Transportation Problem

We'll introduce another common **optimization problem**, known as the **transportation problem**.

Given a set of **supply points** with a known amount of available resources and a set of **demand points** with a known resource requirement, the objective is to organize the transportation of the resource between these supplies and demands.

It's worth noting that this problem has very fast algorithmic solution techniques [15]. However, we're primarily focused on **modeling techniques**. As we'll see, an LP (Linear Programming) or MILP (Mixed-Integer Linear Programming) formulation can be easily adjusted if the problem definition changes. This can be significantly harder to do with specific solution algorithms.

This chapter also presents some additional capabilities of **GNU MathProg**. The goal is to demonstrate how to handle different cost functions while keeping the model within the class of LP and sometimes MILP models. Finally, we'll add an extra layer of transportation to the problem to show how separately modeled parts of a system can be incorporated into a single, cohesive model.

-----

## 6.1 Basic Transportation Problem

The basic transportation problem can be generally described as follows:

**Problem 21.**

Given a **single material**, a set of **supply points**, and a set of **demand points**. Each supply point has a nonnegative **availability**, and each demand point has a nonnegative **requirement** for the material. The material can be transported from any supply point to any demand point, in any amount. The **unit cost** for transportation is known for each specific pair. The task is to find the transportation amounts such that the following conditions are met:

  * **Available amounts** at supply points are not exceeded.
  * **Required amounts** at demand nodes are satisfied.
  * The **total transportation cost** is minimal.

For simplicity, we'll call the supply points and demand points **supplies** and **demands**. Note that the term "material" can be replaced by any other resource, such as electricity, water, funds, or manpower.

The network connecting the supplies and demands can be represented by a **directed graph** (see Figure 1), where the nodes are the supplies and demands, and the arcs represent the connections between them. The direction of an arc shows the direction of material flow, which always goes from a supply to a demand.

Similar to the production problem, we'll provide an example for the transportation problem. The following data will be used throughout this chapter.

**Problem 22.**

There are four supplies, labeled **S1** through **S4**, and six demands, labeled **D1** through **D6**. The amount of materials available at each supply, required at each demand, and the unit transportation costs between each supply-demand pair are summarized in the following table.

| | **D1** | **D2** | **D3** | **D4** | **D5** | **D6** | **Available** |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **S1** | 5 | 10 | 3 | 9 | 5 | 12 | 100 |
| **S2** | 1 | 2 | 6 | 1 | 2 | 6 | 250 |
| **S3** | 6 | 5 | 1 | 6 | 4 | 8 | 190 |
| **S4** | 9 | 10 | 6 | 8 | 9 | 7 | 210 |
| **Required** | 120 | 140 | 170 | 90 | 110 | 120 | |

(The numbers in the last row and column refer to material amounts; all other numbers refer to the cost per unit of material transported.)

The goal is to transport materials from the supplies to the demands to satisfy requirements at the **minimal cost**.

As discussed in Section 5.6, the first step in mathematical programming is to determine the appropriate **decision variables**. However, in GNU MathProg, we can start by implementing the parameters and sets for the problem data.

In this problem, there are two sets of arbitrary size: the set of **supplies** and the set of **demands**. There are three kinds of numeric parameters that define the transportation problem:

  * The **availability**, provided for each supply.
  * The **requirement**, provided for each demand.
  * The **unit transportation cost**, provided for each supply-demand pair.

Therefore, the implementation can be written as follows. Note that all parameters are specified as nonnegative to prevent incorrect data from being supplied. The names of the sets and parameters are self-explanatory.

```glp
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
param Cost {s in Supplies, D in Demands}, >=0;
```

The decisions to be made in a transportation problem are the **exact transportation amounts**. This amount must be determined for each supply-demand pair, and these decisions are independent. For example, the problem above has 4 supplies and 6 demands, meaning 24 individual decisions must be made about the amounts transported between them. Each of these decisions corresponds to a single variable in the model. Using indexing, this can be expressed in a single `var` statement. The variable name is `tran`.

```glp
var tran {s in Supplies, D in Demands}, >=0;
```

Transportation amounts must be **nonnegative**. A negative amount would model a backward transportation (i.e., from a demand to a supply). While this might be valid in some practical applications, it is explicitly prohibited here.

We can see that the transportation amounts fully describe the situation. Based on these amounts, we can easily calculate the total activity at each supply and demand node, check whether the availability and required amounts are violated, and calculate the total costs. Therefore, no additional decision variables are needed.

Now, we formulate the constraints for the model. Not all possible nonnegative real values for the transportation amounts will result in a feasible solution because there are two restrictions we must account for.

First, the total amount transported **from** a supply **cannot exceed** the availability at that supply. This is a constraint for each supply. Note that the summation is over all demands, as material can be transported to all demands from a specific supply.

```glp
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
```

Similarly, the total amount transported **to** a demand **cannot be less than** the requirement at that demand. This constraint is for each demand, and the summation is now over all supplies, as material can be transported to a specific demand from all supplies.

```glp
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {s in Supplies} tran[s,d] >= Required[d];
```

The **objective** is to minimize the **total cost**. Each transportation amount must be multiplied by the unit cost for that particular connection, and then summed over all connections between supplies and demands.

```glp
minimize Total_Costs:
sum {s in Supplies, d in Demands} tran[s,d] * Cost[s,d];
```

At this point, let's consider whether the problem even has a solution. Two quantities are of special interest: the **total amount of available supply**, which we'll denote as $S$, and the **total amount of required demand**, which we'll denote as $D$. There are three possible scenarios:

  * If $S < D$, the problem is **infeasible**, as there is simply not enough supply available to meet all demands.
  * If $S = D$, the problem is **feasible**, but all supply must be used, and each demand must receive exactly the required amount—no more.
  * If $S > D$, the problem is **feasible**. There can (and will) be leftover material at the supplies, excess deliveries at the demands, or both.

Without actually solving the model, we can check the problem data to ensure it's feasible. This check statement is ideally placed after the parameters but before the variable and constraint definitions. This check is useful because it provides a dedicated error message referring to the `check` statement if a problem is infeasible.

```glp
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
```

Note that in our current model formulation, we allow both leftover materials at supplies (via the $\le$ constraint) and excess deliveries at demands (via the $\ge$ constraint). If these were not allowed, the corresponding two constraints would have to be specified as equations ($\text{=}$) instead. It's worth pointing out that if the transport costs are positive, there's no benefit to transporting more than the demand requires, so the optimization process will eliminate that case anyway.

In some formulations of the transportation problem, $S = D$ is an assumption. Note that in a problem where $S > D$, we can introduce a **dummy demand** with a requirement of $S - D$ and zero transportation costs from all supplies. The purpose of this dummy demand is to receive all the leftover amounts. Therefore, this new problem is equivalent to the original one but has equal total supplies and demands. In conclusion, the $S > D$ case is essentially no more general than the $S = D$ case.

The model description for Problem 21 is now complete. The model section can be enhanced with `printf` statements to display the result once it's found. We'll only show transportation amounts that are greater than zero. The full model section is as follows:

```glp
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
param Cost {s in Supplies, D in Demands}, >=0;
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
var tran {s in Supplies, D in Demands}, >=0;
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {s in Supplies} tran[s,d] >= Required[d];
minimize Total_Costs:
sum {s in Supplies, d in Demands} tran[s,d] * Cost[s,d];
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {s in Supplies, d in Demands: tran[s,d] > 0}
{
printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}
end;
```

For completeness, we also show the **data section** corresponding to **Problem 22**.

```glp
data;

set Supplies := S1 S2 S3 S4;
set Demands  := D1 D2 D3 D4 D5 D6;

param Available :=
    S1 100
    S2 250
    S3 190
    S4 210
;

param Required :=
    D1 120
    D2 140
    D3 170
    D4 90
    D5 110
    D6 120
;

param Cost:
        D1  D2  D3  D4  D5  D6 :=
    S1   5  10   3   9   5  12
    S2   1   2   6   1   2   6
    S3   6   5   1   6   4   8
    S4   9  10   6   8   9   7
;

end;

```

Solving the problem with `glpsol` yields the following result:

```
Optimal cost: 2700.
From S1 to D1, transport 10 amount for 50 (unit cost: 5).
From S1 to D5, transport 90 amount for 450 (unit cost: 5).
From S2 to D1, transport 110 amount for 110 (unit cost: 1).
From S2 to D2, transport 140 amount for 280 (unit cost: 2).
From S3 to D3, transport 170 amount for 170 (unit cost: 1).
From S3 to D5, transport 20 amount for 80 (unit cost: 4).
From S4 to D4, transport 90 amount for 720 (unit cost: 8).
From S4 to D6, transport 120 amount for 840 (unit cost: 7).
```

The results of the transportation problem can be fitted back into the original data table by substituting the unit costs with the decided transportation amounts. Zero amounts can be omitted entirely.

| | **D1** | **D2** | **D3** | **D4** | **D5** | **D6** | **Available** |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **S1** | 10 | | | | 90 | | 100 |
| **S2** | 110 | 140 | | | | | 250 |
| **S3** | | | 170 | | 20 | | 190 |
| **S4** | | | | 90 | | 120 | 210 |
| **Required** | 120 | 140 | 170 | 90 | 110 | 120 | |

This representation clarifies the elements of the model. The **decisions** are represented by the inner cells, while the **constraints** are represented by the rightmost column and the bottom row. Each supply constraint dictates that the sum in that row must be at most the number on the right. Each demand constraint dictates that the sum in that column must be at least the number at the bottom. Since the total supply and total demand are equal in this example, all constraints can only hold true as an **equation** ($\text{=}$). This is exactly the case throughout the table.

Examining the results, we can see that the optimal solution attempts to use the **cheapest unit costs** whenever possible, but not always. For instance, transport from **S4 to D4** is chosen despite not being the absolute cheapest method, either from supply S4 or to demand D4. However, it proves to be a good choice because the remaining transportation can then be done more cheaply. Note that based on this single run of the model, we cannot be certain that this is the only optimal solution.

There are many other examples of the transportation problem publicly available; see, for example, [16].

-----

## 6.2 Connections as an Index Set

Based on the complete solution presented in Section 6.1, we will now slightly enhance the implementation. As mentioned previously, in GNU MathProg, we can introduce additional parameters and sets to simplify the model formulation. These can either be defined on the spot, read from a separate data section outside the model, or allow both as a default value.

Notice that the indexing expression `s in Supplies, d in Demands` appears in four different contexts:

  * In the `Cost` parameter, as it is defined for all such pairs.
  * In the `tran` variable, as it is defined for all such pairs.
  * In the objective function, as it is a sum over all such pairs.
  * In the post-processing work, because transport amounts are printed for all such pairs. (In this case, there is a filter that only allows nonzero amounts to be reported.)

It would be a serious error to make a mistake in this indexing—for example, by switching the order of `Supplies` and `Demands`. To avoid such errors and slightly reduce redundancy, we can introduce a two-dimensional set of these pairs. Each supply and each demand are considered to be part of a **connection**. Thus, the transportation problem involves deciding on transportation amounts for each connection. The set `Connections` can be introduced as follows:

```glp
set Connections := setof {s in Supplies, d in Demands} (s,d);
```

We are using a new GNU MathProg operator here: `setof`. This is a general method for defining sets based on data previously defined in the model section. The `setof` operator is followed by an indexing expression, then by a simple expression. The resulting set is formed by evaluating the final expression for all possible indices in the indexing expression. It's similar to `sum`, but instead of adding elements up, it forms a set of them. Note that the indexing expression in `setof` can be filtered, giving us fine control over the set being defined. Since the result is a set, duplicates are removed, and the result can also be empty if everything is filtered out; however, neither of these is the case here.

In fact, this usage of `setof` is quite simple: it just collects all possible pairs formed by the two sets. The set `Connections` is a **Cartesian product** of the sets `Supplies` and `Demands`. There is another built-in operator called `cross` for the Cartesian product of two sets, which allows for a simpler definition of the set `Connections` as follows. Either definition can be used, as they are equivalent.

```glp
set Connections := Supplies cross Demands;
```

The dimension of the sets `Supplies` and `Demands` is 1 because they contain simple elements, whereas the dimension of `Connections` is 2 because it contains pairs (or 2-tuples). In GNU MathProg, a set can have as many as 20 dimensions. If a set contains $n$-tuples, then its dimension is $n$. Sets with different dimensions **cannot be mixed** together with set operations like `union`, `inter`, or `diff`. Even a one-dimensional empty set is considered different from a two-dimensional empty set.

The dimension of a set determines how it can be used in indexing expressions. One-dimensional sets are indexed by a single introduced symbol, like `s in Supplies` or `d in Demands`. However, two- (and higher-) dimensional sets are indexed by a tuple element, like `(s,d) in Connections`. In general, an indexing expression may contain many sets with different dimensions, each one introducing one or more new index symbols that can be referenced.

In short, everywhere we see `s in Supplies, d in Demands` in an indexing expression, we can now write `(s,d) in Connections`, as shown in the complete model below.

```glp
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set Connections := Supplies cross Demands;
param Cost {(s,d) in Connections}, >=0;
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
var tran {(s,d) in Connections}, >=0;
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {s in Supplies} tran[s,d] >= Required[d];
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d];
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {(s,d) in Connections: tran[s,d] > 0}
{
printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}
end;
```

The resulting new model file is **equivalent** to the original one; therefore, solving the same data file describing **Problem 22** should yield the exact same result.

To illustrate how explicitly introducing an index set like `Connections` can be beneficial, consider the following new problem:

**Problem 23.**

Solve **Problem 22**, the original example transportation problem, with one modification: only connections whose unit costs are **no greater than 7** are allowed.

We introduce a parameter to denote the unit cost limit.

```
param Max_Unit_Cost, default 7;
```

Note that by providing a default value of **7** instead of setting the parameter equal to **7**, we allow the possibility to **alter** `Max_Unit_Cost` by providing a value in the data section, if we ever want to choose a different limit.

One possible solution is to express a new constraint that explicitly finds each prohibited connection and sets the transported amount there to zero, effectively excluding the connection from the model.

```
s.t. Connections_Prohibited
{s in Supplies, d in Demands: Cost[s,d] > Max_Unit_Cost}: tran[s,d] = 0;
```

However, in this case, we use many variables in the model just to fix them at zero. It's possible **not to include** those variables in the model formulation at all, and this can be done by introducing a **filter** in the `setof` expression defining the **`Connections`** set.

```
set Connections :=
setof {s in Supplies, d in Demands: Cost[s,d] <= Max_Unit_Cost} (s,d);
```

With this filter, we only include allowed connections in the **`Connections`** set. Therefore, without modifying other parts of the model, the exclusion is implemented—the indexing expressions `(s,d)` in `Connections` just iterate over a **smaller set** in the background.

Note that **care must be taken** with this method, because now the following constraint would cause an **out-of-domain error**:

```
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
```

The problem is that `tran[s,d]` is iterated over **all pairs** of `s` in **`Supplies`** and `d` in **`Demands`**, but the variable is simply **not defined** for all such pairs now. This is in strong contrast with the first approach where they **are defined**, but explicitly set to zero. We must now ensure that the sum only considers **allowed connections**, which can be done as follows:

```
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {(s,d) in Connections} tran[s,d] <= Available[s];
```

In this case, the role of $s$ and $d$ are different in the sum operator. Despite being used as an index, $s$ is a **constant value**. But $d$ is introduced **inside** the indexing expression, so it can be freely chosen by the sum. The meaning of the indexing expression is that all $(s,d)$ pairs are selected for which $s$ is a given value. This effectively sums over all demands that are allowed to be connected to the particular $s$, and the constraint works as desired.

The point is that an $n$-tuple index in an indexing expression can have **constant coordinates** as long as it contains **at least one new, free symbol** for a coordinate. In the GNU MathProg language documentation, an index symbol introduced by an indexing expression is called a **dummy index**. Dummy indices are **freely selected** by the indexing expression in all possible ways and can be used as constants afterward. Here, $s$ is a dummy index from the indexing of the constraint, whereas $d$ is a dummy index from the indexing expression of the sum operator, but **both** can be referred to in the operand of the sum (`tran[s,d]`).

The model contains another constraint for the demands; this must also be updated similarly, by replacing `s in Supplies` with `(s,d) in Connections`. Our model section for the new problem is now ready.

Solving it with the original problem data reports an optimal solution of **2790**, slightly worse than the original solution of **2700**. This isn't surprising, as the original solution used a unit cost of **8**. By excluding it, it's theoretically possible to obtain the same objective another way, but that's not the case here. The moral of the story is that, contrary to first thought, excluding expensive connections can be a **disadvantage** in the transportation problem.

Note that while the transportation problem has feasible solutions if total supplies are **no less** than total demands, this is **no longer guaranteed** if certain connections are prohibited.

-----

## 6.3. Increasing Unit Costs

So far, we've assumed a **linear transportation cost** at each connection. The amount is simply multiplied by a constant to obtain the cost. The relationship between the total amount transported and the total cost incurred can be schematically represented as in Figure 2. The red line represents the calculated total costs, but the area above that curve can be regarded as "feasible" too. The logic behind this is that we're allowed to pay more than needed; it just doesn't make sense to do so.

[Image of cost vs amount linear graph]

The term **proportional cost** is also widely used. Proportional cost means a cost where the ratio of total amounts and costs is a **parameter constant**.

In practice, the total cost to be paid for some resource is **not always proportional** to the amount used. A few common examples are shown in this and the following sections, which can be modeled as a **Linear Program (LP)** or at least as a **Mixed-Integer Linear Program (MILP)** model.

The first example is when the unit cost is constant up to a certain threshold, after which it **increases** to a higher constant value. This is common in practice, often called the **law of diminishing returns**. This means that spending an additional unit for costs yields **less and less return**. This is equivalent to having a unit price that **increases** with the total amount already obtained.

**Problem 24.**

Solve Problem 21, the **transportation problem**, with one modification: there are two **unit costs** for transportation—one for amounts **below** a given **threshold** and a higher unit cost for **surplus amounts above** that threshold.

-----

**Problem 25.**

Solve Problem 22, the original example transportation problem, with one modification: the given unit costs are only for transportation amounts **below 100 units**. Above that limit, costs are **increased by 25%** per material unit transported.

Schematically, the **cost function** can be represented as in **Figure 3**. Again, the region above the red curve denoting the **total costs** can be termed as **feasible** because we can pay more if we want; it's just not advantageous and, therefore, will never happen.

In the example problem, all thresholds and increased costs are **uniform** across the connections. Note that this isn't necessarily always the case. In other problem definitions, each connection may have **unique thresholds**, basic, and increased unit costs.

The first step is to define the **data** in the model needed to calculate the alternative cost function. Two parameters are introduced: **`CostThreshold`** is the amount over which the unit costs increase, and **`CostIncPercent`** denotes the rate of increase in **percent**. Note that the increase must be positive.

```
param CostThreshold, >=0;
param CostIncPercent, >0;
```

In Problem 25, the following values can be given in the **data** section.

```
param CostThreshold := 100;
param CostIncPercent := 25;
```

We introduce another parameter, **`CostOverThreshold`**, which calculates the increased unit cost using the following formula. Note that the original unit cost is `Cost[s,d]`.

```
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 + CostIncPercent / 100);
```

At this point, we have all the required data defined in the model. The question is how to **implement the correct calculation of total costs**, regardless of whether the amount is below or above the threshold.

First, we can simply introduce two variables: **`tranBase`** for amounts below and **`tranOver`** for amounts above the threshold.

```
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;
var tranOver {(s,d) in Connections}, >=0;
```

Note that both quantities are **nonnegative**. The amount to be transported over the threshold for the increased cost (`tranOver`) is **unlimited**; however, we can only transport a **limited amount** at the original cost (`tranBase`). Therefore, `tranBase` gets an **upper bound**: the threshold itself. Note that the decision of transported amounts is **individual for each connection**; therefore, all these variables are defined for each connection.

The amounts represented by `tranBase` and `tranOver` are simply a **separation of the total amount** represented by `tran`. Therefore, a **constraint** is provided to ensure that the sum of the former two equals `tran` for each connection.

```
s.t. Total_Transported {(s,d) in Connections}:
tran[s,d] = tranBase[s,d] + tranOver[s,d];
```

Instead of using `tran` in the objective, we can refer to the **`tranBase` and `tranOver` parts separately** and multiply these amounts by their corresponding unit costs (`Cost` and `CostOverThreshold`).

```
minimize Total_Costs: sum {(s,d) in Connections}
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);
```

Our model is ready, but consider one thing. Now, the `tranBase` and `tranOver` amounts can be set **freely**. For example, if the threshold is **100**, then transporting **130 units** in total can be done as $\text{tranBase}=100$ and $\text{tranOver}=30$, but also as $\text{tranBase}=50$ and $\text{tranOver}=80$. In the latter case, the total cost is not calculated correctly in the objective, but it is **still allowed by the constraints**.

But the model works because the unit cost above the threshold is **strictly higher** than the cost below it. Therefore, the optimal solution would **not attempt** transporting any amounts over the threshold unless all possible amounts are transported below it (i.e., $\text{tranBase}=100$ in the example). Spending more is allowed as **feasible solutions** in the model, but these cases are **eliminated by the optimization procedure**. Consequently, in the optimal solution, there is either **zero amount above the threshold** or the **full amount below it** for each connection. The costs are calculated correctly in both scenarios.

-----

The full model section for the transportation problem with increasing rates is shown here.

```
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set Connections := Supplies cross Demands;
param Cost {(s,d) in Connections}, >=0;
param CostThreshold, >=0;
param CostIncPercent, >0;
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 + CostIncPercent / 100);
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
var tran {(s,d) in Connections}, >=0;
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;
var tranOver {(s,d) in Connections}, >=0;
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {s in Supplies} tran[s,d] >= Required[d];
s.t. Total_Transported {(s,d) in Connections}:
tran[s,d] = tranBase[s,d] + tranOver[s,d];
minimize Total_Costs: sum {(s,d) in Connections}
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {(s,d) in Connections: tran[s,d] > 0}
{
printf "From %s to %s, transport %g=%g+%g " &
"amount for %g (unit cost: %g/%g).\n",
s, d, tran[s,d], tranBase[s,d], tranOver[s,d],
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]),
Cost[s,d], CostOverThreshold[s,d];
}
```

Solving the model with a value of **100** for `CostThreshold` and **25** for `CostIncPercent`, we get the following result.

```
Optimal cost: 2772.5.
From S1 to D5, transport 100=100+0 amount for 500 (unit cost: 5/6.25).
From S2 to D1, transport 120=100+20 amount for 125 (unit cost: 1/1.25).
From S2 to D2, transport 130=100+30 amount for 275 (unit cost: 2/2.5).
From S3 to D2, transport 10=10+0 amount for 50 (unit cost: 5/6.25).
From S3 to D3, transport 170=100+70 amount for 187.5 (unit cost: 1/1.25).
From S3 to D5, transport 10=10+0 amount for 40 (unit cost: 4/5).
From S4 to D4, transport 90=90+0 amount for 720 (unit cost: 8/10).
From S4 to D6, transport 120=100+20 amount for 875 (unit cost: 7/8.75).
```

The **optimal solution is 2,772.5 units**, and in some cases, the thresholds are **surpassed**. The objective is slightly worse than the original 2,700. This is not surprising because the current and original problems only differ due to the **increased costs**. If we look closely at the transportation amounts, we can observe that the increased unit costs over the **100 threshold** not only change the pricing but also affect the **optimal transportation decisions**.

-----

## 6.4 Economy of Scale

The previous section dealt with **increased unit costs**, but what happens when unit costs **decrease above the threshold**?

The case where larger amounts provide **lower unit prices** is called **economy of scale**. This is common in practice. In production, higher volume allows investment costs to be **shared** among more products, decreasing the **cost per product**. In trade, you might get a **discount** for purchasing in larger volumes.

Here, we present the simplest case of **economy of scale**, where unit costs simply decrease above a threshold.

**Problem 26.**

Solve Problem 21, the **transportation problem**, with one modification: there are two **unit costs** for transportation—one for amounts **below** a given **threshold** and a **lower** unit cost for **surplus amounts above** that threshold.

-----

**Problem 27.**

Solve Problem 22, the original example transportation problem, with one modification: the given unit costs are only for transportation amounts **below 100 units**. Above that limit, costs are **decreased by 25%** per amount transported.

The only difference between this problem and the previous one is that the unit costs above the threshold are now **lower**, not higher. It is tempting to address this by slightly modifying our code to calculate decreasing costs. The parameter `CostIncPercent` is renamed to **`CostDecPercent`**, and `CostOverThreshold` is calculated accordingly.

```
param CostDecPercent, >0, <=100;
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 - CostDecPercent / 100);
```

However, if we solve the model, the results **do not reflect reality**.

```
Optimal cost: 2025.
From S1 to D1, transport 10=0+10 amount for 37.5 (unit cost: 5/3.75).
From S1 to D5, transport 90=0+90 amount for 337.5 (unit cost: 5/3.75).
From S2 to D1, transport 110=0+110 amount for 82.5 (unit cost: 1/0.75).
From S2 to D2, transport 140=0+140 amount for 210 (unit cost: 2/1.5).
From S3 to D3, transport 170=0+170 amount for 127.5 (unit cost: 1/0.75).
From S3 to D5, transport 20=0+20 amount for 60 (unit cost: 4/3).
From S4 to D4, transport 90=0+90 amount for 540 (unit cost: 8/6).
From S4 to D6, transport 120=0+120 amount for 630 (unit cost: 7/5.25).
```

The optimal solution is **2,025**, which is much better than the original 2,700. But the details show **zero transportation amounts below the threshold** ($\text{tranBase}=0$), meaning the total amount is being transported at the lower price. This is clearly **not allowed**, as we can only use lower unit costs *after* filling the amounts below the threshold at the higher rate.

When the cost above the threshold was **higher**, the model worked perfectly. Now that the cost above the threshold is **lower**, the model is incorrect. Why?

  * If unit costs **increase**, amounts below the threshold ($\text{tranBase}$) are filled first because it's cheaper. Non-optimal approaches are **ruled out by the optimization procedure**.
  * If unit costs **decrease**, optimization **prefers amounts above the threshold** ($\text{tranOver}$) because of the lower cost. However, this lower cost is a "**right**" that must be earned by filling the base amount first. This is **not enforced by the constraints**, so the reported solution is **infeasible in reality**.

To understand this, observe the schematic representation of the economy of scale (see **Figure 4**).

One property of **Linear Programming (LP)** problems is that their search space is always **convex**. This means if you have two feasible solutions and take a **convex combination** of them, the result is also feasible.

However, in **Figure 4**, the feasible region is **not convex**. We must allow feasibility on both red line segments, but their **convex combinations fall into the infeasible region**. We can see why this wasn't a problem with increasing costs: the convex combinations fell into the **feasible region**—those cases didn't make sense in reality, but the model included them, and the problem could be modeled by LP.

Since the feasible region is not convex, the **economy of scale cannot be modeled by LP**. We must add **integer variables**, making the model a **Mixed-Integer Linear Program (MILP)**. Our goal is to ensure that amounts below the threshold ($\text{tranBase}$) are **fully utilized** whenever any amounts are transported above the threshold ($\text{tranOver}$).

For each connection, we introduce a **binary variable**, $\text{isOver}$.

```
var isOver {(s,d) in Connections}, binary;
```

$\text{isOver}$ determines whether we are **entitled** (= 1) or not (= 0) to transport for the lower unit cost. This binary variable introduces a **discrete nature** to the problem, making the search space **non-convex**. Depending on the value of $\text{isOver}$:

  * If $\text{isOver}=0$, we **cannot** use the lower cost, so amounts above the threshold ($\text{tranOver}$) **must be zero**.
  * If $\text{isOver}=1$, we **must** earn the right to use lower costs, so amounts below the threshold ($\text{tranBase}$) **must be maximal** (equal to $\text{CostThreshold}$).

**The Big-M Constraint Technique**

It's a common problem to want a linear constraint (like $A \ge B$) to be **active only if a condition is met**. The condition is often represented by a binary variable $x$.

The modeling technique used is called the **big-M constraint**. First, arrange the constraint into the form $B - A \le 0$, then find a **positive upper bound** for $B - A$ (denoted $\mathbf{M}$). This bound must be large enough to include all possible values for variables in the expression.

Then, include the following constraint:

$$B - A \le M \cdot (1 - x)$$

Let's investigate what this does:

1.  If **$x = 1$**, the constraint reduces to $B - A \le 0$, which is what we wanted.
2.  If **$x = 0$**, the constraint reduces to $B - A \le M$. Since $M$ is larger than any possible value of $B - A$, the constraint becomes **redundant**—exactly what we wanted.

This is a general technique for the **conditional inclusion of linear constraints** in MILP models.

**Implementing the Economy of Scale Constraints**

There are two conditional constraints to implement:

1.  If $\text{isOver}=0$, then $\text{tranOver}=0$ must hold.
2.  If $\text{isOver}=1$, then $\text{tranBase}=\text{CostThreshold}$ must hold.

For the first constraint, we define the big-M parameter as the sum of all available supplies.

```
param M := sum {s in Supplies} Available[s];
s.t. Zero_Over_Threshold_if_Threshold_Not_Chosen {(s,d) in Connections}:
tranOver[s,d] <= M * isOver[s,d];
```

When $\text{isOver}[s,d]=0$, then $\text{tranOver}[s,d] \le 0$ is enforced (so it must be zero). $M$ must be larger than any sensible value of $\text{tranOver}[s,d]$.

For the second constraint:

```
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
tranBase[s,d] >= CostThreshold - M * (1 - isOver[s,d]);
```

However, we can use a **smarter big-M**. The big-M can be set as low as $\mathbf{CostThreshold}$. With this value, the constraint can be rearranged into a more readable form:

```
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
tranBase[s,d] >= CostThreshold * isOver[s,d];
```

If $\text{isOver}[s,d]=1$, then $\text{tranBase}[s,d] \ge \text{CostThreshold}$ is enforced. If $\text{isOver}[s,d]=0$, the constraint is redundant.

We added the variable $\text{isOver}$ and these two constraints to the previous model, and now our model for the transportation problem with **economy of scale** is ready.

**Full MILP Model for Economy of Scale**

```
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set Connections := Supplies cross Demands;
param Cost {(s,d) in Connections}, >=0;
param CostThreshold, >=0;
param CostDecPercent, >0, <=100;
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 - CostDecPercent / 100);
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
var tran {(s,d) in Connections}, >=0;
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;
var tranOver {(s,d) in Connections}, >=0;
var isOver {(s,d) in Connections}, binary;

s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {s in Supplies} tran[s,d] >= Required[d];
s.t. Total_Transported {(s,d) in Connections}:
tran[s,d] = tranBase[s,d] + tranOver[s,d];
param M := sum {s in Supplies} Available[s];
s.t. Zero_Over_Threshold_if_Threshold_Not_Chosen {(s,d) in Connections}:
tranOver[s,d] <= M * isOver[s,d];
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
# tranBase[s,d] >= CostThreshold - M * (1 - isOver[s,d]);
tranBase[s,d] >= CostThreshold * isOver[s,d];
minimize Total_Costs: sum {(s,d) in Connections}
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {(s,d) in Connections: tran[s,d] > 0}
{
printf "From %s to %s, transport %g=%g+%g " &
"amount for %g (unit cost: %g/%g).\n",
s, d, tran[s,d], tranBase[s,d], tranOver[s,d],
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]),
Cost[s,d], CostOverThreshold[s,d];
}
```

We get the following results for **Problem 27**:

```
Optimal cost: 2625.
From S1 to D1, transport 10=10+0 amount for 50 (unit cost: 5/3.75).
From S1 to D5, transport 90=90+0 amount for 450 (unit cost: 5/3.75).
From S2 to D1, transport 110=100+10 amount for 107.5 (unit cost: 1/0.75).
From S2 to D2, transport 140=100+40 amount for 260 (unit cost: 2/1.5).
From S3 to D3, transport 170=100+70 amount for 152.5 (unit cost: 1/0.75).
From S3 to D5, transport 20=20+0 amount for 80 (unit cost: 4/3).
From S4 to D4, transport 90=90+0 amount for 720 (unit cost: 8/6).
From S4 to D6, transport 120=100+20 amount for 805 (unit cost: 7/5.25).
```

Now, the optimal solution is **2,625**. Observe that each time a lower cost is used (i.e., $\text{tranOver}>0$), the **full threshold of 100 is first reached** ($\text{tranBase}=100$). Unlike the case for increasing unit costs, the reduced costs above the threshold now only affect the objective through pricing; the optimal solution remains the same in terms of transported amounts.

Remember that this model contains **binary variables**, making it an **MILP**. If the number of binary variables is large, computational time may increase dramatically.

-----

## 6.5 Fixed Costs

We have considered different scenarios for unit costs. These were all **proportional costs**. In some cases, **fixed costs** may also be present.

**Problem 28.**

Solve Problem 21, the transportation problem, with the following modification: for each connection, there is a **fixed cost** to be paid once for **establishing it** in order to use that connection.

The **fixed cost** does not depend on the actual amounts. We pay it once to use a connection. We may choose **not to establish a connection**, but then we cannot transport anything between that supply and demand point.

The example problem to be solved here is:

**Problem 29.**

Solve Problem 28 using data from the original **Problem 22**, and the following fixed establishment costs per connection.

| | **D1** | **D2** | **D3** | **D4** | **D5** | **D6** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **S1** | 50 | 50 | 80 | 50 | 200 | 50 |
| **S2** | 200 | 50 | 50 | 50 | 200 | 50 |
| **S3** | 50 | 200 | 200 | 50 | 50 | 50 |
| **S4** | 50 | 50 | 50 | 200 | 200 | 200 |

We start with the general implementation from **Section 6.2**. We add a new parameter, **`FixedCost`**, and implement the matrix in Problem 29 in the data section.

```
param FixedCost {(s,d) in Connections}, >=0;
```

```
param FixedCost:
D1 D2 D3 D4 D5 D6 :=
S1 50 50 80 50 200 50
S2 200 50 50 50 200 50
S3 50 200 200 50 50 50
S4 50 50 50 200 200 200
;
```

If we observe the schematic representation of the fixed cost (**Figure 5**), we can see that the curve is again **not convex**.

We need a **binary decision variable** to distinguish the two cases. **`tranUsed`** equals one if we choose to establish the connection. If `tranUsed` is zero, then transportation on that connection **must also be zero**.

```
var tranUsed {(s,d) in Connections}, binary;
```

Two things must be enforced. First, if we **do not establish the connection** ($\text{tranUsed}=0$), there must be **no amount transported** ($\text{tran}=0$). This can be done with a **big-M constraint**.

```
param M := sum {s in Supplies} Available[s];
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= M * tranUsed[s,d];
```

The coefficient $M$ must be large enough not to exclude legitimate solutions. To create **stricter constraints**, we can use the **minimum of the available amount at the supply and the required amount at the demand**.

```
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= min(Available[s],Required[d]) * tranUsed[s,d];
```

Second, we must include the fixed establishment cost in the **objective function**.

```
minimize Total_Costs: sum {(s,d) in Connections}
(tran[s,d] * Cost[s,d] + tranUsed[s,d] * FixedCost[s,d]);
```

The full model section is the following.

**Full MILP Model for Fixed Costs**

```
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set Connections := Supplies cross Demands;
param Cost {(s,d) in Connections}, >=0;
param FixedCost {(s,d) in Connections}, >=0;
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
var tran {(s,d) in Connections}, >=0;
var tranUsed {(s,d) in Connections}, binary;
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {s in Supplies} tran[s,d] >= Required[d];
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= min(Available[s],Required[d]) * tranUsed[s,d];
minimize Total_Costs: sum {(s,d) in Connections}
(tran[s,d] * Cost[s,d] + tranUsed[s,d] * FixedCost[s,d]);
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {(s,d) in Connections: tran[s,d] > 0}
{
printf "From %s to %s, transport %g " &
"amount for %g (unit cost: %g, fixed: %g).\n",
s, d, tran[s,d],
tran[s,d] * Cost[s,d] + FixedCost[s,d], Cost[s,d], FixedCost[s,d];
}
end;
```

The original optimal solution (zero fixed costs) is **2,700**. If nonzero fixed costs are present, the following output is reported:

```
Optimal cost: 3640.
From S1 to D1, transport 100 amount for 550 (unit cost: 5, fixed: 50).
From S2 to D1, transport 20 amount for 220 (unit cost: 1, fixed: 200).
From S2 to D2, transport 140 amount for 330 (unit cost: 2, fixed: 50).
From S2 to D4, transport 90 amount for 140 (unit cost: 1, fixed: 50).
From S3 to D3, transport 80 amount for 280 (unit cost: 1, fixed: 200).
From S3 to D5, transport 110 amount for 490 (unit cost: 4, fixed: 50).
From S4 to D3, transport 90 amount for 590 (unit cost: 6, fixed: 50).
From S4 to D6, transport 120 amount for 1040 (unit cost: 7, fixed: 200).
```

The objective is **3,640**. The connections used are **different**. The total establishment cost paid is **850**.

-----

## 6.6 Flexible Demands

In some cases, constraints are **soft constraints**. This means we are interested in solutions that **violate them**, provided the **extent of the violation** is minimized. This can be handled using **penalties**, terms added to the objective function proportional to the extent a constraint is violated.

**Problem 30.**

Solve Problem 21, the transportation problem with the addition of **flexible demands**. For each demand point, we do not require the exact requirement to be served. Instead, a **penalty** is introduced proportional to the difference between the required amount and the actually served amount.

-----

**Problem 31.**

Solve Problem 22 with flexible demands. There is a **surplus** and a **shortage penalty constant**.

Two scenarios:

  * **"Small" penalty:** Shortage penalty 3, surplus penalty 1.
  * **"Large" penalty:** Shortage penalty 15, surplus penalty 10.

The starting point is the model with connections from **Section 6.2**. We add parameters **`ShortagePenalty`** and **`SurplusPenalty`**.

Let's investigate penalties as a function of the total materials delivered (**Figure 6**). **Linear penalty functions** are assumed. Although the curve is "broken," the **feasible region is still convex**, suggesting a **pure LP model**.

We introduce an auxiliary variable, **`satisfied`**, denoting the **total amount delivered** to a demand.

```
var satisfied {d in Demands}, >=0;
s.t. Calculating_Demand_Satisfied {d in Demands}:
satisfied[d] = sum {s in Supplies} tran[s,d];
```

**Method 1: Single Penalty Variable**

The penalty function can be modeled by two linear constraints.

```
var penalty {d in Demands}, >=0;
s.t. Shortage_Penalty_Constraint {d in Demands}:
penalty[d] >= ShortagePenalty * (Required[d] - satisfied[d]);
s.t. Surplus_Penalty_Constraint {d in Demands}:
penalty[d] >= SurplusPenalty * (satisfied[d] - Required[d]);
```

The penalty variable is included in the objective function. The optimization procedure eliminates excessively high penalty values, so in the optimal solution, one constraint will be strict (or both if the requirement is met exactly).

```
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
sum {d in Demands} penalty[d];
```

**Method 2: Shortage and Surplus Variables**

Alternatively, we can use variables for the exact shortage and surplus amounts.

```
var surplus {d in Demands}, >=0;
var shortage {d in Demands}, >=0;
s.t. Calculating_Exact_Demands {d in Demands}:
Required[d] - shortage[d] + surplus[d] = satisfied[d];
```

The optimization procedure ensures that **either shortage or surplus is zero** in the optimal solution.

```
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
sum {d in Demands} (shortage[d] * ShortagePenalty +
surplus[d] * SurplusPenalty);
```

**Results**

For the **"small" penalty scenario** ($\text{ShortagePenalty}=3, \text{SurplusPenalty}=1$), total costs are cut by nearly half (**1,450**). There are **vast shortages** because the unit cost of transportation exceeds the gain from satisfying demand.

For the **"large" penalty scenario** ($\text{ShortagePenalty}=15, \text{SurplusPenalty}=10$), the solution is **exactly the same as the original** (2,700). The shortage penalty is more costly than transporting the material, so there are no shortages.

-----

## 6.7 Adding a Middle Level

What happens when the network is more complex, for example, if there is a **third set of nodes**?

**Problem 32.**

Solve **Problem 21** extended by introducing a middle level of **centers**.

Material flows from supply nodes to center nodes (A-type connections), then from center nodes to demand nodes (B-type connections). If a center is utilized, a **one-time establishment cost** must be paid.

**Problem 33.**

Solve **Problem 21** with centers using specific data (S1-S4, C1-C2, D1-D6). Two scenarios:

  * **"Small" establishment cost:** C1=1200, C2=1400.
  * **"Large" establishment cost:** C1=12000, C2=14000.

We define sets `Supplies`, `Centers`, `Demands`, and parameters `Available`, `Required`, `CostA`, `CostB`, and `EstablishCost`.

We define variables `tranA` and `tranB` for transportation amounts. We also need `atCenter` (amount through center) and the binary variable `useCenter` (is center used?).

```
var tranA {(s,c) in ConnectionsA}, >=0;
var tranB {(c,d) in ConnectionsB}, >=0;
var atCenter {c in Centers}, >=0;
var useCenter {c in Centers}, binary;
```

Constraints ensure consistency:

1.  Supply limits.
2.  Flow into center equals `atCenter`.
3.  Flow out of center equals `atCenter`.
4.  Demand requirements.
5.  Center usage (Big-M constraint).

The objective function sums all costs.

**Results**

**Small scenario:** Optimal cost **$7,350**. Both centers are used.

**Large scenario:** Optimal cost **$21,310**. Only center C2 is used (fixed cost 14,000). C2 is chosen despite being more expensive to establish because overall transportation costs are lower.

-----

## 6.8. TRANSPORTATION PROBLEM – SUMMARY

We started with the basic transportation problem involving supply and demand nodes. We improved implementation using index sets.

The problem results in an **LP model**. We presented four elaborate cost functions:

  * **Increasing Unit Costs:** Uses an **LP** model.
  * **Economy of Scale:** Uses **binary variables**, making it an **MILP** model.
  * **Fixed Costs:** Uses a **binary variable**, making it an **MILP**.
  * **Linear Penalties:** Results in an **LP** model.

Finally, we extended the problem with **center nodes**, combining two sub-problems and a fixed cost decision.

-----

# Chapter 7: MILP Models

In previous chapters, most of the problems we discussed were solvable using **LP (Linear Programming) models**. However, certain complex elements—such as fulfilling an entire order, modeling economies of scale, or including fixed costs—required the use of **integer variables**, resulting in **MILP (Mixed-Integer Linear Programming) models**. That said, the primary problems we looked at (production, diet, and transportation) were fundamentally **continuous** in nature. In those cases, variables could take any value within a range of real numbers, and integer values were only necessary under specific conditions.

In this chapter, we will explore several optimization problems that inherently involve **discrete decisions**. The solution space for these problems isn't a convex, continuous region; instead, it is **finite** (or divided into finite parts). These problems naturally require integer variables—typically **binary variables**—to express discrete choices, which inevitably leads to **MILP models**. Solving these problems is usually significantly more complex than solving problems involving only continuous decisions. Even small instances of MILP problems can be difficult or impossible to solve exhaustively. The exact computational limit depends on the problem itself, the specific MILP model used, the solver software and its configuration, and the hardware running the calculations.

-----

## 7.1 Knapsack Problem

One of the simplest optimization problems that is discrete by nature is the **knapsack problem** [18]. Its definition is as follows:

[Image of knapsack problem illustration]

**Problem 34.**

Given a set of **items**, each having a nonnegative **weight** and a **gain** value, and a known **weight limit**, **select** a subset of the items so that their total weight does not exceed the limit and the total gain is **maximized**.

This is called the knapsack problem because you can visualize it as having a large backpack (knapsack) that you must fill with items. Since the total weight you can carry is limited, you must carefully choose which items to pack to achieve the highest possible value or gain.

As usual, we will describe a concrete knapsack problem instance to illustrate the general problem.

**Problem 35.**

Solve **Problem 34**, the knapsack problem, with a weight **capacity of 60** and the following items:

| **Item** | **A** | **B** | **C** | **D** | **E** | **F** | **G** | **H** | **I** | **J** |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Weight** | 16.1 | 19.2 | 15.0 | 14.7 | 11.3 | 20.1 | 17.5 | 14.5 | 14.8 | 18.1 |
| **Gain** | 4.4 | 4.9 | 4.3 | 4.0 | 3.7 | 5.1 | 4.6 | 4.2 | 4.3 | 4.8 |

Starting with the GNU MathProg implementation, we first define the **sets** and **parameters** that describe the problem data. The set `Items` denotes the items, and there are two parameters for each item: `Weight` and `Gain`. A single number, `Capacity`, describes the weight limit. We specify all of these as nonnegative to prevent data errors.

```glp
set Items;
param Weight {i in Items}, >=0;
param Gain {i in Items}, >=0;
param Capacity, >=0;
```

Implementing the data section according to Problem 35 using the sets and parameters described above is straightforward.

```glp
set Items := A B C D E F G H I J;
param Weight :=
A 16.1
B 19.2
C 15.0
D 14.7
E 11.3
F 20.1
G 17.5
H 14.5
I 14.8
J 18.1
;
param Gain :=
A 4.4
B 4.9
C 4.3
D 4.0
E 3.7
F 5.1
G 4.6
H 4.2
I 4.3
J 4.8
;
param Capacity := 60;
```

Now, let's look at the flexibility we have in choosing a solution. Any **subset** of the items is a possible solution, including selecting none or all of them. If the number of items is $n$, the total number of different solutions is $2^n$. Note that not all of these subsets are **feasible** due to the weight limit, and we can also eliminate many non-optimal solutions. Nevertheless, the general optimization problem with arbitrary weights and gains is **NP-hard**. Therefore, for a large $n$, finding an exhaustive solution may be practically impossible.

In mathematical programming, we express our decision-making freedom through **decision variables**. We can easily do this using a single **binary variable** for each item. We name it `select`; it equals **1** if the item is chosen for the knapsack and **0** if it is not.

```glp
var select {i in Items}, binary;
```

There is only one restriction that can prevent a solution from being feasible: the **total weight** of the items. We express this in a single constraint stating that the total weight of the selected items is at most the given limit. The total weight in the knapsack is calculated by summing each `select` variable multiplied by the item's `Weight`. This works because if an item is selected, its weight is added; if it's not selected, it contributes nothing to the total.

```glp
s.t. Total_Weight:
sum {i in Items} select[i] * Weight[i] <= Capacity;
```

The objective is to **maximize** the **total gain**. We sum each `select` variable multiplied by the item's `Gain` value.

```glp
maximize Total_Gain:
sum {i in Items} select[i] * Gain[i];
```

After the `solve` statement, we add some print commands to display the solution. Our complete model section is now ready:

```glp
set Items;
param Weight {i in Items}, >=0;
param Gain {i in Items}, >=0;
param Capacity, >=0;
var select {i in Items}, binary;
# var select {i in Items}, >=0, <=1;
s.t. Total_Weight:
sum {i in Items} select[i] * Weight[i] <= Capacity;
maximize Total_Gain:
sum {i in Items} select[i] * Gain[i];
solve;
printf "Optimal Gain: %g\n", Total_Gain;
printf "Total Weight: %g\n",
sum {i in Items} select[i] * Weight[i];
for {i in Items}
{
printf "%s:%s\n", i, if (select[i]) then " SELECTED" else "";
}
end;
```

Solving Problem 35 reports an **optimal gain of 17.1**, achieved by selecting items **C, E, I, and J**. The total weight of these items is **59.2**, which fits within the limit of 60, though it doesn't utilize the capacity perfectly.

Note that we used a **conditional expression** to print the word `SELECTED` after each item $i$ where `select[i]` is 1, and an empty string where it is 0. The condition for such an expression must be a constant expression that can be interpreted as a logical value. Remember that variables only behave as constants *after* the `solve` statement in the model section. The output produced is as follows:

```
Optimal Gain: 17.1
Total Weight: 59.2
A:
B:
C: SELECTED
D:
E: SELECTED
F:
G:
H:
I: SELECTED
J: SELECTED
```

You might think of an easy, direct **heuristic** for the knapsack problem: arrange the items in descending order of their **gain-to-weight ratio** and select items in this order until you hit the weight limit. This **greedy strategy** seems promising because the weight limit acts as a fixed resource, and we want to maximize the gain per unit of weight. "Greedy" means that at each step, we make the most immediately beneficial choice based on a heuristic. Items with a higher gain/weight ratio represent a more efficient use of the capacity.

The only issue with this strategy is the **slack weight**. We may (and usually will) have some unused weight under the limit. We might actually achieve a better overall solution by sacrificing an item with a high ratio to better fill the remaining space with other items. This small difference prevents the straightforward heuristic from being optimal and makes the knapsack problem computationally difficult.

Let's consider a **"relaxed" version** of the knapsack problem where the items are fluids. This means we are allowed to select a **fraction** of an item, receiving the same fraction of its weight and gain. For this relaxation, the binary variable can be replaced by a continuous one, as follows:

```glp
var select {i in Items}, >=0, <=1;
```

Note that you can achieve this effect by running the original model with the `glpsol` solver and adding the `--nomip` option:

```bash
glpsol -m knapsack.mod -d example.dat --nomip
```

Furthermore, we'll change the output method slightly. Instead of printing the word `SELECTED`, we'll print the actual value of the now continuous `select` variable:

```glp
for {i in Items}
{
printf "%s: %g\n", i, select[i];
}
```

Solving the relaxed model with the exact same data gives the following results:

```
Optimal Gain: 17.7025
Total Weight: 60
A: 0.273292
B: 0
C: 1
D: 0
E: 1
F: 0
G: 0
H: 1
I: 1
J: 0
```

Notice that items C, E, and I are selected entirely. However, instead of choosing J as the fourth item (as in the integer solution), the relaxed model chooses H completely and then item A in a **fractional ratio** (approximately $27.3\%$). This results in perfect utilization of the weight limit (60) and a slightly better objective value of **17.7025** compared to 17.1. If we analyze the data, the items' decreasing order of **gain/weight ratio** is E, I, H, C, A, D, J, G, B, F. Therefore, the relaxed model performs exactly as the greedy heuristic dictates: it selects the first four items entirely and then the necessary fraction of the fifth (A) to fill the limit.

In contrast, the optimal solution to the actual **integer programming problem** does not choose H. Instead, it chooses J, which is much lower in the ratio order, because J fills the remaining weight limit better due to its larger overall weight and gain.

Now that we have seen the complications that arise with integer problems, let's consider a similar problem: the **multi-way number partitioning problem** [19].

**Problem 36.**

Given a set of $N \ge 1$ **real numbers**, divide them **exhaustively** into exactly $K \ge 1$ **subsets** so that the difference between the **smallest** and **largest** sum of numbers in a subset is **minimal**.

The **multi-way number partitioning problem** can be interpreted as a modified version of the **knapsack problem** where all $N$ **items** must be packed into any one of $K$ given **knapsacks**, and this distribution must be as **balanced** as possible. There is no **gain value** here (or rather, the gain can be interpreted as being equal to the **weight**).

We will solve one example problem.

-----

**Problem 37.**

**Distribute** the $N=10$ **items** described in Problem 35 (the **knapsack example problem**) into $K=3$ **knapsacks** so that the difference between the **lightest** and the **heaviest** knapsack is **minimal**.

Let's see how to **implement** this in **GNU MathProg**. First, there is an `Items` set and a `Weight` parameter, just as before, but no `Gain` parameter. Instead, we **define** a single integer parameter `Knapsack_Count`, which refers to the **positive integer** $K$ from the problem description.

```
set Items;
param Weight {i in Items}, >=0;
param Knapsack_Count, integer;
set Knapsacks := 1 .. Knapsack_Count;
```

We also introduced the set `Knapsacks`. However, instead of reading this set from the data section, we **denote** each knapsack by numbers from **1 to K**. The operator `..` defines a set by listing all integers between the **smallest** and **largest** integer element.

Note that we require `Weight` to be **non-negative**; however, these parameters can be restricted to **integers** or relaxed to take **real values**. The **model** remains exactly the same in all cases.

There are **more decisions** to be made here than in the original knapsack problem. For each item, we don't just decide *whether* it goes into a knapsack; we decide **which knapsack it goes into**. We can do this by defining a **binary decision variable** `select` for each pair of an **item** and a **knapsack**, denoting whether that item goes into that specific knapsack. While these decisions cover the situation, we need **auxiliary variables** to express the **objective function concisely**. Therefore, we introduce a variable `weight` for each knapsack (denoting its total weight), along with `min_weight` and `max_weight` for the overall minimal and maximal knapsack weights.

```
var select {i in Items, k in Knapsacks}, binary;
var weight {k in Knapsacks};
var min_weight;
var max_weight;
```

There is only **one constraint** that determines if a decision regarding knapsacks is **feasible**: **each item must go exactly into one knapsack**. If we sum the binary variables for a specific item across all knapsacks and set that sum to one, the only feasible solution is for **one binary variable to be 1 and all others to be 0**. Therefore, the constraint is:

```
s.t. Partitioning {i in Items}:
sum {k in Knapsacks} select[i,k] = 1;
```

We provide **three additional constraint statements** to express the calculation of each knapsack's weight, a **lower limit** on all knapsack weights (`min_weight`), and an **upper limit** (`max_weight`).

```
s.t. Total_Weights {k in Knapsacks}:
weight[k] = sum {i in Items} select[i,k] * Weight[i];
s.t. Total_Weight_from_Below {k in Knapsacks}:
min_weight <= weight[k];
s.t. Total_Weight_from_Above {k in Knapsacks}:
max_weight >= weight[k];
```

The **objective** is the **difference** between the upper and lower limits.

```
minimize Difference: max_weight - min_weight;
```

This design has been used before for **minimizing errors in equations** (Section 4.8), **maximizing minimum production volumes** (Section 5.3), and various **cost functions** (Sections 6.3 or 6.6). The key is that the solver is allowed **not** to assign the actual **minimum** and **maximum** weights to the variables `min_weight` and `max_weight` while still finding **feasible solutions**. However, it is **not beneficial** to do so. Therefore, solutions where these two bounds are not **strict** are **automatically ruled out** during minimization.

Finally, we **print the contents of each knapsack** after the `solve` statement, and our model section is **ready**.

```
set Items;
param Weight {i in Items}, >=0;
param Knapsack_Count, integer;
set Knapsacks := 1 .. Knapsack_Count;
var select {i in Items, k in Knapsacks}, binary;
var weight {k in Knapsacks};
var min_weight;
var max_weight;
s.t. Partitioning {i in Items}:
sum {k in Knapsacks} select[i,k] = 1;
s.t. Total_Weights {k in Knapsacks}:
weight[k] = sum {i in Items} select[i,k] * Weight[i];
s.t. Total_Weight_from_Below {k in Knapsacks}:
min_weight <= weight[k];
s.t. Total_Weight_from_Above {k in Knapsacks}:
max_weight >= weight[k];
minimize Difference: max_weight - min_weight;
solve;
printf "Smallest difference: %g (%g - %g)\n",
Difference, max_weight, min_weight;
for {k in Knapsacks}
{
printf "%d:", k;
for {i in Items: select[i,k]}
{
printf " %s", i;
}
printf " (%g)\n", weight[k];
}
end;
```

Solving example **Problem 37** gives the following result:

```
Smallest difference: 2.5 (55.3 - 52.8)
1: C F J (53.2)
2: D E H I (55.3)
3: A B G (52.8)
```

The **ten items** could be divided into **three subsets** of roughly **equal size**. The **largest knapsack** is the second (weight **55.3**), and the **smallest** is the third (weight **52.8**). Note that the **order of knapsacks** is **not important**. Because **all ten items are distributed**, it is **guaranteed** that the sum of the three knapsacks is a **constant**; therefore, their **average** is also constant and must lie between the two limits.

Another similar and **better-known problem** is the **bin packing problem**, where all items are known, but the **knapsack sizes are fixed**. In that case, the goal is to **minimize** the **number of knapsacks** (called **bins**) [20]. This could also be solved in **GNU MathProg**, but we won't detail it here.

-----

## 7.2 Tiling the Grid

The **knapsack** and **similar problems** require items to "fit" somewhere based on weight constraints. But what happens when **fitting is more complex**? For instance, considering the **size** or **shape** of items and their **container** is a **common real-world question** that leads to much more **difficult optimization problems**.

A **two-dimensional example** is the class of **tiling problems**, where copies of the **same shape** (called **tiles**) are used to **cover a region** on a plane. Tiles are usually **forbidden to overlap**, and the **cover** is often required to be **perfect**; that is, **all of the designated region must be covered**. If we don't require **perfect covering**, we might ask: what is the **maximum area we can cover**? This becomes an **optimization problem**. Provided there is a **single tile**, the copies of which are used, the problem simplifies to **maximizing the number of non-overlapping tiles** that can be put into the region.

In this section, we **restrict tiling** to a **rectangular grid** of **unit squares**. The **tile**, **all its possible positions**, and the **region to be covered** all fit onto **unit squares** of the same grid. The tile will be the **simplest cross**, consisting of **five squares**. For simplicity, the **region to be covered** is a **rectangular area** (see Figure 8). Tiles cannot cover any area outside this region.

**Problem 38.**

Determine the **maximum number of non-overlapping crosses** that can be placed in an $N \times M$ grid.

You might argue that this is a very specialized problem within the class of **tiling problems**. Indeed, many tiling problems cannot be effectively solved using mathematical programming tools. Here, the "general problem" simply refers to creating a general model section that can be applied to any instance of this grid problem.

The data required for this problem is minimal: only the dimensions of the rectangular area need to be specified. Let's look at some examples.

**Problem 39.**

Solve **Problem 38**, the rectangle tiling problem with crosses, for the following rectangle sizes:

  * $6 \times 4$
  * $10 \times 10$
  * $30 \times 30$

This problem requires perhaps the shortest data sections we've seen so far. The following is for the smallest instance:

```glp
param Width := 6;
param Height := 4;
```

We use the parameter names **`Width`** and **`Height`** for the dimensions of the rectangular region. These must be positive integers. **`Height`** represents $N$ (the number of rows), and **`Width`** represents $M$ (the number of columns). Rows are numbered from 1 to $N$, and columns are numbered from 1 to $M$. The set of all squares, or **cells**, in the rectangular grid is the Cartesian product of the row and column sets, resulting in a size of $N \cdot M$. These are defined as shown below.

```glp
param Height, integer, >=1;
param Width, integer, >=1;
set Rows := 1 .. Height;
set Cols := 1 .. Width;
set Cells := Rows cross Cols;
```

At this point, the minimum data requirements are defined in the model, but a concise implementation will require a few more definitions. Let's first determine the decisions needed to describe a tiling.

First, we need to decide, for every possible position of a cross tile, whether to put a tile there or not. This can be done using a **binary variable** introduced for each possible position:

```glp
var place {(r,c) in Tiles}, binary;
```

Here, the set **`Tiles`** refers to a set that hasn't been defined yet, but it will list all possible placements of cross tiles. Decisions for this `place` variable will fully determine the tiling, but an **auxiliary variable** will also be useful.

```glp
var covered {(r,c) in Cells}, binary;
```

Here, `covered` is defined for each cell and determines whether that cell is occupied by a tile. This helps us formulate constraints ensuring that each cell is covered **at most once** to prevent overlaps.

As is customary, a value of **1 means yes** and **0 means no** for these binary variables. For instance, `place` is 1 if a tile is placed at that specific position, and `covered` is 1 if that specific cell is occupied.

Before moving on, we must characterize the set **`Tiles`** that describes all possible positions. Fortunately, the five-cell cross is **symmetric**: rotating or reflecting it does not change its orientation. This means the only difference between tile positions is their location (shifting). Therefore, we define a binary variable for each possible position, and the set `Tiles` simply lists these positions.

If we wanted to tile with **asymmetric shapes** where multiple orientations are possible, we would need to define different binary variables for each unique orientation and position. In that scenario, the `Tiles` set would require a third index dimension to denote orientation. But since the cross only has a single orientation, that dimension is omitted, and `Tiles` is just a two-dimensional set.

Finally, let's decide how coordinates will define the positioning. We define the **anchor point** of the cross tile as the **central cell** of the tile. The set `Tiles` will list all possible anchor points of correctly positioned tiles. This works because different positions have different anchor points.

The selection of the anchor point relative to the tile can be arbitrary, as long as it is consistent. It could even be a cell outside the tile—for example, the corner cell of the $3 \times 3$ square containing the cross.

The last task is to determine the valid anchor points. We must consider all correctly positioned cross tiles in the grid. Since the anchor point is inside the tile, the anchor of a valid tile must be within the grid. However, **not all cells** in the grid are valid anchors. For example, no cells along the edge of the rectangle are valid, as a cross centered there would extend outside the region. Furthermore, corner cells cannot be covered by *any* correctly positioned cross tiles centered elsewhere.

Based on an anchor $(r,c)$, we can define all the cells of the cross tile if placed at that anchor. This is done by the **`CellsOf`** set. Note that this set statement is itself indexed over all cells (i.e., all possible anchors), meaning that $N \times M$ different sets of 5 cells each are defined.

```glp
set CellsOf {(r,c) in Cells} :=
{(r,c),(r+1,c),(r-1,c),(r,c+1),(r,c-1)};
```

The set **`Tiles`** of correct tile positions (anchor points) consists of those anchors for which the 5 cells defined in `CellsOf` are all within the rectangular area.

```glp
set Tiles, within Cells :=
setof {(r,c) in Cells: CellsOf[r,c] within Cells} (r,c);
```

Of course, we could have simply said correct anchor points are those **not on the edges**. However, we chose this approach for two reasons:

  * Defining all cells of the placed tile and keeping only positions entirely within the region is a very **general approach**. It works for arbitrary tiles and arbitrary regions on a finite grid.
  * The `CellsOf` sets provide a **shorter model formulation**, as we will see.

The definitions for `CellsOf` and `Tiles` must be placed before the definition of the variable `place`.

Constraints must establish two things: calculation of the auxiliary variable `covered` for each cell, and ensuring each cell is covered at most once. Surprisingly, both can be done with a single constraint statement:

```glp
s.t. No_Overlap {(r,c) in Cells}: covered[r,c] =
sum {(x,y) in Tiles: (r,c) in CellsOf[x,y]} place[x,y];
```

In plain terms, for each cell, we add the `place` variables of all tiles that cover that cell. Since `place` is an integer variable, the sum exactly equals the number of tiles covering that specific cell. This number can only be zero or one; two or more is forbidden. This restriction is implicitly ensured because the sum equals the single binary variable `covered[r,c]`, and since it is binary, its value cannot exceed one.

Note that `covered` doesn't strictly need to be formulated as **binary**. The constraint ensures its value is an integer because it's a sum of integer variables. The only required property is its **upper bound of 1**.

This insight is useful for analyzing complexity. Generally, more binary variables make a model harder to solve. However, since `covered` doesn't strictly have to be binary, it isn't expected to significantly increase complexity. The true difficulty lies with the `place` variable. Nevertheless, marking `covered` as binary might alter the solution algorithm's process.

The objective is the total number of tiles placed.

```glp
maximize Number_of_Crosses:
sum {(r,c) in Tiles} place[r,c];
```

After the `solve` statement, a useful way to print the solution is to visualize the tiling using character graphics.

```glp
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
```

Since the output is textual, we print each row on a single line. Within a row, we print a single character for each cell so the area aligns correctly in a fixed-width font:

  * If a cell is **not covered**, a **dot (`.`)** is placed there.
  * If a cell is the anchor point of a **placed tile**, it is denoted by a **hash mark (`#`)**.
  * Otherwise, if the cell is covered by a cross but is **not its center**, it is denoted by a **plus sign (`+`)**.

Note the use of nested `if` operators. The key point is that we first check whether $(r,c)$ is a proper anchor point. Only if it is an anchor point do we check `place[r,c]`. We do this because referring to `place[r,c]` for a non-anchor point would cause an **"out of domain" error**, as the `place` variable is only defined for members of the set `Tiles`. Note that if an `else` value is omitted in MathProg, it is assumed to be zero.

The model section for **Problem 38** is complete.

```glp
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
```

Solving the model for the smallest instance ($4 \times 6$) shows that no more than **two** cross tiles can fit. One possible construction is shown below:

```
Max. Cross Tiles (4x6): 2
....+.
.+.+#+
+#+.+.
.+....
```

The medium instance ($10 \times 10$) is still solved very quickly. A maximum of **13** cross tiles fit, and the solution looks like this:

```
Max. Cross Tiles (10x10): 13
.+...+..+.
+#+.+#++#+
.++..+.++.
.+#+.++#+.
..+++#+++.
.++#++++#+
+#++.+#++.
.++..++.+.
.+#++#++#+
..+..+..+.
```

The large instance ($30 \times 30$) was included to demonstrate what happens when the model becomes genuinely large and difficult to solve. In such cases, the solver could take an unacceptably long time. Therefore, we provide a **time limit of 60 seconds**. In the command line, add the `--tmlim 60` argument:

```bash
glpsol -m tiling.mod -d example.dat --tmlim 60
```

If the time limit option is omitted, the solver runs indefinitely. Note that the limit set this way is not strict; `glpsol` tends to slightly exceed it, especially if preparatory steps are lengthy.

Running `glpsol` with a one-minute time limit produced the following output:

```
GLPK Integer Optimizer, v4.65
901 rows, 1684 columns, 5604 non-zeros
1684 integer variables, all of which are binary
Preprocessing...
896 rows, 1680 columns, 4816 non-zeros
1680 integer variables, all of which are binary
Scaling...
A: min|aij| = 1.000e+00 max|aij| = 1.000e+00 ratio = 1.000e+00
Problem data seem to be well scaled
Constructing initial basis...
Size of triangular part is 896
Solving LP relaxation...
GLPK Simplex Optimizer, v4.65
896 rows, 1680 columns, 4816 non-zeros
*
0: obj = -0.000000000e+00 inf = 0.000e+00 (784)
Perturbing LP to avoid stalling [253]...
Removing LP perturbation [1896]...
* 1896: obj = 1.631480829e+02 inf = 0.000e+00 (0) 12
OPTIMAL LP SOLUTION FOUND
```

Note that the original model contained a massive **1684 binary variables**. Preprocessing only removed four of them (likely the corner cells).

After that, the **LP relaxation** of the MILP model is solved. The rows concerning "perturbation" indicate that the solver took measures to avoid **stalling** (an infinite loop in the Simplex algorithm). This message suggests that the solved LP is difficult, very large, or has unusual properties. The last line shows that **163.15** was the optimal solution of the LP relaxation. This tells us that the optimal solution of the actual MILP model **cannot be greater than 163**. The algorithm uses this result to set an initial bound.

```
Integer optimization begins...
Long-step dual simplex will be used
+ 1896: mip = not found yet <= +inf (1; 0)
+ 4865: mip = not found yet <= 1.630000000e+02 (44; 0)
+ 9025: mip = not found yet <= 1.630000000e+02 (102; 0)
+ 11252: >>>>> 1.380000000e+02 <= 1.630000000e+02 18.1% (176; 0)
+ 14948: mip = 1.380000000e+02 <= 1.620000000e+02 17.4% (200; 35)
+ 18811: mip = 1.380000000e+02 <= 1.620000000e+02 17.4% (266; 35)
+ 22402: mip = 1.380000000e+02 <= 1.620000000e+02 17.4% (330; 36)
+ 25362: mip = 1.380000000e+02 <= 1.620000000e+02 17.4% (384; 36)
+ 28609: mip = 1.380000000e+02 <= 1.620000000e+02 17.4% (457; 36)
+ 29844: >>>>> 1.400000000e+02 <= 1.620000000e+02 15.7% (484; 36)
+ 33482: mip = 1.400000000e+02 <= 1.620000000e+02 15.7% (492; 108)
+ 36688: mip = 1.400000000e+02 <= 1.620000000e+02 15.7% (557; 108)
+ 40050: mip = 1.400000000e+02 <= 1.620000000e+02 15.7% (639; 109)
+ 43326: mip = 1.400000000e+02 <= 1.620000000e+02 15.7% (687; 109)
Time used: 60.0 secs. Memory used: 6.4 Mb.
+ 43866: mip = 1.400000000e+02 <= 1.620000000e+02 15.7% (698; 109)
TIME LIMIT EXCEEDED; SEARCH TERMINATED
Time used: 60.3 secs
Memory used: 6.7 Mb (7071653 bytes)
```

The integer optimization follows, generally executed using a **Branch and Bound** procedure. Branching checks different integer values, and bounding eliminates branches early.

Output rows are printed regularly:

  * The numbers on the left (ending at 43866) denote the "steps" taken.
  * The middle column is the currently known **best integer solution** (or "MIP," Mixed-Integer Program). This value can only improve (increase) during the search.
      * Initially, no solution was found.
      * The first solution found involved **138 tiles**.
      * In 60 seconds, this improved to **140 tiles**, at which point the time limit stopped the process.
  * The rightmost column denotes the current **best bound**. This is an upper limit on the objective. It can only decrease. It started at 163 and improved slightly to 162.

This means that even though the procedure didn't finish, there definitely cannot be more than **162 tiles**.

The optimal solution lies somewhere between the best solution and the best bound. If they become equal, the optimal solution is found. The relative difference between them is the **integrality gap** (here, $15.7\%$).

Concluding the large case: we have a feasible solution of **140 tiles**, but the true optimal solution could be as high as **162**. It is possible that 140 is the optimal solution, but the solver hasn't proven it.

What are our options for a large model that `glpsol` fails to solve optimally?

  * **Spend More Time:** Improvement usually slows down, so this might take too long.
  * **Formulate a Better Model:** We can try different decision variables or **tightening constraints** (like cutting planes) to help the solver. A better formulation can drastically improve efficiency.
  * **Choose a Different Solver or Machine:** There are more powerful solvers than `glpsol` (e.g., CBC, lpsolve, or commercial solvers). `glpsol` can export models to CPLEX-LP format for use with these tools.
  * **Adjust Solver Options:** `glpsol` has options that alter the algorithms, such as enabling heuristics.

We will demonstrate the last option: running `glpsol` again with two heuristic options enabled:

  * **Feasibility Pumping** (`--fpump`): A heuristic that aims to find good integer solutions early, helping eliminate branches with low objective values.
  * **Cuts** (`--cuts`): Allows `glpsol` to use all available cuts (Gomory, Mixed-Integer Rounding, Clique, Mixed Cover) to trim the search space.

<!-- end list -->

```bash
glpsol -m tiling.mod -d example.dat --fpump --cuts
```

These heuristics often help, sometimes dramatically, though not always. The output for the $30 \times 30$ instance with these options is:

```
Integer optimization begins...
Long-step dual simplex will be used
Gomory's cuts enabled
MIR cuts enabled
Cover cuts enabled
Number of 0-1 knapsack inequalities = 784
Clique cuts enabled
Constructing conflict graph...
Conflict graph has 896 + 1004 = 1900 vertices
+ 1896: mip = not found yet <= +inf (1; 0)
Applying FPUMP heuristic...
Pass 1
Solution found by heuristic: 153
Pass 1
Pass 2
Pass 3
Pass 4
Pass 5
Cuts on level 0: gmi = 12; clq = 1;
+ 2759: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (15; 0)
...
Time used: 60.2 secs. Memory used: 10.8 Mb.
+ 18551: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (225; 3)
TIME LIMIT EXCEEDED; SEARCH TERMINATED
Time used: 60.5 secs
Memory used: 13.1 Mb (13730993 bytes)
```

We see evidence of preprocessing for cuts, but the most significant improvement came from **feasibility pumping**, which found a solution of **153 tiles**. This is substantially better than 140, and the integrality gap dropped to **$5.9\%$**.

Note that if you are uncertain about complexity, you can omit time limits and manually stop `glpsol`, as it periodically reports the best solution. However, doing so skips the print commands at the end of the file. If `glpsol` stops on its own (e.g., due to a time limit), it sets variables to the current best solution and prints the output. Here is the reported solution with **153 tiles**:

```
Max. Cross Tiles (30x30): 153
..+....+.....+...+....+....+..
.+#+.++#+.+.+#+++#+.++#+.++#+.
..+++#++++#++++#++++#++++#+++.
.++#++++#+++#+.+++#++++#++++#+
+#++++#+++..+.++#++++#++++#++.
.+++#++++#+.++#++++#++++#+++..
.+#++++#++++#++++#++++#++++#+.
..+.+#++++#++++#++++#++++#+++.
..+..+++#++++#++++#++++#++++#+
.+#+++#++++#++++#++++#++++#++.
.+++#++++#++++#++++#++++#+++..
+#+.+++#++++#++++#++++#++++#+.
.++.+#++++#++++#++++#++++#+++.
.+#+.+++#++++#++++#++++#++++#+
..++.+#++++#++++#++++#++++#++.
.++#+.+++#++++#++++#++++#+++..
+#++.++#++++#++++#++++#++++#+.
.+.++#++++#++++#++++#++++#+++.
.++#++++#++++#++++#++++#++++#+
+#++++#++++#++++#++++#++++#++.
.+++#++++#++++#++++#++++#+++..
.+#++++#++++#++++#++++#++++#+.
..+++#++++#++++#++++#++++#+++.
.++#++++#++++#++++#++++#++++#+
+#++++#++++#++++#++++#++++#++.
.+++#++++#++++#++++#++++#++.+.
.+#++++#++++#++.+#++++#+++.+#+
..+++#++++#+++..++.+#++++#+++.
..+#++.+#++.+#++#+..+.+#+++#+.
...+....+....+..+......+...+..
```

The $30 \times 30$ square is almost perfectly filled. The gap between 153 and 162 remains open.

-----

## 7.3 Assignment Problem

This section presents another well-known optimization problem: the **assignment problem** [21].

-----

**Problem 40.**

Given $N$ workers and $N$ tasks, and knowing how well each worker can execute each task (described by a cost value), assign each worker exactly one task so that the **total cost is maximized** (or minimized).

As usual, we demonstrate the general problem through an example.

-----

**Problem 41.**

Solve Problem 40, the assignment problem, using the following data. There are $N = 7$ workers (W1 to W7), tasks T1 to T7, and the following cost matrix:

| | T1 | T2 | T3 | T4 | T5 | T6 | T7 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **W1** | 9 | 6 | 10 | 10 | 8 | 7 | 11 |
| **W2** | 7 | 12 | 6 | 14 | 10 | 5 | 5 |
| **W3** | 8 | 9 | 7 | 11 | 10 | 15 | 6 |
| **W4** | 4 | 10 | 2 | 10 | 6 | 4 | 7 |
| **W5** | 10 | 11 | 7 | 12 | 14 | 9 | 10 |
| **W6** | 5 | 9 | 8 | 9 | 13 | 3 | 8 |
| **W7** | 7 | 12 | 7 | 7 | 11 | 10 | 9 |

We can define the input sets and parameters in various ways. One possibility is to simply read $N$ and use numbers 1 to $N$. However, we want to allow naming from the data section, so we provide two sets: `Workers` and `Tasks`. A `check` statement ensures these sets have the same size.

Next, we introduce the `Assignments` set for all possible worker-task pairs, which helps formulation. The `Cost` parameter is defined for all assignments.

```
set Workers;
set Tasks;
check card(Workers)==card(Tasks);
set Assignments := Workers cross Tasks;
param Cost {(w,t) in Assignments};
```

Data for Problem 41 can be implemented as follows:

```
data;
set Workers := W1 W2 W3 W4 W5 W6 W7;
set Tasks := T1 T2 T3 T4 T5 T6 T7;
param Cost:
T1 T2 T3 T4 T5 T6 T7 :=
W1 9 6 10 10 8 7 11
W2 7 12 6 14 10 5 5
W3 8 9 7 11 10 15 6
W4 4 10 2 10 6 4 7
W5 10 11 7 12 14 9 10
W6 5 9 8 9 13 3 8
W7 7 12 7 7 11 10 9
;
end;
```

-----

There is only one kind of decision to be made: for each assignment, decide whether to assign that task to the worker or not. This is a binary variable named `assign`.

```
var assign {(w,t) in Assignments}, binary;
```

There are two rules we must obey: each worker must have exactly one task, and each task must have exactly one worker.

```
s.t. One_Task_Per_Worker {w in Workers}:
sum {t in Tasks} assign[w,t] = 1;
s.t. One_Worker_Per_Task {t in Tasks}:
sum {w in Workers} assign[w,t] = 1;
```

The objective is the total cost, obtained by adding each assignment variable multiplied by its cost.

```
minimize Total_Cost:
sum {(w,t) in Assignments} assign[w,t] * Cost[w,t];
```

Finally, we print the optimal cost and the task assigned to each worker.

```
set Workers;
set Tasks;
check card(Workers)==card(Tasks);
set Assignments := Workers cross Tasks;
param Cost {(w,t) in Assignments};
var assign {(w,t) in Assignments}, binary;
s.t. One_Task_Per_Worker {w in Workers}:
sum {t in Tasks} assign[w,t] = 1;
s.t. One_Worker_Per_Task {t in Tasks}:
sum {w in Workers} assign[w,t] = 1;
minimize Total_Cost:
sum {(w,t) in Assignments} assign[w,t] * Cost[w,t];
solve;
printf "Optimal Cost: %g\n", Total_Cost;
for {w in Workers}
{
printf "%s->", w;
for {t in Tasks: assign[w,t]}
{
printf "%s (%g)\n", t, Cost[w,t];
}
}
end;
```

The solution to the example problem is as follows (costs in parentheses):

```
Optimal Cost: 42
W1->T2 (6)
W2->T1 (7)
W3->T7 (6)
W4->T5 (6)
W5->T3 (7)
W6->T6 (3)
W7->T4 (7)
```

The smallest possible sum of assignments is 42.

Here are a few notes about the assignment problem:

  * The model is relatively simple. The number of feasible solutions for $N$ workers is $N!$ (factorial). For $N=7$, that's 5,040, which is manageable. However, for 20 tasks, $20! > 10^{18}$, making brute force impossible.
  * Mathematical programming handles large sizes well, but the **Hungarian method** [22] is a polynomial-time algorithm specifically designed for this problem that is substantially faster.
  * The **LP relaxation** of the assignment problem yields the optimal result for the MILP model. The integrality gap is guaranteed to be zero. Therefore, we don't even need binary variables; continuous variables between 0 and 1 suffice. This allows us to solve very large instances using LP.
  * The assignment problem is closely related to the transportation problem; it's effectively a transportation problem with $N$ sources and $N$ demands of 1 unit each.
  * Adding the same number to any row or column of the cost matrix doesn't change the optimal assignment, only the objective value.
  * Minimization and maximization are equivalent; negating costs turns one problem into the other.

Now, we will show an interesting extension: what happens when some decisions have already been made?

**Problem 42.**

Solve Problem 40 (the assignment problem) with **a priori decisions**: some assignments are explicitly declared to be either used or not used.

This technique isn't specific to the assignment problem; it applies to many real-world scenarios. Our goal is to support **a priori decisions** without breaking existing data files.

First, we define a parameter **`Fixing`** to express these decisions.

```
param Fixing {(w,t) in Assignments}, in {0,1,2}, default 2;
```

This parameter has three values:

  * **0**: **Exclude** the assignment.
  * **1**: **Force** this assignment to be used.
  * **2**: Leave the decision to **optimization**.

Setting the default to 2 ensures **compatibility with old data files** that don't mention `Fixing`.

Next, we enforce these decisions. For any `Fixing` value of 0 or 1, we explicitly set the `assign` variable to that value.

```
s.t. Fixing_Constraints {(w,t) in Assignments: Fixing[w,t]!=2}:
assign[w,t] = Fixing[w,t];
```

This completes the model. We demonstrate it with two trials.

-----

**Trial 1: Prohibiting an Assignment**

We set assignment **W6 to T6 as zero (excluded)**. Since the original optimal solution used this assignment, prohibiting it forces the solver to find an alternative.

```
param Fixing :=
W6 T6 0
;
```

```
Optimal Cost: 42
W1->T2 (6)
W2->T6 (5)
W3->T7 (6)
W4->T5 (6)
W5->T3 (7)
W6->T1 (5)
W7->T4 (7)
```

Even though W6-\>T6 was very cheap (cost 3), there is an alternative solution with the same cost of **42**.

-----

**Trial 2: Mandating an Assignment**

We set assignment **W4 to T3 as mandatory (1)**. This is the **cheapest assignment** in the matrix (cost 2) but wasn't used in previous optimal solutions.

```
param Fixing :=
W4 T3 1
;
```

```
Optimal Cost: 43
W1->T2 (6)
W2->T7 (5)
W3->T5 (10)
W4->T3 (2)
W5->T1 (10)
W6->T6 (3)
W7->T4 (7)
```

Surprisingly, forcing the cheapest assignment results in a **worse overall solution** (cost **43**). This demonstrates that simple **greedy heuristics** do not work perfectly for the assignment problem.

Note that a priori decisions can also be implemented by manipulating costs: giving an assignment a huge positive cost effectively excludes it, while a huge negative cost forces it.

-----

## 7.4 Graphs and Optimization

We will now look at two basic problems from **graph theory** that can be solved by MILP models.

A **simple graph** has **nodes** and **undirected edges**, where each edge connects two different nodes, and any two nodes are connected by at most one edge.

Some definitions required for the upcoming problems:

  * A **path** is a sequence of distinct nodes connected by edges. If the first and last nodes are connected, it forms a **cycle**.
  * A graph is **connected** if you can get from any node to any other via a path. Otherwise, it is **disconnected**.
  * A **tree** is a connected graph with no cycles.
  * A **spanning tree** of a graph is a subgraph that includes all nodes and is a tree. It's obtained by removing edges until no cycles remain but the graph stays connected.

If we assign a number (**edge weight**) to each edge, we get a **weighted simple graph**. We assume weights are positive.

**Problem 43.**

Solve the **shortest path problem** [24] on an arbitrary simple weighted graph: Given two nodes, find a path connecting them so that the **total weight of edges on the path is minimal**.

-----

**Problem 44.**

Solve the **minimum weight spanning tree (MST)** [25] problem: find the spanning tree of the graph with the **minimal total edge weight**.

-----

**Understanding the Problems**

In the **shortest path problem**, weights usually represent **distances**. In the **MST problem**, weights often represent **connection costs**. Since minimal connected spanning subgraphs are always spanning trees, the MST problem is essentially looking for the minimum weight connected graph.

Note that extremely efficient polynomial-time algorithms exist for these problems (e.g., **Dijkstra’s algorithm** [26] for shortest paths, **Kruskal’s** [27] or **Prim’s algorithm** for MST). However, MILP models can be easier to formulate and adapt to complex variations.

**Figure 12** shows an example graph used for demonstration.

-----

**Problem 45.**

On the graph in **Figure 12**, find the shortest path between nodes **A and I**, and find the minimum weight spanning tree.

**Data Implementation**

We first implement a data section. The set **`Nodes`** contains the nodes. We define **`Start`** and **`Finish`** nodes for the shortest path. **`Weight`** describes edge weights.

```
data;
set Nodes := A B C D E F G H I;
param Start := A;
param Finish := I;

param Weight :=
A B 5
B C 7
A D 3
...
F H 2
;
end;
```

Parameters **`Start`** and **`Finish`** are symbolic and must be in the `Nodes` set. We assert they are different.

```
set Nodes;
param Start, symbolic, in Nodes;
param Finish, symbolic, in Nodes;
check Start!=Finish;
```

While edges in simple graphs are undirected ($AB = BA$), it is easier in math programming to refer to them as **$(A, B)$ ordered pairs**. We allow all ordered pairs (directed arcs) because edge direction helps in the model.

We introduce a parameter **`Infty`** as a default large cost to effectively exclude edges not listed in the data.

```
param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);
```

Parameter **`W`** ensures that if we provide a weight for $AB$, it applies to both $AB$ and $BA$.

**Solving the Shortest Path Problem**

The idea is to imagine a single **"droplet" of material** placed at **`Start`**. It flows through the arcs to reach **`Finish`**. This draws the path.

A binary variable **`flow`** denotes whether the droplet flows through an arc $(a, b)$.

```
var flow {a in Nodes, b in Nodes}, binary;
```

We need to check the **material balance** at each node:

  * **Start**: Droplet leaves. Balance is **-1**.
  * **Finish**: Droplet arrives. Balance is **1**.
  * **Others**: Droplet arrives and leaves. Balance is **0**.

<!-- end list -->

```
subject to Path_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Start) then -1 else if (x==Finish) then 1 else 0;
```

This ensures a **feasible trail** exists. The objective is to minimize total weight.

```
minimize Total_Weight:
sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b];
```

Optimization will naturally rule out cycles and extra edges because of their positive weight, resulting in a simple path.

Solving for **A to I** gives:

```
Distance A-I: 19
A->D (3)
B->E (4)
D->B (1)
E->H (2)
H->I (9)
```

The path is **19** (A-D-B-E-H-I). Note that the shortest path isn't necessarily the one with the fewest edges. Like the assignment problem, the **LP relaxation** of this model yields the optimal solution, so it could be a pure LP.

-----

**Solving the Minimum Weight Spanning Tree (MST) Problem**

We use a similar flow strategy. We want a connected graph. Let's put a droplet in **each node** and have them all flow to a single **sink node** (e.g., A).

  * If the graph is connected, droplets can reach the sink from everywhere.
  * If disconnected, they cannot.

<!-- end list -->

```
param Sink := A;
```

We use two variables:

  * **`use`**: Binary. Is the edge selected?
  * **`flow`**: Continuous. How much material flows through it?

<!-- end list -->

```
var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};
```

Constraints ensure flow in one direction is the negative of the other, and flow only happens on selected (`use`) edges (using a big-M constraint based on node count).

```
subject to Flow_Direction {a in Nodes, b in Nodes}:
flow[a,b] + flow[b,a] = 0;
subject to Flow_On_Used {a in Nodes, b in Nodes}:
flow[a,b] <= use[a,b] * (card(Nodes) - 1);
```

Material balance:

  * **Sink**: Receives all droplets ($\mathbf{1 - \text{card(Nodes)}}$).
  * **Others**: Sends one droplet ($\mathbf{1}$).

<!-- end list -->

```
subject to Material_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Sink) then (1-card(Nodes)) else 1;
```

Minimizing the total weight of `use`d edges results in a spanning tree directed toward the Sink.

Solving the example with Sink **A**:

```
Cheapest spanning tree: 31
A<-D (3)
B<-E (4)
D<-B (1)
E<-H (2)
F<-C (6)
F<-I (8)
H<-F (2)
H<-G (5)
```

The total weight is **31**. Unlike shortest path, this **cannot be relaxed to LP** because `use` must remain binary to capture the fixed cost of an edge regardless of flow volume.

-----

## 7.5 Traveling Salesman Problem

Here we present the **Traveling Salesman Problem (TSP)** [28], a notoriously difficult problem.

[Image of traveling salesman problem]

**Problem 46.**

Given a set of **nodes** and **distances** between them, find the **shortest cycle** that **visits all nodes**.

The goal is to visit a set of targets and return to the start with minimal travel. This optimal route is a **Hamiltonian cycle**. The starting node can be arbitrary.

Compared to the knapsack problem, TSP is generally harder to solve for the same number of elements. We assume equal distances in both directions. For simplicity, we solve a TSP for nodes on a **plane** using **Euclidean distances**.

-----

**Problem 47.**

Find the **shortest route** starting and ending at the **green node** and visiting all **red nodes** in Figure 15.

We implement a model that accepts planar positions and calculates distances. The nodes are listed in a set `Node_List`.

```
data;
set Node_List :=
P00 0 0
P08 0 8
...
P97 9 7
;
param Start := P23;
end;
```

In the model, `Node_List` is a three-dimensional set (name, x, y). We derive `Nodes`, `X`, and `Y` from it. We calculate Euclidean distance `W` using `sqrt` and `^2`.

**Solution Strategy:**

TSP is closely related to the **assignment problem**. Each node must have exactly one "next" node in the cycle. This is an assignment from the set of nodes to itself.

```
var use {a in Nodes, b in Nodes}, binary;
subject to Path_In {b in Nodes}: sum {a in Nodes} use[a,b] = 1;
subject to Path_Out {a in Nodes}: sum {b in Nodes} use[a,b] = 1;
```

However, simple assignment constraints might result in **multiple smaller cycles** rather than one big cycle (see Figure 17). To prevent this, we must ensure **connectivity**. We reuse the MST flow technique: put a droplet at each node and ensure they can all flow to `Start`. This is possible if and only if there is a single connected cycle.

```
var flow {a in Nodes, b in Nodes};
...
subject to Material_Balance {x in Nodes}: ...
```

The TSP model is essentially a combination of the **assignment problem** and **connectivity constraints**.

Solving Problem 47 yields a cycle length of **44.59**.

```
Shortest Hamiltonian cycle: 44.5948
P00->P31 (3.16228)
...
P97->P69 (3.60555)
```

Even with only 19 nodes, solving takes time (about 9 seconds here).

**SVG Output**

To visualize the result, the model generates an **SVG image**. We translate TSP coordinates to image pixels, define a file parameter, and use `printf` to write XML tags (rectangles for background/nodes, lines for the grid/path). This allows `glpsol` to produce a graphical solution file directly.

-----

## 7.6 MILP Models – Summary

This chapter demonstrated how **Mixed-Integer Linear Programming (MILP)** solves problems involving discrete decisions.

  * **Knapsack & Partitioning:** Basic examples of discrete choices using integer variables.
  * **Tiling:** Solved by defining sets for valid placements.
  * **Assignment Problem:** Implemented as an MILP, though its LP relaxation works perfectly. We also showed how to implement **a priori decisions**.
  * **Graphs:** **Shortest Path** and **MST** were solved using **flow/material balance** concepts.
  * **TSP:** Solved by combining assignment logic with connectivity constraints. We also generated **visual SVG output**.

**Integer programming** expands the range of solvable problems significantly compared to pure LP, but it comes with a steep increase in **computational complexity**.