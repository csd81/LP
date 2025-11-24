

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

```ampl
set Raws;
set Products;
set Recipes;
```

Note that the problem definition doesn't exclude the possibility that the **same material acts as both a raw material and a product** in different recipes. This is natural in real-world scenarios: a material produced by one recipe might be consumed by another. However, considering this would raise questions regarding **timing**. For instance, if a material is consumed as a raw material in a second recipe, it must first be produced by the first recipe. This implies a sequence where the first recipe executes before the second. Alternatively, the production could describe an equilibrium where amounts must be maintained, making timing irrelevant. Given the complexity of these possibilities, we won't go into details here. For simplicity, we assume that **raw materials and products are distinct**.

To ensure that raw materials are indeed distinct from products, we introduce a `check` statement. We explicitly state that the **intersection** of the set of raw materials and the set of products must contain exactly zero elements. If this condition isn't met, model construction fails immediately, as it should.

```ampl
check card(Raws inter Products) == 0;
```

For each recipe, there are ratios for both raw materials and products. Since these are two different sets, defining them would typically require two different parameters: one for raw material ratios and one for product ratios. This would apply to other parameters as well.

Instead, we introduce the concept of **materials** in our model. We simply group raw materials and products together as "materials." In GNU MathProg, it is legal to introduce a set that is calculated on the spot based on other sets.

```ampl
set Materials := Products union Raws;
```

Since we assumed no material is both a product and a raw material, we can assume each raw material and product is represented exactly once in the union, and they are all distinct. Now, with this new set, we can define the necessary parameters compactly.

```ampl
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

```ampl
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

```ampl
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

```ampl
maximize Profit: profit;
```

After solving the problem, we can print out the auxiliary variables, the utilization volumes for each recipe, and the total consumption and production amounts for each material. The full model section is ready as follows.

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
s.t. Material_Balance_Production {m in Materials}: usage_production[m] =
    sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

s.t. Material_Balance_Orders {m in Materials}: usage_orders[m] =
    sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];
```

**2. Total Usage and Balance for Raw Materials**

For raw materials, total amount obtained must equal total amount consumed (production + leftover).

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl

Solving the problem with `glpsol` yields the following result:

```ampl
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

```ampl
param Max_Unit_Cost, default 7;
```

Note that by providing a default value of **7** instead of setting the parameter equal to **7**, we allow the possibility to **alter** `Max_Unit_Cost` by providing a value in the data section, if we ever want to choose a different limit.

One possible solution is to express a new constraint that explicitly finds each prohibited connection and sets the transported amount there to zero, effectively excluding the connection from the model.

```ampl
s.t. Connections_Prohibited
{s in Supplies, d in Demands: Cost[s,d] > Max_Unit_Cost}: tran[s,d] = 0;
```

However, in this case, we use many variables in the model just to fix them at zero. It's possible **not to include** those variables in the model formulation at all, and this can be done by introducing a **filter** in the `setof` expression defining the **`Connections`** set.

```ampl
set Connections :=
setof {s in Supplies, d in Demands: Cost[s,d] <= Max_Unit_Cost} (s,d);
```

With this filter, we only include allowed connections in the **`Connections`** set. Therefore, without modifying other parts of the model, the exclusion is implemented—the indexing expressions `(s,d)` in `Connections` just iterate over a **smaller set** in the background.

Note that **care must be taken** with this method, because now the following constraint would cause an **out-of-domain error**:

```ampl
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
```

The problem is that `tran[s,d]` is iterated over **all pairs** of `s` in **`Supplies`** and `d` in **`Demands`**, but the variable is simply **not defined** for all such pairs now. This is in strong contrast with the first approach where they **are defined**, but explicitly set to zero. We must now ensure that the sum only considers **allowed connections**, which can be done as follows:

```ampl
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

```ampl
param CostThreshold, >=0;
param CostIncPercent, >0;
```

In Problem 25, the following values can be given in the **data** section.

```ampl
param CostThreshold := 100;
param CostIncPercent := 25;
```

We introduce another parameter, **`CostOverThreshold`**, which calculates the increased unit cost using the following formula. Note that the original unit cost is `Cost[s,d]`.

```ampl
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 + CostIncPercent / 100);
```

At this point, we have all the required data defined in the model. The question is how to **implement the correct calculation of total costs**, regardless of whether the amount is below or above the threshold.

First, we can simply introduce two variables: **`tranBase`** for amounts below and **`tranOver`** for amounts above the threshold.

```ampl
var tranBase {(s,d) in Connections}, >=0, <=CostThreshold;
var tranOver {(s,d) in Connections}, >=0;
```

Note that both quantities are **nonnegative**. The amount to be transported over the threshold for the increased cost (`tranOver`) is **unlimited**; however, we can only transport a **limited amount** at the original cost (`tranBase`). Therefore, `tranBase` gets an **upper bound**: the threshold itself. Note that the decision of transported amounts is **individual for each connection**; therefore, all these variables are defined for each connection.

The amounts represented by `tranBase` and `tranOver` are simply a **separation of the total amount** represented by `tran`. Therefore, a **constraint** is provided to ensure that the sum of the former two equals `tran` for each connection.

```ampl
s.t. Total_Transported {(s,d) in Connections}:
tran[s,d] = tranBase[s,d] + tranOver[s,d];
```

Instead of using `tran` in the objective, we can refer to the **`tranBase` and `tranOver` parts separately** and multiply these amounts by their corresponding unit costs (`Cost` and `CostOverThreshold`).

```ampl
minimize Total_Costs: sum {(s,d) in Connections}
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);
```

Our model is ready, but consider one thing. Now, the `tranBase` and `tranOver` amounts can be set **freely**. For example, if the threshold is **100**, then transporting **130 units** in total can be done as $\text{tranBase}=100$ and $\text{tranOver}=30$, but also as $\text{tranBase}=50$ and $\text{tranOver}=80$. In the latter case, the total cost is not calculated correctly in the objective, but it is **still allowed by the constraints**.

But the model works because the unit cost above the threshold is **strictly higher** than the cost below it. Therefore, the optimal solution would **not attempt** transporting any amounts over the threshold unless all possible amounts are transported below it (i.e., $\text{tranBase}=100$ in the example). Spending more is allowed as **feasible solutions** in the model, but these cases are **eliminated by the optimization procedure**. Consequently, in the optimal solution, there is either **zero amount above the threshold** or the **full amount below it** for each connection. The costs are calculated correctly in both scenarios.

-----

The full model section for the transportation problem with increasing rates is shown here.

```ampl
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

```ampl
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

