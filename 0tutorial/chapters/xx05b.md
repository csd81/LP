 
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

      * **Expense** ($\text{Order\_Cash\_Flow} > 0$): $\text{Cost}$ increases.
      * **Income** ($\text{Order\_Cash\_Flow} < 0$): $\text{Cost}$ decreases (increasing available funds).
      * Term: `sum \text{Order\_Cash\_Flow}[o] \times \text{ordcnt}[o]`.

2.  **Payment due AFTER production (`!Order\_Pay\_Before[o]` is 1):** Cash flow subtracts from `total_revenue`.

      * **Income** (`Order_Cash_Flow} < 0`): Subtracting a negative increases `Revenue`.
      * **Expense** (`Order_Cash_Flow > 0`): `Revenue` decreases (treated as negative revenue).
      * Term: `-\sum \text{Order\_Cash\_Flow}[o] \times \text{ordcnt}[o]`.

**Filtering in GNU MathProg**

We use a **filter** in the summation's indexing expression for selective addition:

  * $\text{sum \{o in Orders: Order\_Pay\_Before[o]\} ...}$ iterates only over orders $o$ where `Order_Pay_Before[o]` is true (1).
  * $\text{!Order\_Pay\_Before}[o]$ iterates over orders where the parameter is false (0).
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