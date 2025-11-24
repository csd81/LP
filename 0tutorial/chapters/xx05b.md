
## 5.6 Arbitrary Recipes

The implementation of the **diet problem** and the **production problem** are surprisingly similar. This is true for the number of sets, parameters, variables, constraints, the content of the constraints, and the objective. In this section, we will show how the diet problem can be viewed as a production problem. Finally, we will show a production problem with **arbitrary recipes** that generalizes both problems at the same time.

There are two ways a diet problem can be represented as a production problem.

1.  **Products are Food Types, Raw Materials are Nutrients.** This can be logical in reality as well. Food can be treated as if it were "**produced**" from its nutrients, in given ratios. In the diet, we eat the products and decompose them into their nutrients, so the process is just reversed in time. The products have costs, like foods, and the amounts exactly define the solution. The only difference is that instead of "storage" amounts for raw materials, which serve as an **upper bound** for usage, we have a **lower bound** because each nutrient must be consumed in a minimal total amount to obtain a good diet. But this feature is already implemented in the limits extension, in Problem 10. Another issue is that in this case, food "production" should be **minimized** instead of maximized, but that can be easily achieved if food costs are represented by **negative revenues** in the model. So, technically, we would have no difficulty rewriting our diet problem into a production problem with limits and negative unit revenues. This works if we consider the **food type as the products** and the **nutrients as the raw materials**.

2.  **Products are Nutrients, Raw Materials are Food Types.** This matches the process in time: the foods are the "**inputs**" that are available first, and then the products are the nutrients that we want to obtain through the whole process. There are more differences in this representation, which may make it seem unnatural. There are no upper or lower limits for foods, but there is a lower limit for nutrients, which means there would be a minimum production amount for each product in the production problem. There are no costs for the nutrients, but for the foods, which means that in the production problem there would be only costs for the raw materials but **zero revenues** for all products.

However, the most important difference, which actually prevents us from utilizing the production problem model directly in this second representation, is that the **logic of production is reversed**. That is, in the production problem, there are **many raw materials producing a single product** in given ratios. However, in the case of the diet problem, there would be a **single raw material (food) producing many products** in given ratios.

So, at this point, we could say that the second representation is flawed, and we should therefore use only the first one. Technically, nothing prevents us from doing that. However, the second representation suggests a valuable generalization for the production problem itself: **What if we relax the rule that there is only a single product in each production step?** This leads to the **production problem with arbitrary recipes**.

A **recipe** describes a process that consumes several **inputs** at once and produces several **outputs** at once, in given amounts. Each recipe can be utilized in an arbitrary volume, and both inputs and outputs are proportionally sized according to this volume.

We can see that this concept of recipes can describe both the production problem and the diet problem:

  * In the **production problem**, there is one recipe for each product. That recipe only produces that particular product as **output** but can consume any given combination of raw materials as **inputs**.
  * In the **diet problem**, there is one recipe for each food type. That recipe consumes only that particular food type as an **input** but can produce any given combination of nutrients as **outputs**.
  * Moreover, there may be other problems where there are **many inputs and many outputs** at the same time in a single recipe. These are covered by neither the production nor the diet problem alone.

Now we can define the production problem with arbitrary recipes as follows.

-----




**Problem 17.**

Given a set of **raw materials** and a set of **products**. There is also a set of **recipes** defined.

Each recipe describes the ratio in which it **consumes raw materials** and **produces products**; these ratios are arbitrary nonnegative numbers. Each recipe may be utilized in an arbitrary amount, which is named its **volume**.

  * There is a **unit cost** defined for each raw material, and a **unit revenue** for each product.
  * There can be **minimal and maximal total consumption** amounts defined for each raw material, and **minimal and maximal total production** amounts defined for each product.
  * For practical purposes, the total cost of consumed raw materials is limited: it **cannot exceed a given value**, which represents the initial funds available for raw material purchase.

Find the optimal production, where recipes are utilized in arbitrary volumes, such that all the limits on consumption and production are satisfied, and the **total profit is maximal**. The total profit is the difference between the total revenue from products and the total costs of raw materials consumed.

-----

**Model Implementation**