```ampl
param CostDecPercent, >0, <=100;
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 - CostDecPercent / 100);
```

However, if we solve the model, the results **do not reflect reality**.

```ampl
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

```ampl
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

```ampl
param M := sum {s in Supplies} Available[s];
s.t. Zero_Over_Threshold_if_Threshold_Not_Chosen {(s,d) in Connections}:
tranOver[s,d] <= M * isOver[s,d];
```

When $\text{isOver}[s,d]=0$, then $\text{tranOver}[s,d] \le 0$ is enforced (so it must be zero). $M$ must be larger than any sensible value of $\text{tranOver}[s,d]$.

For the second constraint:

```ampl
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
tranBase[s,d] >= CostThreshold - M * (1 - isOver[s,d]);
```

However, we can use a **smarter big-M**. The big-M can be set as low as $\mathbf{CostThreshold}$. With this value, the constraint can be rearranged into a more readable form:

```ampl
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
tranBase[s,d] >= CostThreshold * isOver[s,d];
```

If $\text{isOver}[s,d]=1$, then $\text{tranBase}[s,d] \ge \text{CostThreshold}$ is enforced. If $\text{isOver}[s,d]=0$, the constraint is redundant.

We added the variable $\text{isOver}$ and these two constraints to the previous model, and now our model for the transportation problem with **economy of scale** is ready.

**Full MILP Model for Economy of Scale**

```ampl
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

```ampl
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

```ampl
param FixedCost {(s,d) in Connections}, >=0;
```

```ampl
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

```ampl
var tranUsed {(s,d) in Connections}, binary;
```

Two things must be enforced. First, if we **do not establish the connection** ($\text{tranUsed}=0$), there must be **no amount transported** ($\text{tran}=0$). This can be done with a **big-M constraint**.

```ampl
param M := sum {s in Supplies} Available[s];
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= M * tranUsed[s,d];
```

The coefficient $M$ must be large enough not to exclude legitimate solutions. To create **stricter constraints**, we can use the **minimum of the available amount at the supply and the required amount at the demand**.

```ampl
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= min(Available[s],Required[d]) * tranUsed[s,d];
```

Second, we must include the fixed establishment cost in the **objective function**.

```ampl
minimize Total_Costs: sum {(s,d) in Connections}
(tran[s,d] * Cost[s,d] + tranUsed[s,d] * FixedCost[s,d]);
```

The full model section is the following.

**Full MILP Model for Fixed Costs**

```ampl
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

```ampl
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

```ampl
var satisfied {d in Demands}, >=0;
s.t. Calculating_Demand_Satisfied {d in Demands}:
satisfied[d] = sum {s in Supplies} tran[s,d];
```

**Method 1: Single Penalty Variable**

The penalty function can be modeled by two linear constraints.

```ampl
var penalty {d in Demands}, >=0;
s.t. Shortage_Penalty_Constraint {d in Demands}:
penalty[d] >= ShortagePenalty * (Required[d] - satisfied[d]);
s.t. Surplus_Penalty_Constraint {d in Demands}:
penalty[d] >= SurplusPenalty * (satisfied[d] - Required[d]);
```

The penalty variable is included in the objective function. The optimization procedure eliminates excessively high penalty values, so in the optimal solution, one constraint will be strict (or both if the requirement is met exactly).

```ampl
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
sum {d in Demands} penalty[d];
```

**Method 2: Shortage and Surplus Variables**

Alternatively, we can use variables for the exact shortage and surplus amounts.

```ampl
var surplus {d in Demands}, >=0;
var shortage {d in Demands}, >=0;
s.t. Calculating_Exact_Demands {d in Demands}:
Required[d] - shortage[d] + surplus[d] = satisfied[d];
```

The optimization procedure ensures that **either shortage or surplus is zero** in the optimal solution.

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
set Items;
param Weight {i in Items}, >=0;
param Knapsack_Count, integer;
set Knapsacks := 1 .. Knapsack_Count;
```

We also introduced the set `Knapsacks`. However, instead of reading this set from the data section, we **denote** each knapsack by numbers from **1 to K**. The operator `..` defines a set by listing all integers between the **smallest** and **largest** integer element.

Note that we require `Weight` to be **non-negative**; however, these parameters can be restricted to **integers** or relaxed to take **real values**. The **model** remains exactly the same in all cases.

There are **more decisions** to be made here than in the original knapsack problem. For each item, we don't just decide *whether* it goes into a knapsack; we decide **which knapsack it goes into**. We can do this by defining a **binary decision variable** `select` for each pair of an **item** and a **knapsack**, denoting whether that item goes into that specific knapsack. While these decisions cover the situation, we need **auxiliary variables** to express the **objective function concisely**. Therefore, we introduce a variable `weight` for each knapsack (denoting its total weight), along with `min_weight` and `max_weight` for the overall minimal and maximal knapsack weights.

```ampl
var select {i in Items, k in Knapsacks}, binary;
var weight {k in Knapsacks};
var min_weight;
var max_weight;
```

There is only **one constraint** that determines if a decision regarding knapsacks is **feasible**: **each item must go exactly into one knapsack**. If we sum the binary variables for a specific item across all knapsacks and set that sum to one, the only feasible solution is for **one binary variable to be 1 and all others to be 0**. Therefore, the constraint is:

```ampl
s.t. Partitioning {i in Items}:
sum {k in Knapsacks} select[i,k] = 1;
```

We provide **three additional constraint statements** to express the calculation of each knapsack's weight, a **lower limit** on all knapsack weights (`min_weight`), and an **upper limit** (`max_weight`).

```ampl
s.t. Total_Weights {k in Knapsacks}:
weight[k] = sum {i in Items} select[i,k] * Weight[i];
s.t. Total_Weight_from_Below {k in Knapsacks}:
min_weight <= weight[k];
s.t. Total_Weight_from_Above {k in Knapsacks}:
max_weight >= weight[k];
```

The **objective** is the **difference** between the upper and lower limits.

```ampl
minimize Difference: max_weight - min_weight;
```

This design has been used before for **minimizing errors in equations** (Section 4.8), **maximizing minimum production volumes** (Section 5.3), and various **cost functions** (Sections 6.3 or 6.6). The key is that the solver is allowed **not** to assign the actual **minimum** and **maximum** weights to the variables `min_weight` and `max_weight` while still finding **feasible solutions**. However, it is **not beneficial** to do so. Therefore, solutions where these two bounds are not **strict** are **automatically ruled out** during minimization.

Finally, we **print the contents of each knapsack** after the `solve` statement, and our model section is **ready**.

```ampl
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

```ampl
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

