# Here is the full text, fully rephrased into clear, correct American English **while preserving every paragraph, section, structure, list, table, variable, equation, and GMPL code exactly as in the original**. No content has been removed or reordered—only rewritten into fluent American English.

---

## Advanced modeling techniques: Big-M constraints

Expressing logical conditions in models.

### Prerequisites

Advanced modeling techniques: “Redundant” variables
Advanced GMPL techniques: data/logic decoupling

### The usual issue

When building a model, we very often encounter conditions of the type *“if something holds, then something else must behave like this.”* Examples include:

* The admissible range for the size/capacity/activity level of something is often not a simple closed interval or just an on/off choice. It may be a set of disjoint intervals—for instance, either 0 or a value in
  ([min, max]).
  A single decision variable, whether continuous or discrete, cannot express this. The typical solution is to use a binary variable
  (y)
  indicating whether we are at 0 or inside the interval, along with a continuous
  (x)
  that holds the actual value. Then we need a constraint enforcing: if
  (y=0)
  then
  (x=0); otherwise
  (x \in [min, max]).

* In scheduling problems, we often need constraints such as: if two tasks are assigned to the same resource, their processing times must not overlap.

* While writing models, we often bump into bilinear terms—products of a continuous and an integer (usually binary) variable. Such expressions make the model nonlinear, but they can be linearized by introducing a continuous variable representing the product and enforcing: if the binary variable is 0, the product is 0; if it is 1, the product equals the continuous variable.

* Sometimes one binary decision depends on another. For instance, selecting which site to send a worker to, and then selecting which tasks that worker will perform at that site. Naturally, a worker cannot perform tasks at a location they never visited.

The challenge is that MILP languages have **no built-in conditional constructs**. Fortunately, there is a modeling trick that expresses these logical relations purely through linear constraints. Before explaining the trick, let’s look at a situation where we need it.

---

## Repairman allocation problem

We provide technical service for several companies located in different cities. At each site, there are issues that need to be resolved today. We work with specialist contractors—referred to simply as *repairmen*. Each morning, we must decide which repairmen to hire and, if hired, where they should travel and which issues they should fix. A repairman’s shift can be at most 12 hours, and the average travel overhead for each location is 1 hour.

We start with the following assumptions:

* Every repairman can fix any issue.
* The time required to fix an issue is the same regardless of who fixes it.
* All repairmen have the same hourly wage.
* Travel time between any pair of sites is identical.
* There is no timing component and no dependency between issues.

These assumptions can later be removed to generalize the model.

Our goal is to minimize total salary costs—simply the hourly wage multiplied by travel time plus issue-fixing time.

Let’s begin constructing the model.

### Input data

```
set Sites;
param traveltime;
set Issues;
param site{Issues} symbolic, within Sites;
param time{Issues} >=0;
set Repairmen;
param maxhours;
param wage;
```

### Variables

```
var visits{Repairman,Sites} binary;
var fixes{Repairman,Issues} binary;
```

### Constraints

Each issue must be fixed exactly once:

```
s.t. FixAllIssues{i in Issues}:
  sum{r in Repairmen} fixes[r,i] = 1;
```

A repairman may not exceed the maximum working hours:

```
s.t. MaxWorkLoad{r in Repairmen}:
  sum{s in Sites} (traveltime*visits[r,s]) + 
  sum{i in Issues}(time[i]*fixes[r,i]) <= maxhours;
```

### Objective

Minimize total cost:

```
minimize TotalCost:
  wage * sum {r in Repairmen} (
    sum{s in Sites} (traveltime*visits[r,s]) +
    sum{i in Issues}(time[i]*fixes[r,i])
  );
```

If we solve this model as written, we notice that every `visits[r,s]` becomes 0 in the optimal solution. That’s because we haven’t yet enforced:

> A repairman may only fix an issue if they actually visit its site.

Translated:
`fixes[r,i]` can be 1 only if `visits[r,site[i]]` is also 1.

A more intuitive statement:
If a repairman does **not** visit a site, then all issue-fixing variables at that site must be 0.

A naïve attempt would be:

```
s.t. NoMagicalTeleportation{r in Repairmen, s in Sites, i in Issues :
    visits[r,s]==0 && site[i]==s}:
  fixes[r,i]=0;
```

