
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