```ampl
Max. Cross Tiles (4x6): 2
....+.
.+.+#+
+#+.+.
.+....
```

The medium instance ($10 \times 10$) is still solved very quickly. A maximum of **13** cross tiles fit, and the solution looks like this:

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
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

```ampl
set Workers;
set Tasks;
check card(Workers)==card(Tasks);
set Assignments := Workers cross Tasks;
param Cost {(w,t) in Assignments};
```

Data for Problem 41 can be implemented as follows:

```ampl
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

```ampl
var assign {(w,t) in Assignments}, binary;
```

There are two rules we must obey: each worker must have exactly one task, and each task must have exactly one worker.

```ampl
s.t. One_Task_Per_Worker {w in Workers}:
sum {t in Tasks} assign[w,t] = 1;
s.t. One_Worker_Per_Task {t in Tasks}:
sum {w in Workers} assign[w,t] = 1;
```

The objective is the total cost, obtained by adding each assignment variable multiplied by its cost.

```ampl
minimize Total_Cost:
sum {(w,t) in Assignments} assign[w,t] * Cost[w,t];
```

Finally, we print the optimal cost and the task assigned to each worker.

```ampl
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

```ampl
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

```ampl
param Fixing {(w,t) in Assignments}, in {0,1,2}, default 2;
```

This parameter has three values:

  * **0**: **Exclude** the assignment.
  * **1**: **Force** this assignment to be used.
  * **2**: Leave the decision to **optimization**.

Setting the default to 2 ensures **compatibility with old data files** that don't mention `Fixing`.

Next, we enforce these decisions. For any `Fixing` value of 0 or 1, we explicitly set the `assign` variable to that value.

```ampl
s.t. Fixing_Constraints {(w,t) in Assignments: Fixing[w,t]!=2}:
assign[w,t] = Fixing[w,t];
```

This completes the model. We demonstrate it with two trials.

-----

**Trial 1: Prohibiting an Assignment**

We set assignment **W6 to T6 as zero (excluded)**. Since the original optimal solution used this assignment, prohibiting it forces the solver to find an alternative.

```ampl
param Fixing :=
W6 T6 0
;
```

```ampl
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

```ampl
param Fixing :=
W4 T3 1
;
```

```ampl
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

```ampl
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

```ampl
set Nodes;
param Start, symbolic, in Nodes;
param Finish, symbolic, in Nodes;
check Start!=Finish;
```

While edges in simple graphs are undirected ($AB = BA$), it is easier in math programming to refer to them as **$(A, B)$ ordered pairs**. We allow all ordered pairs (directed arcs) because edge direction helps in the model.

We introduce a parameter **`Infty`** as a default large cost to effectively exclude edges not listed in the data.

```ampl
param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);
```

Parameter **`W`** ensures that if we provide a weight for $AB$, it applies to both $AB$ and $BA$.

**Solving the Shortest Path Problem**

The idea is to imagine a single **"droplet" of material** placed at **`Start`**. It flows through the arcs to reach **`Finish`**. This draws the path.

A binary variable **`flow`** denotes whether the droplet flows through an arc $(a, b)$.

```ampl
var flow {a in Nodes, b in Nodes}, binary;
```

We need to check the **material balance** at each node:

  * **Start**: Droplet leaves. Balance is **-1**.
  * **Finish**: Droplet arrives. Balance is **1**.
  * **Others**: Droplet arrives and leaves. Balance is **0**.

<!-- end list -->

```ampl
subject to Path_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Start) then -1 else if (x==Finish) then 1 else 0;
```

This ensures a **feasible trail** exists. The objective is to minimize total weight.

```ampl
minimize Total_Weight:
sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b];
```

Optimization will naturally rule out cycles and extra edges because of their positive weight, resulting in a simple path.

Solving for **A to I** gives:

```ampl
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

```ampl
param Sink := A;
```

We use two variables:

  * **`use`**: Binary. Is the edge selected?
  * **`flow`**: Continuous. How much material flows through it?

<!-- end list -->

```ampl
var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};
```

Constraints ensure flow in one direction is the negative of the other, and flow only happens on selected (`use`) edges (using a big-M constraint based on node count).

```ampl
subject to Flow_Direction {a in Nodes, b in Nodes}:
flow[a,b] + flow[b,a] = 0;
subject to Flow_On_Used {a in Nodes, b in Nodes}:
flow[a,b] <= use[a,b] * (card(Nodes) - 1);
```

Material balance:

  * **Sink**: Receives all droplets ($\mathbf{1 - \text{card(Nodes)}}$).
  * **Others**: Sends one droplet ($\mathbf{1}$).

<!-- end list -->

```ampl
subject to Material_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Sink) then (1-card(Nodes)) else 1;
```

Minimizing the total weight of `use`d edges results in a spanning tree directed toward the Sink.

Solving the example with Sink **A**:

```ampl
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

```ampl
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

```ampl
var use {a in Nodes, b in Nodes}, binary;
subject to Path_In {b in Nodes}: sum {a in Nodes} use[a,b] = 1;
subject to Path_Out {a in Nodes}: sum {b in Nodes} use[a,b] = 1;
```

However, simple assignment constraints might result in **multiple smaller cycles** rather than one big cycle (see Figure 17). To prevent this, we must ensure **connectivity**. We reuse the MST flow technique: put a droplet at each node and ensure they can all flow to `Start`. This is possible if and only if there is a single connected cycle.

```ampl
var flow {a in Nodes, b in Nodes};
...
subject to Material_Balance {x in Nodes}: ...
```

The TSP model is essentially a combination of the **assignment problem** and **connectivity constraints**.

Solving Problem 47 yields a cycle length of **44.59**.

```ampl
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

**Integer programming** expands the range of solvable problems significantly compared to pure LP, but it comes with a steep increase in **computational complexity**.
----
# Chapter 8: Solution Algorithms

Up to this point, we have focused on $\text{LP}$ and $\text{MILP}$ **modeling techniques** and the specifics of **GNU MathProg implementation**. Mathematical programming models are solved using **dedicated solvers**, and typically, you can perform the modeling process without needing to know exactly how these solvers operate under the hood.

However, understanding the **solution algorithms** themselves can be incredibly valuable during the modeling phase. This knowledge aids in **designing models**, **improving their efficiency**, **selecting the right solver tools and configurations**, and **interpreting results** and solver outputs. Therefore, this chapter aims to provide insight into how the models we describe in a modeling language are actually solved in the background.

