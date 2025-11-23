Linear Programming: first steps
Constructing the first (MI)LP models for the motivational examples.

---

**Prerequisites**
Motivational example: festivals
Motivational example: fröccs

---

**Modeling in general**
Modeling is used in many fields for different purposes, such as simulation, planning, and of course, optimization. A model is essentially a simplified version of something real, which makes it easier and cheaper to work with. A model does not have to be mathematical; for example, a mock-up can be viewed as a physical model. On this site, however, the word *model* will always refer to a *mathematical model*, unless stated otherwise.

Many different things can serve as models. The simplest ones are taught in high school physics, for example,
(v = \dfrac{s}{t}),
where (v) is the average velocity if distance (s) is covered in time (t). This is a simple equation involving 3 variables. Other models may use different mathematical structures, such as graphs. In this course, we will focus on *algebraic* models as discussed below.

It’s important to note that in most cases, a model is only a *simplification* of a real-life phenomenon. Typically, the model ignores some parameters that may influence how a system behaves. In the example above, we implicitly assumed that the object moves along a straight line. When a real-world problem arises, the modeler has a serious responsibility in choosing which parameters to include and at what level of detail they should be represented.

This can be illustrated nicely with the evolution of GPS navigation tools. The basic task is simple: we want to get from point A to point B as quickly as possible.

* The simplest approach is to find the *shortest path* between the two locations. This can be done easily if we have the weighted graph of the road network.
* A slightly more advanced approach is to take into account the speed limit on each road segment and replace distances in the graph with the *minimum travel times*. From a computational standpoint, this requires similar resources, but more input data.
* Most modern navigation systems, running on devices with internet access, go one step further and use *real-time traffic data* in route planning.
* We could go even further by adding weather data, road conditions, driver characteristics, etc. As we include more and more parameters, the model becomes more accurate, but also more difficult to handle.

In general, the goal is to find a model that:

* can be solved/simulated/etc. with the available computing resources in a reasonable amount of time,
* can provide results that are accurate enough to be relevant for the original real-life problem,
* requires only such data as can actually be obtained.

Later on, we will not focus on this first step of modeling. We will assume that these decisions have already been made, and our task is simply to construct and solve the appropriate mathematical model.

---

**Model for the Fröccs example**
Let’s assume we already have a solution—not necessarily an optimal one, just any valid solution. This solution specifies how much we sell from each type of drink. Let:

* (x_{KF}) denote the number of portions of *Kisfröccs* we sell,
* (x_{NF}) the number of portions of *Nagyfröccs*,
* and so on for the other drink types.

From these values, we can easily compute how much wine is needed for this solution. For (x_{KF}) portions of Kisfröccs, we need (x_{KF} \cdot 1) dl of wine. Similarly, for (x_{NF}) portions of Nagyfröccs, we need (x_{NF} \cdot 2) dl of wine. Following the same logic, the total wine used (in deciliters) is

[
1 \cdot x_{KF}

* 2 \cdot x_{NF}
* 1 \cdot x_{HL}
* 3 \cdot x_{HM}
* 2 \cdot x_{VHM}
* 9 \cdot x_{KrF}
* 1 \cdot x_{SF}
* 6 \cdot x_{PF}.
  ]

Our wine stock is 100 liters = 1000 deciliters, so for any acceptable solution, the following inequality must hold:

[
1 \cdot x_{KF}

* 2 \cdot x_{NF}
* 1 \cdot x_{HL}
* 3 \cdot x_{HM}
* 2 \cdot x_{VHM}
* 9 \cdot x_{KrF}
* 1 \cdot x_{SF}
* 6 \cdot x_{PF}
  \le 1000.
  ]

We can similarly write a constraint for soda:

[
1 \cdot x_{KF}

* 1 \cdot x_{NF}
* 2 \cdot x_{HL}
* 2 \cdot x_{HM}
* 3 \cdot x_{VHM}
* 1 \cdot x_{KrF}
* 9 \cdot x_{SF}
* 3 \cdot x_{PF}
  \le 1500.
  ]