Let's start by implementing this problem without a specific example. We will find that its implementation is very similar to the original production problem. The first step is to "read" all the available data for future use. For this reason, there are three sets in the model: the set of raw materials, the set of products, and the set of recipes.

```
set Raws;
set Products;
set Recipes;
```

Note that the problem definition doesn't exclude the case where the **same material is both a raw material and a product** in the recipes. This is actually natural in real-world situations: some material is produced by one recipe and consumed by another. However, questions regarding **timing** would arise if we took this case into account. For instance, if a material is consumed as a raw material in a second recipe, it must first be produced by the first recipe. This would require the production according to the first recipe to happen before the execution of the second. Alternatively, the production could describe an equilibrium where amounts must be maintained, so timing is irrelevant. Given the complexity of these possibilities, we will not go into the details. For simplicity, we assume that **raw materials and products are distinct**.

To ensure that raw materials are indeed distinct from products, a `check` statement is introduced. We explicitly state that the **intersection** of the set of raw materials and the set of products must contain exactly zero elements. If this condition is not met, model construction fails immediately, as it should.

```
check card(Raws inter Products) == 0;
```

For each recipe, there are ratios for both the raw materials and the products. Because these are two different sets, defining them would typically require two different parameters: one for the ratios of raw materials in each recipe and one for the ratios of products in each recipe. This would hold true for other parameters as well.

Instead, we introduce the concept of **materials** in our model. We simply call raw materials and products together as materials. In GNU MathProg, it is legal to introduce a set that is calculated on the spot based on other sets.

```
set Materials := Products union Raws;
```

Since we assumed that no material is both a product and a raw material, we can further assume that each raw material is represented in the union once, as is each product, and these are all distinct. Now, with the new set, we can define the necessary parameters in a compact way.

```
param Min_Usage {m in Materials}, >=0, default 0;
param Max_Usage {m in Materials}, >=Min_Usage[m], default 1e100;
param Value {m in Materials}, >=0, default 0;
param Recipe_Ratio {c in Recipes, m in Materials}, >=0, default 0;
param Initial_Funds, >=0, default 1e100;
```

The parameters **`Min_Usage`** and **`Max_Usage`** denote the lower and upper bound for each material in the model. These two parameters are indexed over the `Materials` set. For raw materials, `Min_Usage` and `Max_Usage` mean limits for **total consumption**. For products, these parameters mean limits for **total production**. Because each raw material and each product is represented in the `Materials` set exactly once, this definition unambiguously describes all the limits for both raw materials and products. Note that the default limits are **0** for the lower bound and a very large number, **$10^{100}$**, for the upper limit. So, technically, there is no limit by default.

The **`Value`** parameter works similarly; it represents **raw material costs** in the case of raw materials and **revenues** in the case of products. Both are nonnegative and default to zero.

The **`Recipe_Ratio`** parameter is for describing recipes. The only data needed for the recipes are the exact amounts of inputs consumed and outputs produced. With the common `Materials` set, this can be done with a single parameter. `Recipe_Ratio` is defined for all recipes and all materials. If the material is a raw material, it describes the **consumption amount**; if it is a product, it describes the **production amount**. We call this parameter "ratio" because it corresponds to the amounts consumed and produced when utilizing the recipe with a **volume of 1**. In general, because both inputs and outputs are proportional, the ratio must be multiplied by the volume to obtain the amounts consumed or produced.

Finally, there is a single numeric parameter, **`Initial_Funds`**. This serves as an **upper limit for raw material costs**. In practice, it's generally not possible to invest unlimited amounts into raw materials; there is usually a cap on this. Note that without such a restriction and any upper limits for consumption or production, it may be possible to gain unlimited profit by consuming an unlimited amount of raw materials to produce at least one product in unlimited amounts. By default, `Initial_Funds` is set to the extreme value of **$10^{100}$** again so that it does not change the model.

Now that all the parameters and sets are defined, let's see what the freedom in our model is. What we have to decide is the **volume for each recipe utilized**. This is slightly different than before, because decisions do not correspond to one particular product or raw material, but to a given recipe. If recipe amounts are defined, the solution is exactly determined, and all other information can be calculated, including raw material usages, production amounts, costs, revenues, the profit, and corresponding limitations.