Operations research boasts a rich body of literature regarding solution algorithms, dating back to the 1970s. We recommend a few books for interested readers. First, W. L. Winston's book [31] is a widely used handbook covering the main models and algorithms. We also suggest István Maros's book on Linear Programming [32] and the work of George Dantzig [33].

**Linear Programming (LP)** is a primary technique within operations research. There are several solution methods, most notably the **Simplex Method** and its various iterations. The initial version, called the **Primal Simplex Method**, was introduced by George Dantzig in 1947. We will briefly introduce it in the next section by solving a simple production problem.



---

## 8.1 The Primal Simplex Method

Let's look at the table below, which contains the data for a production problem:

| | P1 | P2 | P3 | P4 | P5 | Cap |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Res1 | 1 | 2 | 1 | 3 | 0 | 24 |
| Res2 | 0 | 1 | 1 | 5 | 1 | 43 |
| Res3 | 1 | 0 | 0 | 2 | 2 | 18 |
| **Profit** | **19** | **23** | **15** | **42** | **33** | |

The data represents a scenario similar to the production problems mentioned previously (see Problem 9 from Chapter 5).

Imagine a small factory that can produce several products ($\text{P}1, \ldots, \text{P}5$). We use three **resources** for production. Each product column shows the number of units required from each resource to produce one unit of that specific product. For example, producing one unit of product $\text{P}4$ requires 3 units from $\text{Res}1$, 5 units from $\text{Res}2$, and 2 units from $\text{Res}3$. A resource could be raw material, labor, electricity, etc. We can produce as much as we want, provided production doesn't exceed the available **capacities** of the resources. For instance, if we produce 8 units of $\text{P}2$ and 1 unit of $\text{P}4$, the total consumption from the first resource will be $8 \cdot 2 + 1 \cdot 3 = 19$ units. The usage of the other resources is calculated the same way. We earn a certain **profit** from production, which is a linear combination of the production plan and the profit coefficient vector. If the production vector is $x(0, 8, 0, 1, 0)$ and we introduce the profit vector $c(19, 23, 15, 42, 33)$, the earned profit would be $c \cdot x = (19, 23, 15, 42, 33) \cdot (0, 8, 0, 1, 0) = 226$. Our goal is to find a production plan that satisfies all constraints and maximizes the earned profit.

If we denote the matrix of resource coefficients by $A$ and the capacity vector by $b$, our problem can be written in the general $\text{LP}$ format:

$$z = c \cdot x \to \max$$

$$\text{s.t. } Ax \le b, x \ge 0.$$

We will demonstrate how to solve this using the Primal Simplex Method. First, let's write out the model in detail:

$$\begin{array}{rcccccccc}
x_1 & +2x_2 & +x_3 & +3x_4 & & & & \le & 24 \\
& x_2 & +x_3 & +5x_4 & +x_5 & & & \le & 43 \\
x_1 & & & +2x_4 & +2x_5 & & & \le & 18 \\
19x_1 & +23x_2 & +15x_3 & +42x_4 & +33x_5 & = & z & \to & \max \\
& & x_i \ge 0, 1 \le i \le 5
\end{array}$$

Next, we convert the inequalities into equations by adding so-called **slack variables** ($s_i$) to the left-hand side:

$$\begin{array}{rccccccccc}
x_1 & +2x_2 & +x_3 & +3x_4 & & +s_1 & & & = & 24 \\
& x_2 & +x_3 & +5x_4 & +x_5 & & +s_2 & & = & 43 \\
x_1 & & & +2x_4 & +2x_5 & & & +s_3 & = & 18 \\
19x_1 & +23x_2 & +15x_3 & +42x_4 & +33x_5 & & & = & z & \to \max \\
& & x \ge 0, s \ge 0
\end{array}$$

In this model, writing $x \ge 0$ is shorthand for writing out all non-negativity constraints for the $x$ variables, and the same holds for the $s$ vector. Instead of the system of equations, we can use a compact form called the **simplex tableau**, shown below.

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $s_1$ | 24 | 1 | **2** | 1 | 3 | 0 | 1 | 0 | 0 |
| $s_2$ | 43 | 0 | 1 | 1 | 5 | 1 | 0 | 1 | 0 |
| $s_3$ | 18 | 1 | 0 | 0 | 2 | 2 | 0 | 0 | 1 |
| $z$ | 0 | -19 | -23 | -15 | -42 | -33 | 0 | 0 | 0 |

Note that there are several equivalent versions of the simplex tableau. Here, we place the **basis solution** on the left-hand side and the extra row for the **objective function** at the bottom. These specific choices are not fundamentally important.

Here, **B** stands for the **basis**, which is a maximal linearly independent set of vectors. Currently (initially), $B = \{s_1, s_2, s_3\}$, composed of the three unit vectors. The corresponding **basic feasible solution** is $x_B = (0, 0, 0, 0, 0, 24, 43, 18)$. This is a solution to the linear system; moreover, every variable is non-negative (meaning the solution is **feasible**), and any non-zero component in the vector corresponds to a basis vector.

The tableau contains all the data plus an extra row. How do we define the objective function's extra row? It simply contains the **negatives** of the coefficients from the $c$ vector.

The following theorem is crucial:

> **Theorem 1** Exactly one of the following options occurs:
>
> a) There is **no negative entry** in the last row. In this case, the corresponding basic feasible solution is **optimal**.
>
> b) There is a negative value in the last row such that there is **no positive value** in its column. In this case, there is **no optimal solution**, as the objective value is not bounded from above.
>
> c) Otherwise (there is a negative value in the last row, but for every such value, a positive value exists in its column), we can perform a **basis transformation** so that the corresponding objective value is not smaller.

Since this is only a brief overview of the simplex method, we won't prove the theorem; interested readers can find the proof in any of the suggested books. However, we will demonstrate the transformation process. Each transformation **exchanges one vector in the basis for another** not already present.

Let's assume we choose the column of $a_2$ (which has the most negative coefficient in the objective row, -23) for the vector that **enters the basis**. The vector that **leaves the basis** is determined by a rule called the **minimum ratio test**. We calculate the following minimum: $\min \{24/2, 43/1\}$. The numerator is taken from the current basic solution ($x_B$), and the denominator is taken from the same row but in the chosen entering column ($a_2$). We **cannot divide by zero** or a **negative value**.

The minimum is $24/2 = 12$, which means the vector in the row corresponding to 24 ($s_1$) must be chosen as the **leaving vector**. The value $\mathbf{2}$ is called the **pivot number**, which is bolded in the initial tableau.

How is the transformation performed?
* Divide the pivot row (the $s_1$ row) by the pivot value (2).
* Subtract $1/2$ times the pivot row from the second row ($s_2$).
* Subtract $0/2$ times the pivot row from the third row ($s_3$).
* **Add** $23/2$ times the pivot row to the objective row ($z$).