If the values of
(x_{KF}, x_{NF}, \dots)
are chosen from the interval ([0, \infty[) (i.e., nonnegative real numbers) in such a way that both inequalities above are satisfied, then the solution is feasible (good). We now have a simple algebraic model for the *constraints* of the problem. The only thing left is to express our *objective*.

Just as we computed wine and soda usage, we can express the profit of such a plan as

[
110 \cdot x_{KF}

* 200 \cdot x_{NF}
* 120 \cdot x_{HL}
* 260 \cdot x_{HM}
* 200 \cdot x_{VHM}
* 800 \cdot x_{KrF}
* 200 \cdot x_{SF}
* 550 \cdot x_{PF}.
  ]

This is the value we want to *maximize*.

Putting everything together, we get:

[
x_{KF}, x_{NF}, x_{HL}, x_{HM}, x_{VHM}, x_{KrF}, x_{SF}, x_{PF} \in [0, \infty[
]

[
1 \cdot x_{KF}

* 2 \cdot x_{NF}
* 1 \cdot x_{HL}
* 3 \cdot x_{HM}
* 2 \cdot x_{VHM}
* 9 \cdot x_{KrF}
* 1 \cdot x_{SF}
* 6 \cdot x_{PF}
  \le 1000
  ]

[
1 \cdot x_{KF}

* 1 \cdot x_{NF}
* 2 \cdot x_{HL}
* 2 \cdot x_{HM}
* 3 \cdot x_{VHM}
* 1 \cdot x_{KrF}
* 9 \cdot x_{SF}
* 3 \cdot x_{PF}
  \le 1500
  ]

[
110 \cdot x_{KF}

* 200 \cdot x_{NF}
* 120 \cdot x_{HL}
* 260 \cdot x_{HM}
* 200 \cdot x_{VHM}
* 800 \cdot x_{KrF}
* 200 \cdot x_{SF}
* 550 \cdot x_{PF}
  \to \max.
  ]

This mathematical description of the problem’s constraints, goal, and decision variables follows the rules of a *Linear Programming* (LP) model:

* There are a finite number of variables.
* The domain of each variable is a continuous interval.
* There are a finite number of constraints.
* The left-hand side (LHS) of each constraint is a linear expression in the variables.
* The relation in each constraint is either (\le), (=), or (\ge).
* The right-hand side (RHS) of each constraint is a constant.
* The objective function is a linear expression in the variables, and it is either maximized or minimized.

Mathematical models that satisfy the conditions above are called LP models, and they can be solved to optimality efficiently (the computational time is bounded by a polynomial function of the number of variables) using variants of the simplex algorithm or interior-point methods.

---

**Model for the Festival example**
Let’s try to build a model similar to the one above for the festival example. First, observe the relationship between the parts of the problem description and the parts of the mathematical model.

In the LP model above, the variables represent the decisions we can make, i.e., the *flexibilities* of the problem. Each possible choice corresponds to some value in the domain of the associated variable, and vice versa. The constraints express the restrictions from the problem statement. The objective function models our goal.

Problem definition  Linear Programming model
Decision ⟺ Variable
Option for decision ⟺ Value of the variable
Restriction ⟺ Constraints
Goal ⟺ Objective function

Let’s construct the model along these lines in three simple steps.

---

**Step 1: variables**
In the festival example, each decision is whether we attend a given festival or not. We’ll represent these decisions with variables
(y_1, y_2, y_3, y_4, y_5).

Next, we have to define the domain of each variable and assign a *meaning* (decision outcome) to each possible value. For each festival, the outcome is either that we go or we don’t go. Therefore, the domain must have two elements. In theory, we could pick any two numbers, but it is natural (and useful later) to choose:

* (y_n = 1): We will go to the (n)-th festival.
* (y_n = 0): We will *not* go to the (n)-th festival.

---

**Step 2: constraints**
If the variables and their value interpretations are chosen appropriately, writing down the equations is often straightforward, as in the fröccs example. Sometimes it is trickier, as in this case.

First we must identify our restrictions. Here, the only restriction is: *we must see each of our favorite bands at least once*. In fact, that is really 7 separate conditions, one for each band.

Using the author’s favorites: to see **Haggard**, we must attend at least one of festivals 1, 3, or 4. In terms of our variables, at least one of
(y_1, y_3, y_4)
must be equal to 1. So we need a constraint that is satisfied if and only if at least one of these variables equals 1.

Try to come up with such a *linear* constraint yourself before reading further!

We can check that

[
y_1 + y_3 + y_4 \ge 1
]

works as desired. A small truth table illustrates this:

[
\begin{array}{ccc|c}
y_1 & y_3 & y_4 & y_1 + y_3 + y_4 \
\hline
0 & 0 & 0 & 0 \not\ge 1 \
0 & 0 & 1 & 1 \ge 1 \
0 & 1 & 0 & 1 \ge 1 \
0 & 1 & 1 & 2 \ge 1 \
1 & 0 & 0 & 1 \ge 1 \
1 & 0 & 1 & 2 \ge 1 \
1 & 1 & 0 & 2 \ge 1 \
1 & 1 & 1 & 3 \ge 1
\end{array}
]

Following this pattern, we can write a similar constraint for each band. For example, for **Stratovarius**:

[
y_1 + y_2 + y_3 + y_5 \ge 1
]

For **Dalriada**:

[
y_3 + y_5 \ge 1
]

The case of **Apocalyptica** is special:

[
y_4 \ge 1,
]

which effectively forces (y_4 = 1). This makes sense because festival 4 is the only one where Apocalyptica performs.

---

**Step 3: objective**
Our goal is to attend as *few* festivals as possible. Using the variables (y_n), we need to express the total number of festivals we attend. It is easy to see that

[
y_1 + y_2 + y_3 + y_4 + y_5
]

gives exactly that number.

---

**Finally, the complete model**
Combining everything:

[
y_1, y_2, y_3, y_4, y_5 \in {0,1}
]

[
y_1 + y_3 + y_4 \ge 1
]

[
y_1 + y_2 + y_3 + y_5 \ge 1
]

[
y_1 + y_2 + y_4 + y_5 \ge 1
]

[
y_3 + y_5 \ge 1
]

[
y_4 \ge 1
]

[
y_2 + y_3 + y_4 + y_5 \ge 1
]

[
y_3 + y_5 \ge 1
]

[
y_1 + y_2 + y_3 + y_4 + y_5 \to \min
]

Now let’s check whether this model satisfies the LP rules listed earlier:

* There are a finite number of variables — ✅
* The domain of each variable is a continuous interval — **not satisfied**
* There are a finite number of constraints — ✅
* The LHS of each constraint is a linear expression in the variables — ✅
* The relation in each constraint is either (\le), (=), or (\ge) — ✅
* The RHS of each constraint is a constant — ✅
* The objective function is a linear expression in the variables and is minimized (or maximized) — ✅

So this is *not* an LP model, but something very similar. The one crucial difference is that (some of) the variables take values from a *discrete* set. Such models are called *Mixed-Integer Linear Programming* (MILP) problems. In MILP models, some variables may range over a continuous interval, while others are restricted to discrete values such as integers. In theory, any discrete set could be used, but in practice we usually consider subsets of (\mathbb{Z}), so these are called *integer variables*. Very often, this subset is simply ({0, 1}); variables of this type are called *binary variables*. In our example, all variables are binary, and there are no other integer or continuous variables.

MILP models are computationally harder to solve. MILP solvers typically combine the simplex algorithm with additional techniques such as Branch-and-Bound (B&B) or Cutting-plane / Branch-and-Cut methods. Roughly speaking, the time (number of steps) required to solve a general MILP problem grows exponentially with the number of integer variables. This means that beyond a certain size, the problem becomes extremely difficult and practically unsolvable to proven optimality. These tools can still return a solution if the solver is stopped after a time limit, but the optimality of that solution is not guaranteed.

Note that not all MILP models are hard to solve. If, for example, the coefficient matrix of the model is *totally unimodular*, the problem can be solved in polynomial time, just like an LP. A famous example is the *Assignment problem*, which can be solved efficiently by the Hungarian method. (The algorithm was developed by an American mathematician, Harold W. Kuhn, who named it the Hungarian method because it was based on earlier work by two Hungarian mathematicians: Dénes Kőnig and Jenő Egerváry. Kőnig wrote the first textbook on graph theory.)

---

**Final notes**
The main takeaway from this section is that certain problems can be described using algebraic models such as LP or MILP. If a practical problem can be adequately represented by one of these models, it can be solved using well-known (and very well implemented) algorithms. If the problem has only linear constraints and continuous decision variables, it is relatively easy to solve. Difficulties arise when discrete decisions (integer or binary variables) are involved.