```
var volume {c in Recipes}, >=0;
var usage {m in Materials}, >=Min_Usage[m], <=Max_Usage[m];
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;
```

In our implementation, **`volume`** is the variable that denotes the volume each recipe shall be utilized in. This is a nonnegative value but can be zero and even fractional, as usual. As we mentioned, this single variable would be sufficient for model formulation, but we introduce a few **auxiliary variables** as well to write a compact and readable model.

The variable **`usage`** is the total "usage" of each material. It is indexed over the `Materials` set and works similarly to the parameters: it has a slightly different meaning for raw materials and products, but for simplicity, it can be denoted by the same single variable. For raw materials $r$, `usage[r]` is the **total consumption**, while for products $p$, `usage[p]` is the **total production** amount. Note that we can use `Min_Usage[m]` and `Max_Usage[m]` as bounds for this variable, which implements the limitations in our problem.

There is also a variable named **`total_costs`** which denotes the total costs of consumed raw materials, a variable **`total_revenue`** for the total revenue from products, and finally, a variable **`profit`** for the difference, which is our objective function. We set `Initial_Funds` as an upper bound for `total_costs`, which implements the maximum usage limitation.

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

Although this model is intended to be a generalization for both the production problem and the diet problem, supporting most of the features mentioned so far, there is only one key constraint: the **material balance** established by recipe utilization. The constraint states that the usage of each material, regardless of whether it is a raw material or a product, is calculated by adding, for each recipe, its volume multiplied by the ratio the material is represented in the recipe. This is exactly the same for both the original production problem and the diet problem.

We also define three additional constraints to calculate the values of the auxiliary variables `total_costs`, `total_revenue`, and `profit`. Note that even though parameters and variables (here `Value` and `usage`) are indexed over the `Materials` set, it is valid in GNU MathProg to index those parameters and variables over a **smaller set**. Using the original `Raws` and `Products` sets, we can sum up only for raw materials and only for products. Be careful: we can only index over the original domain, or its subset; otherwise, we will get an out-of-domain error (and the model is also guaranteed to be logically wrong).

The objective is straightforward: the profit itself.

```
maximize Profit: profit;
```

After solving the problem, we can print out the auxiliary variables, as well as the utilization volumes for each recipe and the total consumption and production amounts for each material. The full model section is ready as follows.

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

Although the model for arbitrary recipes is similar in nature to the former models, we implemented it all at once. The question arises: how can a large, complex model be implemented in GNU MathProg from scratch? Or, generally, in any mathematical programming language?

**Guide to Complex Model Implementation**

There is no universal guide for modeling, but there are good **rules of thumb** to follow. The recommendation is the following, specifically for GNU MathProg:

1.  **Feasibility Assessment:** First, decide whether the problem can be effectively solved by **LP (or MILP)** models. Many problems simply cannot be, or only with very complicated workarounds, or there is a much more suitable algorithm or other method for solving it. This is the hardest part: you basically have to determine the **decision variables** and how the appropriate **search space** can be defined by adding constraints and other variables. If you are sure you can implement an LP (or MILP) model for the problem, then you can continue with the implementation of the model file.
2.  **Data Collection and Parameter Definition:** Collect all data that are available and needed. Define **sets and parameters** which will be provided by the data sections. Data files can be implemented at this point if example problem instances are available. If some data is missing or must be calculated afterward, you will always have the opportunity to introduce other sets and parameters and calculate other data in the model file.
3.  **Define Decision Variables:** Define the decision variables. Keep in mind that the values of all the variables should **exactly determine** what is happening in the real world. In particular, you must be able to calculate the objective and decide for each restriction whether it is violated or not, based on the variables.
4.  **Implement Constraints and Bounds:** Implement all possible rules as **constraints or bounds**. Keep in mind that there are two mistakes you can make: a problem may be **under-constrained** or **over-constrained**, or both.
      * In **under-constrained** problems, solutions remain in the search space that are infeasible in the problem but feasible in the model. These additional solutions may be found by the solver and reported as fake optimal solutions. Then, additional constraints must be defined to exclude those solutions, or existing constraints redefined to be more restrictive.
      * In **over-constrained** problems, interesting solutions are excluded from the search space, and therefore not found by the solver. Then, some constraints or bounds are too restrictive; you have to reformulate or remove them. Remember that you can always introduce new auxiliary variables in the model.