In the calculations above ($1/2$, $0/2$, and $23/2$), the numerator comes from the column of the pivot value, and the denominator is always the pivot value. The purpose of choosing these factors is to perform row operations that eliminate every element in the pivot column (reducing them to zero), except for the pivot element itself.

After the transformation, we get the following tableau:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_2$ | 12 | 1/2 | 1 | 1/2 | 3/2 | 0 | 1/2 | 0 | 0 |
| $s_2$ | 31 | -1/2 | 0 | 1/2 | 7/2 | 1 | -1/2 | 1 | 0 |
| $s_3$ | 18 | 1 | 0 | 0 | 2 | **2** | 0 | 0 | 1 |
| $z$ | 276 | -15/2 | 0 | -7/2 | -15/2 | -33 | 23/2 | 0 | 0 |

Now, let's choose the column of $a_5$ to enter the basis (as it has the most negative objective coefficient, $-33$). According to the minimum ratio test: $\min \{\text{N/A}, 31/1, 18/2\}$. Division by $0$ or a negative value (which occurs for $a_5$ in the $a_2$ row) is not allowed. The minimum is $18/2 = 9$. Thus, $s_3$ is the leaving vector.

After the transformation, we get:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_2$ | 12 | 1/2 | 1 | 1/2 | 3/2 | 0 | 1/2 | 0 | 0 |
| $s_2$ | 22 | -1 | 0 | 1/2 | 5/2 | 0 | -1/2 | 1 | -1/2 |
| $a_5$ | 9 | 1/2 | 0 | 0 | 1 | 1 | 0 | 0 | 1/2 |
| $z$ | 573 | 9 | 0 | **-7/2** | 51/2 | 0 | 23/2 | 0 | 33/2 |

Only one negative entry remains in the last row: the column of $a_3$ (with $-7/2$). We must choose this column to enter the basis. According to the minimum ratio test: $\min \{12/(1/2), 22/(1/2), \text{N/A}\}$. The minimum is $12/(1/2) = 24$. Thus, $a_2$ is the leaving vector.

As we've observed, the rule for the objective function change is:
* If we choose a column to enter the basis where the objective row value is **negative**, the **objective value increases**.
* If we choose a column where the objective row value is **positive**, the objective value will **decrease** (which we avoid since our goal is to maximize the objective).
* If we choose a column where the objective row value is **zero**, there will be **no change** in the objective value.

Note that this rule regarding the entering column and objective change is only true if the basic solution is **non-degenerate**. This means that if the current basis is $B(a_2, s_2, a_5)$, then all of $x_2, s_2, x_5$ are positive. If the value of the variable in the basic solution for the pivot row were zero, there would be no change in the basic solution column, and consequently, no change in the objective.

Let's see what happens after the final transformation:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_3$ | 24 | 1 | 2 | 1 | 3 | 0 | 1 | 0 | 0 |
| $s_2$ | 10 | -3/2 | -1 | 0 | 1 | 0 | -1 | 1 | -1/2 |
| $a_5$ | 9 | 1/2 | 0 | 0 | 1 | 1 | 0 | 0 | 1/2 |
| $z$ | **657** | 25/2 | 7 | 0 | 36 | 0 | 15 | 0 | 33/2 |

We can see there are no more negative entries in the last row, which means (according to Theorem 1) that the current solution is **optimal**. This optimal solution is $x_B = (0, 0, 24, 0, 9 \mid 0, 10, 0)$. The vertical line separates the first five variables (the original product variables) from the last three (the slack variables), as their meanings differ. The solution indicates that in the optimal plan (where profit is maximized while satisfying all constraints), we need to produce **24 units of the third product** and **9 units of the fifth product**. Furthermore, **10 units of the second resource remain unused**, while the full capacities of the other two resources are completely consumed.

We performed three transformations, but the final tableau could have been reached with only two (since only $a_3$ and $a_5$ needed to replace vectors in the original basis). It is not easy to know in advance which transformations will lead to the final state in the fewest steps. However, several tricks can help. For example (in a small problem like this), it might be beneficial to choose the leaving vector that results in the largest possible increase in the objective function.

Other issues can complicate the problem, such as the very rare occurrence of **"cycling,"** which involves returning to a previously visited basis after several transformations. In practice, this is rarely seen.