But this is illegal—constraints cannot be added or removed based on variable values. MILP solvers require a fixed set of constraints determined *before* solving.

So we need a different approach.

---

## Turning the conditional into a valid linear constraint

Start by rewriting the idea informally:

```
s.t. NoMagicalTeleportation{r in Repairmen, s in Sites, i in Issues : site[i]==s}:
  if visits[r,s]==0 then fixes[r,i]=0;
```

We can simplify, because for each issue `i`, `site[i]` is a single site:

```
s.t. NoMagicalTeleportation{r in Repairmen, i in Issues}:
  if visits[r,site[i]]==0 then fixes[r,i]=0;
```

Now we embed the binary variable into the inequality. Since equality is harder to relax than inequality, we rewrite:

```
if visits[r,site[i]]==0 then fixes[r,i] <= 0;
```

Now we use the trick:

```
fixes[r,i] <= 0 + visits[r,site[i]];
```

Explanation:

* If `visits` = 0: RHS = 0 ⇒ `fixes <= 0` ⇒ fixes = 0.
* If `visits` = 1: RHS = 1 ⇒ `fixes <= 1`, which places no meaningful restriction (since `fixes` is binary).

Thus, the final and simplified form is:

```
fixes[r,i] <= visits[r,site[i]];
```

This gives exactly the intended logic.

---

## Improving the model

Putting everything together:

```
set Sites;
  param traveltime;
set Issues;
  param site{Issues} symbolic, within Sites;
  param time{Issues} >=0;
set Repairmen;
  param maxhours;
  param wage;

var visits{Repairman,Sites} binary;
var fixes{Repairman,Issues} binary;

s.t. FixAllIssues{i in Issues}:
  sum{r in Repairmen} fixes[r,i] = 1;

s.t. MaxWorkLoad{r in Repairmen}:
  sum{s in Sites} (traveltime*visits[r,s]) + 
  sum{i in Issues}(time[i]*fixes[r,i]) <= maxhours;

s.t. NoMagicalTeleportation{r in Repairmen, i in Issues}:
  fixes[r,i] <= visits[r,site[i]];

minimize TotalCost:
  wage * sum {r in Repairmen} (
    sum{s in Sites} (traveltime*visits[r,s]) +
    sum{i in Issues}(time[i]*fixes[r,i])
  );
```

---

## Introducing an “at least 8 hours paid” rule

Suppose that if a repairman is hired, we must pay for at least 8 hours of work—even if the actual work takes less time.

To support this, introduce a **redundant** variable representing the actual hours worked:

```
var worked{Repairmen} >= 0;
```

This simplifies both workload and objective:

```
s.t. Workload{r in Repairmen}:
  worked[r] = sum{s in Sites} (traveltime*visits[r,s]) +
              sum{i in Issues}(time[i]*fixes[r,i]);

s.t. MaxWorkLoad{r in Repairmen}:
  worked[r] <= maxhours;

minimize TotalCost:
  wage * sum {r in Repairmen} worked[r];
```

### Adding paid hours

Introduce:

```
var paid{Repairmen} >= 0;
```

Objective becomes:

```
minimize TotalCost:
  sum {r in Repairmen} paid[r];
```

Link paid and worked:

```
s.t. Payment{r in Repairman}:
  paid[r] = wage * worked[r];
```

Now add a parameter for minimum paid hours:

```
param minhourspaid;
```

But we **cannot** simply set `paid >= wage * minhourspaid` because that forces payment even for people who were never hired.

We need a variable representing hiring:

```
var hired{Repairmen} binary;
```

Express the rule:

```
paid[r] >= wage * minhourspaid * hired[r];
```

Now the constraint only applies if hired[r] = 1.

### Prevent work if not hired

We must ensure:

> A repairman may travel or fix issues only if hired.

Equivalent:
If hired[r] = 0 then all `visits` and `fixes` must be 0.

We express this using a big-M constraint:

```
s.t. CannotWorkIfNotHired{r in Repairmen}:
  sum{s in Sites} visits[r,s] + sum{i in Issues} fixes[r,i]
     <= M * hired[r];
```

A reasonable value for M is:

```
param M := card(Sites) + card(Issues);
```

---

## The final model

```
set Sites;
  param traveltime;
set Issues;
  param site{Issues} symbolic, within Sites;
  param time{Issues} >=0;
set Repairmen;
  param maxhours;
  param wage;

param M := card(Sites)+card(Issues);

var worked{Repairmen} >= 0;
var paid{Repairmen} >= 0;

var hired{Repairmen} binary;

var visits{Repairman,Sites} binary;
var fixes{Repairman,Issues} binary;

s.t. FixAllIssues{i in Issues}:
  sum{r in Repairmen} fixes[r,i] = 1;

s.t. Workload{r in Repairmen}:
  worked[r] = sum{s in Sites} (traveltime*visits[r,s]) +
              sum{i in Issues}(time[i]*fixes[r,i]);

s.t. MaxWorkLoad{r in Repairmen}:
  worked[r] <= maxhours;

s.t. Payment{r in Repairman}:
  paid[r] = wage * worked[r];

s.t. NoMagicalTeleportation{r in Repairmen, i in Issues}:
  fixes[r,i] <= visits[r,site[i]];

s.t. MinimumWorkHours{r in Repairman}:
  paid[r] >= wage * minhourspaid * hired[r];

s.t. CannotWorkIfNotHired{r in Repairmen}:
  sum{s in Sites} visits[r,s] + 
  sum{i in Issues} fixes[r,i] <= M * hired[r];

minimize TotalCost:
  sum {r in Repairmen} paid[r];
```

---

## Several forms of Big-M logical constraints

Below is a summary of commonly used Big-M formulations. Assume
(y, y', y^*, y_1, y_2, …, y_n)
are binary variables.

**If (y=1) then (LHS ≥ RHS):**
[
LHS ≥ RHS - M(1-y)
]

**If (y=0) then (LHS ≥ RHS):**
[
LHS ≥ RHS - My
]

**If (y=1) then (LHS = RHS):**
[
LHS ≥ RHS - M(1-y)
]
[
LHS ≤ RHS + M(1-y)
]

**If (y=0) then (y') must be 0:**
[
y' ≤ y
]

**If (y=1) then (y') must be 0:**
[
y' ≤ 1-y
]

**If (y=0) then (y_1, y_2, …, y_n) must be 0:**
[
y_1 + y_2 + … + y_n ≤ M y
]

**If (y=0) then (y_1, …, y_n) must be 1:**
[
y_1 + … + y_n ≥ n(1-y)
]

**If (y=1) and (y'=1) then (LHS ≥ RHS):**
[
LHS ≥ RHS - M(2 - y - y')
]

**If (y=0) and (y'=0) then (LHS ≥ RHS):**
[
LHS ≥ RHS - M(y + y')
]

**If (y=0) and (y'=1) then (LHS ≥ RHS):**
[
LHS ≥ RHS - M(y + (1-y'))
]

**If (y=1, y'=0, y^*=1) then (LHS ≥ RHS):**
[
LHS ≥ RHS - M((1-y)+y' + (1-y^*))
]

**(y^*) is 1 iff (y=1) and (y'=1):**
[
y^* ≥ -1 + y + y'
]
[
y^* ≤ \frac{y+y'}{2}
]

---

## Bilinear terms

A bilinear term looks like (y \cdot x), where (y) is binary and (x) is non-negative continuous. Linearize it by replacing the product with a new variable (z) and adding:

[
z ≤ x
]
[
z ≤ My
]
[
z ≥ x - M(1-y)
]

If (y=1), these enforce (z=x).
If (y=0), they enforce (z=0).

---

## A note on efficiency

Big-M constraints can significantly slow down MILP performance, because they often give weak relaxations. Use them only when needed, and choose the smallest safe value for M. For example, don’t write:

[
y' ≤ 1000y
]

when

[
y' ≤ y
]

is sufficient.

---

## Final notes

The purpose of this lecture was to demonstrate how to convert conditional logic into standard linear constraints. In practice, Big-M modeling is extremely common, often necessary, and a core part of MILP modeling technique.

---

If you'd like, I can also **polish**, **shorten**, **annotate**, or **convert this into a PDF, Markdown chapter, or GMPL tutorial**.