5.  **Define the Objective:** Define the objective function.
6.  **Reporting:** After the `solve` statement, report the relevant details of the solution found, in the desired format.

Complex models may have several dozen constraints, so how can you be sure you haven't forgotten any rules? One idea is to focus on **parameters or variables**. In many cases, parameters are used only once in the model. Even if not, you can list all the roles the parameter or variable must appear in the model: as a bound, a constraint, or an objective term, etc. Then it is easy to spot one that has been forgotten.

***Applications of the Arbitrary Recipe Model***

Now that we have our model for arbitrary recipes ready, we will demonstrate how this works for all the problems mentioned so far in this chapter (with the exception of the maximum-of-minimum production amounts case).

***1\. Production Problem with Costs (Problem 14)***

First, **Problem 14**, which introduced raw material costs, is solved. Since this is a pure production problem in the original way, a recipe is introduced to produce each of the products. All the limits are implemented by the `Min_Usage` parameter, while raw material costs and product revenues are implemented by the `Value` parameter. The data section is the following.

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

If we solve it, we get exactly the same result as for the original model with raw costs. The optimal profit is **$1,577.45**, with production of 25.48 units of P1, 164.52 units of P2, and 10 units of P3. The output is the following.

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

The second application is the **diet problem**. We solve exactly the same problem instance as in **Problem 16**. In this example, the food types are the **raw materials** and the nutrients are the **products** we want to obtain. Contrary to the original production problem, where there were several inputs and one output per recipe, here there is only one input (a food type) per recipe, which produces several nutrients with given ratios.

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

The solution is again exactly the same as for the original diet problem, which is an optimal cost of 29,707.2, with food consumption amounts of 42.86 of F2, 49.20 of F4, and 28.75 of F5. Note that in this case, the objective reported by the solver is -29,707.2, because the profit is determined solely by the food costs (revenue is zero, so profit = $0 - \text{Total Costs}$).

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

Recall that we mentioned two ways a diet problem can be represented as a production problem. Now the second of them was implemented, where food types are the raw materials and nutrients are the products. But how could we implement the representation of the first case, where food types are the products and nutrients are the raw materials?

Surprisingly, this **arbitrary recipe model** is able to do that as well, simply by **exchanging the roles of the products and raw materials**. If we understand this, we can see that there is a very high degree of **symmetry** in the production problem with arbitrary recipes. There are minimum and maximum usages for both the raw materials and the products. The cost of a raw material is the counterpart of the revenue of a product. If we look at the recipes, we can see that there is no "source-target" relation between raw materials and products; these two roles are **interchangeable**. The only slight difference between raw materials and products that breaks the symmetry is the **`Initial_Funds`** feature, which gives an upper limit for the total of raw material costs. The symmetry would be perfect if `Initial_Funds` was set to infinity, or if another feature, like maximal revenue, was also introduced.

Finally, let's look at a new example problem to further demonstrate the capabilities of the arbitrary recipe model. The starting point for the problem instance is **Problem 14**, where raw material costs were introduced, but we will make a few modifications.

 

**Problem 18.**

Solve **Problem 14**, the original production problem, using the exact same data, but with two additional production options.

  * **P1** and **P2** can be produced jointly, with slightly different consumption amounts than when produced separately. Producing one unit of both products requires **240 units** of raw material $\text{A}$ (instead of 250 when done separately), **200 units** of raw material $\text{B}$ (instead of 205 when done separately), **4,400 units** of raw material $\text{C}$ (slightly more than 4,200 when done separately), and **2 units** of raw material $\text{D}$ (exactly as if done separately).

  * Similarly, **P2** and **P3** can also be produced jointly. The costs are **51 units** of raw material $\text{A}$ (slightly more than 50 when done separately), **250 units** of raw material $\text{B}$ (instead of 255 when done separately), **5,400 units** of raw material $\text{C}$ (instead of 5,500 when done separately), and **2 units** of raw material $\text{D}$ (exactly as if done separately).

