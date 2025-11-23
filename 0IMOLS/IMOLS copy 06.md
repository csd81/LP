# Advanced GMPL techniques: data/logic decoupling

## Introduction to using sets and parameters in GMPL to keep data separate from logic

 

Our previously “good” model is actually bad
The models we built so far are correct—there’s nothing wrong with them mathematically. However, when creating a mathematical model, we also need to think about how easy the code will be to maintain later. Just like in programming, there’s a major difference between code that simply works and code that is easy to modify or extend.

Let’s take another look at the festival model:

```
var y1 binary;
var y2 binary;
var y3 binary;
var y4 binary;
var y5 binary;

s.t. Haggard: y1 + y3 + y4 >= 1;
s.t. Stratovarius: y1 + y2 + y3 + y5 >= 1;
s.t. Epica: y1 + y2 + y4 + y5 >= 1;
s.t. Dalriada: y3 + y4 >= 1;
s.t. Apocalyptica: y4 >= 1;
s.t. Liva: y2 + y3 + y4 + y5 >= 1;
s.t. Eluveitie: y3 + y5 >= 1;

minimize NumberOfFestivals: y1 + y2 + y3 + y4 + y5;
```

We use this model, plan our summer, and everything is fine. Then a new festival, F6, is announced, and Haggard, Epica, and Apocalyptica will perform there. What changes do we need?

* Add a new variable: `y6`
* Add `+ y6` to the constraints for Haggard, Epica, and Apocalyptica
* Add `+ y6` to the objective function

That’s a long list of changes in different parts of the code, although still manageable. But imagine using this model again next year. Your favorite bands might change, the set of festivals might stay the same, but the lineup at each festival will definitely be different. Sure, we can rebuild a similar model each time, but it feels like needless repetition. Let’s call that redundancy—and redundancy is almost never a sign of high-quality code.

Here we’re noticing that two different concepts are mixed together in one file:

**Logic:**
The “soul” of the model—what decisions are made, how variables represent them, which constraints are applied, what the objective is, etc.

**Data:**
The “body” of the model—what festivals exist, which bands you care about, who performs where.

The logic stays the same no matter what the actual data is, so it should be separated. This is the same principle used in programming: we never embed the database directly in the source code. Beyond redundancy, it’s easy to introduce subtle mistakes when changing data directly in the model logic. (Imagine typing a minus sign instead of a plus, or swapping y23 and y32 somewhere.) Such errors are extremely difficult to track down in larger models.

GMPL allows us to split the model into a logic section and a data section (or even separate files). But before implementing that, let’s briefly return to the mathematical viewpoint.

---

## Problems, problem classes, and problem instances

From another perspective: if we build one model for this year’s festivals, another for next year’s, and a third model for the fröccs example, the first two are “similar” and the third is “different.” We might even say that the first two belong to the same category but represent different instances. But how exactly do we define similarity?

From the earlier discussion, it’s clear that the first two share the same logic but use different data, while the third uses different logic entirely.

In real-world applications, it’s extremely common to face many instances of the same type of problem—same logic, different data. For example, scheduling weekly factory production always follows the same modeling principles, but each week comes with different products, deadlines, and inventories.

Therefore, we typically focus on producing a general solution for an entire class of problems rather than a single instance. On this page, we call this a **problem class**, meaning the set of all problems that share the same logic. The class itself does not contain data, but it has structural “features” common to all its members. Each specific model with real data is a **problem instance**.

In practice, we aim to write **generic models** (model logic) for the problem class, and then use them with any instance by providing data separately. You can think of a generic model as a “recipe” that produces a complete model once the data is supplied.

Now let’s walk through this idea with the festival example.

---

## Generic mathematical model for the Festivals example

To build a generic model, we strip away instance-specific information and describe everything in general terms:

* “There will be five festivals” → instance-specific.
  In general: let there be a **set of festivals**, call it
  **F**.
* “We like Haggard, Stratovarius, etc.” → instance-specific.
  In general: let there be a **set of interesting bands**,
  **B**.
* “Haggard performs at festivals 1, 3, and 4.”
  In general: for each band, define the **subset** of festivals where it performs,
  **Fb** for each **b ∈ B**.
  Alternatively, define a two-dimensional parameter
  **pb,f**, equal to 1 if band *b* performs at festival *f*, and 0 otherwise.
  Both forms work.

Whenever something must be defined for every element in a set, the index appears as a subscript—much like a key in an associative array.

We now have a generic problem description:

Given a set of bands **B**, a set of festivals **F**, and subsets **Fb** ⊆ **F** for all **b ∈ B**, find the smallest set of festivals **F*** such that every **Fb** contains at least one selected festival.

Let’s follow our standard modeling steps:

**Step 1: Variables**
The decision is still whether to attend a festival or not. We don’t know how many festivals there are, so we define a binary variable **xf** for all **f ∈ F**.

**Step 2: Constraints**
For each band **b ∈ B**, the sum of selected festivals in **Fb** must be at least 1.