Another point is that in many cases, before solving a problem, we can perform some **pre-processing**. For example, identifying and deleting **redundant** constraints (meaning that removing the constraint doesn't change the optimal solution of the remaining system).

What happens if the factory introduces a new (sixth) product, where the data for its resource need is given by $a_6$? We can easily realize that there's no need to repeat the entire computation. We only compute the column for the new product. The transformed form of the $a_6$ vector can be written as $B^{-1}a_6$, where $B$ is the current basis and $B^{-1}$ is its inverse. We then insert this column vector into the tableau. If the coefficient of this new vector in the last row (calculated as $c_B B^{-1}a_6 - c_6$) is non-negative, it means producing this new product is **not advantageous**. If this value is negative, and it's the only negative value in the last row, we continue the transformations as before.

For example, suppose the column of the new product is $a_6 = (1, 2, 1)^T$, where the components represent the resource consumption from the three resources to produce one unit of this new product (say, product $\text{P}6$). Furthermore, let $c_6 = 35$, which is the profit gained from producing one unit.

Note that the current basis is:

$$B(a_3, s_2, a_5) = \begin{bmatrix} 1 & 0 & 0 \\ 1 & 1 & 1 \\ 0 & 0 & 2 \end{bmatrix} \quad \text{and} \quad B^{-1} = \begin{bmatrix} 1 & 0 & 0 \\ -1 & 1 & -1/2 \\ 0 & 0 & 1/2 \end{bmatrix}.$$

We can also find the inverse in the last three columns of the simplex tableau. Thus, $B^{-1}a_6 = (1, 1/2, 1/2)^T$, and $c_B B^{-1}a_6 - c_6 = (15, 0, 33) \cdot (1, 1/2, 1/2) - 35 = -7/2$. This negative value means producing the new product is **advantageous**, and the procedure will continue with the vector representing the new product entering the basis.

Finally, we mention an article that discusses various pivoting rules [34].

---

## 8.2 The Two-Phase (Primal) Simplex Method

In this section, we'll briefly introduce the **Two-Phase Method**. What we demonstrated earlier is actually the **second phase** of this method. Therefore, we need to show the **first phase**.



[Image of two-phase simplex method flowchart]


The goal of the first phase is to **find a basic feasible solution**. In the second phase, starting from this feasible solution, we proceed step-by-step to find an **optimal solution**. When is the first phase needed? It's required when we are **not able to start** with a suitable feasible solution immediately.

We will illustrate the first phase with an example. Let's assume our $\text{LP}$ is:

$$\begin{array}{rcccccccc}
x_1 & +2x_2 & +x_3 & +3x_4 & & & & \ge & 24 \\
& x_2 & +x_3 & +5x_4 & +x_5 & & & \le & 43 \\
x_1 & & & +2x_4 & +2x_5 & & & = & 18 \\
19x_1 & +23x_2 & +15x_3 & +42x_4 & +33x_5 & = & z & \to & \max \\
& & x_i \ge 0, 1 \le i \le 5
\end{array}$$

We've slightly modified our original example. This could be interpreted as needing to use **at least 24 units** of the first resource, being able to use **at most 43 units** of the second resource (as before), and needing to consume the **exact amount** of the third resource.

First, we convert the inequalities to equations:

$$\begin{array}{rccccccccc}
x_1 & +2x_2 & +x_3 & +3x_4 & & -s_1 & & & = & 24 \\
& x_2 & +x_3 & +5x_4 & +x_5 & & +s_2 & & = & 43 \\
x_1 & & & +2x_4 & +2x_5 & & & & = & 18 \\
19x_1 & +23x_2 & +15x_3 & +42x_4 & +33x_5 & & & & = & z \to \max \\
& & x \ge 0, s \ge 0
\end{array}$$

Now, we can see that we **do not have enough unit vectors** to serve as an initial basis. Note that $s_2$ is called a **slack variable** and $s_1$ is called a **surplus variable**. Let's create the missing unit vectors we need for a basis:

$$\begin{array}{rcccccccccc}
x_1 & +2x_2 & +x_3 & +3x_4 & & -s_1 & & +t_1 & & = & 24 \\
& x_2 & +x_3 & +5x_4 & +x_5 & & +s_2 & & & = & 43 \\
x_1 & & & +2x_4 & +2x_5 & & & & +t_2 & = & 18 \\
19x_1 & +23x_2 & +15x_3 & +42x_4 & +33x_5 & & & & & = & z \to \max \\
& & x \ge 0, s \ge 0, t \ge 0
\end{array}$$

We call $t_1$ and $t_2$ **artificial variables**; we use them, but we aren't "allowed" to use them in the final result. The original equation system has a feasible solution (where all equations are satisfied with the bounded $x$ and $s$ variables) if and only if we can **eliminate the artificial variables** from the system. So, our goal is to eliminate them, which is the task of the first phase. Our technique involves introducing an **artificial (or secondary) objective function** as $\hat{z} = -t_1 - t_2$. Instead of the original objective function $z$, we will **maximize $\hat{z}$** in the first phase (using the same maximization method shown earlier). If the maximum value of $\hat{z}$ is **zero**, it means we have successfully eliminated the artificial variables, and we can continue with the second phase, where we return to the original objective function $z$. Otherwise, if the maximum of $\hat{z}$ is **negative**, it means the original $\text{LP}$ cannot be solved without the artificial variables, i.e., it **does not have a feasible solution**.

---

## 8.3 The Dual Simplex Method

Alongside the Primal Simplex Method, the **Dual Simplex Method** is the other main version. We'll introduce it briefly. Consider the following $\text{LP}$:

$$\begin{array}{rccccccc}
x_1 & & +x_3 & & & \ge & 1 \\
2x_1 & +x_2 & +3x_3 & & & \ge & 3 \\
x_1 & +2x_2 & & & & \ge & 5 \\
4x_1 & +2x_2 & +x_3 & & & \ge & 7 \\
10x_1 & +12x_2 & +15x_3 & = & z & \to & \min \\
& & x \ge 0
\end{array}$$

After multiplying all inequalities and the objective function by $-1$ and adding slack variables ($s_i$), we get the following system:

$$\begin{array}{rccccccc}
-x_1 & & -x_3 & +s_1 & & & & = & -1 \\
-2x_1 & -x_2 & -3x_3 & & +s_2 & & & = & -3 \\
-x_1 & -2x_2 & & & & +s_3 & & = & -5 \\
-4x_1 & -2x_2 & -x_3 & & & & +s_4 & = & -7 \\
-10x_1 & -12x_2 & -15x_3 & & & & & = & -z \to \max \\
& & x \ge 0
\end{array}$$

Here is the first simplex tableau:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $s_1$ | -1 | **-1** | 0 | -1 | 1 | 0 | 0 | 0 |
| $s_2$ | -3 | -2 | -1 | -3 | 0 | 1 | 0 | 0 |
| $s_3$ | -5 | -1 | -2 | 0 | 0 | 0 | 1 | 0 |
| $s_4$ | -7 | -4 | -2 | -1 | 0 | 0 | 0 | 1 |
| $-z$ | 0 | 10 | 12 | 15 | 0 | 0 | 0 | 0 |

Right away, you'll notice that this simplex tableau is different from the previous form. There are **only non-negative values** in the last row. We call this property **dual-feasibility**. However, the basic solution is **not primal-feasible**; there are negative values in the $x_B$ column. In fact, all values are negative or zero, as the basic solution is $x_B = (0, 0, 0, -1, -3, -5, -7)$. If, after several transformations, we can reach a tableau that is **both dual and primal feasible**, it means we have found the optimal tableau. Note that in the Primal Simplex Method (Phase 2), we move through primal feasible solutions, while in the Dual Simplex Method, we move through dual feasible solutions.

Here is the rule for the transformation:
* First, choose a row where the coordinate of the basic solution is **negative** (this basis vector will **leave the basis**).
* From this row, we must choose a **negative pivot value**.
* Then, apply an appropriate version of the minimum ratio test to choose the **entering column**.

Let's suppose $s_1$ is the leaving vector. We choose the pivot value from the first row. We can choose the entering column from $a_1$, $a_2$, and $a_3$ as all other vectors are in the basis. The appropriate values in this row and these columns are $-1$, $0$, and $-1$. As we said, we must choose a negative value, so we cannot choose the zero. Regarding the other two values, we perform the calculation: $\min \{10/|-1|, 15/|-1|\}$. Here, the numerators come from the objective row, and the denominators are the **negatives** of the two previously listed values (i.e., $|-1|$ and $|-1|$). Since $10/1$ is smaller, the value $\mathbf{-1}$ in the $a_1$ column is chosen as the pivot value (bolded in the tableau).

After the transformation (where the rule is the same as for the primal simplex method), we get the following tableau:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_1$ | 1 | 1 | 0 | 1 | -1 | 0 | 0 | 0 |
| $s_2$ | -1 | 0 | **-1** | -1 | -2 | 1 | 0 | 0 |
| $s_3$ | -4 | 0 | -2 | 1 | -1 | 0 | 1 | 0 |
| $s_4$ | -3 | 0 | -2 | 3 | -4 | 0 | 0 | 1 |
| $-z$ | -10 | 0 | 12 | 5 | 10 | 0 | 0 | 0 |

Now, let's choose $s_3$ as the leaving vector (since $-4$ is the most negative basic solution value). There are only two negative values in its row that can be considered as the pivot value: $-2$ (in $a_2$) and $-1$ (in $s_1$). The calculation is: $\min \{12/|-2|, 10/|-1|\}$. Since the former fraction ($12/2 = 6$) is smaller, $\mathbf{-2}$ is chosen as the pivot value.

After the transformation, the next tableau is:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_1$ | 1 | 1 | 0 | 1 | -1 | 0 | 0 | 0 |
| $s_2$ | 1 | 0 | 0 | -3/2 | -3/2 | 1 | -1/2 | 0 |
| $a_2$ | 2 | 0 | 1 | -1/2 | 1/2 | 0 | -1/2 | 0 |
| $s_4$ | 1 | 0 | 0 | 2 | -3 | 0 | -1 | 1 |
| $-z$ | -34 | 0 | 0 | 11 | 4 | 0 | 6 | 0 |

Since we obtained a tableau with a solution that is **both primal and dual feasible**, this is an optimal solution. Here, $x_B = (1, 2, 0 \mid 0, 1, 0, 1)$, and the optimal value of the objective function is $z = 34$.

---

## 8.4 The Gomory Cut

The **Gomory cut** is a key technique for finding **integer solutions** for an $\text{LP}$. If we require that the variables of an $\text{LP}$ must be integer numbers, the model is called an **Integer Linear Program ($\text{ILP}$)**. In many cases, some variables are required to be integers, while others can be real values; this is called a **Mixed-Integer Linear Program ($\text{MILP}$)**.

Solving an integer (or mixed-integer) program is usually much more difficult than a standard LP. There are several tools to handle the integrality of variables; we will show only one such commonly used method. We will demonstrate the method using an example. The example comes from a book by András Prékopa, as mentioned in Tamás Szántai's manuscript [35], page 28 (in Hungarian), and also shown in Mihály Hujter's short (Hungarian) draft [36]. Note that we perform the calculations in a slightly different manner to maintain uniformity with our presentation of the Primal and Dual Simplex tableaux.



Let's consider the following $\text{ILP}$:

$$\begin{array}{rccccccc}
2x_1 & +x_2 & & & & \ge & 1 \\
2x_1 & +5x_2 & & & & \ge & 4 \\
-x_1 & +x_2 & & & & \ge & 0 \\
-x_1 & -x_2 & & & & \ge & -5 \\
-x_1 & -2x_2 & & & & \ge & -4 \\
5x_1 & +4x_2 & = & z & \to & \min \\
& & x \ge 0, x_1, x_2 \text{ are integers}
\end{array}$$

Let's transform the inequalities to the "$\le$" type, then convert them to equations by introducing slack variables. We also transform the objective to the "$\max$" form. We get the following:

$$\begin{array}{rccccccc}
-2x_1 & -x_2 & +s_1 & & & & & = & -1 \\
-2x_1 & -5x_2 & & +s_2 & & & & = & -4 \\
x_1 & -x_2 & & & +s_3 & & & = & 0 \\
x_1 & +x_2 & & & & +s_4 & & = & 5 \\
x_1 & +2x_2 & & & & & +s_5 & = & 4 \\
-5x_1 & -4x_2 & & & & & & = & -z \to \max \\
& & x \ge 0
\end{array}$$

Now, let's create the usual simplex tableau:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** | **$s_5$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $s_1$ | -1 | **-2** | -1 | 1 | 0 | 0 | 0 | 0 |
| $s_2$ | -4 | -2 | -5 | 0 | 1 | 0 | 0 | 0 |
| $s_3$ | 0 | 1 | -1 | 0 | 0 | 1 | 0 | 0 |
| $s_4$ | 5 | 1 | 1 | 0 | 0 | 0 | 1 | 0 |
| $s_5$ | 4 | 1 | 2 | 0 | 0 | 0 | 0 | 1 |
| $-z$ | 0 | 5 | 4 | 0 | 0 | 0 | 0 | 0 |

The tableau is **dual-feasible** but **primal-infeasible**. Let's perform basis transformations using the **Dual Simplex Method** to reach the optimal solution. In fact, two steps will be enough. First, $s_1$ leaves the basis and $a_1$ enters (according to the minimum ratio test), then $s_2$ leaves the basis and $a_2$ enters. The resulting tableau is as follows:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** | **$s_5$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_1$ | 1/8 | 1 | 0 | -5/8 | 1/8 | 0 | 0 | 0 |
| $a_2$ | 3/4 | 0 | 1 | 1/4 | -1/4 | 0 | 0 | 0 |
| $s_3$ | 5/8 | 0 | 0 | 7/8 | -3/8 | 1 | 0 | 0 |
| $s_4$ | 33/8 | 0 | 0 | 3/8 | 1/8 | 0 | 1 | 0 |
| $s_5$ | 19/8 | 0 | 0 | 1/8 | 3/8 | 0 | 0 | 1 |
| $-z$ | -29/8 | 0 | 0 | 17/8 | 3/8 | 0 | 0 | 0 |

This tableau is optimal. The optimal (fractional) solution is $x_B = (1/8, 3/4 \mid 0, 0, 5/8, 33/8, 19/8)$. This is the optimal solution of the **relaxed model**, where $x \ge 0$ is required, but the integrality of the variables is not. The optimum value of the relaxed problem is $z = 29/8$.

At this point, we will perform the famous **Gomory Cut**!

We pick a fractional variable, e.g., $x_1 = 1/8$. Let's also consider the row of this variable in the tableau, where the data means:

$$1/8 = x_1 - 5/8s_1 + 1/8s_2.$$

We **round up** all coefficients in this equation. The rounding-up values (for $1/8, 1, -5/8, \text{ and } 1/8$) are $7/8, 0, 5/8, \text{ and } 7/8$, respectively. Using these values (and omitting the zero), we create the next (new) constraint:

$$7/8 \le 5/8s_1 + 7/8s_2.$$

We can see that this condition **does not hold**, since $s_1 = s_2 = 0$ in the current optimal (fractional) basic solution. This means that by adding this constraint to the previously used constraints, the current basic solution becomes **infeasible**. Let's multiply the new constraint by $-1$ and introduce a new slack variable, $s_6$. We get:

$$-5/8s_1 - 7/8s_2 + s_6 = -7/8.$$

We add this new equation to the system and write it as a new line in the simplex tableau:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** | **$s_5$** | **$s_6$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_1$ | 1/8 | 1 | 0 | -5/8 | 1/8 | 0 | 0 | 0 | 0 |
| $a_2$ | 3/4 | 0 | 1 | 1/4 | -1/4 | 0 | 0 | 0 | 0 |
| $s_3$ | 5/8 | 0 | 0 | 7/8 | -3/8 | 1 | 0 | 0 | 0 |
| $s_4$ | 33/8 | 0 | 0 | 3/8 | 1/8 | 0 | 1 | 0 | 0 |
| $s_5$ | 19/8 | 0 | 0 | 1/8 | 3/8 | 0 | 0 | 1 | 0 |
| $s_6$ | -7/8 | 0 | 0 | -5/8 | **-7/8** | 0 | 0 | 0 | 1 |
| $-z$ | -29/8 | 0 | 0 | 17/8 | 3/8 | 0 | 0 | 0 | 0 |

The tableau is still dual-feasible but not primal-feasible. We choose the row of $s_6$ for the leaving vector. According to the minimum ratio test, the pivot value is **$-7/8$** (in $s_2$'s column) since $3/|-7/8| = 3/(7/8) = 24/7 \approx 3.43$, which is smaller than $17/|-5/8| = 17/(5/8) = 136/5 = 27.2$.

After the transformation, the next tableau is as follows:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$s_1$** | **$s_2$** | **$s_3$** | **$s_4$** | **$s_5$** | **$s_6$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_1$ | 0 | 1 | 0 | -5/7 | 0 | 0 | 0 | 0 | 1/7 |
| $a_2$ | 1 | 0 | 1 | 3/7 | 0 | 0 | 0 | 0 | -2/7 |
| $s_3$ | 1 | 0 | 0 | 8/7 | 0 | 1 | 0 | 0 | -3/7 |
| $s_4$ | 4 | 0 | 0 | 2/7 | 0 | 0 | 1 | 0 | 1/7 |
| $s_5$ | 2 | 0 | 0 | -1/7 | 0 | 0 | 0 | 1 | 3/7 |
| $s_2$ | 1 | 0 | 0 | 5/7 | 1 | 0 | 0 | 0 | -8/7 |
| $-z$ | -4 | 0 | 0 | 13/7 | 0 | 0 | 0 | 0 | 3/7 |

We obtained an optimal tableau again (primal and dual feasible, so it's optimal). Here, the optimal solution is $x_B = (0, 1 \mid 0, 1, 1, 4, 2)$. Since $x_1 = 0$ and $x_2 = 1$ are integer values, this means we have found the optimal solution of the $\text{ILP}$ as well.

---
----

# Chapter 9: Summary

We have explored the capabilities of the **GNU MathProg modeling language** through various examples. This included solving linear equation systems, the production and diet problems (along with their common extensions), the transportation problem, various general cost functions, and integer programming techniques applied to common optimization problems.

**Mathematical programming** generally offers a simple, practical solution for the types of problems it is designed to handle. While **$\text{MILP}$** models cover a much wider range of scenarios than their purely **$\text{LP}$** counterparts, both problem classes are useful in their own right.

Gaining expertise in GNU MathProg provides us with a **unique tool** for solving complex optimization problems. Although the solution speed might not be the absolute fastest for every specific problem, the **ease of implementation**, **maintenance**, and **adaptability to changes** in the problem definition make this methodology highly valuable for both industrial and scientific applications.

Typically, you develop a single **model file** to handle all instances of a problem, while the specific data for each instance is stored in separate **data files**. The **glpsol** solver can parse the language and solve the model in a single run, and it can also generate user-defined output.

We also provided insight into how $\text{LP}$ models are solved using the **Simplex Method** and introduced one technique for integer programming: the **Gomory cut**. These serve only as an introduction to how $\text{LP}/\text{MILP}$ solver software operates in the background. While we can often treat solvers as **black boxes**, having a basic understanding of them is useful for developing and improving mathematical programming models, as well as interpreting their results.

Note that there are many approaches beyond the primary workflow demonstrated in this tutorial. Here are a few concluding points:

* The GNU MathProg language and a parser/solver like glpsol can be used alone to develop and solve models, but the GLPK software kit offers **other features**, most notably a **callable library**. Accessing linear programming tools directly from a programming language is often better in the long run than relying on standalone GNU MathProg model files. For instance, you cannot "change" the value of a parameter within GNU MathProg logic, which limits your ability to process input data dynamically.
* We only briefly touched on the different **configurations** of the glpsol solver in this tutorial. Applying the appropriate **heuristics** or **alternative solution methods** can significantly speed up the search.
* While the glpsol solver is an easy-to-use tool, it is likely **not the fastest** $\text{LP}/\text{MILP}$ solver available. Other free solvers, such as **$\text{CBC}$** [7] or **$\text{lpsolve}$** [8], may be superior if performance is a concern. **Commercial $\text{MILP}$ solvers** can be significantly faster. You can still use these alternative solvers with GNU MathProg models because glpsol supports exporting models into well-known formats.
* GNU MathProg is **not the only language** for linear programming. There are dozens of other languages, each supporting its own class of models, input/output formats, and solvers.
* **$\text{LP}$ and $\text{MILP}$ are not the only mathematical programming problem classes** with general-purpose solvers. If you need specific **nonlinear objectives and constraints** to model a situation, you might try developing a **Nonlinear or Mixed-Integer Nonlinear Programming ($\text{NLP}$ or $\text{MINLP}$)** model in an appropriate environment. Just remember that more general tools can be much more costly in terms of running time.
* Mathematical programming is a powerful tool, but some problems have **much more effective algorithmic solutions**. Sometimes, writing a specific algorithm yields better results, though it often requires more coding effort.
* Throughout this tutorial, we solved models **in their entirety** to get a final answer. Generally, however, mathematical programming tools can be used as **part of a larger algorithmic framework**. For example, a large problem can be **decomposed** into several different models that are solved separately or sequentially. Alternatively, an $\text{LP}/\text{MILP}$ model can serve as a **relaxation** for a more complex optimization problem, providing a **bound** for its objective function.

We hope you find this tutorial helpful and motivating as you tackle real-life optimization problems in the future.