This problem can be solved by manipulating the data section of the original problem. We need to add two extra *recipes* to the **Recipes** set, then two rows to the **Recipe\_Ratios** parameter to describe these two new recipes. The data section and the results are as follows:

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

The optimal solution is **$1,965.62$**, which is a bit better than the original **$1,577.45$**. This is because the only modification was adding new production opportunities, which widened the search space. We can also see that **Comp1** and **Comp2**, the recipes for the joint production methods, are used as an alternative to the original options. There are still a few units (6.25) of **P2** produced alone, though. The total production is also slightly different in this solution, with **86.88 units** of $\text{P1}$, **103.13 units** of $\text{P2}$, and **10 units** of $\text{P3}$.

-----

## 5.7 Order Fulfillment

Now we have a complete model for the production problem of arbitrary recipes, which allows us to easily implement and solve a wide range of problems, including the diet problem. We will further extend the model with a new, practically important feature: **orders**. Orders allow materials to be bought and sold in bulk. This is potentially a more lucrative option but can only be acquired entirely or ignored completely.

So far in the production problem topic, we only had **real-valued variables**; therefore, all the models were **Linear Programming (LP)** models. Now, we will introduce **integer variables**, making the model a **Mixed Integer Linear Programming (MILP)** model. We must note that while MILP models are easy to implement, the solution procedure can take an unacceptably long time if there are too many **binary variables**. The limit on what is considered *too many* depends on the model: in some problems, we can only have several dozens of integer variables, while sometimes several hundreds or even thousands will work. Regardless, this limit is definitely lower than the number of ordinary real-valued variables in LP models. Unfortunately, in many situations, the limitations can only be slightly pushed up by choosing stronger equipment, better solvers, or improved modeling techniques, because **integer programming** is an **NP-Complete problem**. Nevertheless, using integer variables is a very powerful modeling tool that allows a significantly wider range of problems to be potentially modeled by MILP than those by LP.

We will see an example of how a **GNU MathProg** model can be extended with new features while maintaining compatibility with old data files. We will also see how we can use a filter within an indexing expression in **GNU MathProg**.

An **order** is a fixed amount of several raw materials that are purchased and/or products that are sold when ready by the producing party. An order can either cost money or gain income, and payment may happen either before or after all the production takes place. The same order may be fulfilled multiple times.

The general problem definition for arbitrary recipes and order fulfillment is the following.

 

**Problem 19.**

Solve **Problem 17**, the production problem with arbitrary recipes, where production proceeds as usual, but now includes **orders** that we may acquire. Orders are **optional** but must be acquired (and subsequently fulfilled) **completely**, not partially. Each order has the following characteristics:

  * **Fixed Material and Product Amounts:** If a raw material is included in an order, acquiring the order means we **obtain** that raw material in the specified amount *before* production. If a product is included in an order, acquiring it means we must **deliver** that product in the specified amount *after* it is produced.
  * **Order Price (Cash Flow):** This can be a cash **gain (revenue)** or a **payment (cost)**. The payment occurs either **before** or **after** production takes place.
  * **Maximum Count:** An order can be acquired and fulfilled multiple times, up to a specified upper limit.

Raw materials must either be purchased from the market, as before, or obtained by acquiring an order. Any **leftover** raw materials after production are **lost** without compensation.

Products must either be sold on the market or delivered via an order. The only way to obtain products is by producing them. Fulfilling acquired orders is **mandatory**.

Minimum and maximum usage limitations still apply as before. Limitations correspond to the **total amounts** of materials and products in possession at the same time.

The **Total Costs** include all incomes and expenses from orders where payment is due *before* production, plus the total cost of raw materials purchased from the market in the ordinary way. Total Costs are limited: there is a fixed amount of **initial funds** that cannot be exceeded.

The **Total Revenue** includes all incomes and expenses from orders where payment is due *after* production, plus the total revenue from selling products on the market in the ordinary way.

The objective is to optimize for **Profit**, which is the difference between the Total Revenue and the Total Costs.

-----

**Model Analysis and Compatibility**

The first observation is that although this problem definition is extensive, if we assume there are **no orders** in the problem, we revert exactly to the production problem with arbitrary recipes.