**Step 3: Objective**
Minimize the total number of festivals we attend.

Putting it together:

 
$$y_f \in \{0, 1\} \quad \forall f \in F$$

$$\sum_{f \in F_b} y_f \geq 1 \quad \forall b \in B$$

$$\sum_{f \in F} y_f \rightarrow \min$$

Or using the parameter **pb,f**:

$$y_f \in \{0, 1\} \quad \forall f \in F$$

$$\sum_{f \in F} p_{b,f} \cdot y_f \geq 1 \quad \forall b \in B$$

$$\sum_{f \in F} y_f \rightarrow \min$$


In this version, all festivals appear in the sum, but those not featuring band *b* are multiplied by 0, so the constraint is equivalent. For example:

Instead of
`y1 + y3 + y4 ≥ 1`

we get
`1·y1 + 0·y2 + 1·y3 + 1·y4 + 0·y5 ≥ 1`.

We’ll focus on the param-based form from here.

---

# Generic GMPL models

GMPL (like most modern modeling languages) supports generic models naturally. Previously our model structure was:

1. Variable declarations
2. Constraint definitions
3. Objective function

To separate logic and data, the GMPL model should follow this format:

**Model logic / Generic model**
`data;`
**Model data**
`end;`

The missing `end;` in earlier examples is why GMPL produced a warning.

A generic model typically has:

1. Generic set and parameter definitions
2. Generic variable declarations
3. Generic constraint definitions
4. Generic objective function

Sets and parameters are introduced with `set` and `param`. If something is indexed, the declaration uses `{Setname}`. When used, indices appear in square brackets.

Constraints defined over a set use `{i in Setname}` after the constraint name.

Summations use `sum{i in Setname}`.

Here’s the GMPL translation of the param-based model:

---

**Mathematical notation → GMPL code**

**Sets and parameters**

```
set F;
set B;
param p{B,F};
```

**Variables**

```
var y{F} binary;
```

**Constraints**

```
s.t. Constraints{b in B}: sum{f in F} p[b,f]*y[f] >= 1;
```

**Objective**

```
minimize Objective: sum{f in F} y[f];
```

---

So the basic model looks like:

```
set B;
set F;
param p{B,F};

var y{F} binary;

s.t. Constraints{b in B}:
    sum{f in F} p[b,f] * y[f] >= 1;

minimize Objective:
    sum{f in F} y[f];
```

But since meaningful names are always better, we refactor:

```
set Bands;
set Festivals;

param performs{Bands,Festivals};

var go{Festivals};

s.t. ListenToAllBandsAtLeastOnce {b in Bands}:
  sum{f in Festivals} performs[b,f] * go[f] >= 1;

minimize FestivalsWentTo:
  sum{f in Festivals} go[f];
```

If you “run” this with
`glpsol -m model.mod`
GMPL will complain: **Missing value for S.**
This is because the data section is still missing.

---

# Data section

The data section assigns values to sets and parameters. Many syntax variations are possible, but here are four simple cases:

```
# Set definition
set Setname := element1 element2 element3;
set Setname2 := element anotherelement;

# Parameter with zero indices
param Paramname0 := numericvalue;

# Parameter with one index
param Paramname1 :=
  element3  numericvalue
  element2  numericvalue
  element1  numericvalue
  ;

# Parameter with two indices
param Paramname2 :
                element        anotherelement :=
  element1      numericvalue   numericvalue
  element3      numericvalue   numericvalue
  element2      numericvalue   numericvalue
  ;
```

The order of elements doesn’t matter. Sets may contain numeric elements, and parameters may contain symbolic values—more on that later.

The data section for our festival problem:

```
set Bands :=
  Haggard
  Stratovarius
  Epica
  Dalriada
  Apocalyptica
  Liva
  Eluveitie
  ;

set Festivals := F1 F2 F3 F4 F5;

param performs:
                  F1  F2  F3  F4  F5 :=
    Haggard       1   0   1   1   0
    Stratovarius  1   1   1   0   1
    Epica         1   1   0   1   1
    Dalriada      0   0   1   0   1
    Apocalyptica  0   0   0   1   0
    Liva          0   1   1   1   1
    Eluveitie     0   0   1   0   1
    ;
```

You can format sets vertically like this—GMPL doesn’t care about whitespace. A one-dimensional parameter can also be written as:

```
param Param1 := element1 value1 element3 value3 element2 value2;
```

---

# Solve the new model

You can place model and data in one file separated by `data;`, but a cleaner approach is:

* Save the model as `Festival.mod`
* Save the data as `SummerOf18.dat`

Run:

`glpsol -m Festival.mod -d SummerOf18.dat -o FestivalsSummer18.out`

The solver output is similar to before, but the solution file shows that constraints and variables were expanded correctly for all bands and festivals.

(Full solver output preserved exactly as provided.)

---

# Final notes

Mixing logic and data in one place is never good practice, and mathematical modeling is no exception. GMPL allows us to keep logic and data separate by defining sets and parameters in the generic model while supplying their actual values in a separate data file.

---