If there were no orders, the only way to get raw materials is by purchasing from the market, and the only way to gain revenue is by selling products on the market. We would purchase exactly the amount of raw materials needed and sell all the products produced. There would be no potential loss of materials or alternatives.

For this reason, the new model is designed to work with the data files from the "old" arbitrary recipes model, ensuring **backward compatibility**.

-----

**Data Implementation for Orders**

First, let's see how the extra data for orders can be implemented in the model using sets and parameters:

```
set Orders, default {};

param Order_Material_Flow {o in Orders, m in Materials}, >=0, default 0;
param Order_Cash_Flow {o in Orders}, default 0;
param Order_Count {o in Orders}, >=0, integer, default 1;
param Order_Pay_Before {o in Orders}, binary, default 1;
```

  * The additional set **Orders** uses a default value of `{}` (an empty one-dimensional set in GNU MathProg). This ensures that original data files, which do not mention the `Orders` set, will still work.
  * **`Order_Material_Flow`**: Similar to `Recipe_Ratio`. If material $m$ is a **raw material**, the order denotes a **purchase** (input). If $m$ is a **product**, the order denotes a **delivery** (output). By default, material flow is zero.
  * **`Order_Cash_Flow`**: Denotes the cash flow associated with the order. This is the **only parameter that can be negative**.
      * A **positive value** means a **cost** (payment) for acquiring the order.
      * A **negative value** means a **revenue** (cash gain) from the order.
      * A zero value is relevant, as it means the order facilitates a materials/products exchange without immediate cash impact.
      * *Note*: A zero `Order_Material_Flow` for all materials in an order with a non-zero cash flow would represent an investment (an expense now for income later), though the current model only implements cash flow once (before or after production).
  * **`Order_Count`**: Denotes the maximum number of times an order can be acquired. Since orders multiply material flows and prices, this must be a non-negative **integer** ($\ge 0$, `integer` keyword). A default of **1** means the order is either acquired once or not at all.
  * **`Order_Pay_Before`**: A **binary** parameter (0 or 1) that specifies the timing of the cash flow.
      * **1 (True)**: Payment is due **before** production (contributes to Total Costs).
      * **0 (False)**: Payment occurs **after** production (contributes to Total Revenue).
      * The default is **1**.
  * *Note*: The `binary` and `integer` keywords indicate the same value restriction for parameters and variables in this context.

-----

**Decision Variables**

The following variables are defined, with a new variable to handle order acquisition:

```
var volume {c in Recipes}, >=0;
var total_costs, <=Initial_Funds;
var total_revenue;
var profit;
var ordcnt {o in Orders}, integer, >=0, <=Order_Count[o];
```

  * The main recipe variable (`volume`) and the auxiliary variables (`total_costs`, `total_revenue`, `profit`) remain unchanged.
  * **`ordcnt`**: A new variable that denotes how many times a given order is acquired. It is constrained by the `Order_Count` parameter and is required to be an **integer** (`integer` keyword). This is the **only variable** that changes the model from an LP to an **MILP**. Since orders cannot be partially fulfilled, `ordcnt` must take only whole number values (0, 1, 2, ...).

-----

**Material Usage Variables**

The material flow is now more complicated because materials can come from and go to different sources. We introduce several usage variables to track this:

  * **Raw Materials** can be obtained from the market or orders, used up by production, or become wasted leftover.
  * **Products** are obtained only by production, and then sold to the market or delivered via orders. Leftovers are not modeled for products because there's no incentive to keep them instead of selling them on the market.
  * Usage refers to the **total amount** in possession at the same time.

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

Constraints are used to define the relationships between the new usage variables.

**1. Production and Order Calculations**

These constraints calculate the amounts flowing through production and orders based on the decision variables (`volume` and `ordcnt`).

```
s.t. Material_Balance_Production {m in Materials}: usage_production[m] =
    sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

s.t. Material_Balance_Orders {m in Materials}: usage_orders[m] =
    sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];
```

**2. Total Usage and Balance for Raw Materials**

For raw materials, the total amount obtained must equal the total amount consumed (production + leftover).

```
s.t. Material_Balance_Total_Raws_1 {r in Raws}:
    usage_total[r] = usage_orders[r] + usage_market[r]; 
    // Total amount obtained = (From Orders) + (From Market)

s.t. Material_Balance_Total_Raws_2 {r in Raws}:
    usage_total[r] = usage_production[r] + usage_leftover[r];
    // Total amount used = (Consumed by Production) + (Leftover)
```

  * `usage_market` and `usage_leftover` are "free" variables that the model selects to satisfy the balance equations, given the calculated `usage_orders` and `usage_production` amounts.

**3. Total Usage and Balance for Products**

For products, the total amount obtained must equal the total amount sold/delivered.

```
s.t. Material_Balance_Total_Products_1 {p in Products}:
    usage_total[p] = usage_production[p];
    // Total available amount = (Amount Produced)

s.t. Material_Balance_Total_Products_2 {p in Products}:
    usage_total[p] = usage_orders[p] + usage_market[p];
    // Total disposed = (Delivered to Orders) + (Sold on Market)
```

  * The first constraint makes `usage_total[p]` an auxiliary variable equal to `usage_production[p]`. The second constraint ensures this total produced amount is covered by deliveries to orders and sales to the market (`usage_market[p]` is the "free" variable here).

-----

**Cost, Revenue, and Profit Calculation**

These constraints calculate the financial variables, incorporating the timing of cash flows from orders.

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

The sign of `Order_Cash_Flow` is used to represent cost (positive) or revenue (negative).

1.  **If payment is due BEFORE production (`Order_Pay_Before[o]` is true, or 1):** The cash flow is added to `total_costs`.

      * If the order is an **expense** ($\text{Order\_Cash\_Flow} > 0$), $\text{Cost}$ increases.
      * If the order is an **income** ($\text{Order\_Cash\_Flow} < 0$), $\text{Cost}$ decreases (increases available funds).
      * The term is `sum \text{Order\_Cash\_Flow}[o] \times \text{ordcnt}[o]`.

2.  **If payment is due AFTER production (`!Order\_Pay\_Before[o]` is true, or 0):** The cash flow is subtracted from `total_revenue`.

      * If the order is an **income** (`Order_Cash_Flow} < 0`), subtracting a negative number increases `Revenue`.
      * If the order is an **expense** (`Order_Cash_Flow > 0`), `Revenue` decreases (treated as a negative revenue).
      * The term is `-\sum \text{Order\_Cash\_Flow}[o] \times \text{ordcnt}[o]`.

**Filtering in GNU MathProg**

The selective addition of order cash flow is done using a **filter** in the summation's indexing expression:

  * The syntax $\text{sum \{o in Orders: Order\_Pay\_Before[o]\} ...}$ means the sum only iterates over orders $o$ for which the logical expression $\text{Order\_Pay\_Before}[o]$ evaluates to true (i.e., 1).
  * The condition $\text{!Order\_Pay\_Before}[o]$ means the sum iterates over orders where the parameter evaluates to false (i.e., 0).
  * In GNU MathProg, filtering is allowed on all indexing expressions (e.g., `param`, `set`, `var`, `s.t.`, `for`). A sum over an empty set evaluates to zero.

-----

**Complete Model Section and Output**

The final model maximizes the profit:

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

The order of variables and constraints does not affect the solution, but a logical flow helps in understanding the model:

1.  **Decision on Orders:** Set `ordcnt`.
2.  **Calculate Order Flows:** Determine `usage_orders`.
3.  **Decision on Production:** Set `volume`.
4.  **Calculate Production Flows:** Determine `usage_production`.
5.  **Adjust Market/Total Flows:** Set `usage_market` and calculate `usage_total` to satisfy material balance.
6.  **Calculate Leftovers:** Determine `usage_leftover`.
7.  **Calculate Financials:** Determine `total_costs`, `total_revenue`, and `profit`.

-----

**Example 1: Problem 14 Data (No Orders)**

The first example uses data from **Problem 14** (arbitrary recipes with costs) but without defining the `Orders` set.

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

**Results:** The optimal solution is the same as the original: **$1,577.45$** profit, with production of 25.48 units of P1, 164.52 units of P2, and 10 units of P3.

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

The second example uses data from **Problem 18** (arbitrary recipes with joint production), but explicitly defines the order-related parameters and sets as empty.

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

**Results:** The optimal solution is again the same as before: **$1,965.63$** profit, using the joint production options `Comp1` and `Comp2`.

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

Solve **Problem 18**, a production problem example with arbitrary recipes, with the following modifications:

  * **Raw Material Usage Limits:** The maximum usage limits for raw materials have been reset. Instead of 23,000 units of A, 31,000 units of B, 450,000 units of C, and 200 units of D, the new limits are **50,000 units of A**, **120,000 units of B**, **1,000,000 units of C**, and **1,500 units of D**.
  * **Initial Funds:** Initial funds are capped at **35,000**.
  * **Available Orders:** There are three available orders with the following properties:

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

Since the maximum usages for raw materials are much larger and production is generally profitable, the extra capacities result in a significant increase in the objective function. Also, orders are being used.

We can see that the **optimal profit is 20,705.4**. The total production volume is **89.16 units of P1**, **553.72 units of P2**, and **10 units of P3**. We acquire **Ord1 once** and **Ord3 30 times**, which is the maximum available. Ord3 is a lucrative way to produce and deliver product P1. Significant amounts of each raw material are obtained through orders, and additional amounts are purchased from the market. For this reason, there are **no leftovers** after production. Some of the products are delivered via orders, but in all three cases, amounts are also sold on the market.

Let's run an experiment to examine the integer nature of this model. As previously mentioned, this is an **MILP** (Mixed-Integer Linear Programming) model because of the order acquisition decisions, which must be modeled using integer variables. However, `glpsol` has a built-in `--nomip` option to relax all integer variables.

**Relaxing** means that variables are not forced to be integers but are only constrained to be between their defined lower and upper bounds, if any. By relaxing all integer variables of an MILP model, we obtain its **LP (Linear Programming) relaxation**.

```bash
glpsol -m model.mod -d data.dat --nomip
```

If this option is used, the model is treated as an LP. This is solved much faster, but integer variables are allowed to take fractional values. If this occurs, the solution is **infeasible in reality**. Using this option on the problem instance above, the following result is reported:

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

The optimal solution of the LP relaxation is **21,397**, which is **better** than the MILP's profit of 20,705.4. This is a natural result because the LP relaxation has a wider search space, including all MILP solutions and possibly others where integer variables take fractional values. The LP relaxation is important not for modeling but for the algorithmic solution process. The LP relaxation of an MILP is usually fast to solve, and its optimal solution is guaranteed to be an **upper bound** for the optimal solution of the MILP itself. This is useful because solving the MILP to global optimality can be hard or impossible. The optimal solution will always lie between the best currently found integer solution and a suitable bound, like the LP relaxation.

If we look closely at the LP relaxation solution, it surprisingly seems "more integer" than the MILP solution. However, because the objective values are different, we can be certain that at least one integer variable has a fractional value. In fact, there are partially acquired orders; for example, **Ord1 is acquired 1.5 times**. We can deduce this by looking at the material amounts related to orders. The reason this wasn't reported is simply that the order count was printed using the `%d` format specifier, which rounds the fractional value to the nearest integer before printing. Therefore, the post-processing output is not precise when integer variables are relaxed. Alternatively, `%f` or `%g` could have been used.

-----

## 5.8 Production Problem – Summary 

We began with the simplest production problem: given only the available amounts of raw materials, the goal was to decide the production mix to achieve the highest revenue. We demonstrated how this problem can include upper and lower limits on production and consumption, how to optimize using a different objective if necessary, and how to factor in raw material costs.

The **diet problem**—determining the optimal amount of certain food types to satisfy nutritional requirements—while seemingly quite different, resulted in a very similar implementation to the production problem. In fact, the two problems can be interpreted as special cases of a more general production problem where recipes may involve multiple raw materials and products simultaneously.

Finally, the concept of **orders** was introduced in the ultimate model of the chapter, which gave the problem an **integer nature**. This is because orders can only be acquired and fulfilled completely, not partially. This extension provides new possibilities for raw material supply and final product demand, and the problem remains linear. Additional data files, ranging from basic to more complex problems, can be easily implemented and solved using the same single model file.




