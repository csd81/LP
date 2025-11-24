

# Chapter 1: Introduction

This Tutorial is intended to provide an **overview** of mathematical programming and Operations Research in general, using the development of Linear Programming (LP) and Mixed-Integer Linear Programming (MILP) models with the GNU MathProg (GMPL) modeling language.

Optimization involves finding the **best** solution in real-world situations. While this is often achievable using common sense or simple logic, many cases require advanced approaches. Typically, a mathematical model of the problem is created, and solution methods are designed by leveraging the best available mathematical theory, computer science, and existing technology.

The primary difficulty often lies in the **vast number of potential solutions** to a problem, making it impossible to evaluate each one, even with the fastest computers available. In many situations, instead of seeking a perfect solution, "rules of thumb," also known as **heuristic methods**, are employed. These methods simplify the underlying problem model, reduce the set of possible solutions to investigate, or both. This approach sacrifices optimality but makes finding a reasonably good solution computationally feasible. Nevertheless, even in these cases, finding such a solution usually requires some form of optimization, for example, to select the best option from a few candidates.

When faced with an optimization problem, a "conventional" approach to solving it is to design, implement, and apply a specific algorithm, which usually requires a programming language. The concept of an algorithm is very broad, and its implementation depends on the chosen programming language. However, it typically involves describing the data structures used and the sequence of steps to be executed. This is what most common programming languages, such as C/C++, Java, Python, and others, facilitate. The commonality among these languages is that the programmer addresses not only the "What?" (the goal of the algorithm) but also the "How?" (the exact steps to be performed with the data). For instance, Dijkstra’s algorithm can find the shortest path in a graph, Kruskal’s algorithm can find the cheapest spanning tree of a graph, or the Ford-Fulkerson algorithm can find the optimal flow in a flow network.

Mathematical programming methods offer an alternative. Instead of describing the steps to be taken, **only the mathematical model** of the real-world problem is formulated. This model consists of statements like equations, inequalities, logical expressions, and others that correspond to the rules governing the real-world problem and its solution. The real-world problem is then solved by finding solutions to the system of these equations, inequalities, or other statements. However, the programmer is only responsible for formulating the mathematical model, not for the algorithm used to solve it. The latter is actually handled by **solver software**, which is designed to solve a particular class of mathematical programming models.

This Tutorial focuses on a subset of mathematical programming methods, specifically Linear Programming (LP) and Mixed-Integer Linear Programming (MILP) models, which can be formulated using the GNU MathProg (GMPL) modeling language [1]. **Tackling** real-world optimization problems by formulating a mathematical programming model and solving it with solver software is a valuable skill set that differs substantially from "conventional" programming. Nevertheless, an algorithm designed for a specific optimization problem may be significantly faster than a general mathematical programming model: many well-studied optimization problems have state-of-the-art algorithmic solutions. However, for some problems—even those with decent algorithms—designing a mathematical programming model can be surprisingly quick and easy. Mathematical programming models are also more flexible if the real-world problem itself changes.

The algorithms that solvers utilize to actually solve our formulated mathematical programming model are an interesting topic in their own right, but they are not the focus here. In short, the methods for formulating these models are more important than the methods for solving these mathematical models to optimality.

The GNU MathProg modeling language was selected because, along with its solver `glpsol` in the GNU Linear Programming Kit [2], these tools are relatively easy to understand and are available under the GNU General Public License. Many other free and commercial tools exist for both formulating and solving not only MILP but more general mathematical programming models. Many of these tools are much faster than `glpsol`.

Several other learning resources are available on this subject. The basic installation of GLPK also includes a number of example models, including complex ones. GLPK also has a Wikibooks project that covers usage in great detail [3]. We would like to recommend Hegyháti’s Linear Programming tutorial [4]. Furthermore, many useful books and lecture materials can be found on the Hungarian Tankönyvtár homepage [5].

This Tutorial presents the basics of the language and some key problems that can be easily solved by mathematical programming tools, offering insight into the power of optimization using mathematical, and particularly MILP, models. Some algorithmic solution methods for specific problems are also presented.

The remainder of the Tutorial is organized as follows:

* Chapter 2 provides an introduction to the main goals, tools, and concepts of optimization.
* Chapter 3 introduces the basic usage of GNU MathProg and the `glpsol` solver. A minimal, "Hello, World!" model file is shown.
* In Chapter 4, linear equation systems are solved using GNU MathProg, with gradually improved model implementations. This part aims to demonstrate language features required to develop concise and general LP/MILP models, most importantly indexing and the separation of model and data sections.
* Chapter 5 introduces the production problem, a simple optimization problem. Incremental model development is the focus, demonstrated through changes and extensions to the problem definition. Some additional language features and integer variables are used.
* Chapter 6 presents another simple optimization problem, the transportation problem. Modeling techniques for some cost functions, which can be part of more complex problems, are introduced.
* Chapter 7 discusses some more challenging problems requiring MILP model formulations. Advanced modeling and coding techniques, along with possible graphical outputs, are presented.
* Chapter 8 provides a brief insight into LP/MILP solving algorithms, explaining how software tools may work in the background.

This Tutorial contains attachments. All GNU MathProg codes, including model and data files, and their outputs mentioned in the text, can be found, grouped by chapters and sections. (A more detailed description is available in the attachment itself.)

For learning purposes, it is recommended to manually examine and solve the models with their corresponding data file(s) to investigate the results. Note that most of the codes and the more important output file segments are included, either fully or partially, within the text of the Tutorial itself, using a specific format.

GNU MathProg code for model files is formatted like this.

> GNU MathProg code of data sections that may go to
> separate data files are formatted like this.

> Output generated by the solver is formatted like this.

> Commands to be run are formatted like this.

If you have questions or find any errors in this Tutorial, please feel free to contact us at eles@dcs.uni-pannon.hu. We hope you will find this material useful.



# Chapter 2: Optimization

## 2.1 Equations

Equations are one of the simplest and most powerful mathematical modeling tools we have. Let's look at an example problem that can be solved using an equation.

**Problem 1.**
Alice's train leaves 75 minutes from now. She lives 3 km away from the station and plans to walk, but she also needs 30 minutes to get ready. How fast must she walk to the station to catch the train?

We can see that we are actually looking for the minimal average speed Alice must maintain. She might walk faster at some points or slower at others, but the overall average speed determines her arrival time. She could even walk at a constant speed to achieve the same result. We are also seeking the minimal speed with which she *just* catches the train. Of course, she could walk faster and have some waiting time at the station. These steps may seem trivial, but they are part of the modeling process: we have simplified the problem to finding a single minimal speed value and can assume that Alice walks at that constant speed, arriving precisely on time.

The problem can be solved by expressing the time until she reaches the station in two different ways. First, her arrival time is 75 minutes, based on the train schedule. Second, her arrival time is the 30 minutes needed for preparation plus the time spent walking. The walking time is the unknown term, as it depends on Alice's speed. We now introduce a variable $x$ to represent Alice's speed, which is what we need to find. Variable $x$ is a value that can be chosen, giving Alice control over the outcome. She can choose her speed to arrive at the station sooner or later.

Using $x$, we can easily express the time she spends walking as $\frac{3 \text{ km}}{x}$. Now, an equation can be formulated based on the fact that Alice's arrival time is expressed in two different ways.

$$30 \text{ min} + \frac{3 \text{ km}}{x} = 75 \text{ min}$$ (1)

Alice's task is to choose an appropriate $x$ so that this equation holds true. From this point, the equation is formulated, and we can set aside the real-world problem and apply our mathematical knowledge about solving equations. This is an easy one. We can, for example, subtract 30 minutes from both sides, multiply by $x$ (which we can assume is not zero), and then divide by 3 km, in that order. We arrive at the following:

$$x = \frac{4 \text{ km}}{\text{h}}$$ (2)

## 2.2 Finding the "Best" Solution

What we actually do when solving an equation is transform it into simpler forms, where each subsequent form is a direct consequence of the previous one. The final form is $x = \frac{4 \text{ km}}{\text{h}}$, which literally means: "If $30 \text{ min} + \frac{3 \text{ km}}{x} = 75 \text{ min}$, then its direct consequence is $x = \frac{4 \text{ km}}{\text{h}}$." So, if Alice is to just catch the train, her average speed must be $\frac{4 \text{ km}}{\text{h}}$. At this point, we have the result and can interpret it in reality. This is the general way equations are used in problem-solving. First, we identify the degree of freedom we have in the problem ($x$, the speed). Then, we use equations as modeling tools to express the rules of reality that must be followed (the first equation). The model is now ready; we apply our solution techniques, which are typically general for all types of equations and have nothing to do with the underlying real-world problem. In this case, the equation is transformed in a chain of direct consequences until the variable is expressed directly as a constant value. Finally, once the result for the mathematical model is obtained, we interpret it as the solution to our initial real-world problem.

Of course, there are much more difficult examples of equation solving (for example, multiple solutions for single equations, extraneous solutions, multiple variables, systems of multiple equations, etc.), which are not covered here. But the point is that the scheme is always similar: we formulate a mathematical model that describes the real-world situation, solve that model with some well-known general techniques, and then interpret the model's solution as the solution to the original problem.

## 2.3 Main Concepts

Note that the question about Alice catching the train in Problem 1 was about how fast she *must* go. The answer was $x = \frac{4 \text{ km}}{\text{h}}$, but that is not entirely accurate. In reality, $x = \frac{5 \text{ km}}{\text{h}}$, $x = \frac{10 \text{ km}}{\text{h}}$, or even $x = \frac{15 \text{ km}}{\text{h}}$ are also solutions for her, assuming she can walk that fast. However, $x = \frac{3 \text{ km}}{\text{h}}$ is not a solution, as she would miss the train if she were that slow. Of course, for this particular problem, we understand there is a minimum speed of $x = \frac{4 \text{ km}}{\text{h}}$ for which Alice just makes the train on time. However, the more precise formulation would be the following inequality instead:

$$30 \text{ min} + \frac{3 \text{ km}}{x} \leq 75 \text{ min}$$ (3)

Two quantities are compared here: the time Alice needs to reach the station if her speed is $x$ (which is $30 \text{ min} + \frac{3 \text{ km}}{x}$) and the time the train departs (75 min). These two quantities are related: Alice must arrive at or before the train is due (in other words, no later). This can be expressed as an inequality rather than an equation, but the goal is the same. We must find a speed $x$ for Alice for which the inequality holds. Technically, this can be solved in exactly the same way the equation was solved, leading to $x \geq \frac{4 \text{ km}}{\text{h}}$. This means the solutions are actually all speeds $x$ that are at least $\frac{4 \text{ km}}{\text{h}}$. There are infinitely many solutions for the inequality, meaning Alice can choose from infinitely many speeds.

Now, this is more precise, but Alice may be interested in the minimum speed she can choose, so let $x$ be as small as possible. The formulation is as follows:

$$\begin{aligned} \text{minimize} &: x \\ 
\text{subject to} &: 30 \text{ min} + \frac{3 \text{ km}}{x} \leq 75 \text{ min}\end{aligned}$$ 

(4)

At this point, the formulated problem is an **optimization problem**. The goal is not only to find a suitable solution for a real-world problem but to find the **most suitable** one in some specific aspect. From a mathematical perspective, optimization involves finding the *best* solution, not just *a* solution, for an equation, inequality, or a set of such statements. Optimization is a sub-field of Operations Research, as it is an essential way to support business decisions: given a complex real-world situation, what is the best course of action?

 

Now that we have seen some optimization from Problem 1, it is time to establish some basic concepts of optimization models.

When solving a real-world problem by defining variables, equations, inequalities, and so on, we formulate a **mathematical model** for the problem. That model is then solved using mathematical knowledge that is usually independent of the original, real-world problem. If the solution procedure is carried out by software (which is usually the case), that software is called a **solver**.

An optimization model contains **variables**. These represent our freedom of choice: the different values a variable can take represent our different potential actions. In Problem 1, there is a single variable, $x$, representing Alice's average speed.

A **solution** to an optimization model is when all the variables are assigned a value. If the model has multiple variables, a single solution consists of values for all of those variables. Two solutions are considered different if any of the variables take a different value. In Problem 1, there are infinitely many solutions, such as $x = \frac{4 \text{ km}}{\text{h}}$, $x = \frac{10 \text{ km}}{\text{h}}$, and even $x = \frac{1 \text{ km}}{\text{h}}$ (see below), though in the latter case Alice misses the train.

Usually, the variables cannot take arbitrary values. In Problem 1, Alice cannot choose a speed if she would miss the train with it. Such mandatory restrictions are called **constraints**. So, in the example problem, there is a single constraint, which is expressed by Inequality (3).

A wide range of constraints may appear in an optimization problem; some cannot even be expressed as inequalities. The concept of **bounds** should be mentioned: these are constraints that require a single variable to be no less than or no more than a given constant limit. For example, $x \geq \frac{0 \text{ km}}{\text{h}}$ is a bound that must also be enforced. The problem required Alice to move at a positive speed, so this was implicitly enforced and not explicitly stated. In many optimization problems, however, we must explicitly consider bounds; otherwise, solutions might not reflect reality. Bounds also have great practical importance in model solution algorithms.

Constraints determine whether solutions are **feasible** or **infeasible**. A feasible solution is one where all variables take values for which all the constraints hold true. Otherwise, it is an infeasible solution. In Problem 1, solutions $x = \frac{4 \text{ km}}{\text{h}}$ and $x = \frac{10 \text{ km}}{\text{h}}$ are feasible, while $x = \frac{1 \text{ km}}{\text{h}}$ is infeasible. We could also say that $x = \frac{4 \text{ km}}{\text{h}}$ is a solution and $x = \frac{1 \text{ km}}{\text{h}}$ is not a solution, but we prefer the terminology of feasible and infeasible solutions.

The way we differentiate between feasible solutions of a model—determining which ones are more or less suitable—is expressed in the model as an **objective function**, which is to be minimized (or maximized). An objective function, like constraints, evaluates an expression based on the model variables. The goal of optimization is to find a feasible solution for which the objective function is minimal (or maximal). A solution with this property is an **optimal solution** of the model. If a solution is optimal, we can be sure that any other solutions are either infeasible, have an equal or worse objective value, or both. There can be multiple optimal solutions for the same model. In Problem 1, we have a very simple objective function, $c(x) = x$, which is minimal at the solution $x = \frac{4 \text{ km}}{\text{h}}$. The optimal objective for the problem is therefore $\frac{4 \text{ km}}{\text{h}}$. Sometimes, we refer to the objective value as the solution of an optimization problem. Therefore, we can say that the optimal solution to Problem 1 is $\frac{4 \text{ km}}{\text{h}}$.

It may happen that an optimization model does not have a feasible solution at all, and thus, there are no optimal solutions either. In this case, we say the model is **infeasible**. For example, the following modification of the problem (Problem 2), the resulting System (5) would be infeasible: Alice is too far away and cannot go fast enough; she will miss the train by at least 3 minutes.





**Problem 2.**

Alice’s train leaves 75 minutes from now. She lives 8 km away from the station and plans to walk, and she also needs 30 minutes to get ready. Furthermore, she cannot average a speed faster than $\frac{10 \text{ km}}{\text{h}}$. How fast must she walk to the station to catch the train?

$$\begin{aligned} \text{minimize} &: x \\ 
\text{subject to} &: 30 \text{ min} + \frac{8 \text{ km}}{x} \leq 75 \text{ min} \\ 
& x \leq \frac{10 \text{ km}}{\text{h}}\end{aligned}$$ 

(5)

In rare cases, a model may be **unbounded**. This means that feasible solutions exist, but none of them are optimal, because there are always better and better feasible solutions available. For example, if Alice’s goal was to go as fast as possible to catch a train, instead of as slow as possible, then neither $\frac{4 \text{ km}}{\text{h}}$, $\frac{10 \text{ km}}{\text{h}}$, $\frac{1000 \text{ km}}{\text{h}}$, nor the speed of light would be optimal solutions, because there would always be a feasible solution with a higher speed value. Of course, this scenario is nonsensical. Typically, when our model turns out to be unbounded, we either made a mistake in solving it, or it does not accurately describe reality—perhaps because it omits some real-world constraint we overlooked. The latter was the case in our example, because, in practice, Alice cannot walk as fast as she wishes.

We can also call the set of feasible solutions of the model the **search space**, emphasizing that our actual goal in optimization is to maximize or minimize an objective function value over the set of feasible solutions. If all the variables are treated together as a mathematical vector, each solution can be considered a point in that vector space. The set of all feasible solutions is a set of points in space that may have special properties. For instance, in LP problems, it is a convex polytope. Constraints (and bounds) are used to define the search space. Each constraint may exclude some values, making them no longer feasible within the search space.

It may appear that a constraint does not exclude any solutions from the search space at all. We call those constraints **redundant**. Note that redundant constraints do not affect the model's solutions and therefore do not change the optimal solution, but they might affect the solution procedure itself, either positively or negatively. We may also refer to constraints as redundant if they do exclude some solutions, but only those that are not interesting to us (for example, because they cannot be optimal for some reason and will not be reported by the solution algorithm anyway).

Now, let's look at a slightly more elaborate example of an optimization problem.


**Problem 3.**

A company wants to design a new type of chocolate in the form of a rectangular block of uniform material. They want the block to contain as much mass as possible; however, there are regulations concerning the block's faces for shipping considerations. One face must have an area no greater than $6 \text{ cm}^2$, another face cannot be greater than $8 \text{ cm}^2$, and the largest face cannot be greater than $12 \text{ cm}^2$. What is the greatest possible mass for a piece of chocolate?

This example could be part of a business decision-making problem. The company aims to maximize its profit but must find a suitable solution for production. Operations Research assists in decision-making, for instance, through optimization models.

In this case, defining the variables isn't even straightforward. Though not explicitly mentioned in the problem description, the three edge lengths of the block—say, $x$, $y$, and $z$—are appropriate, for the following reasons. From these lengths, we can easily express the other quantities specified in the problem: $xy$, $xz$, and $yz$ are the face areas, and $xyz$ is the total volume, which is to be maximized. Note that if the chocolate is homogeneous, volume is proportional to mass, so maximizing volume is equivalent to maximizing mass. Second, $x$, $y$, and $z$ are independent of one another: selecting $x$ does not directly affect the selection of $y$, as all possible combinations can form a block. If they were not independent, additional constraints would need to be formalized. 

The most important requirement for a set of variables to be suitable for a model is that if $x$, $y$, and $z$ are given, the solution to the real-world problem is well-defined. That is, we can accurately determine whether the constraints are satisfied and what the objective value is. Now, let's express the three face area constraints and the volume objective to formulate the optimization model. Note that $x$, $y$, and $z$ should also be positive, but these bounds will be implicitly enforced by an optimal solution of the model.

$$\begin{aligned} \text{maximize} &: xyz \\ 
\text{subject to} &: xy \leq 6 \text{ cm}^2 \\ 
& xz \leq 8 \text{ cm}^2 \\ 
& yz \leq 12 \text{ cm}^2 \\ 
& x, y, z \geq 0\end{aligned}$$ 

(6)

There are many feasible solutions for this model; for example, $x = y = z = 2 \text{ cm}$ is feasible, but $x = y = z = 2.5 \text{ cm}$ is infeasible. There is a single optimal solution, which is $x = 2 \text{ cm}$, $y = 3 \text{ cm}$, and $z = 4 \text{ cm}$; the total volume in this case is $24 \text{ cm}^3$.

The method for finding this optimal solution and unequivocally proving its optimality is non-trivial and beyond the scope of this Tutorial. Here’s a hint, if the reader wishes to solve it: $(xyz)^2 = (xy) \cdot (xz) \cdot (yz)$.

---

## 2.4 Mathematical Programming

We've examined two very simple optimization problems so far. However, for the second one, we would have trouble if we had to actually solve it and prove that our solution is indeed optimal.

The key idea of mathematical programming, though, is that **we are not the ones who actually solve the models**. We are the ones who translate the real-world problem into an optimization model; then, software specifically designed for solving models typically does the heavy lifting for us. Finally, we only need to verify that the model's solution is suitable for the real-world problem.

A mathematical programming model consists of the **model variables** that represent our freedom of choice, the **constraints** that express the requirements for a solution to be feasible and suitable for the real-world problem, and finally, the **objective function**, which determines the criteria for finding the best among the feasible solutions.

Although the general concept is that we are only formulating a model, we still need to be careful about which class of model we choose. The main reason is that the class greatly affects the available solution methods. Solving a model from a more specialized class, as opposed to a more general one, can be drastically cheaper in terms of computational effort. We explicitly mention two model classes that are highly important in Operations Research.

In **Linear Programming (LP)** models, the variables can take arbitrary real values. The constraints are equations or non-strict inequalities involving **linear expressions** of the variables. A linear expression is the sum of some variables, each multiplied by a constant. Linear expressions cannot contain multiplication or division of variables with each other, or any other mathematical functions or operations: only addition, subtraction, and multiplication by a constant are allowed. The objective function itself must be a linear expression of the variables, the minimization or maximization of which is the optimization goal. The following is an example of an LP problem:

$$\begin{aligned} \text{minimize} &: 3x + 4y - z \\ \text{subject to} &: 2x + 5 = z + 2 \\ & x - y \leq 0 \\ & x + y + z \leq 2 (x + y) \\ & x, y, z \geq 0\end{aligned}$$ (7)

An important point about LP models is that only non-strict constraints are allowed ($\leq$, $\geq$, or $=$), but strict constraints ($<$, $>$ ) are not. Also note that Problem 1 about Alice is formulated as an LP model, while Problem 3 about the chocolate blocks is **not** an LP, because it contains a product of variables ($xyz$), which is a nonlinear term.

An LP model is solvable in polynomial time based on the number of constraints and variables. This means large models can be formulated and solved in acceptable time using a modern computer. LP problems have several interesting properties that make them solvable with efficient algorithms, for example, the Simplex Method (see Chapter 8). One such property is that the set of feasible solutions in space is always a closed, convex set.

In **Mixed-Integer Linear Programming (MILP)** models, we may also require some variables to only take integer values in feasible solutions, contrary to LP problems. This difference makes solving the generally broader class of MILP models an **NP-complete problem** in the number of integer variables. This means that if there are many integer variables in an MILP model, we generally cannot expect a complete solution in an acceptable amount of computational time. However, the number of applications that MILP models can cover is surprisingly much wider than for LP problems, making MILP models a popular method for solving complex optimization problems. Effective software tools utilizing heuristic algorithms often solve non-complex MILP models very quickly.

In this manual, we focus on MILP and LP models. In both cases, only linear expressions of the variables appear in the formulations. There are other problem classes, such as Nonlinear Programming (NLP) and Mixed-Integer Nonlinear Programming (MINLP), with corresponding solvers, but these are not covered here.



# Chapter 3: GNU MathProg

This chapter aims to briefly introduce GNU MathProg and demonstrate how it can be used to implement and solve mathematical programming models in the LP or MILP class. A short example problem is presented with implementation, solution, and results, showing some of the most frequently used features of the language.

-----

## 3.1 Prerequisites for Programming

GNU MathProg, also referred to as the **GNU Mathematical Programming Language** (GMPL), is a modeling language used for designing and solving LP and MILP problems. The **GNU Linear Programming Kit (GLPK)** provides free software for both parsing implemented models and solving them to report the optimal solution. GLPK is available under the General Public License version 3.0 or later [6].

There are other software tools available for solving MILP models; some are available with a free license, like CBC or lpsolve. These mentioned tools can be much faster than GLPK. Commercial software can be even better, with some options available through academic licenses. However, we selected GNU MathProg and the solver **`glpsol`** from GLPK because they are relatively easy to use and include both the language and the model-solving tools.

Installing GLPK depends on the operating system. On Linux, you can visit the official GLPK website, where installation packages, source codes, and sample GNU MathProg problems can be found. On some distributions, installation can be done with a single command, as follows:

```
sudo apt-get install glpk-utils
```

If the installation is successful, the program **`glpsol`** should be available in the command line. Throughout this manual, we will use this tool in the command line to parse and solve models.

On Windows, it is possible to obtain the command-line solver as well. However, a more convenient option is a desktop application called **GUSEK** [9], which is a simple Integrated Development Environment (IDE) with a text editor specifically for the GNU MathProg language. The `glpsol` solver is available with all of its functionalities there. With GUSEK, no command line is needed, although managing multiple files requires some attention.

A reference manual for the GNU MathProg modeling language, including usage of the `glpsol` software, is publicly available (see reference [1]).

-----

## 3.2 "Hello World\!" Program

After successful installation, we can try the program with a very simple LP problem. This will be our first GNU MathProg program, much like a "Hello World\!" example.

```
var x >= 0;
var y >= 0;
var z >= 0;
s.t. Con1: x + y <= 3;
s.t. Con2: x + z <= 5;
s.t. Con3: y + z <= 7;
maximize Sum: x + y + z;
solve;
printf "Optimal (max) sum is: %g.\n", Sum;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
end;
```

GNU MathProg is designed to be easily readable and for its mathematical meaning to be simple to understand. The language consists of commands ending with a semicolon (;), which are called **statements**. There are six distinct statements in this file: `var`, `s.t.`, `maximize`, `solve`, `printf`, and `end`. The meanings of most are self-explanatory, as we will see.

```
var x >= 0;
var y >= 0;
var z >= 0;
```

First of all, this is an LP problem, where all three variables $x$, $y$, and $z$ can take real values. They also have **bounds** defined: each must be non-negative. Note that this is the most common bound for variables.

```
s.t. Con1: x + y <= 3;
s.t. Con2: x + z <= 5;
s.t. Con3: y + z <= 7;
```

In the problem, there are three **constraints**, separate from the bounds, which are treated differently in the language. The constraints are named `Con1`, `Con2`, and `Con3`, respectively. The names are preceded by **"s.t."**, which is an abbreviation for "subject to," but it has several aliases and can even be omitted entirely. The constraints state that the sum of any two of the three variables cannot be greater than the given constants, which are 3, 5, and 7, respectively.

```
maximize Sum: x + y + z;
```

The goal of the optimization is to **maximize** the objective titled "Sum," which is, of course, the sum of the three variables. A model file can contain at most one `maximize` or `minimize` statement.

At this point, the LP problem is fully defined. This is a relatively easy linear problem; however, its optimal solution might not be immediately obvious.

It should be noted that the objective function can be omitted entirely from a GNU MathProg model formulation. In that case, the only task is to find any **feasible solution** for the problem.

```
solve;
printf "Optimal (max) sum is: %g.\n", Sum;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
end;
```

There is a **`solve`** statement in the file. This denotes the point where the solver software should finish reading all the data, then construct and solve the model. After the `solve` statement, there may still be other statements in the file to report valuable information about our solution. In this case, the objective value and our three variables are printed with the values obtained by the optimization procedure. The **`printf`** statement works similarly to the `printf()` function from the C programming language but supports fewer format specifiers. We prefer the `%g` format because it can print both integers and fractional values in a compact form. In some cases, a fixed-precision number is more appropriate, like `%.3f`.

An **`end`** statement denotes the end of the model description, although it is optional.

We can use any text editor we like, but some offer syntax highlighting options. GUSEK on Windows has its own text editor specifically designed for modeling. On Linux, we can use `gedit`. It does not have built-in syntax highlighting for GNU MathProg by default, but one can be obtained from the internet.

Let's name this file `helloworld.mod`. On some systems, the file extension `.mod` can be recognized as a video format by the file browser. This might cause a "double-click" action to try opening the file as a video instead of a text file. For this reason, it is recommended to set the file's opening method to the text editor we prefer, such as `gedit`. Alternatively, we can simply use a different file extension, like `.m` or simply `.txt`; it does not matter from the perspective of `glpsol`, although it may matter if we use an IDE like GUSEK.

The file `helloworld.mod` is a **model file** because it contains the business logic of the problem we want to solve. It is sufficient on its own for defining a problem. Later on, we will split our problem formulations into a single model file and one or more **data files**. The model file encapsulates the problem's logic, while the data file(s) provide the actual data the problem will be solved with. This separation is useful because if the data for the real-world problem changes, we do not need to modify the model itself. In other words, a user who wants to solve a model for a particular problem does not need to know the model; they only need to correctly implement a data file, which is much easier and less error-prone.

Use `glpsol` to solve the model file with the following command:

```
glpsol -m helloworld.mod
```

Something similar to the following output is obtained:

```
GLPSOL: GLPK LP/MIP Solver, v4.65
Parameter(s) specified in the command line:
-m helloworld.mod

Reading model section from helloworld.mod...
20 lines were read
Generating Con1...
Generating Con2...
Generating Con3...
Generating Sum...
Model has been successfully generated
GLPK Simplex Optimizer, v4.65
4 rows, 3 columns, 9 non-zeros
Preprocessing...
3 rows, 3 columns, 6 non-zeros
Scaling...
A: min|aij| = 1.000e+00 max|aij| = 1.000e+00 ratio =
Problem data seem to be well scaled
Constructing initial basis...
Size of triangular part is 3
* 0: obj = -0.000000000e+00 inf =   0.000e+00 (3)
* 3: obj =   7.500000000e+00 inf =   0.000e+00 (0)
OPTIMAL LP SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (102283 bytes)
Optimal (max) sum is: 7.5.
x = 0.5
y = 2.5
z = 4.5
Model has been successfully processed
```

This is a small problem, so the result is almost instantaneous. Let's look at what information can be read from the output.

```
GLPSOL: GLPK LP/MIP Solver, v4.65
Parameter(s) specified in the command line:
-m helloworld.mod
Reading model section from helloworld.mod...
18 lines were read
Generating Con1...
Generating Con2...
Generating Con3...
Generating Sum...
Model has been successfully generated
```

The first section of the output is printed during the **model generation procedure**. Note that if the model has bad syntax, it will be noted here. Only the first error is displayed. It can also be observed that the constraints and the objective are the model elements that must be "generated."

```
GLPK Simplex Optimizer, v4.65
4 rows, 3 columns, 9 non-zeros
Preprocessing...
3 rows, 3 columns, 6 non-zeros
Scaling...
A: min|aij| = 1.000e+00 max|aij| = 1.000e+00 ratio =
Problem data seem to be well scaled
Constructing initial basis...
Size of triangular part is 3
* 0: obj = -0.000000000e+00 inf =   0.000e+00 (3)
* 3: obj =   7.500000000e+00 inf =   0.000e+00 (0)
OPTIMAL LP SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (102283 bytes)
```

The solution procedure for an LP problem, from the constraints themselves to the final, optimal solution, is an interesting subject in Operations Research. However, we do not focus on the underlying solution algorithms themselves. Still, basic knowledge about them will help us with debugging later. First, all LP problems are represented in a **matrix of coefficients**, where the rows correspond to constraints (and the objective), the columns correspond to variables, and the matrix entries are the coefficients of a given variable in a given constraint.  Some preprocessing steps are performed on this matrix, and then the main algorithm is launched.

There are two rows in this output that show a "current" result. The first one shows an objective of 0; the second shows the objective $7.5$, which is actually the final optimal solution. The row "OPTIMAL LP SOLUTION FOUND" indicates that the solver successfully solved the problem and now knows the optimal solution and the corresponding values of the variables. If there are multiple optimal solutions, one of them is chosen.

With more complex problems, the solution can take a significant amount of time, and the current best solutions are regularly displayed. The solution procedure may end before reaching the optimal solution, in which case the best feasible solution found so far is reported. This happens, for example, when a time limit is set for `glpsol` and that limit is exceeded during the procedure.

```
Optimal (max) sum is: 7.5.
x = 0.5
y = 2.5
z = 4.5
Model has been successfully processed
```

Finally, we can see the result of the `printf` statements that we added at the end. We can see that the optimal solution is $x = \frac{1}{2} = 0.5$, $y = \frac{5}{2} = 2.5$, $z = \frac{9}{2} = 4.5$, and the objective function value is $x + y + z = \frac{15}{2} = 7.5$. This result means we cannot choose values for the variables to obtain a larger sum unless at least one of the constraints (or bounds) is violated. Note that `printf` statements are also valid before the `solve` statement, that is, during the model construction procedure. However, before the `solve` statement, variables and the objective are not available, as they have not yet been calculated. The final "Model has been successfully processed" message suggests that the solver call was successful.

We should also note that the `glpsol` command-line tool has many other options available. For example, we can automatically print a solution file using the `-o` option. We can also save the program's output with the `--log` option. Additionally, the constructed model can be exported to formats that other MILP solvers can use. For instance, with the `--wlp` option, we can export to CPLEX-LP matrix format, which is supported by many other solver software. Perhaps we don't want to use `glpsol` to solve the model; we only need it to translate the model to another format. In that case, the `--check` option ensures that the model is only parsed, but not solved. It is also possible to manipulate the solution procedure in many ways.

Now that we have successfully formulated, solved, and analyzed the output for our first LP problem implemented in GNU MathProg, let's make a slight change in the model file. Add the **integer restriction** to all three variables, as follows. The modified file is now saved as `helloworld-int.mod`.

```
var x >= 0, integer;
var y >= 0, integer;
var z >= 0, integer;
```

From now on, this is no longer an LP model but a **Mixed-Integer Linear Programming (MILP)** model because some (in this case, all) of the variables must take integer values. Solving the model with `glpsol` is the same:

```
glpsol -m helloworld-int.mod
```

The solver identifies the model as MILP, and there are some changes in the generated output.

```
Solving LP relaxation...
GLPK Simplex Optimizer, v4.65
3 rows, 3 columns, 6 non-zeros
* 0: obj = -0.000000000e+00 inf =   0.000e+00 (3)
* 4: obj =   7.500000000e+00 inf =   0.000e+00 (0)
OPTIMAL LP SOLUTION FOUND
Integer optimization begins...
Long-step dual simplex will be used
+     4: mip =   not found yet <=     +inf        (1; 0)
+     6: >>>>>   7.000000000e+00 <=   7.000000000e+00   0.0% (2; 0)
+     6: mip =   7.000000000e+00 <=   7.000000000e+00   0.0% (0; 3)
tree is empty
INTEGER OPTIMAL SOLUTION FOUND
Time used:   0.0 secs
Memory used: 0.1 Mb (124952 bytes)
Optimal (max) sum is: 7.
x = 1
y = 2
z = 4
Model has been successfully processed
```

We can observe that a so-called **LP relaxation** is solved first, the output for which appears to be the same as the output for our initial LP problem. This is actually the nature of the solution algorithm: it is first solved as if all the integer restrictions were removed, as an LP problem. Then, the actual MILP model is solved, and we find that the optimal solution is only $7.0$ instead of the LP's optimal solution, which was $7.5$.

This is not surprising. The only difference between the two models is that the integer problem is more restrictive regarding the variables. This means any solution to the MILP is also a solution to the LP. But the opposite is not true, as the optimal solution of the LP, $x = 0.5$, $y = 2.5$, $z = 4.5$, was eliminated by the integer restrictions. The LP relaxation is an important concept in solving MILP models—for example, it can be used as a good initial solution when trying to make all variables obtain integer values. Also, if the integer variables all happen to have integer values in the LP relaxation, it is guaranteed to be an optimal solution for the MILP as well, because the MILP is the more restricted problem.

In this model, the solver needed a little extra work for the MILP and found the solution $x = 1$, $y = 2$, and $z = 4$. Note that this is an optimal solution, but not the only one. $x = 0$, $y = 3$, $z = 4$ and $x = 0$, $y = 2$, $z = 5$ are also feasible and optimal solutions with the same objective value of $7.0$.

As we might suspect, the algorithmic procedure behind the MILP can be substantially more complex than that of an LP. However, the difference in the formulation is only the integer restrictions on the variables.

We should keep in mind that solvers can handle a large number of variables and constraints in an LP model, but they can usually only handle a **limited number of integer variables** in an MILP model. The exact limit for integer variables strongly depends on the model itself; it can range from dozens to thousands.


# Chapter 4: Equation Systems

In this chapter, we present the basic capabilities of the GNU MathProg language using an example modeling problem: the general solution of linear equation systems. The aim is to navigate from a straightforward initial implementation to the use of indexing and separated model and data sections.

With this knowledge, code maintenance and solving the model with different instances (different data) become very easy, provided the model is correctly implemented in the first place. This is the standard approach we intend to use for future models.

Note that solving linear systems of equations is considered a routine task. There are plenty of capable software tools available, either standalone or embedded. A well-known algorithm is Gaussian elimination [10]. However, we are currently interested in modeling rather than solution algorithms—specifically, GNU MathProg implementation techniques.

---

## 4.1 Example System

Let’s begin by solving a small system of equations using GNU MathProg.

**Problem 4.**
Solve the following system of equations in the real domain.

$$
\begin{aligned}
2 (x - y) &= -5 \\
y - z &= w - 5 \\
1 &= y + z \\
x + 2w &= 7y - x
\end{aligned}
$$
(8)

Although not explicitly stated in the problem description, there are four variables: $x$, $y$, $z$, and $w$. The "real domain" means that all of these can independently take arbitrary real values. Our goal is to find values for these four variables such that all four equations are true.

If a complete analysis of the problem were required, the goal would be not only to find a single solution but to find *all* of them. If there were infinitely many solutions, we would need to characterize this infinite set and prove that no other solutions exist. However, for the sake of simplicity, we currently only want to find a single solution to the system of equations without determining if others exist.

Therefore, this is a feasibility problem, meaning only a single feasible solution needs to be found. There is no need for an objective function to optimize, as there are no better or worse solutions.

It can be observed that Problem 4 describes a linear system of equations. This becomes apparent after we arrange the equations into the following format:

$$
\begin{aligned}
2x - 2y - w &= -5 \\
y - z - w &= -5 \\
y + z &= 1 \\
2x - 7y + 2w &= 0
\end{aligned}
$$
(9)

The point is that this arrangement can be obtained from the original system by simplifying each equation individually: removing parentheses and adding or merging terms on both sides. In this way, the arranged system is equivalent to the original. On the left-hand side (LHS) of each equation, there is a linear expression of the variables (each multiplied by a constant and then added), and on the right-hand side (RHS), there is a constant. Therefore, all equations are linear.

If we further add zero terms and emphasize the coefficients in each column of the arranged format, we get the following equivalent form of the same system:

$$
\begin{aligned}
(+2) \cdot x + (-2) \cdot y + 0 \cdot z + 0 \cdot w &= -5 \\
0 \cdot x + (+1) \cdot y + (-1) \cdot z + (-1) \cdot w &= -5 \\
0 \cdot x + (+1) \cdot y + (+1) \cdot z + 0 \cdot w &= 1 \\
(+2) \cdot x + (-7) \cdot y + 0 \cdot z + (+2) \cdot w &= 0
\end{aligned}
$$
(10)

Although this representation is less readable, it represents more generally what a system of linear equations actually means. For each equation, there is a constant right-hand side and a linear expression on the left-hand side, for which we only need to know the coefficients for each variable. Thus, this whole problem can be represented in a matrix of coefficients, where the rows correspond to equations and the columns correspond to variables—except for the rightmost column, which corresponds to the right-hand side. 

This is very close to what we call the standard form of a Linear Programming problem. The standard form also includes $\ge 0$ bounds for all variables, consists of $\le$ inequalities instead of equations, and, of course, has a linear objective function. This matrix-like form is important because it inspires solution algorithms. However, we will not go into the details of solution algorithms here, neither for systems of equations nor for LP problems.

Instead, the representation shown in Equation System 10 will be useful for understanding the general scheme behind systems of linear equations and for implementing a separated GNU MathProg MILP model. For this model, a data section describing an arbitrary system of linear equations can be provided and solved.

Now, let's see what the code looks like in GNU MathProg. First, the most straightforward implementation is shown, without arranging the equations.

```
var x;
var y;
var z;
var w;
s.t. Eq1: 2 * (x - y) = -5;
s.t. Eq2: y - z = w - 5;
s.t. Eq3: 1 = y + z;
s.t. Eq4: x + 2 * w = 7 * y - x;
solve;

printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
end;
```

As we can see here, GNU MathProg allows the use of parentheses and basic operations, provided that the constraints—now named Eq1, Eq2, Eq3, and Eq4—simplify into an equality (or non-strict inequality) between two linear expressions.

If we solve the model file above, the solution $x = 0.5$, $y = 3$, $z = -2$, and $w = 10$ is obtained. This solution is unique, so all solution methods should end up with this exact result. We can also manually verify that all four equations are satisfied with the resulting variable values. The code itself helps us by printing the values of the four variables to the solver output.

Now, if we were to implement the aligned version, we would get the following:

```
s.t. Eq1: 2 * x + (-2) * y +    0 * z +    0 * w = -5;
s.t. Eq2: 0 * x +    1 * y + (-1) * z + (-1) * w = -5;
s.t. Eq3: 0 * x +    1 * y +    1 * z +    0 * w = 1;
s.t. Eq4: 2 * x + (-7) * y +    0 * z +    2 * w = 0;
```

As we can see, whitespace characters can be freely used in GNU MathProg to improve readability. Also, zero-coefficient terms can be eliminated from the expressions and padded with whitespace instead. The rest of the model file can remain unchanged. The result of solving this arranged model file should be the same.

---

## 4.2 Modifications in Code

Now that we have a working model file that solves a particular system of linear equations, let's try to solve another one obtained by making slight modifications to the original. The problem description is as follows:



**Problem 5.**

Take the equations defined by Equation system (8) as the initial system, using its aligned form described in either Equation system (9) or (10). Then, obtain another system by applying the following modifications:

1.  Change the coefficient of **x** everywhere from $2$ to $4$.
2.  Add **z** to Eq1 with a coefficient of $3$.
3.  Delete **y** from Eq2 (zero out its coefficient).
4.  Change the RHS of Eq3 to $1.5$.
5.  Add a fifth variable **v**, with no bounds.
6.  Add the equation $x + 3v + 0.5 = -2z$ as Eq5.
7.  Introduce **v** in Eq4 with a coefficient of $5$.
8.  Print out the newly introduced variable **v** after the `solve` statement, just like the others.

These modifications can be done one-by-one in a straightforward way until the following model is obtained.

```
var x;
var y;
var z;
var w;
var v;
s.t. Eq1: 4 * x + (-2) * y + 3 * z + 0 * w + 0 * v = -5;
s.t. Eq2: 0 * x + 0 * y + (-1) * z + (-1) * w + 0 * v = -5;
s.t. Eq3: 0 * x + 1 * y + 1 * z + 0 * w + 0 * v = 1.5;
s.t. Eq4: 4 * x + (-7) * y + 0 * z + 2 * w + 5 * v = 0;
s.t. Eq5: 1 * x + 0 * y + 2 * z + 0 * w + 3 * v = -0.5;
solve;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;
end;
```

The solution to the new system is $x = 2$, $y = 3.5$, $z = -2$, $w = 7$, and $v = 0.5$. Although it is not proven here, this solution is unique.

Now, observe the types of modifications we had to implement in the code to achieve these results. The first four tasks were simply replacing, introducing, or erasing coefficients from the corresponding equations. In these cases, one must find the corresponding constraints, locate the corresponding variable within the constraint, and apply the changes.

However, introducing the new variable requires more work than just declaring `v` as a variable with no bounds. If we wanted to maintain the arrangement of the equations, all existing equations must be expanded with an extra column for **v**'s coefficients. These coefficients are initially zero, indicating the variable is not yet used. Then, in Eq4 and Eq5, we can insert a nonzero coefficient for **v** afterward. We also needed to manually modify the printing code after the `solve` statement to include **v**.

Inserting the new equation, Eq5, also requires additional work. Again, if we wanted to keep the code easy to read and maintain the arrangement, the new code line for Eq5 must be formatted accordingly.

Although this was still a small problem, we can sense that modifying a system of equations to accommodate another problem might be frustrating. This difficulty worsens if the number of variables and equations increases—note that several thousands of both are still considered a problem of reasonable size.

One problem is that the model code includes some **redundancy**—we have to maintain the arrangement to preserve readability, even though this is not feasible for very large problems. However, the greatest drawback is that we have to understand and **tamper with model code**, even though we only intend to change the actual problem data, which is still just a system of linear equations.

It would be wise to somehow **separate the modeling logic** of linear equation systems from the **actual data** of the linear equations to be solved (that is, the number of variables, equations, coefficients, and right-hand side constants). This is exactly what we will do in the next sections. Afterward, we only need to alter the data, and the model can remain unchanged, which helps us reuse code in the future and implement problems with large data sets.

-----

## 4.3 Parameters

The first step we take to separate problem data from the model logic is the introduction of **parameters**. In this case, the modified problem is to be implemented. We only change the code, not the underlying problem.

Parameters can be introduced with the **`param`** statement. Its syntax is similar to the `var` statement used for introducing variables. However, the `param` statement defines **constant values** that can be used in the model formulation. Parameters are numeric values by default and are used here as such, but note that they can also represent symbolic values (like strings).

The fundamental difference is that **variables** are the values the optimization procedure must find to satisfy all constraints and optimize a given objective function. From an implementation perspective, variable values are only available **after** the `solve` statement. **Parameters**, on the other hand, are constant values that are initially **given**, and they are typically used to formulate the model itself.

Note that parameters defined by the `param` statement, similar to variables defined in the `var` statement, must have a **unique name**, and they can only be used in the model file **after** they have been defined. Hence, in any expression, we can only refer to parameters defined earlier in the code. For this reason, parameter definitions typically precede constraint and even variable definitions.

First, we only introduce parameters for the right-hand side (RHS) values of the equations, as follows:

```
var x;
var y;
var z;
var w;
var v;
param Rhs1 := -5;
param Rhs2 := -5;
param Rhs3 := 1.5;
param Rhs4 := 0;
param Rhs5 := -0.5;
s.t. Eq1: 4 * x + (-2) * y + 3 * z + 0 * w + 0 * v = Rhs1;
s.t. Eq2: 0 * x + 0 * y + (-1) * z + (-1) * w + 0 * v = Rhs2;
s.t. Eq3: 0 * x + 1 * y + 1 * z + 0 * w + 0 * v = Rhs3;
s.t. Eq4: 4 * x + (-7) * y + 0 * z + 2 * w + 5 * v = Rhs4;
s.t. Eq5: 1 * x + 0 * y + 2 * z + 0 * w + 3 * v = Rhs5;
solve;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;
end;
```

From now on, if we need to modify the RHS of an equation, we do not need to modify the code of the constraint describing that equation. Instead, we only need to replace the definition of the given RHS parameter.

In the same manner, we can also introduce parameters for the coefficients of the equations. Because there are coefficients for all 5 equations and all 5 variables, a total of **25 additional parameters** are needed.

```
var x;
var y;
var z;
var w;
var v;
param Rhs1 := -5;
param Rhs2 := -5;
param Rhs3 := 1.5;
param Rhs4 := 0;
param Rhs5 := -0.5;
param c1x:=4; param c1y:=-2; param c1z:= 3; param c1w:= 0; param c1v:= 0;
param c2x:=0; param c2y:= 0; param c2z:=-1; param c2w:=-1; param c2v:= 0;
param c3x:=0; param c3y:= 1; param c3z:= 1; param c3w:= 0; param c3v:= 0;
param c4x:=4; param c4y:=-7; param c4z:= 0; param c4w:= 2; param c4v:= 5;
param c5x:=1; param c5y:= 0; param c5z:= 2; param c5w:= 0; param c5v:= 3;
s.t. Eq1: c1x * x + c1y * y + c1z * z + c1w * w + c1v * v = Rhs1;
s.t. Eq2: c2x * x + c2y * y + c2z * z + c2w * w + c2v * v = Rhs2;
s.t. Eq3: c3x * x + c3y * y + c3z * z + c3w * w + c3v * v = Rhs3;
s.t. Eq4: c4x * x + c4y * y + c4z * z + c4w * w + c4v * v = Rhs4;
s.t. Eq5: c5x * x + c5y * y + c5z * z + c5w * w + c5v * v = Rhs5;
solve;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;
end;
```

Note that `param` statements can be placed on a single line for readability and to preserve the arrangement of the equations. After the total of **30 parameters** are introduced, the implementation of the equations can be considered final. With the sole modification of the parameter statements in the model file, we can solve arbitrary systems of linear equations with 5 variables and 5 equations.

Note that the solution of either of these two models is exactly the same as before, as the system of equations itself did not change, only its implementation.

-----

## 4.4 Data Blocks

We have successfully separated the coefficients and RHS values from the equations they are in, but we still need to modify the `param` statements within the model file to alter the problem. We have used a single model file each time so far. Now we introduce the concept of the **model section** and the **data section**, with which we can separate the model logic from the problem data entirely.

Parameter values in GNU MathProg can be determined in two ways:

  * A parameter value is **explicitly given** where it is defined: as a constant value, or some expression involving other constant values, other parameters, and built-in functions and operators of the GNU MathProg language.
  * A parameter value is **not given** in the model section but in a **separate data section**.

Now let us see how we can modify the model file to obtain separate model and data sections. In the case where only the RHS parameters were introduced, the complete separation is as follows:

```
var x;
var y;
var z;
var w;
var v;
param Rhs1;
param Rhs2;
param Rhs3;
param Rhs4;
param Rhs5;
s.t. Eq1: 4 * x + (-2) * y + 3 * z + 0 * w + 0 * v = Rhs1;
s.t. Eq2: 0 * x + 0 * y + (-1) * z + (-1) * w + 0 * v = Rhs2;
s.t. Eq3: 0 * x + 1 * y + 1 * z + 0 * w + 0 * v = Rhs3;
s.t. Eq4: 4 * x + (-7) * y + 0 * z + 2 * w + 5 * v = Rhs4;
s.t. Eq5: 1 * x + 0 * y + 2 * z + 0 * w + 3 * v = Rhs5;
solve;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;
data;
param Rhs1 := -5;
param Rhs2 := -5;
param Rhs3 := 1.5;
param Rhs4 := 0;
param Rhs5 := -0.5;
end;
```

We can observe that the parameters are only **defined** in the model section, without a value given. Then, after the model construction and the post-processing procedures (here, printing the variables out), there is a **`data`** statement. There can be a single `data` statement at the end of a model file, which denotes the end of the model section and the start of the data section. The data section contains the actual values of parameters that were defined in the model without a value provided there.

This can also be done for the full parameterization example:

```
var x;
var y;
var z;
var w;
var v;
param Rhs1;
param Rhs2;
param Rhs3;
param Rhs4;
param Rhs5;
param c1x; param c1y; param c1z; param c1w; param c1v;
param c2x; param c2y; param c2z; param c2w; param c2v;
param c3x; param c3y; param c3z; param c3w; param c3v;
param c4x; param c4y; param c4z; param c4w; param c4v;
param c5x; param c5y; param c5z; param c5w; param c5v;
s.t. Eq1: c1x * x + c1y * y + c1z * z + c1w * w + c1v * v = Rhs1;
s.t. Eq2: c2x * x + c2y * y + c2z * z + c2w * w + c2v * v = Rhs2;
s.t. Eq3: c3x * x + c3y * y + c3z * z + c3w * w + c3v * v = Rhs3;
s.t. Eq4: c4x * x + c4y * y + c4z * z + c4w * w + c4v * v = Rhs4;
s.t. Eq5: c5x * x + c5y * y + c5z * z + c5w * w + c5v * v = Rhs5;
solve;
printf "x = %g\n", x;
printf "y = %g\n", y;
printf "z = %g\n", z;
printf "w = %g\n", w;
printf "v = %g\n", v;
data;
param Rhs1 := -5;
param Rhs2 := -5;
param Rhs3 := 1.5;
param Rhs4 := 0;
param Rhs5 := -0.5;
param c1x:=4; param c1y:=-2; param c1z:= 3; param c1w:= 0; param c1v:= 0;
param c2x:=0; param c2y:= 0; param c2z:=-1; param c2w:=-1; param c2v:= 0;
param c3x:=0; param c3y:= 1; param c3z:= 1; param c3w:= 0; param c3v:= 0;
param c4x:=4; param c4y:=-7; param c4z:= 0; param c4w:= 2; param c4v:= 5;
param c5x:=1; param c5y:= 0; param c5z:= 2; param c5w:= 0; param c5v:= 3;
end;
```

The solution obtained by solving these model files is exactly the same in all the parameterization examples, because the system of linear equations is still the same. But now, if one wants to solve an arbitrary system of 5 linear equations with 5 variables, then only the **data section** of this model file must be modified accordingly.

There are more complex data sections required for more complex models. However, the syntax for data sections is generally **more permissive** than in the model section. That means, even if we only want to implement a single model and only solve it with a single problem instance, it is still a good choice to write its data to a separate data section rather than hard-coding parameter values into the model section. The more permissive syntax also allows for shorter and more readable data representation.

One feature that makes data sections useful is that they can be implemented in a **separate data file**. A data file is simply a data section written in a separate file. Its content would be all the code between the `data` and `end` statements. Note that both statements are optional in this case, but they increase readability.

The model file should only contain the full model section and no data sections. Suppose we had a model file named `equations.mod`, and we write the data section for the actual system of equations into the file `eq-example.dat`. Then, the solution using the `glpsol` command line tool can be obtained with the following command:

```
glpsol -m equations.mod -d eq-example.dat
```

Unlike in the model section where referring to model elements defined afterward is illegal, the statements in the data section can be in **arbitrary order**. Moreover, multiple data files can be solved with a single model file, allowing us to further separate problem data. This does not mean we are solving different problems at the same time, but a single problem instance where its different parameters are separated into different data files.

For example, if we have $n$ different variations for the value of a given parameter and $k$ different variations for the value of another parameter, we can implement these as $n + k$ data files. We actually have $nk$ different problem instances, all of which can be solved with the same single model file by providing `glpsol` the corresponding two variations for the two parameters.

One important property of parameters in GNU MathProg that should be kept in mind is that parameter values are only calculated if they are actually **required**—for example, to define model elements (like constraints, variable bounds, objectives), to print them out, or if they are required in the calculation of other parameters which are themselves required. This might cause, for instance, an erroneously defined parameter value to be reported as a modeling error only when the constraint it first appears in is reached in the model file. Note that basic syntax checking is still performed by `glpsol` even in this case; only the substitution of parameter values is "lazy."

One particular example of this is when we do not give a value for a parameter and use it afterward. It is legal in GNU MathProg to define a parameter without a value—for example, when we want to assign a value to it in the data section after the whole model section, or even in a separate file. If the parameter is not actually used at all in the model, then it is not an error. However, if the parameter **is used** and there is no value at definition or in any data sections, an error is generated.

To demonstrate this, erase the statement `param c3z := 1;` from the data section of the model and try to solve it with `glpsol` as before. The following error message is shown:

```
Generating Eq1...
Generating Eq2...
Generating Eq3...
eqsystem-data-blocks-full.mod:21: no value for c3z
MathProg model processing error
```

We can see that the first two equations, Eq1 and Eq2, were generated successfully. However, Eq3 utilized the parameter `c3z` in its definition, but there was no value given for that particular parameter: neither in the model section nor in the data section (or any data sections). The model could not be generated and solved.

Note that it is also illegal to provide a parameter value twice (in the model and in a data section, or in any two data sections). However, there is a way we can "optionally" provide parameter values in data files by providing default values in the model file. More on that later.

-----

## 4.5 Indexing

At this point, we are able to completely separate the model logic and the problem data—at least for the case of systems of linear equations. However, one might argue that this did not actually help much. While the model section including all the constraints does not need to be touched, the parameter definition part of the model, and also their values in a data section, require even *more* code to be written. Modifying the problem data is still very complicated.

Not to mention that the number of variables and the number of equations cannot be altered solely by redefining parameters. A new variable or a new equation would require many additional parameters.

However, we can understand the logic behind systems of linear equations: we know the exact way a system with any number of variables and any number of equations can be implemented. The model formulation is redundant: model elements are defined very similarly, and much of the code can be copy-pasted. It seems the model implementation does not exploit the underlying logic of systems of linear equations.

First, let us try to express how the solution of a system of linear equations generally works:

1.  There are **variables**. The number of variables is not known. These are all reals with no bounds.
2.  There are **equations**. The number of equations is not known.
3.  All equations have a single **right-hand side value**. This means there exists a parameter for all equations that defines these RHS constants.
4.  All the equations have a **left-hand side** where we add all the variables up, each with a single **coefficient**, which is a parameter. This means there exists a parameter for all equations **AND** all variables that defines the coefficients. Note that here "AND" means for all pairs of equations and variables. That implies, if there are $n$ equations and $k$ variables, there are a total of $nk$ parameters.
5.  After the `solve` statement, we simply write a `printf` statement individually for all variables to print their values found by the solution algorithm.

We can see that the **"for all"** parts of the logic are where the redundancy is introduced into the model file and the data section. The reason is that in these cases, code must be reused many times. We need a uniform way to tell the solver that we actually want to do many similar things at once. For example, to write `var` and `printf` statements for all variables in the system; `s.t.` statements and `param` statements denoting RHS constants for all equations in the system. Also, to define `param` statements for all equations and variables that describe the coefficients, and to appropriately implement each of these constraints that involve summing up a particular coefficient multiplied by the particular variable, for all variables.

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

```
param Rhs {e in Equations};
param Coef {e in Equations, u in UnknownValues};
```

This is the first time we use **indexing expressions**. They are denoted by the curly braces. In the first example, `Equations` is the set providing the possible indices for the parameter `Rhs`. The line literally means that we define a parameter named `Rhs` for all $e$, where $e$ is an element of the `Equations` set. This means that whatever the number of equations is, there is an individual parameter for each of these equations.

Note that we could also legally provide a value for the parameter `Rhs`, just like we did for the individual parameters before. We do not want that now, as the constants at the RHS are not part of the model logic; they are represented in the data section. Note that we have much more freedom regarding indexing expressions, which we will not mention for now; refer to the GNU MathProg language manual for the possibilities.

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

Now let us look at the parts of this implementation one-by-one. Whitespace characters, including newlines, are used for better readability. Note that this is a **single constraint statement** in GNU MathProg, named `Cts`, but due to the indexing, it will generate a **set of individual equations** in the model.

First, there must be exactly one constraint written for each equation in the system. This is established by the first indexing expression before the colon, **`e in Equations`**. This not only determines the number of equation constraints to be generated, but it also introduces $e$ as a constant that we can refer to in the definition part.

The **RHS** of the constraint is simpler, as it is the `Rhs` parameter itself. But here we can see how indexing works for parameters. When `Rhs` was defined, it was defined for all equations. That means, for example, if there are three equations in the system, named Eq1, Eq2, and Eq3, then exactly one parameter is defined in the model for each of these. They can be referred to as `Rhs['Eq1']`, `Rhs['Eq2']`, and `Rhs['Eq3']`, respectively. Remember that these are three different parameters. However, we do not write something like `Rhs['Eq1']` in the model section because the exact equation name is not part of the model logic; it is rather arbitrarily given in a data section. Instead, we refer to **`Rhs[e]`**. Remember that $e$ denotes the current element of the `Equations` set we are writing a constraint for. The result is that in each constraint, the RHS is the `Rhs` parameter for the corresponding equation.

The **LHS** of the constraint is more complicated because it contains a summation of an undetermined number of terms. Note that the logic is that for each unknown value, we multiply the variable by the corresponding coefficient of the system, and these terms are added up. The **`sum` operator** does exactly this job for us. It involves an indexing expression, where we denote that we want to sum up terms for all unknown values $u$, and the term to be summed follows. The `sum` operator in GNU MathProg has lower precedence than multiplication, so there is no need to use parentheses. `Coef[e,u] * value[u]` is the term that is summed up for all $u$. Each of these terms refers to the variable of the corresponding unknown value $u$, which is `value[u]`. The term also refers to **`Coef[e,u]`**, which is the coefficient parameter for the equation $e$ and the unknown value $u$.

Note that inside the scope of the `sum` operator, the $u$ index is also available, just as $e$ is available inside the whole indexed constraint. However, $u$ would not be available outside the `sum`, for example, in the RHS. It would not even make sense because $u$ is introduced only to define the terms of the sum.

Now that we have a single `s.t.` constraint statement describing the model of systems of linear equations, the `solve` statement may come, after which we can print the values of the variables. Again, we do not know the exact set of variables, but indexing can be used to do something for all variables:

```
for {u in UnknownValues}
{
   printf "%s = %g\n", u, value[u];
}
```

The **`for` statement** requires an indexing expression and effectively repeats the statements written inside the block following it, throughout the given index set. Note that the statements allowed in a `for` block are limited, but they include `printf` and another `for`, which are enough for very complex tasks to be implemented simply. The `for` statement cannot be used to define model elements like parameters, variables, constraints, or the objective, but it is useful for displaying information.

Now, for each $u$ unknown value, we want to print out the corresponding value in the solution of the system of equations. Therefore, the `printf` statement refers to $u$ itself, the name of the variable of the system of equations, and its value, which is `value[u]`.

At this point, we are ready with the model section. That means, any system of linear equations can be translated into a data section, and if done with correct syntax, can be solved without altering the model file. Now, let us translate the previous problem instance into a well-formed data section.

```
data;
set UnknownValues := x y z w v;
set Equations := Eq1 Eq2 Eq3 Eq4 Eq5;
```

The sets are assigned values here. That means, the names of the unknown values and equations are given one-by-one. Note that in the data section, there is **no need for apostrophes**. If we wanted to hard-code a set definition into the model section, we would need apostrophes or quotation marks to denote string constraints.

One of the parameters that requires values to be given is the RHS constants.

```
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

```
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

And now we are ready. The model section has attained its most general form. From now on, the solution of any system of linear equations can be done solely by writing a well-formed data section. This data section may come after the model section in the model file itself, or, more practically, it can be put in a separate file. Typically, each problem instance (in this case, each system of linear equations to be solved) can be implemented in a single data file, containing the data section.

The complete model file and one possible data section are the following. The solution is again exactly the same as before: $x = 2$, $y = 3.5$, $z = -2$, $w = 7$, and $v = 0.5$.

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

However, we see that many of the coefficients in the system of linear equations can be zero. This is actually a kind of default behavior: an equation might only refer to a subset of the variables. If an equation does not refer to a variable, then it still has a zero coefficient due to the modeling logic. But we do not want to provide these zero parameters for all variables each time we write a new equation. Instead, we want to only provide those parameter values that are **different than this default zero**.

This can be achieved by indicating a **default value** for a given parameter in the model section. In this case, the model parameter does not have a hard-coded calculated value, but a given default value instead. If there is a value provided in a data section, that value is used. If no value is provided, then the default value is used. Note that default values can also be given for sets. However, they cannot be given for variables, as variables are determined by the optimization procedure, so it does not make sense to provide default values for them.

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
param Coef: x y z w v :=
Eq1 4 -2 3 . .
Eq2 . . -1 -1 .
Eq3 . 1 1 . .
Eq4 4 -7 . 2 5
Eq5 1 . 2 . 3
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

This is an error because the correct indexing would be `Coef[Eq1,x]`, not `Coef[x,Eq1]`. The latter is not a valid index for parameter `Coef`, because neither $x$ is in the set `Equations` nor Eq1 is in the set `UnknownValues`. The same error message may be reported if we do not use the indices properly in the data section.

This example suggests an important source of error: **indexing must be done properly**. In this case, the out of domain error is raised, and the mistake could be corrected easily. However, the situation can be much worse; for example, if a wrong indexing would actually mean a valid index in the index set. In that case, the error remains unnoticed, and the wrong model is solved. This is especially dangerous if the two indices are from the same set, as they can be switched by mistake. For example, in a directed graph of vertices A, B, and C, the arc AB is different from BA, but both describe an arc and are valid if implemented in GNU MathProg.

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
param Coef: 1 2 3 4 5 :=
1 4 -2 3 . .
2 . . -1 -1 .
3 . 1 1 . .
4 4 -7 . 2 5
5 1 . 2 . 3
;
end;
```

Now, if this is the data section, and it is paired with the wrongly indexed model section we presented before, there are **no out of domain errors**, as all wrong indices are actually valid. So a wrong model is solved now, which has a substantially different result than the original: $4.8$, $-20.6$, $-67.5$, $-10.3$, and $17$. Remember that the original result was $2, 3.5, -2, 7, 0.5$. Conclusion: always pay special care for indexing, use meaningful and unique names even in the data sections, and always validate the result of model solution.

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
param EqConstants: x y z w v RHS :=
Eq1 4 -2 3 . . -5
Eq2 . . -1 -1 . -5
Eq3 . 1 1 . . 1.5
Eq4 4 -7 . 2 5 0
Eq5 1 . 2 . 3 -0.5
;
end;
```

Note that this implementation does not work in one extreme situation: where one of the unknown values is named `'RHS'`, in which case it is interchangeable with the string `'RHS'` denoting the right-hand side column instead of ordinary variables in the system. So, for this model, the usage of the keyword `'RHS'` is forbidden for unknown values in the data section. But this restriction is a fair trade for the more compact data section we got instead.

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
param Coef: x y z w v :=
Eq1 4 -2 3 . .
Eq2 . . -1 -1 .
Eq3 . 1 1 . .
Eq4 4 -7 . 2 5
Eq5 1 . 2 . 3
Eq6 1 1 1 1 1
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

-----

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



# Chapter 5: Production Problem

This chapter explores a **fundamental Linear Programming (LP) problem** in terms of model implementation: the **production problem**. This problem involves determining which products to manufacture in order to achieve the **maximum profit** when resources are limited. It is also referred to as the **product mix problem** or **production planning problem**.

The production problem is one of the oldest problems in **Operations Research**, and numerous tutorials use it as an introduction to mathematical programming (see, for example, [11, 12]). The **diet problem**, which seeks to find the least expensive combination of foods that meets all nutritional requirements, is also presented. A common generalization of these two problems is also shown. The final section includes an overview of **integer programming**, where "packages" of raw materials and products can be bought and sold all at once.

The chapter focuses on how a single model can be extended to incorporate various circumstances one-by-one. We begin with a simple exercise that can even be solved manually and conclude with a very general and complex optimization model.

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

Let's begin formulating the model. The first step is selecting the **decision variables**. The goal of optimization is to determine the values of these variables. Each solution obtained describes a decision on how the plant will be operated. Of course, not all solutions are generally feasible, and the revenues are also usually different. Therefore, we seek the **feasible solution with the highest revenue**.

The decision variables can be read directly from the problem description. The **amounts of each product to be determined** are the decision variables; these must definitely be determined by the optimization. The question is, should there be more variables? If we only know the amounts produced, we can calculate everything relevant in the plant: the exact amounts consumed of each raw material and the total revenue. Therefore, at this point, we do not need any more variables in our optimization model.

The **objective function** is easy to determine. The production amount of each product must be multiplied by its **unit revenue**, and the total revenue is the sum of these products.

What remains are the **constraints** and **variable bounds**. In general, the only requirement is that production can be zero or a positive number, but it definitely **cannot be negative**. So, each variable must be **nonnegative**; this is a **lower bound**. There is no upper bound, as any production amount is considered feasible as long as there is sufficient raw material for it. This brings us to the **only constraint**, which is about **raw material availability**. Based on the amounts produced (which are denoted by the variables), we can easily calculate how much of each raw material is used per product and in total. This total usage must not be greater than the availability of that particular raw material.

We have defined the variables, the objective, constraints, and bounds, so we are ready to implement our model in **GNU MathProg**. First, we will not use indexing and will implement it in the most straightforward way.

The variables denote production amounts. For convention, these are all in the **dollar ($)** currency.

```
var P1, >=0;
var P2, >=0;
var P3, >=0;
```

Constraints are formulated next. For each production amount, it must be multiplied by the coefficient that describes **raw material consumption per product unit**. These must be summed for all three products to obtain the total consumption for a given raw material.

Note how the tabular data of the problem correspond to the implementation of constraints.

```
s.t. Raw_material_A: 200 * P1 +
50 * P2 +
0 * P3 <= 23000;
s.t. Raw_material_B:
25 * P1 + 180 * P2 +
75 * P3 <= 31000;
s.t. Raw_material_C: 3200 * P1 + 1000 * P2 + 4500 * P3 <= 450000;
s.t. Raw_material_D:
1 * P1 +
1 * P2 +
1 * P3 <= 200;
```

Finally, the objective can also be defined based on production amounts. Note that each constraint is within its own unit for the raw material, and the objective is in the **$** unit. From now on, we use units consistently and will not refer to them.

```
maximize Raw_material: 252 * P1 +

89 * P2 +

139 * P3;
```

A `solve` statement can be inserted in the model, after which some additional post-processing work can be done to print the solution. The full code is the following. We print the total revenue (the objective), the production of each product (the variables), and the usage of each raw material. In the usage part, we print both the total amount consumed for production and the amount remaining available.

```
var P1, >=0;
var P2, >=0;
var P3, >=0;
s.t. Raw_material_A: 200 * P1 +
50 * P2 +
0 * P3 <= 23000;
s.t. Raw_material_B:
25 * P1 + 180 * P2 +
75 * P3 <= 31000;
s.t. Raw_material_C: 3200 * P1 + 1000 * P2 + 4500 * P3 <= 450000;
s.t. Raw_material_D:
1 * P1 +
1 * P2 +
1 * P3 <= 200;
maximize Raw_material: 252 * P1 +

89 * P2 +

139 * P3;

solve;
printf "Total Revenue: %g\n", ( 252 * P1 +
printf "Production of P1: %g\n", P1;
printf "Production of P2: %g\n", P2;
printf "Production of P3: %g\n", P3;
printf "Usage of A: %g, remaining: %g\n",

89 * P2 +

139 * P3);

( 200 * P1 +
50 * P2 +
0 * P3),
23000 - ( 200 * P1 +
50 * P2 +
0 * P3);
printf "Usage of B: %g, remaining: %g\n",
( 25 * P1 + 180 * P2 +
75 * P3),
31000 - ( 25 * P1 + 180 * P2 +
75 * P3);
printf "Usage of C: %g, remaining: %g\n",
(3200 * P1 + 1000 * P2 + 4500 * P3),
450000 - (3200 * P1 + 1000 * P2 + 4500 * P3);
printf "Usage of D: %g, remaining: %g\n",
(
1 * P1 +
1 * P2 +
1 * P3),
200
- (
1 * P1 +
1 * P2 +
1 * P3);
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

We interpret the solutions as follows: **$33,389** is the **maximum revenue** that can be obtained. The way to obtain this revenue is to produce **91.34 units of P1**, **94.65 units of P2**, and **14.02 units of P3**. Note that, in this case, it is allowed to produce **fractional amounts** of a product—this can occur in practice, for example, if the products and raw materials are chemicals, fluids, heat, electricity, or other divisible quantities.

Production consumes **all of A, C, and D**, but there is a **surplus of B** that is not used up. Some remaining amounts are reported as extremely small positive numbers. These are actually tiny **numerical errors** from the actual value of zero in the optimal solution because `glpsol` uses floating-point arithmetic, which is not perfect. If this output is inconvenient, we can use the format specifier `%f` instead of `%g`, or alternatively, explicitly round down the numbers to be printed in the model using the built-in `floor()` function.

Another option is to add `--xcheck` as a command-line argument to `glpsol`. This forces the final solution to be recalculated with **exact arithmetic**, eliminating rounding errors.

```
glpsol -m model.mod -d data.dat --xcheck
```

One interesting observation about the solution is that **three of the remaining amounts are zero**. If we varied the problem data and solved the model repeatedly, it would turn out that, from the seven values printed (three production amounts and four remaining amounts), there are almost always **three zeroes**. In general, the number of zeroes is the number of products, and the number of nonzeroes is the number of raw materials. (Exceptions occur in some special cases.) This is a beautiful property of production problems that is better understood by knowing how the solution algorithms (particularly the **simplex method**) work, generally for LP problems. However, we are not focusing on the algorithms here, only the model implementations. Nevertheless, understanding what a good solution looks like is a very valuable skill.

We now have a working implementation for the particular production problem described. However, we know this solution is not very general. If a different production problem is in question, we must understand and **tamper with the code** describing the model logic. Also note that the exact expressions describing the total consumption of each raw material appear **three times**: once in the constraints and twice in the post-processing work. This level of **redundancy** is typically considered bad code design, regardless of the programming language.

Our next task is to create a more general, **indexed model** that requires only a properly formatted data section to solve any production problem.

In the production problem, two sets are relevant: the set of **products** and the set of **raw materials**.

```
set Products;
set Raw_Materials;
```

We can also identify three important **parameters**. One for the production ratios, which is defined for each pair of raw materials and products; we'll call it `Consumption_Rate`. One parameter is for availability. This is defined for each raw material, and we name it `Storage`. The name "storage" captures the logic of how raw materials work from a modeling perspective: they are present in a given amount beforehand, like physically stored material, and no more than this amount can be used for production. Another parameter is the `Revenue`, which is defined for each product.

```
param Storage {r in Raw_Materials}, >=0;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;
```

Notice how **indexing** is used so that each `param` statement refers not just to a single scalar but to a **collection of values** instead. For `Consumption_Rate` and `Revenue`, we also provide a default value of **zero**. This means if we do not provide data, we assume no raw material need or revenue for that particular case.

Also, in GNU MathProg, we can define **bounds and other value restrictions for parameters**. In this case, all three parameters are forced to be **nonnegative** by the `>=0` restriction. This is generally good practice if we do not expect specific values for a given parameter. If a restriction is violated by a value provided for the parameter (for example, in the data section or calculated on the spot), model processing terminates with an error describing the exact situation. It's much easier to notice and correct errors this way than to allow a wrong parameter value in the model, which could lead to an invalid solution. It is typically difficult to debug a model once it can be processed, so it is recommended to explicitly check data as much as possible.

The variables can now be defined. They denote production amounts, and each must be nonnegative.

```
var production {p in Products}, >=0;
```

Finally, all the constraints can be described by one general `s.t.` statement. The logic is as follows: There is a single inequality for each raw material: its **total consumption cannot exceed its availability**. The availability is simply described as a parameter, but the total consumption is obtained by a **summation**. We must sum, for each product, its amount multiplied by the consumption rate of that particular raw material.

$$
\sum_{p \in \text{Products}} \text{Consumption\_Rate}[r,p] \cdot \text{production}[p] \le \text{Storage}[r]
$$

```
s.t. Material_Balance {r in Raw_Materials}:
sum {p in Products} Consumption_Rate[r,p] * production[p]
<= Storage[r];
```

The objective is obtained as a **sum** for all products, where the amounts must be multiplied by the unit revenues.

$$
\text{Maximize Total\_Revenue} = \sum_{p \in \text{Products}} \text{Revenue}[p] \cdot \text{production}[p]
$$

```
maximize Total_Revenue:
sum {p in Products} Revenue[p] * production[p];
```

Finally, we can implement a general post-processing routine to print the total revenue, production amounts, and raw material usages. The full model file is the following.

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
P1
P2
P3 :=
A
200
50
0
B
25
180
75
C 3200 1000 4500
D
1
1
1
;
param Revenue :=
P1 252
P2 89
P3 139
;
end;
```

Although the model is very general and compact, it still contains some **redundancy**. The total consumed amount of each raw material is still represented three times in the code. At least, we do not have to rewrite that code ever again if another problem's data is given; we only have to modify the data section. However, we still want to eliminate this redundancy.

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

The solution should be exactly the same as before again, for the same data file. But now, some of the redundancy has been eliminated from the model section. Unfortunately, the parameter for the total amounts consumed **cannot be used** in the constraints where it appears first. More on that later.

-----

## 5.2 Introducing Limits

Now that we have a working implementation for arbitrary production problems, let's change the problem description itself.

 

**Problem 10.**

Solve the **production problem**, provided that for each **raw material** and each **product**, a **minimum** and **maximum** total **usage** is also given that must be respected by the solution.

The usage of a raw material is the total amount consumed, and the usage of a product is the total amount produced.

These are **additional restrictions** on the production mix in question. Let's see how this affects the model formulation. The problem remains almost the same; just additional solutions must be excluded from the **feasible set**—namely, those for which any newly introduced restriction is violated.

The change only added new restrictions, so the **variables**, the **objective function**, and even the already mentioned **constraints** and **bounds** may remain the same. The new limits shall be implemented by new constraints and/or bounds. We also need to provide new options in the **data sections** where these limits can be given as **parameter** values.

There are four limits altogether.

  * **Upper limit on production amount.** The production amount for any product $p$ appears as the $production[p]$ variable in the model. A constant upper limit for this value can easily be implemented as a **linear constraint**, but an even easier way is to implement it as an **upper bound** of the $production$ variable.
  * **Lower limit on production amount.** The same as for the upper limit. Just note that there is already a non-negativity bound defined for the variables, and defining two lower or two upper bounds on the same variable is forbidden in **GNU MathProg**.
  * **Upper limit on raw material consumption.** The total consumption of each raw material is already represented in the model as an **expression**. Actually, the only constraint in the production problem so far defines an upper limit for this expression as $Storage[r]$ for any raw material $r$. Therefore, there's no need to further define upper bounds. If one wants to give an extra upper limitation for the total consumption of a raw material, it can be done without modifying the **model section**, simply by decreasing the appropriate $Storage$ parameter value in the **data section**.
  * **Lower limit on raw material consumption.** As we noticed before, the expression already appears in a constraint. We need to implement another constraint with exactly the same expression, but expressing a **minimum limit** instead of the maximum.

First, we have to add the extra parameters to describe the limits.


```
param Storage {r in Raw_Materials}, >=0, default 1e100;
param Consumption_Rate {r in Raw_Materials, p in Products}, >=0, default 0;
param Revenue {p in Products}, >=0, default 0;
param Min_Usage {r in Raw_Materials}, >=0, <=Storage[r], default 0;
param Min_Production {p in Products}, >=0, default 0;
param Max_Production {p in Products}, >=Min_Production[p], default 1e100;
```

The new $Min\_Usage$ is for the **minimum** total consumption for each raw material, while parameters $Min\_Production$ and $Max\_Production$ are for the **lower and upper limit** of production for each product. The fourth limit parameter is the original $Storage$, for the **upper limit** of raw material consumption. All these limit parameters now have sensible bounds and default values. Lower limits are defaulted to $0$, while upper limits are defaulted to $10^{100}$, which is a number of a large magnitude that we **expect not to appear** in problem data. Also, the lower limits must **not be larger** than the upper limits. Meanwhile, all limits must be **non-negative**. Remember that these restrictions on parameter values are valuable to **prevent mistakes in the data sections** but we don't expect them to contribute to generating and solving the model if once satisfied. This is in contrast to **variable bounds**, which are part of the model formulation and may affect solutions.

The variables and the objective function remain the same. However, we must add **three additional constraints** to tighten the search space of the model. Each of the four constraints actually corresponds to the four limits mentioned. The $Material\_Balance$ constraint is for the upper limit of total consumption of raw materials; this one was originally there and was left unchanged.

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

-----


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

> Total Revenue: **$32,970$**
> Production of P1: $90$
> Production of P2: $100$
> Production of P3: $10$
> Usage of A: $23,000$, remaining: $-7.27596e-12$
> Usage of B: $21,000$, remaining: $10,000$
> Usage of C: $433,000$, remaining: $17,000$
> Usage of D: $200$, remaining: $0$

This means that **$90$ units of P1, $100$ units of P2, and $10$ units of P3** are produced. We can verify that all the limitations are met. It's interesting to note that all the variables in this solution are **integers**, even though they are not forced to be. This means that if the problem were changed to only consider integer solutions (for example, if the product is an object for which an integer number must be produced), then this solution would also be valid. Moreover, it would also be the **optimal solution**, too, because restricting variables to only attain integer values just makes the model's search space even tighter. So, if a solution is optimal even in the original model—meaning there are no better solutions—then there shouldn't be better solutions in the more restrictive **integer counterpart** either.

Now, our implementation for limits is complete. But we can still improve the model implementation by making it a bit more **readable** and less **redundant**. First, there's a neat feature in **GNU MathProg**: if a **linear expression** can be bounded by both an upper and a lower value, and both of these limits are constants, then they can be defined in a **single constraint** instead of two that contain the same expression twice. Using this feature, we can reduce the number of `s.t.` statements from four to two in our model section, as follows. All other parts of the model, the data, and the solution remain the same.

```
s.t. Material_Balance {r in Raw_Materials}: Min_Usage[r] <=
sum {p in Products} Consumption_Rate[r,p] * production[p]
<= Storage[r];
```

```
s.t. Production_Limits {p in Products}:
Min_Production[p] <= production[p] <= Max_Production[p];
```

There is another thing we can improve, which is actually a **modeling technique** rather than a language feature: we can introduce **auxiliary variables** for linear expressions. The variables, constraints, and the objective function will look like the following:

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

Observe the newly introduced variable $usage$. We intend for this variable to denote the total consumption of a raw material. Therefore, we add the $Usage\_Calc$ constraint to ensure this. We now have that variable throughout the model to denote this value. We also do this for the total revenue, which is denoted by the variable $total\_revenue$, calculated in the $Total\_Revenue\_Calc$ constraint, and then used in the objective function. The objective function is actually the $total\_revenue$ variable itself.

Now, observe that all the expressions we have to limit are actually variables, and all the limits are constants. This means that the constraints for the limits can be converted to **bounds** of these variables, specifically $production$ and $usage$. This way, we effectively got rid of all the previously defined constraints and converted them into bounds, but we needed two more constraints ($Usage\_Calc$ and $Total\_Revenue\_Calc$) to calculate the values of $usage$ and $total\_revenue$.

We might think that the main importance of introducing the new variable lies in the possibility of using bounds instead of `s.t.` statements, which makes our implementation shorter. This is just an example of its usefulness. The key point is that if some expression is used more than once in our model, we can simply introduce a **new variable** for it, define a new constraint so that the variable equals that expression, and then use the variable instead of that expression everywhere.

Think about this: does this operation of adding auxiliary variables change the **search space**? Well, formally, yes. The search space has a different **dimension**. There are more variables, so in a solution to the new problem, we have to decide more values. However, note that feasible solutions of the new model will be in a **one-to-one correspondence** with the original ones. For a solution feasible to the original problem, we can introduce the auxiliary variable with the corresponding value of the expression and get a feasible solution for the extended problem. Conversely, each feasible solution in the extended problem must have its auxiliary variable equal to the expression it is defined for, and thus it can be substituted back into the model to return to a feasible solution of the original model.

In short, the search space formally changes, but the (feasible) solutions for the problem **logically remain the same**.

An important question arises: how does the introduction of auxiliary variables change the course of the algorithms, and **solver performance**? The general answer is that we don't know. There are more variables, so computational performance might be slightly worse, but this is often **negligible**, because the main difficulty of solving a model in practice comes from the complexity of the search space, which is logically unchanged. Of course, if there are magnitudes more auxiliary variables than ordinary variables and constraints themselves, it might cause technical problems. Also note that, in theory, the solver has the right to substitute out auxiliary variables, effectively reverting back to the original problem formulation, but we generally cannot be sure that it does so. The solver doesn't see which of our variables are intended to be "auxiliary." If there is an equation constraint in the model, the solver might use that equation to express one of the variables appearing in it and perform a substitution into that variable, even if we had not considered it auxiliary at all.

In short, the course of the solution algorithm may be different, and the computational performance of the solver might change, but this is usually negligible.

Note also that we have already introduced some new values in the post-processing work so that we didn't have to write the total consumption expression twice. That was done by introducing a new parameter, not a variable, and only worked **after** the `solve` statement because it involved variable values that are only available when the model is already solved. However, now with an auxiliary variable introduced for the total consumption, we can use it **both before and after** the `solve` statement. Therefore, we write this expression down in code only once, and that redundancy finally totally diminished.

The ultimate model code for the limits is the following. Note that the data section and the solution remained the same as before. Also note that we didn't have to introduce new parameters after the `solve` statement, as the auxiliary variables do the work.

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

## 5.3. MAXIMIZING MINIMUM PRODUCTION

In the previous parts, we've seen a complete implementation for the production problem where total raw material consumption and production can be limited by constants for all raw materials and products. Now, let's modify the goal of the optimization to **maximize the minimum production**. The exact definition is the following.






**Problem 12.**

The problem requires us to **maximize the minimum production** amount among all products, while keeping the problem data the same. The minimum production refers to the product for which the least amount is manufactured.

Regardless of whether we start with the simple model or the one with added limitations, this problem only requires us to modify the **objective function**. This means the **feasible solutions** and the search space remain exactly the same as before.

This also makes the **revenue parameter** irrelevant, because we are no longer interested in the total monetary value of the products, but only the production amounts (specifically, the minimum of those amounts).

We have already solved a similar problem in the case of the system of linear equations (see Problem 7 from Section 4.8), where the objective was to minimize the maximum error across all equations. Here, we need to maximize the minimum production. The required **modeling technique** is indeed similar.

The idea is to introduce a new **variable** to represent the minimum of all production amounts. Specifically, this variable will denote a **lower bound** for all the individual production amounts. This lower bound also serves as a lower bound for the minimum of those amounts. If this variable is **maximized**, the optimization process will eventually increase its value as much as possible until it reaches the true minimum of the production amounts.

Using this modeling trick, we can ensure that the final optimal solution found will correspond to the maximal possible value of the minimum production amount. This is a general method that works for any set of linear expressions where either the minimum must be maximized or the maximum must be minimized.

In the implementation, the parameters and post-processing work remain the same, as do the already-existing variables, bounds, and constraints from the extended model (including `Min_Production`, `Max_Production`, and the auxiliary variables for usage and revenue calculation):

```
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;
s.t. Usage_Calc {r in Raw_Materials}:
sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];
s.t. Total_Revenue_Calc: total_revenue =
sum {p in Products} Revenue[p] * production[p];
```

The change is that, instead of the original objective of maximizing total revenue, we set the minimum production as the new objective. This requires introducing a new variable, `min_production`, to denote a lower bound for all production amounts, and a constraint to ensure that the variable is, in fact, a lower bound. Then, this new variable is maximized as the objective function.

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

Note that in our code, `min_production` is the name of the **variable**, and `Minimum_Production` is the name of the **objective function**. In GNU MathProg, we could use both as values. However, be cautious when referring to the objective by its name, because constant terms in the objective are omitted. The reason for this is that constant terms do not affect the selection of the optimal solution, only the value of the objective. Therefore, it is recommended to refer to the objective function value using the variable `min_production` instead.

We can now run our model to solve two problems.

**Example 1: Ignoring Production/Usage Limits**

In the first example, all the limits (`Min_Usage`, `Min_Production`, `Max_Production`) are ignored, except for the `Storage` capacity. Note that, in the data section, we can begin rows with a hash mark (`#`). This turns the row into a **comment**, effectively excluding it from processing. The data section looks like the following:

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
P1
P2
P3 :=
A
200
50
0
B
25
180
75
C 3200 1000 4500
D
1
1
1
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

It turns out that production is **balanced** to the edge to achieve this solution. All resources are distributed evenly, and all three products are produced in an **equal amount**. If we consider the objective, this is not surprising. Why would we produce any product amount above the minimum if it offers no advantage to the objective function, but represents a disadvantage in terms of raw materials consumed?

It looks like raw material **C is the bottleneck** in this problem. We call a factor a **bottleneck** if changing that factor has a visible impact on the final solution while other factors remain the same—for example, the most scarce resource, as in this case. If there were slightly less or more of raw materials A, B, and D, the solution would be the same because all of C is completely used up and distributed evenly among the products. This kind of knowledge can be fundamental in real-world optimization problems because it informs decision-makers that some factors are unnecessary to improve. On the other hand, slightly more or less of C would likely result in slightly more or less production (likely, because there could be other limitations in the model that we do not see). For this reason, raw material **C is the bottleneck** in this particular production problem.

**Example 2: With Constraints** (Excluding $P3 \le 10$)

In the second example, **Problem 11** is used but without the constraint on $P3$. This means all the limitations are now included in the model, except for the restriction that $P3$ is maximized at 10 units. Note that if this constraint were enabled, there would be no question that the optimal solution would be 10 units, as the former solution we already know produces exactly 10 units of $P3$, and there cannot be more.

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

The solution is slightly different in this case. Now, only **P1 and P3 are produced in equal amounts**, both at the minimum production amount of **43.86**. Also, not only C but **D is also totally used up**. Note that a much larger amount of P2 is needed because all 200 units of D must be used up in this problem. This answers a former question: why is it advantageous to produce products above the minimum limit? Because it might help satisfy the minimum production and/or minimum consumption constraints.

Note that the objective in this case is slightly **worse** than that of the first example problem, where the objective was 51.72. This is a natural consequence of differences in the data. In the second example, the data were the same, except that there were **additional constraints** on consumption and production. If a problem is more constrained, we can only get an optimal solution with the **same, or a worse, objective value**.

Generally, if only the objective is changed in a model, the set of **feasible solutions remains the same**, because the objective only guides the selection of the most suitable solution, not which solutions are feasible. In this case, the new objective function involved a new variable, `min_production`, which served as a lower bound and was maximized.

Note that, in theory, the variable `min_production` does not need any lower bound and can even be allowed to be zero or negative. The solution would still be feasible. However, such solutions are not reported because they are not optimal. Therefore, only those feasible solutions are interesting for which `min_production` is not only a valid lower bound on production amounts but is actually **strict**—that is, it equals the minimum production amount.

Among these interesting solutions, `min_production` works just like an **auxiliary variable**. Each optimal solution where `min_production` is a strict bound corresponds to a feasible solution of the original problem where revenues were maximized, and vice versa.

-----

## 5.4 Raw Material Costs and Profit

We have seen an example where only the objective was changed. Now let's look at another example, which is a more natural extension to the problem. From now on, raw materials are no longer considered **"free"**: they must be produced, purchased, stored, etc. In general, they have **costs**. Just as there is a revenue for each product per unit produced, there is now a **cost for each raw material per unit consumed**.


---

**Problem 13.**

Solve the production problem, but now instead of optimizing for revenue, optimize for **profit**. The profit is defined as the difference between the **total revenue** from products and the **total cost** of raw materials consumed for production. The cost for each raw material is proportional to the material consumed and is independent of which product it is used for. A single **unit cost** for each raw material is given.

This is the general description of the problem. We will again use an example for demonstration, which includes costs for raw materials. The other data for the example problem remain the same as before.

-----

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

Again, we want to write a general model and a separate, corresponding data section for the particular example problem. The starting point is the model and data sections we obtained by solving **Problem 11**, where the limits were introduced, as both the model and data sections are almost ready; we only need to implement some modifications.

First, we definitely need a new parameter that describes the costs. Let's call this parameter `Material_Cost`. We can simply add it to the model section. No other data is needed.

Before proceeding, let's observe what happens when material costs are zero. This means our problem is the same as the original, where raw materials were free. This means that the current problem with raw material costs is a **generalization** of the original problem. In other words, the original problem is a **special case** of the current problem where all raw material costs are zero. For this reason, it is sensible to give a **zero default value** to material costs. This makes data files implemented for the original problem compatible with our new model as well.

```
param Material_Cost {r in Raw_Materials}, >=0, default 0;
```

We also know the corresponding data, which can be implemented in the data section. Each raw material has a nonzero cost.

```
param Material_Cost :=
A 1
B 0.07
C 0.013
D 8
;
```

Beyond the data, the only difference in the model is the **objective value**. We could simply change the objective line and our model would be complete. However, for better readability, we will introduce an **auxiliary variable** for the profit and use it instead. The modified part of the model section is the following. Only three lines of code changed: the `profit` variable was introduced, the objective changed, and the `Profit_Calc` constraint was added to ensure that the `profit` variable obtains the corresponding value. We also print it after the `solve` statement.

```
var production {p in Products}, >=Min_Production[p], <=Max_Production[p];
var usage {r in Raw_Materials}, >=Min_Usage[r], <=Storage[r];
var total_revenue;
var profit;
s.t. Usage_Calc {r in Raw_Materials}:
sum {p in Products} Consumption_Rate[r,p] * production[p] = usage[r];
s.t. Total_Revenue_Calc: total_revenue =
sum {p in Products} Revenue[p] * production[p];
s.t. Profit_Calc: profit = total_revenue - sum {r in Raw_Materials} Material_Cost[r] * usage[r];
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

Now let's examine this solution briefly. Logically, the **search space** of the problem did not change: exactly the same solutions are **feasible** in both the original problem (where revenue is maximized) and the current problem (where profit is maximized). This explains the difference in total revenues. In the original problem, the optimal (maximal) total revenue was **$32,970**, achieved by producing 90 units of P1, 100 units of P2, and 10 units of P3. However, when we optimize for **profit** instead, we get a total revenue of **$22,453.87**, which is worse. The profit in this case is much smaller, **$1,577.45**, meaning most of the revenue is diminished by raw material costs. The production is also slightly different: 25.48 units of P1, 164.52 units of P2, and 10 units of P3 are now produced.

Although the revenue is significantly higher for the original solution than for the current one, we can now be certain that the profit would be no more than **$1,577.45** in that case either.

-----

## 5.5 Diet Problem

We have seen several versions of the production problem. Now, a seemingly unrelated problem is considered, which is called the **diet problem** [13, 14], or the **nutrition problem**.

-----



**Problem 15.**

Given a set of **food types** and a set of **nutrients**. Each food consists of a given, fixed ratio of the nutrients.

We aim to arrange a **diet**, which is any combination of the set of food types, in any amounts. However, for each nutrient, there is a **minimum requirement** that the diet must satisfy in order to be healthy. Also, each food has its own proportional **cost**.

**Find the healthy diet with the lowest total cost of food involved.**

After the general problem definition, let's look at a specific example.

-----

**Problem 16.**

Solve the diet problem with the following data. There are five food types, named **F1 to F5**, and four nutrients under focus, named **N1 to N4**. The contents of a unit amount of each food, the unit cost of each food, and the minimum requirement of each nutrient are shown in the following table.

| | **N1** | **N2** | **N3** | **N4** | **Cost (per unit)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **F1** | 30 | 5.2 | 0.2 | 0.0001 | **450** |
| **F2** | 20 | 0 | 0.7 | 0.0001 | **220** |
| **F3** | 25 | 2 | 0.1 | 0.0001 | **675** |
| **F4** | 13 | 3.6 | 0 | 0.0002 | **120** |
| **F5** | 19 | 0.1 | 0 | 0.0009 | **500** |
| **Required** | **2000** | **180** | **30** | **0.04** | |

The diet problem is regarded as one of the first problems that led to the field of **Operations Research**.

Note that the underlying dimensions are slightly different in the diet problem and the production problem. Here we have omitted fictional physical dimensions, but the scale of each nutrient suggests which data belong to a single dimension. In this data table, each column corresponds to a single nutrient and, therefore, has its own unit of measure. The last column shows unit costs.

Usually, when implementing a model, the first things we must decide are: how our **freedom of choice** will be implemented as **decision variables**, how the **search space** can be described by **constraints**, and how the **objective** can be calculated. These steps are essential for deciding whether a mathematical programming approach is even suitable for a real-world problem.

However, we will instead start by defining all the data available in the problem and then proceed with the steps above. This makes defining the variables, constraints, and objectives easier afterward. So, the first part of modeling in GNU MathProg is now defining the **sets and parameters**. These are either calculated on the spot or provided later in a data section at the end of the model file or in separate data file(s).

Two sets appear in the problem: one for **food types** and one for **nutrients**. These sets will be used in indexing expressions.

```
set FoodTypes;
set Nutrients;
```

There are three parameters available. One is for denoting **food costs**, obviously defined for each food type. One parameter is for denoting the **minimum required amount of nutrients**, defined for each nutrient. Finally, one parameter is for the **contents of food**, which can be given by a unit amount for each pair of food type and nutrient. In the particular problem, for example, each unit of F2 contains 20 units of N1, 0.7 units of N3, and 0.0001 units of N4. The default values are all set to zero, and all these parameters are nonnegative by nature.

```
param Food_Cost {f in FoodTypes}, >=0, default 0;
param Content {f in FoodTypes, n in Nutrients}, >=0, default 0;
param Requirement {n in Nutrients}, >=0, default 0;
```

Now that all the data are defined as sets and variables, we must identify our freedom of choice. The **amounts of each food used** are clearly under our decision. If we know these amounts, we can easily calculate the total cost and nutrient contents, so we can determine whether the diet is healthy and, if so, how much it costs. This means we should define a variable denoting **food consumption** for each food type separately, and no more variables are needed in the model.

We introduce a variable named `eaten` to denote the amount of each food included in the diet. This variable is obviously nonnegative and is indexed over the set of food types. We also introduce the auxiliary variable `total_costs` so that it can be printed out more easily. We could define bounds for the auxiliary variable, but it is unnecessary as its value will be exactly calculated by a constraint.

```
var eaten {f in FoodTypes}, >=0;
var total_costs;
```

There is one significant factor in our model that restricts which diets are acceptable: the **total nutritional content**. This translates into a constraint for each nutrient. The total amount contained in the selected diet must be summed up, and this total must be **no less than** the minimal requirement for that particular nutrient.

Additionally, there is another constraint for calculating the auxiliary variable denoting the total food costs.

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

After the `solve` statement, we can again write our own printing code that will show the solution found by the solver. This time, the amount of each food in the diet is shown, as well as the total consumption per nutrient, along with the lower limit. Our model section is now ready.

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

Now we also implement the particular problem mentioned. It is described in a single data section as follows.

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
N1
N2
N3
N4 :=
F1
30 5.2
0.2 0.0001
F2
20
.
0.7 0.0001
F3
25
2
0.1 0.0001
F4
13 3.6
.
0.0002
F5
19 0.1
.
0.0009
;
param Requirement :=
N1 2000
N2 180
N3 30
N4 0.04
;
end;
```

Now we can solve the problem, and the result is the following.

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

The optimal objective is **$29,707.2**. This result literally means that any diet containing at least 2,000 units of N1, 180 units of N2, 30 units of N3, and 0.04 units of N4, and consisting of F1 through F5, would cost at least **$29,707.2**, and there exists a solution to obtain exactly this number.

The optimal solution only uses **F2, F4, and F5**. This means that if F1 and F3 were omitted from the problem data altogether, the optimal solution would be exactly the same. This is because introducing a new food type only **increases the freedom** in the model, leaving any previously feasible solutions as feasible afterward, and potentially introducing new feasible solutions that utilize the newly introduced food type. We can also observe that **N1 is the only nutrient** for which the consumption in the optimal diet is **more than** the minimal amount required, with 2,042.99 units rather than 2,000. For the other three nutrients, there is exactly enough. This suggests that the solution shows a diet that is **balanced to the edge** to meet the minimum requirements while optimizing costs.

-----

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
s.t. Total_Costs_Calc: total_costs = sum {r in Raws} Value[r] * usage[r];
s.t. Total_Revenue_Calc: total_revenue =
sum {p in Products} Value[p] * usage[p];
s.t. Profit_Calc: profit = total_revenue - total_costs;
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
s.t. Total_Costs_Calc: total_costs = sum {r in Raws} Value[r] * usage[r];
s.t. Total_Revenue_Calc: total_revenue =
sum {p in Products} Value[p] * usage[p];
s.t. Profit_Calc: profit = total_revenue - total_costs;
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
A
B
C
D
P1
P2
P3 :=
MakeP1 200
25 3200
1
1
0
0
MakeP2
50 180 1000
1
0
1
0
MakeP3
0
75 4500
1
0
0
1
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
F1 F2 F3 F4 F5 N1
N2
N3
N4 :=
EatF1
1
0
0
0
0
30 5.2 0.2 0.0001
EatF2
0
1
0
0
0
20
.
0.7 0.0001
EatF3
0
0
1
0
0
25
2
0.1 0.0001
EatF4
0
0
0
1
0
13 3.6
. 0.0002
EatF5
0
0
0
0
1
19 0.1
. 0.0009
;
end;
```

The solution is again exactly the same as for the original diet problem, which is an optimal cost of **$29,707.2**, with food consumption amounts of 42.86 of F2, 49.20 of F4, and 28.75 of F5. Note that in this case, the objective reported by the solver is **-$29,707.2**, because the profit is determined solely by the food costs (revenue is zero, so profit = $0 - \text{Total Costs}$).

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
A      B      C      D    P1  P2  P3 :=
MakeP1 200    25     3200   1    1   0   0
MakeP2 50     180    1000   1    0   1   0
MakeP3 0      75     4500   1    0   0   1
Comp1  240    200    4400   2    1   1   0
Comp2  51     250    5400   2    0   1   1
;

end;
```

-----

**Production Results**

| Metric | Value |
| :--- | :--- |
| **Total Costs** | $30,495.00$ |
| **Total Revenue** | $32,460.62$ |
| **Profit** | $1,965.62$ |

-----

**Recipe Volumes**

| Recipe | Volume |
| :--- | :--- |
| Volume of recipe **MakeP1** | 0 |
| Volume of recipe **MakeP2** | 6.25 |
| Volume of recipe **MakeP3** | 0 |
| Volume of recipe **Comp1** | 86.875 |
| Volume of recipe **Comp2** | 10 |

-----

**Raw Material Usage**

| Raw Material | Consumption |
| :--- | :--- |
| Consumption of raw **A** | $21,672.5$ |
| Consumption of raw **B** | $21,000$ |
| Consumption of raw **C** | $442,500$ |
| Consumption of raw **D** | $200$ |

-----

**Product Production**

| Product | Production |
| :--- | :--- |
| Production of product **P1** | $86.875$ |
| Production of product **P2** | $103.125$ |
| Production of product **P3** | $10$ |

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

s.t. Profit_Calc: profit = total_revenue - total_costs;
```

**Order Cash Flow Logic:**

The sign of `Order_Cash_Flow` is used to represent cost (positive) or revenue (negative).

1.  **If payment is due BEFORE production (`Order_Pay_Before[o]` is true, or 1):** The cash flow is added to `total_costs`.

      * If the order is an **expense** ($\text{Order\_Cash\_Flow} > 0$), $\text{Cost}$ increases.
      * If the order is an **income** ($\text{Order\_Cash\_Flow} < 0$), $\text{Cost}$ decreases (increases available funds).
      * The term is $\sum \text{Order\_Cash\_Flow}[o] \times \text{ordcnt}[o]$.

2.  **If payment is due AFTER production (`!Order\_Pay\_Before[o]` is true, or 0):** The cash flow is subtracted from `total_revenue`.

      * If the order is an **income** ($\text{Order\_Cash\_Flow} < 0$), subtracting a negative number increases $\text{Revenue}$.
      * If the order is an **expense** ($\text{Order\_Cash\_Flow} > 0$), $\text{Revenue}$ decreases (treated as a negative revenue).
      * The term is $-\sum \text{Order\_Cash\_Flow}[o] \times \text{ordcnt}[o]$.

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
MakeP1 200    25     3200   1    1   0   0
MakeP2 50     180    1000   1    0   1   0
MakeP3 0      75     4500   1    0   0   1
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
A
B
C
D
P1
P2
P3 :=
MakeP1 200
25 3200
1
1
0
0
MakeP2
50 180 1000
1
0
1
0
MakeP3
0
75 4500
1
0
0
1
Comp1
240 200 4400
2
1
1
0
Comp2
51 250 5400
2
0
1
1
;
param Initial_Funds := 35000;
set Orders := Ord1 Ord2 Ord3;
param Order_Material_Flow:
A
B
C
D
P1
P2
P3 :=
Ord1 20000 10000 300000 500
40
80
0
Ord2 15000 10000 400000 500
45
70
6
Ord3
190
20
3000
0
1
0
0
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




# Chapter 6: Transportation Problem 

We'll introduce another common **optimization problem**, known as the **transportation problem**.

Given a set of **supply points** with a known amount of available resources and a set of **demand points** with a known resource requirement, the objective is to organize the transportation of the resource between these supplies and demands.

It's worth noting that this problem has very fast algorithmic solution techniques [15]. However, we're primarily focused on the **modeling techniques**. As we'll see, an LP (Linear Programming) or MILP (Mixed-Integer Linear Programming) formulation can be easily adjusted if the problem definition changes. This can be significantly harder to do with specific solution algorithms.

This chapter also presents some additional capabilities of **GNU MathProg**. The goal is to demonstrate how to handle different cost functions while keeping the model within the class of LP and sometimes MILP models. Finally, we'll add an extra layer of transportation to the problem to show how separately modeled parts of a system can be incorporated into a single, cohesive model.

-----

## 6.1 Basic Transportation Problem

The basic transportation problem can be described generally as follows:

**Problem 21.**

Given a **single material**, a set of **supply points**, and a set of **demand points**. Each supply point has a nonnegative **availability**, and each demand point has a nonnegative **requirement** for the material. The material can be transported from any supply point to any demand point, in any amount. The **unit cost** for transportation is known for each specific pair. The task is to find the transportation amounts such that the following conditions are met:

  * **Available amounts** at supply points are not exceeded.
  * **Required amounts** at demand nodes are satisfied.
  * The **total transportation cost** is minimal.

For simplicity, we'll simply call the supply points and demand points **supplies** and **demands**. Note that the term "material" can be replaced by any other resource, such as electricity, water, funds, or manpower.

The network connecting the supplies and demands can be represented by a **directed graph** (see Figure 1), where the nodes are the supplies and demands, and the arcs represent the connections between them. The direction of an arc shows the direction of material flow, which always goes from a supply to a demand.

**Figure 1:** Graph representing the original transportation problem.

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

Now, we formulate the constraints for the model. Not all possible nonnegative real values for the transportation amounts will result in a feasible solution in reality, because there are two restrictions we must account for.

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
  * If $S > D$, the problem is **feasible**. There can (and will) be leftover material at the supplies, or excess deliveries at the demands, or both.

Without actually solving the model, we can check the problem data to ensure it's feasible. This check statement is ideally placed after the parameters but before the variable and constraint definitions. This check is useful because it provides a dedicated error message referring to the `check` statement if a problem is infeasible.

```glp
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
```

Note that in our current model formulation, we allow both leftover materials at supplies (via the $\le$ constraint) and excess deliveries at demands (via the $\ge$ constraint). If these were not allowed, the corresponding two constraints would have to be specified as equations ($\text{=}$) instead. It's worth pointing out that if the transport costs are positive, there's no benefit to transporting more than the demand requires, so the optimization process will eliminate that case anyway.

In some formulations of the transportation problem, $S = D$ is an assumption. Note that in a problem where $S > D$, we can introduce a **dummy demand** with a requirement of $S - D$ and zero transportation costs from all supplies. The purpose of this dummy demand is to receive all the leftover amounts. Therefore, this new problem is equivalent to the original one but has equal total supplies and demands. In conclusion, the $S > D$ case is essentially no more general than the $S = D$ case.

The model description for Problem 21, the transportation problem, is now complete. The model section can be enhanced with `printf` statements to display the result once it's found. We'll only show transportation amounts that are greater than zero. The full model section is as follows:

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
set Demands := D1 D2 D3 D4 D5 D6;
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
D1 D2 D3 D4 D5 D6 :=
S1
5 10
3
9
5 12
S2
1
2
6
1
2
6
S3
6
5
1
6
4
8
S4
9 10
6
8
9
7
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

This representation better clarifies the elements of the model. The **decisions** are represented by the inner cells, while the **constraints** are represented by the rightmost column and the bottom row. Each supply constraint dictates that the sum in that row must be at most the number on the right. Each demand constraint dictates that the sum in that column must be at least the number at the bottom. Since the total supply and total demand are equal in this example, all constraints can only hold true as an **equation** ($\text{=}$). This is exactly the case throughout the table.

Examining the results, we can see that the optimal solution attempts to use the **cheapest unit costs** whenever possible, but not always. For instance, the transport from **S4 to D4** is chosen despite not being the absolute cheapest method, either from supply S4 or to demand D4. However, it proves to be a good choice because the remaining transportation can then be done more cheaply. Note that based on this single run of the model, we cannot be certain that this is the only optimal solution.

There are many other examples of the transportation problem publicly available; see, for example, [16].

-----

## 6.2 Connections as an Index Set

Based on the complete solution presented in Section 6.1, we will now slightly enhance the implementation. As mentioned previously, in GNU MathProg, we can introduce additional parameters and sets to simplify the model formulation. These can either be defined on the spot, read from a separate data section outside the model, or allow both as a default value.

Notice that the indexing expression `s in Supplies, d in Demands` appears in four different contexts:

  * In the `Cost` parameter, as it is defined for all such pairs.
  * In the `tran` variable, as it is defined for all such pairs.
  * In the objective function, as it is a sum over all such pairs.
  * In the post-processing work, because transport amounts are printed for all such pairs. (In this case, there is a filter that only allows nonzero amounts to be reported.)

It would be a serious error to make a mistake in this indexing—for example, by switching the order of `Supplies` and `Demands`, which would result in a modeling error. To avoid such errors and slightly reduce redundancy in the model formulation, we can introduce a two-dimensional set of these pairs to be used later. Each supply and each demand are considered to be part of a **connection**. Thus, the transportation problem involves deciding on transportation amounts for each connection. The set `Connections` can be introduced as follows:

```glp
set Connections := setof {s in Supplies, d in Demands} (s,d);
```

We are using a new GNU MathProg operator here: `setof`. This is a general method for defining sets based on data previously defined in the model section. The `setof` operator is followed by an indexing expression, then by a simple expression. The resulting set is formed by evaluating the final expression for all possible indices in the indexing expression. It's similar to `sum`, but instead of adding elements up, it forms a set of them. Note that the indexing expression in `setof` can be filtered, which gives us fine control over the set being defined. Since the result is a set, duplicates are removed, and the result can also be empty if everything is filtered out; however, neither of these is the case here.

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

To illustrate how explicitly introducing an index set like `Connections` in the model can be beneficial, consider the following new problem...

 

 

**Problem 23.**

Solve **Problem 22**, the original example transportation problem, with one modification: only those connections are allowed for transportation whose unit costs are **no greater than 7**.

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

With this filter, we only include those connections in the **`Connections`** set that are allowed. Therefore, without modifying other parts of the model, the exclusion is implemented—the indexing expressions `(s,d)` in `Connections` just iterate over a **smaller set** in the background.

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

The point is that an $n$-tuple index in an indexing expression can have **constant coordinates** as long as it contains **at least one new, free symbol** for a coordinate. In the GNU MathProg language documentation, an index symbol that is introduced by an indexing expression is called a **dummy index**. Dummy indices are **freely selected** by the indexing expression in all possible ways and can be used as constants afterward in the expression. Here, $s$ is a dummy index from the indexing of the constraint, whereas $d$ is a dummy index from the indexing expression of the sum operator, but **both** can be referred to in the operand of the sum, which is `tran[s,d]` now.

The model contains another constraint for the demands; this must also be updated similarly, by replacing `s in Supplies` with `(s,d) in Connections`, and our model section for the new problem is ready.

Solving it with the original problem data reports an optimal solution of **2790**, slightly worse than the original solution of **2700**. This isn't surprising, as the original solution used a unit cost of **8**. By excluding it, it's theoretically possible to obtain the same objective another way, but that's not the case here. The moral of the story is that, contrary to first thought, excluding connections that are too expensive can be a **disadvantage** in the transportation problem.

Note that although the transportation problem has feasible (and optimal) solutions if the total supplies are **no less** than the total demands, this is **no longer guaranteed** if certain connections are prohibited.

-----

## 6.3. Increasing Unit Costs

So far, a **linear transportation cost** was assumed at each connection. The amount is simply multiplied by a constant to obtain the cost. The relationship between the total amount transported and the total cost incurred can be schematically represented as in Figure 2. The red line represents the calculated total costs, but the area above that curve can be regarded as "feasible" too.  The logic behind this is that we're allowed to pay more than needed; it just doesn't make sense.

The term **proportional cost** is also widely used. Proportional cost means a cost or its component for which the ratio of total amounts and costs is a **parameter constant**.

In practice, the total cost or effort to be paid for some resource is **not always proportional** to the amount of resource actually used. A few common examples are shown in this and the following sections, which can be modeled as a **Linear Program (LP)** or at least as a **Mixed-Integer Linear Program (MILP)** model.

The first example is when the unit cost is a constant, but after some threshold amount is reached, it **increases** to a higher constant value. This is common in practice, and the phenomenon is called the **law of diminishing returns**. This means that if we spend an additional unit for costs, we get **less and less return**. This is equivalent to having a unit price that **increases** with the total amount already obtained.

 

**Problem 24.**

Solve Problem 21, the **transportation problem**, with one modification: there are two **unit costs** for transportation—one for amounts **below** a given **threshold** and a higher unit cost for **surplus amounts above** that threshold.

-----

**Problem 25.**

Solve Problem 22, the original example transportation problem, with one modification: the given unit costs are only for transportation amounts **below 100 units**. Above that limit, costs are **increased by 25%** per material unit transported.

Schematically, the **cost function** (in contrast with the simple linear case) can be represented as in **Figure 3**. Again, the region above the red curve denoting the **total costs** can be termed as **feasible** because we can pay more if we want; it's just not advantageous and, therefore, will never happen.

In the example problem, all thresholds and increased costs are **uniform** across the connections. Note that this isn't necessarily always the case. In other problem definitions, each connection may have **unique thresholds**, basic, and increased unit costs.

The first step is to define the **data** in the model needed to calculate the alternative cost function. Two parameters are introduced: **`CostThreshold`** is the amount over which the unit costs increase, and **`CostIncPercent`** denotes the rate of increase, in **percent**. Note that the increase must be positive.

```
param CostThreshold, >=0;
param CostIncPercent, >0;
```

In the particular example, Problem 25, to be solved, the following values can be given in the **data** section.

```
param CostThreshold := 100;
param CostIncPercent := 25;
```

We introduce another parameter, **`CostOverThreshold`**, which calculates the increased unit cost using the following formula. Note that the original unit cost is `Cost[s,d]`.

```
param CostOverThreshold {(s,d) in Connections} :=
Cost[s,d] * (1 + CostIncPercent / 100);
```

At this point, we have all the required data defined in the model. The question is how we can **implement the correct calculation of total costs**, regardless of whether the amount is below or above the threshold.

First, we can simply introduce two variables, **`tranBase`** for the amounts below and **`tranOver`** for the amounts above the threshold.

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

Instead of using `tran` in the objective, we can refer to the **`tranBase` and `tranOver` parts separately** and multiply these amounts by their corresponding unit costs, which are `Cost` and `CostOverThreshold`.

```
minimize Total_Costs: sum {(s,d) in Connections}
(tranBase[s,d] * Cost[s,d] + tranOver[s,d] * CostOverThreshold[s,d]);
```

Our model is ready, but consider one thing. Now, the `tranBase` and `tranOver` amounts can be set **freely**. For example, if the threshold is **100**, then transporting **130 units** in total can be done as $\text{tranBase}=100$ and $\text{tranOver}=30$, but also, for example, as $\text{tranBase}=50$ and $\text{tranOver}=80$. In the latter case, the total cost is not calculated correctly in the objective, but it is **still allowed by the constraints**.

But the model still works because the unit cost above the threshold is **strictly higher** than the cost below it. Therefore, the optimal solution would **not attempt** transporting any amounts over the threshold unless all possible amount is transported below it (i.e., $\text{tranBase}=100$ in the example). Spending more is allowed as **feasible solutions** in the model, but these cases are **eliminated by the optimization procedure**. Consequently, in the optimal solution, there is either **zero amount above the threshold**, or the **full amount below it**, for each connection. The costs are calculated correctly in both scenarios.

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

The previous **Section 6.3** deals with the case of **increased unit costs**, but what happens when the unit costs do not increase, but **decrease above the threshold**?

The case where larger amounts provide **lower unit prices** is called the **economy of scale**. This is also common in practice. In production environments, if more products are processed, the same investment and/or operating costs can be **shared** among more products. Therefore, the **cost per product decreases**, making production in larger volumes **cost-efficient**. In trade, it is possible to get a **discount** if we purchase in a larger volume.

Here, the simplest case of **economy of scale** is presented, where unit costs simply decrease above a threshold. As usual, we provide a general problem definition and an example problem.



**Problem 26.**

Solve Problem 21, the **transportation problem**, with one modification: there are two **unit costs** for transportation—one for amounts **below** a given **threshold** and a **lower** unit cost for **surplus amounts above** that threshold.

-----

**Problem 27.**

Solve Problem 22, the original example transportation problem, with one modification: the given unit costs are only for transportation amounts **below 100 units**. Above that limit, costs are **decreased by 25%** per amount transported.

Note that the only difference between this problem and the previous one is that the unit costs above the threshold are now **lower**, not higher. Even the threshold of 100 and the rate of 25% remain the same. Therefore, it is tempting to address this problem by only slightly modifying our code to calculate with decreasing costs instead. The parameter `CostIncPercent` is renamed to **`CostDecPercent`**, and the `CostOverThreshold` is calculated accordingly.

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

The optimal solution is **2,025**, which is much better than the original 2,700. There is nothing wrong with this so far, because the costs have decreased. But the details show that there are **zero transportation amounts below the threshold** ($\text{tranBase}=0$), meaning the total amount is being transported at the lower price (using $\text{tranOver}$) for amounts above the threshold. This is clearly **not allowed**, as we can only use the lower unit costs *after* we have filled the amounts below the threshold first, paying the higher unit cost for the base amount.

In the case where the cost above the threshold was **higher**, the model worked perfectly. Now, when the cost above the threshold is **lower**, the model is incorrect. What causes this difference?

  * If the unit costs **increase** above the threshold, the amounts below the threshold ($\text{tranBase}$) are filled first, and then we can optionally transport additional amounts above the threshold ($\text{tranOver}$). We (and the model) are *allowed* to transport above the threshold first, but it doesn't provide any benefit. Therefore, these non-optimal approaches are **ruled out by the optimization procedure**.
  * If the unit costs **decrease** above the threshold, however, the optimization **prefers using the amounts above the threshold** ($\text{tranOver}$) because of the lower cost. However, this lower cost is not a "free option," but a "**right**" that must be earned: we can only use the lower unit cost if we have **filled the amounts below the threshold first**. This is **not enforced by the constraints**, and therefore the reported optimal solution is **infeasible in reality**.

To better understand the difference, observe the slightly modified schematic representation of the economy of scale (see **Figure 4**). One might argue that the only difference is that the curve is going downward, not upward, but observe the **feasible region**.

One property of **Linear Programming (LP)** problems is that their search space is always **convex**. This means if we have two feasible solutions, and we take a **convex combination** of these, the result is also a feasible solution. For example, if $x_1 = 3, y_1 = 1$ is one feasible solution, and $x_2 = 7, y_2 = 9$ is another, let's obtain a convex combination of these with weights $\frac{3}{4}$ and $\frac{1}{4}$. We get $x_3 = \frac{3}{4} x_1 + \frac{1}{4} x_2 = 4$ and $y_3 = \frac{3}{4} y_1 + \frac{1}{4} y_2 = 4$, which is guaranteed to be also feasible. If we investigate what general constraints are allowed in LP models, the convexity of the feasible region can be easily verified.

However, if we look at the schematic representation in **Figure 4**, the feasible region is **not convex**. Moreover, we cannot make it convex by cutting parts from it. The reason is that we must allow feasibility on both of the two red line segments, but their **convex combinations fall into the infeasible region** that must be prohibited by model constraints. We can see why this wasn't a problem in the case of increasing unit costs: because the convex combinations of the two red line segments fell into the **feasible region**—those cases didn't make sense in reality, but the model still included them, and overall the problem could be perfectly modeled by LP.

Since the feasible region is clearly not convex, this suggests that the **economy of scale cannot be modeled by LP**. However, we can model it by adding **integer variables**, making the model a **Mixed-Integer Linear Program (MILP)**. Our goal is to ensure that the amounts below the threshold, denoted by $\text{tranBase}$, are **fully utilized** whenever any amounts are transported above the threshold, denoted by $\text{tranOver}$.

For each connection, we introduce a **binary variable**, $\text{isOver}$.

```
var isOver {(s,d) in Connections}, binary;
```

The meaning of $\text{isOver}$ is whether we are **entitled** (= 1) or not (= 0) to transport for the lower unit cost, for amounts above the threshold. This binary variable introduces a **discrete nature** to the problem, and now the search space is **not convex** because no fractional values are allowed for $\text{isOver}$ between 0 and 1. Depending on the value $\text{isOver}$ takes, there are specific circumstances required:

  * If $\text{isOver}=0$, then we **cannot** use the lower cost, hence the amounts above the threshold ($\text{tranOver}$) **must be zero**.
  * If $\text{isOver}=1$, then we **must** earn the right to use the lower costs, hence the amounts below the threshold ($\text{tranBase}$) **must be maximal**, i.e., equal to the threshold amount ($\text{CostThreshold}$).

**The Big-M Constraint Technique**

It's a common problem in mathematical programming that we have an ordinary linear constraint, like $A \ge B$, but we want this constraint to be **active if and only if a certain condition is met**. The condition is often represented by the value of a binary variable $x$. If $x = 1$, then constraint $A \ge B$ must hold. However, if $x = 0$, there are no restrictions on $A$ or $B$.

The modeling technique used is called the **big-M constraint**. The first step is to arrange the linear constraint into the form $B - A \le 0$, then find a **positive upper bound** for $B - A$. This upper bound ($\mathbf{M}$) must be large enough to include all possible values for all model variables appearing in the expression $B - A$. In practice, often a very large number, like $M = 1,000,000$, is selected as an upper bound, which is magnitudes larger than any sensible solution for the problem, and is sufficient. This is the so-called **big-M value**.

Then, include the following constraint in the model formulation:

$$B - A \le M \cdot (1 - x)$$

Now, let's investigate what this constraint does in the model. Because $x$ is an integer variable, there are two cases:

1.  If **$x = 1$**, then the constraint reduces to $B - A \le 0$, which is exactly what we wanted to achieve when $x = 1$.
2.  If **$x = 0$**, the constraint reduces to $B - A \le M$. Remember that $M$ is magnitudes larger than any possible, sensible values of $B - A$. Therefore, the constraint becomes **redundant**, as it does not impose further restrictions on model variables—again, exactly what we wanted for $x = 0$.

If the linear constraint is an **equation**, like $A = B$, then we can express it as two inequalities ($A \ge B$ and $A \le B$) and implement a big-M constraint for each. If the condition is not $x = 1$ but $x = 0$ instead, then we can simply replace $(1 - x)$ with $x$ in the model formulation, as the negation of any binary value $x$ is $(1 - x)$.

This is a very general technique that allows for the **conditional inclusion of linear constraints** in MILP models, provided that their condition can be expressed as a binary variable (or any other linear expression that results in a value that can only be 0 or 1, but nothing in between).

One might ask: if $M$ is only required to be large enough, what is the most suitable $M$ to be given? From an algorithmic point of view, the best choice is usually the **lowest possible $M$**. Be careful, though, if $M$ is too small, the constraint is not redundant when the condition is not met, and we risk excluding valuable solutions. (It might be okay to exclude feasible solutions, and even optimal ones, provided that at least one optimal solution remains.) Too large $M$ values may also result in **numerical errors** in the solution procedure.

**Implementing the Economy of Scale Constraints**

Now that the general technique of big-M constraints is introduced, let's head back to the economy of scale and implement the required constraints. There are two conditional constraints to implement:

1.  If $\text{isOver}=0$, then $\text{tranOver}=0$ must hold.
2.  If $\text{isOver}=1$, then $\text{tranBase}=\text{CostThreshold}$ must hold.

The first constraint can be formulated as follows. We define the big-M parameter as the sum of all available supplies, ensuring it is a safe upper bound for any single transportation amount.

```
param M := sum {s in Supplies} Available[s];
s.t. Zero_Over_Threshold_if_Threshold_Not_Chosen {(s,d) in Connections}:
tranOver[s,d] <= M * isOver[s,d];
```

Note that when $\text{isOver}[s,d]=0$, then $\text{tranOver}[s,d] \le 0$ is enforced, and because it is a nonnegative variable, it must be zero. The value $M$ must be selected to be larger than any sensible value of $\text{tranOver}[s,d]$. One easy possibility is to add up all total supplies in the problem. Clearly, no single transportation amount can be larger than this $M$; we introduced this value as a parameter. We could provide smaller values for each $\text{tranOver}[s,d]$ if we wanted, but a single $M$ will suffice.

The second constraint can be formulated as follows.

```
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
tranBase[s,d] >= CostThreshold - M * (1 - isOver[s,d]);
```

  * If $\text{isOver}[s,d]=1$, then $\text{tranBase}[s,d] \ge \text{CostThreshold}$ is enforced, and because parameter $\text{CostThreshold}$ is also an upper bound for $\text{tranBase}[s,d]$, they will be equal ($\text{tranBase}[s,d]=\text{CostThreshold}$).
  * If $\text{isOver}[s,d]=0$, then the constraint is redundant, because the right-hand side, $\text{CostThreshold} - M$ is a negative number and $\text{tranBase}[s,d]$ is a nonnegative variable.

However, we can provide a **more clever big-M** for this constraint. The only requirement is that $\text{CostThreshold} - M$ cannot be positive; otherwise, $\text{tranBase}[s,d]=0$ would be excluded from the search space entirely, which is unacceptable. But the big-M in this constraint can be set as low as $\mathbf{CostThreshold}$, in which case $\text{CostThreshold} - M = 0$, and the constraint is still redundant when $\text{isOver}[s,d]=0$. For this particular big-M, the whole constraint can be rearranged into a more readable form, as follows:

```
s.t. Full_Below_Threshold_if_Threshold_Chosen {(s,d) in Connections}:
tranBase[s,d] >= CostThreshold * isOver[s,d];
```

We can see that if $\text{isOver}[s,d]=1$, then $\text{tranBase}[s,d] \ge \text{CostThreshold}$ is enforced, but if $\text{isOver}[s,d]=0$, then the constraint is equivalent to $\text{tranBase}[s,d] \ge 0$, which is redundant (since $\text{tranBase}$ is a nonnegative variable).

In conclusion, we added the variable $\text{isOver}$ and these two constraints to the previous model for increasing cost rates, and now our model for the transportation problem with **economy of scale** is ready.

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

Now, the optimal solution is **2,625**, which is still better than the original 2,700, but not significantly. We can observe that each time a lower cost is used (i.e., $\text{tranOver}>0$), the **full threshold of 100 is first reached** ($\text{tranBase}=100$). Unlike the case for the increasing unit costs in Section 6.3, the reduced costs above the threshold now only affect the objective through pricing, and the optimal solution remains the same in terms of the transported amounts.

Remember that the model contains **binary variables**, making it an **MILP**, instead of a pure LP model. If the number of binary variables in an MILP is large, the computational time required for the final solution may increase dramatically. This is not the case here only because the resulting MILP model, with its 24 binary variables, is still considered **small**.

-----

## 6.5 Fixed Costs

Different scenarios for unit costs and changes were considered. These kinds of costs were all **proportional costs** because the calculation formula was always based on the amount in question, which was multiplied by some constant. In some cases, not only proportional costs, but **fixed costs** may also be present.



**Problem 28.**

Solve Problem 21, the transportation problem, with the following modification: for each connection, there is a **fixed cost** to be paid once for **establishing it**, in order to use that connection to transport materials.

The term **fixed cost** means that its value does not depend on the actual amounts in question. We only have to pay the fixed cost once to utilize a feature. In this example, the feature is transportation through each connection. We may choose **not to establish a connection**, but then we cannot transport anything between that particular supply and demand point.

The example problem to be solved here is the following.

-----

**Problem 29.**

Solve Problem 28, the transportation problem with fixed costs, using data from the original example **Problem 22**, and the following fixed establishment costs per connection.

| | **D1** | **D2** | **D3** | **D4** | **D5** | **D6** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **S1** | 50 | 50 | 80 | 50 | 200 | 50 |
| **S2** | 200 | 50 | 50 | 50 | 200 | 50 |
| **S3** | 50 | 200 | 200 | 50 | 50 | 50 |
| **S4** | 50 | 50 | 50 | 200 | 200 | 200 |

The starting point for implementing our model is the general implementation from **Section 6.2** where all connections were present. We add a new parameter, **`FixedCost`**, for the establishment costs per connection. The matrix in Problem 29 can then be implemented in the data section to provide values for `FixedCost`.

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

If we observe the schematic representation of the fixed cost (**Figure 5**), we can see that the curve is again **not convex**, as in the case of the economy of scale.  The non-convex nature comes from the single point where the total amount and the total cost are zero, a single point which cannot be directly connected to the horizontal line describing the fixed cost for any amounts above zero without intersecting the infeasible region.

As in the case of the economy of scale, we need a **binary decision variable** to distinguish the two cases. Here, **`tranUsed`** equals one if we choose to establish the connection and are able to send any positive amount of materials over it. If `tranUsed` is zero, then transportation on that particular connection **must also be zero**.

```
var tranUsed {(s,d) in Connections}, binary;
```

Two things must be enforced regarding the fixed cost and the `tranUsed` variable. The first is that if we **do not establish the connection** ($\text{tranUsed}=0$), then there must be **no amount transported** there ($\text{tran}=0$). This can be done with a single **big-M constraint**.

```
param M := sum {s in Supplies} Available[s];
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= M * tranUsed[s,d];
```

The coefficient $M$ must be large in order not to exclude legitimate solutions from the search space. Precisely, it must be at least the largest possible value of $\text{tran}[s,d]$ in the optimal solution to be found. The total of all available supplies, denoted by $M$, is a single valid candidate for all big-M constraints, for any supply and demand pair. However, if we want **stricter constraints** that might result in better solver running times, we can provide a particular value for each supply and demand, which is the **minimum of the available amount at the supply and the required amount at the demand**. There cannot be more traffic between the two points than this minimum.

```
s.t. Zero_Transport_If_Fix_Cost_Not_Paid {(s,d) in Connections}:
tran[s,d] <= min(Available[s],Required[d]) * tranUsed[s,d];
```

The second thing to implement is the inclusion of the fixed establishment cost into the **objective function**.

```
minimize Total_Costs: sum {(s,d) in Connections}
(tran[s,d] * Cost[s,d] + tranUsed[s,d] * FixedCost[s,d]);
```

Our implementation is ready. The variable $\text{tranUsed}[s,d]$ is either zero, in which case there is no fixed cost and no transportation over that connection, or $\text{tranUsed}[s,d]$ is one, the cost is paid, and there can be a positive transportation amount over that connection. Simultaneously zero transportation while still establishing the connection ($\text{tranUsed}[s,d]=1$ and $\text{tran}[s,d]=0$) is allowed as a feasible solution in the model, but the optimization procedure rules these cases out. The full model section is the following.

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

The original **Problem 22** with zero fixed costs and the new **Problem 29** mentioned here are both solved by the model. The original optimal solution is **2,700**, and this is reproduced by the model with fixed costs if these fixed costs are simply zero. If nonzero fixed costs are present, the following output is reported.

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

The objective is **3,640**. The connections used are **not the same** in the two cases (zero fixed costs vs. the fixed costs from Problem 29). The total establishment cost paid is **850**, which is smaller than the increment of 940 in the objective ($3,640 - 2,700 = 940$). This is natural, because not only is the extra fixed cost paid, but the new transportation solution obtained is also **not necessarily optimal** according to the original, pure unit-cost objective anymore.

-----

## 6.6 Flexible Demands

Several transportation cost functions were introduced, including increasing, decreasing proportional, and fixed costs. One additional example is mentioned now, but in a slightly different context.

The common property of transportation costs was that total cost **increased** (or remained constant) as the total transported amount increased. But what happens when the curve is **not monotonically increasing**? Since this is not very practical for transportation costs, we will instead demonstrate it through the **demands**. So far, the required amount at each demand point was a **strict constraint**. This means that any solutions for the problem in which demands are not met are **infeasible** and are eliminated from the search. All constraints so far were strict.

In some cases, constraints are **soft constraints** instead. This means we are interested in solutions that **violate them**. In that case, the **extent of the violation** must be minimized, which becomes another objective of the optimization procedure. Considering multiple objectives falls under the field of **goal programming** [17], and is not covered here. However, there are techniques to **merge different objective functions into a single one**, resulting in an LP/MILP model again. One technique is the usage of **penalties**, which are terms added to the objective function and are proportional to the extent a constraint is violated. Penalties are practical: failing to meet a desired goal can sometimes be measured or estimated as **costs**, which can be added to the objective if it is profit maximization or cost minimization.

In this section, the starting point is the original transportation problem again, and it is expanded with **flexible demands**.



**Problem 30.**

Solve Problem 21, the transportation problem with the addition of **flexible demands**. For each demand point, we do not require the exact requirement to be served. Instead, a **penalty** is introduced into the objective which is **proportional to the extent of the difference** between the required amount at a demand point and the actually served amount.

Two example problems will be solved, which differ only in the parameter constants.

-----

**Problem 31.**

Solve Problem 22, the originally proposed transportation problem, with flexible demands added. There is a **surplus** and a **shortage penalty constant**. The penalty for each demand is calculated by multiplying the difference between the actual transported materials and the requirement by a corresponding penalty constant.

Two different scenarios are to be evaluated:

  * The **shortage penalty constant is 3**, and the **surplus penalty constant is 1**. This is the "**small**" penalty scenario.
  * The **shortage penalty constant is 15**, and the **surplus penalty constant is 10**. This is the "**large**" penalty scenario.

The starting point for implementation is the model with connections, from **Section 6.2**. The data content is expanded by two parameters, let's call them **`ShortagePenalty`** and **`SurplusPenalty`**. These can be given values in the data section according to the scenarios in Problem 31.

Let's investigate penalties as a function of the total materials delivered at a given demand point (**Figure 6**). **Linear penalty functions** are assumed in both directions. We can observe that this penalty can be considered a special cost function, which **decreases below** and **increases above** the actual requirement for the demand point. If the requirement is exactly met, the penalty is zero. Although the function curve is "broken" in a manner similar to the absolute value function, the **feasible region is still convex**, which suggests a **pure LP model** (Linear Programming).

The model is extended with an auxiliary variable, **`satisfied`**. This is defined for each demand and denotes the **total amount of materials delivered** to that demand. This helps in the formulation as the penalty for a demand $d$ is based on the difference between $\text{satisfied}[d]$ and $\text{Required}[d]$.

```
var satisfied {d in Demands}, >=0;
s.t. Calculating_Demand_Satisfied {d in Demands}:
satisfied[d] = sum {s in Supplies} tran[s,d];
```

From this point, two different methods are shown, which are applicable to penalties in general and are considered equally effective.

1.  The first method introduces a **single variable for the penalty itself**.
2.  The second method introduces **two variables for the shortage and the surplus** of materials.

**Method 1: Single Penalty Variable**

The first method relies on the idea that the penalty function (a convex, piecewise linear function) can be correctly modeled by two linear constraints. This means that two linear constraints can achieve what we want.

```
var penalty {d in Demands}, >=0;
s.t. Shortage_Penalty_Constraint {d in Demands}:
penalty[d] >= ShortagePenalty * (Required[d] - satisfied[d]);
s.t. Surplus_Penalty_Constraint {d in Demands}:
penalty[d] >= SurplusPenalty * (satisfied[d] - Required[d]);
```

The first constraint ensures that the penalty is at least as defined for **shortage**. Note that this constraint is **redundant** if the demand is satisfied, as the right-hand side (RHS) becomes negative.

The second constraint ensures that the penalty is at least as defined for **surplus**. Similarly, this constraint becomes **redundant** if the demand is not met, as the RHS becomes negative.

The penalty variable can be directly included into the objective function, and the model formulation for the first method is ready. Note that the model allows penalty values higher than described as feasible solutions, but these are **eliminated by the optimization procedure**. That means, in the optimal solution, **one of the constraints will be binding (strict)**, or both will be non-binding if the requirement is exactly met and the penalty is zero.

```
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
sum {d in Demands} penalty[d];
```

**Method 2: Shortage and Surplus Variables**

Let us see the second method for implementing flexible demands. This alternative way uses **more variables**, but **fewer constraints**. The exact shortage and surplus amounts are introduced as variables in this formulation.

```
var surplus {d in Demands}, >=0;
var shortage {d in Demands}, >=0;
s.t. Calculating_Exact_Demands {d in Demands}:
Required[d] - shortage[d] + surplus[d] = satisfied[d];
```

Note that the exactly transported amount, termed as $\text{satisfied}[d]$, is now the required amount, minus the shortage, plus the surplus—provided that **either variable is zero**, as common sense dictates. This is expressed by the constraint shown.

However, the model allows both the shortage and the surplus value to be increased by the same amount (e.g., $\text{shortage}' = \text{shortage} + \delta$ and $\text{surplus}' = \text{surplus} + \delta$, where $\delta > 0$), and everything else remains the same. But these cases will be **eliminated by the optimization procedure**, as the new variables are introduced into the objective with their corresponding penalty constants as factors. This completes the implementation of the second method. Note that the optimization procedure ensures that **either the shortage or the surplus is zero** in the optimal solution.

```
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
sum {d in Demands} (shortage[d] * ShortagePenalty +
surplus[d] * SurplusPenalty);
```

**Full Model (Method 1) and Results**

The full model section for the **first method** is presented below. Remember that the two methods are equivalent.

```
set Supplies;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set Connections := Supplies cross Demands;
param Cost {(s,d) in Connections}, >=0;
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
param ShortagePenalty, >=0;
param SurplusPenalty, >=0;
var tran {(s,d) in Connections}, >=0;
var satisfied {d in Demands}, >=0;
var penalty {d in Demands}, >=0;
s.t. Calculating_Demand_Satisfied {d in Demands}:
satisfied[d] = sum {s in Supplies} tran[s,d];
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {d in Demands} tran[s,d] <= Available[s];
s.t. Shortage_Penalty_Constraint {d in Demands}:
penalty[d] >= ShortagePenalty * (Required[d] - satisfied[d]);
s.t. Surplus_Penalty_Constraint {d in Demands}:
penalty[d] >= SurplusPenalty * (satisfied[d] - Required[d]);
minimize Total_Costs:
sum {(s,d) in Connections} tran[s,d] * Cost[s,d] +
sum {d in Demands} penalty[d];
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {d in Demands}
{
printf "Required: %s, Satisfied: %g (%+g)\n",
d, satisfied[d], satisfied[d]-Required[d];
}
for {(s,d) in Connections: tran[s,d] > 0}
{
printf "From %s to %s, transport %g amount for %g (unit cost: %g).\n",
s, d, tran[s,d], tran[s,d] * Cost[s,d], Cost[s,d];
}
end;
```

Regardless of which method we choose, the same result is obtained.

**"Small" Penalty Scenario** ($\text{ShortagePenalty}=3, \text{SurplusPenalty}=1$)

For the "small" penalty scenario, we can see that the total costs are cut by almost half.

```
Optimal cost: 1450.
Required: D1, Satisfied: 120 (+0)
Required: D2, Satisfied: 40 (-100)
Required: D3, Satisfied: 170 (+0)
Required: D4, Satisfied: 90 (+0)
Required: D5, Satisfied: 0 (-110)
Required: D6, Satisfied: 0 (-120)
From S2 to D1, transport 120 amount for 120 (unit cost: 1).
From S2 to D2, transport 40 amount for 80 (unit cost: 2).
From S2 to D4, transport 90 amount for 90 (unit cost: 1).
From S3 to D3, transport 170 amount for 170 (unit cost: 1).
```

There are **no surplus penalties**, but **vast shortages** for D2, D5, and D6. The latter two demand sites (D5 and D6) do not receive any materials at all. The reason is that the **unit cost of transportation exceeds the gain by satisfying the demand**. In the case of D2, the first 40 units can be transported for low costs, but the remaining part of the requirements cannot. The reason for not satisfying demands is that the shortage penalty constant of **3 is very low**, so it is worth not delivering any materials at all and incurring the shortage penalty instead of paying the transportation cost.

**"Large" Penalty Scenario** ($\text{ShortagePenalty}=15, \text{SurplusPenalty}=10$)

On the other hand, the "large" penalty scenario results in **exactly the same solution as the original transportation problem** without the penalties (optimal cost: 2,700). There is no surplus again, but **no shortages either**, simply because the shortage penalty of **15 per unit material is more costly than transporting the material** from any available supply. Therefore, there are no shortages.

There were **no surplus deliveries** in any case, which is not surprising. There had been no point in surplus delivery to any demand point in the original problem either, because it just increases the transportation costs. The surplus penalty just makes surplus even **less beneficial**. The case would be different if surplus deliveries were somehow needed—for example, if available supplies were required to be transported completely.

-----

## 6.7 Adding a Middle Level

In the former sections, different modeling techniques for cost functions and penalties were presented. Now, the transportation problem is expanded to a larger scale.

So far, the graph had been very simple: there were two sets of nodes in the network, the **supplies** and **demands**, and these were all directly connected. But what happens when the network is more complex, for example, if there is a **third set of nodes**?




**Problem 32.**

Solve **Problem 21**, the transportation problem extended by introducing a middle level of so-called **centers**.

Material doesn't flow directly from the **supply** to the **demand** nodes. Instead, material first goes from supply nodes to center nodes and then from center nodes to demand nodes. Connections between either supplies and centers, or centers and demands, have their own transportation costs, as is standard. Moreover, centers are not necessarily used in transportation, but if a center is utilized, an **establishment cost** must be paid first if any transportation is routed through that center. Establishment costs are one-time fees and are given for each center.

As previously mentioned, the original transportation problem can be represented by a graph with two types of nodes: supplies and demands (see Figure 1 in Section 6.1). In contrast, the scheme of the new transportation problem can be seen in Figure 7. Connections from supplies to centers are referred to as **A-type**, while connections from centers to demands are referred to as **B-type**, as the figure shows.

Note that in general, transportation could occur over any network. However, if **cycles** are present, care must be taken to correctly interpret material flow through these cycles. Throughout this chapter, there are no cycles; material only flows in one direction.

> **Figure 7:** Graph representing the transportation problem with center nodes included.

-----

**Problem 33.**

Solve **Problem 21**, the general transportation problem with centers, using the following problem data. There are four supplies, named **S1 to S4**, two centers, **C1 and C2**, and six demands, named **D1 to D6**. Transportation costs, available amounts for supplies, and required amounts for demands are summarized in the following table:

| From Supply to Center | C1 | C2 | Available Amounts |
| :---: | :---: | :---: | :---: |
| S1 | 5 | 10 | 100 |
| S2 | 10 | 2 | 250 |
| S3 | 3 | 7 | 190 |
| S4 | 10 | 4 | 210 |
| **From Center to Demand** | **D1** | **D2** | **D3** | **D4** | **D5** | **D6** | **Required Amounts** |
| C1 | 10 | 3 | 9 | 8 | 1 | 6 | - |
| C2 | 2 | 7 | 3 | 2 | 7 | 8 | - |
| Required Amounts | 120 | 140 | 170 | 90 | 110 | 120 | **Total: 750** |

Two scenarios must be evaluated:

  * **In the first, "small" establishment cost scenario,** using C1 and C2 requires a fixed cost of **1,200** and **1,400**, respectively.
  * **In the second, "large" establishment cost scenario,** fixed costs are multiplied by $10$ (e.g., **12,000** and **14,000**, respectively).

-----


Before starting the model implementation, the **data section** describing Problem 33 can be implemented as follows. The only difference between the two scenarios is the value of the `EstablishCost` parameter.

```
data;
set Supplies := S1 S2 S3 S4;
set Centers := C1 C2;
set Demands := D1 D2 D3 D4 D5 D6;
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
param CostA:
C1 C2 :=
S1
5 10
S2 10
2
S3
3
7
S4 10
4
;
param CostB:
D1 D2
C1 10
3
C2
2
7
;

D3
9
3

D4
8
2

D5
1
7

D6 :=
6
8

param EstablishCost :=
C1 1200
C2 1400
;
```

Sets `Supplies` and `Demands`, and parameters `Available` and `Required` have the same meaning as before. However, instead of a single parameter for transportation costs, two parameters, named **`CostA` and `CostB`**, are introduced for **A-type** (supply-to-center) and **B-type** (center-to-demand) connections, respectively. Finally, `EstablishCost` denotes the fixed cost of using a center node.

The corresponding definitions in the model section are the following. Note that the sets of all A-type and B-type connections are also defined.

```
set Supplies;
set Centers;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set ConnectionsA := Supplies cross Centers;
set ConnectionsB := Centers cross Demands;
param CostA {(s,c) in ConnectionsA}, >=0;
param CostB {(c,d) in ConnectionsB}, >=0;
param EstablishCost {c in Centers}, >=0;
```

We can still check the **feasibility** of the problem by asserting that the total available amounts are greater than or equal to the total required amounts.

```
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
```

Now that the data are available in the model section, let's figure out what the **decision variables** in the model should be. At first glance, the problem seems like two independent transportation sub-problems: one from supplies to centers, and one from centers to demands. However, we cannot solve these two transportation stages separately because the amounts at the center nodes are not fixed; these are part of the decision.

However, we **can** solve the two transportation sub-problems in a \*\* single model\*\*. The necessary decision variables for both transportation problems are simultaneously defined in the model: from supplies to centers, and from centers to demands. The only difference is that the amount of materials delivered to and sent from the centers are not fixed values in the sub-problems, but **variable quantities**. Moreover, the amount delivered **to** and **from** a center node must be equal. This is where the two sub-problems are connected, and it can be easily established by constraints.

Because of these considerations, variables `tranA` and `tranB` are introduced to denote transportation amounts for A-type and B-type connections (e.g., from supplies to centers and from centers to demands). In fact, these decisions are sufficient to determine everything about the resulting transportation system; however, **additional variables** are required. Variable `atCenter` denotes the amount of material going through each center node, which is exactly the amount going in and going out. This is more of an **auxiliary variable**, as it's not strictly required but makes implementation easier. However, the **binary variable** `useCenter`, denoting whether a center is used at all ($=1$) or not ($=0$), **is required** in order to implement the **fixed establishment costs** associated with center nodes.

```
var tranA {(s,c) in ConnectionsA}, >=0;
var tranB {(c,d) in ConnectionsB}, >=0;
var atCenter {c in Centers}, >=0;
var useCenter {c in Centers}, binary;
```

Four constraints ensure the consistency of material flow through the entire network. The following rules are expressed in order:

1.  **Total transportation from supply nodes** shall not exceed the available amount.
2.  **Total transportation to center nodes** is equal to the `atCenter` value of that center node.
3.  **Total transportation from center nodes** is equal to the `atCenter` value of that center node.
4.  **Total transportation to demand nodes** shall be at least the required amount.

<!-- end list -->

```
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {c in Centers} tranA[s,c] <= Available[s];
s.t. Total_To_Center {c in Centers}:
atCenter[c] = sum {s in Supplies} tranA[s,c];
s.t. Total_From_Center {c in Centers}:
atCenter[c] = sum {d in Demands} tranB[c,d];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {c in Centers} tranB[c,d] >= Required[d];
```

Note that since we express `atCenter` in two different ways (in `Total_To_Center` and `Total_From_Center`), the two expressions that are equal to `atCenter` are made equal to each other.

A fifth constraint must be added to ensure that a center node can only receive or send materials if it is established. The total available amount is denoted by $\mathbf{M}$, which serves as the coefficient in the required **Big-M constraint**.

```
param M := sum {s in Supplies} Available[s];
s.t. Zero_at_Center_if_Not_Established {c in Centers}:
atCenter[c] <= M * useCenter[c];
```

The **objective function** is the total of all costs, which has three components: A-type connection costs, B-type connection costs, and the establishment costs of center nodes.

```
minimize Total_Costs:
sum {(s,c) in ConnectionsA} tranA[s,c] * CostA[s,c] +
sum {(c,d) in ConnectionsB} tranB[c,d] * CostB[c,d] +
sum {c in Centers} useCenter[c] * EstablishCost[c];
```

We can include `printf` statements after the `solve` statement, as usual, to show the details of the optimal solution found. Our model section is ready.

```
set Supplies;
set Centers;
set Demands;
param Available {s in Supplies}, >=0;
param Required {d in Demands}, >=0;
set ConnectionsA := Supplies cross Centers;
set ConnectionsB := Centers cross Demands;
param CostA {(s,c) in ConnectionsA}, >=0;
param CostB {(c,d) in ConnectionsB}, >=0;
param EstablishCost {c in Centers}, >=0;
check sum {s in Supplies} Available[s] >= sum {d in Demands} Required[d];
var tranA {(s,c) in ConnectionsA}, >=0;
var tranB {(c,d) in ConnectionsB}, >=0;
var atCenter {c in Centers}, >=0;
var useCenter {c in Centers}, binary;
s.t. Availability_at_Supply_Points {s in Supplies}:
sum {c in Centers} tranA[s,c] <= Available[s];
s.t. Total_To_Center {c in Centers}:
atCenter[c] = sum {s in Supplies} tranA[s,c];
s.t. Total_From_Center {c in Centers}:
atCenter[c] = sum {d in Demands} tranB[c,d];
s.t. Requirement_at_Demand_Points {d in Demands}:
sum {c in Centers} tranB[c,d] >= Required[d];
param M := sum {s in Supplies} Available[s];
s.t. Zero_at_Center_if_Not_Established {c in Centers}:
atCenter[c] <= M * useCenter[c];
minimize Total_Costs:
sum {(s,c) in ConnectionsA} tranA[s,c] * CostA[s,c] +
sum {(c,d) in ConnectionsB} tranB[c,d] * CostB[c,d] +
sum {c in Centers} useCenter[c] * EstablishCost[c];
solve;
printf "Optimal cost: %g.\n", Total_Costs;
for {c in Centers: useCenter[c]}
{
printf "Establishing center %s for %g.\n", c, EstablishCost[c];
}
for {(s,c) in ConnectionsA: tranA[s,c] > 0}
{
printf "A: From %s to %s, transport %g amount for %g (unit cost: %g).\n",
s, c, tranA[s,c], tranA[s,c] * CostA[s,c], CostA[s,c];
}
for {(c,d) in ConnectionsB: tranB[c,d] > 0}
{
printf "B: From %s to %s, transport %g amount for %g (unit cost: %g).\n",
c, d, tranB[c,d], tranB[c,d] * CostB[c,d], CostB[c,d];
}
end;
```

Now we can use the solver to find the optimal decisions for both scenarios in Problem 33. Recall that the **small scenario** assumes fixed costs of $1,200$ and $1,400$ for establishing C1 and C2, while the **large scenario** assumes $12,000$ and $14,000$.

The results of the **small scenario** are the following:

> Optimal cost: **$7,350$**.
>
> Establishing center C1 for $1,200$.
> Establishing center C2 for $1,400$.
>
> A: From S1 to C1, transport $100$ amount for $500$ (unit cost: $5$).
> A: From S2 to C2, transport $250$ amount for $500$ (unit cost: $2$).
> A: From S3 to C1, transport $190$ amount for $570$ (unit cost: $3$).
> A: From S4 to C2, transport $210$ amount for $840$ (unit cost: $4$).
>
> B: From C1 to D2, transport $140$ amount for $420$ (unit cost: $3$).
> B: From C1 to D5, transport $110$ amount for $110$ (unit cost: $1$).
> B: From C1 to D6, transport $40$ amount for $240$ (unit cost: $6$).
> B: From C2 to D1, transport $120$ amount for $240$ (unit cost: $2$).
> B: From C2 to D3, transport $170$ amount for $510$ (unit cost: $3$).
> B: From C2 to D4, transport $90$ amount for $180$ (unit cost: $2$).
> B: From C2 to D6, transport $80$ amount for $640$ (unit cost: $8$).

The results of the **large scenario** are the following:

> Optimal cost: **$21,310$**.
>
> Establishing center C2 for $14,000$.
>
> A: From S1 to C2, transport $100$ amount for $1,000$ (unit cost: $10$).
> A: From S2 to C2, transport $250$ amount for $500$ (unit cost: $2$).
> A: From S3 to C2, transport $190$ amount for $1,330$ (unit cost: $7$).
> A: From S4 to C2, transport $210$ amount for $840$ (unit cost: $4$).
>
> B: From C2 to D1, transport $120$ amount for $240$ (unit cost: $2$).
> B: From C2 to D2, transport $140$ amount for $980$ (unit cost: $7$).
> B: From C2 to D3, transport $170$ amount for $510$ (unit cost: $3$).
> B: From C2 to D4, transport $90$ amount for $180$ (unit cost: $2$).
> B: From C2 to D5, transport $110$ amount for $770$ (unit cost: $7$).
> B: From C2 to D6, transport $120$ amount for $960$ (unit cost: $8$).

As we can see, the optimal solution for the small scenario uses **both** center nodes, with an almost equal distribution of materials. Therefore, establishing both centers for a total of $2,600$ is advantageous. There is no need to deliver to both center nodes from the same supply, and there is only a single demand, D6, where delivery is made from both center nodes. It seems like the establishment costs are paid, and then the cheapest possible routes are used from supplies to demands.

In contrast, the establishment costs are **too high** in the large scenario, so establishing both centers is not beneficial. However, we still need at least one center node for the network, and the optimal solution chooses **C2** with a fixed cost of $14,000$. Assuming this decision, transportation is straightforward: every supply is transported to C2 and then from C2 to the demands. Note that C2 is more expensive to establish than C1 by $2,000$, but choosing C2 seems to be justified by the larger transportation costs across C1.

-----

## 6.8. TRANSPORTATION PROBLEM – SUMMARY

The basic case of the transportation problem was first presented, which involves a set of supply and demand nodes and transportation costs between them. The implementation was later improved by introducing index sets and some additional features of GNU MathProg.

The transportation problem results in an **LP (Linear Programming) model**, and transportation costs for each connection are linear (e.g., they can be described by a single cost coefficient, which, when multiplied by the transported amount, gives the total cost). Four cases of more elaborate cost functions, example problems, and their implementations were also presented:

  * **Increasing Unit Costs:** Two factors and a threshold describe the situation, but we still use an **LP** model.
  * **Economy of Scale:** Two factors and a threshold describe the function again, but the cost above the threshold is now lower. **Binary decision variables** are required, making it a **MILP (Mixed-Integer Linear Programming)** model.
  * **Fixed Costs:** A fixed cost is paid once instead of a proportional cost describing the cost function. A **binary variable** is used; the model is **MILP**.
  * **Linear Penalties:** Flexible demands were assumed, and any difference, either positive or negative, was penalized by a linear factor. This results in an **LP** model.

Finally, the transportation problem was extended by **center nodes**, which divides the entire problem into two related sub-problems, and a fixed cost decision problem is also involved.

 

# Chapter 7: MILP Models 

In the previous chapters, most of the problems we presented were solvable using an **LP (Linear Programming) model**. Nevertheless, some complex elements, such as fulfilling an entire order, modeling the economy of scale, and including fixed costs, required the use of **integer variables**, which resulted in an **MILP (Mixed-Integer Linear Programming) model**. However, the main problems we looked at—production, diet, and transportation—were fundamentally **continuous** in nature. That is, the variables could take any value within a range of real numbers, and integer values were only necessary under specific conditions.

In this chapter, we will explore several optimization problems that inherently involve **discrete decisions**. The solution space for these problems is not a convex, continuous region but is instead **finite** (or divided into finite parts). These problems naturally require integer variables, typically **binary variables**, to express these discrete choices, inevitably leading to **MILP models**. The complexity of solving these problems is usually significantly higher than for problems involving only continuous decisions. Some MILP problem instances, even if they aren't very large, can be difficult or impossible to solve exhaustively. The exact computational limit depends on the problem itself, the specific MILP model used, the solver software and its configuration, and the machine running the calculations.

-----

## 7.1 Knapsack Problem 

One of the simplest optimization problems that is discrete by nature is the **knapsack problem** [18]. Its definition is as follows:

**Problem 34.**

Given a set of **items**, each having a nonnegative **weight** and a **gain** value. A **weight limit** is known. **Select** a subset of the items so that their total weight does not exceed the given limit, and the total gain is **maximal**.

The problem is named the knapsack problem because it can be visualized as having a large knapsack that must be filled with some of the items, but the total weight you can carry is limited. Therefore, you must carefully choose which items to carry in order to obtain the highest possible gain.

As usual, we'll describe a concrete knapsack problem instance for the general problem.

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

Implementing the data section according to Problem 35 and the sets and parameters described here is straightforward.

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

Now let's consider the flexibility we have in choosing a solution for the knapsack problem. Any **subset** of all items is a possible solution, including selecting none or all items. If the number of items is $n$, the total number of different solutions is $2^n$. Note that not all of these subsets are **feasible** due to the weight limit, and we can also eliminate many non-optimal solutions. Nevertheless, the general optimization problem with arbitrary weights and gains is **NP-hard**. Therefore, for a large $n$, finding an exhaustive solution may be practically impossible.

In mathematical programming, we express our decision-making freedom through **decision variables**. This can be easily done using a single **binary variable** for each item. We name it `select`; it is equal to **1** if the item is chosen into the knapsack and **0** if it is not.

```glp
var select {i in Items}, binary;
```

There is only one restriction that can prevent a solution from being feasible: the **total weight** of the items. We express in a single constraint that the total weight of the selected items is at most the given limit. The total weight in the knapsack is calculated by summing each `select` variable multiplied by the item's `Weight`. This correctly yields the result because if an item is selected, its weight is added; if it's not selected, it contributes nothing to the total weight of the knapsack.

```glp
s.t. Total_Weight:
sum {i in Items} select[i] * Weight[i] <= Capacity;
```

The objective is to **maximize** the **total gain**. We sum each `select` variable multiplied by the item's `Gain` value.

```glp
maximize Total_Gain:
sum {i in Items} select[i] * Gain[i];
```

After the `solve` statement, we add some print commands to display the solution. Our complete model section is ready:

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

Solving Problem 35 reports an **optimal gain of 17.1**, which is achieved by selecting items **C, E, I, and J**. The total weight of these items is **59.2**, which fits within the given limit of 60, though it doesn't utilize the capacity perfectly.

Note that we used a **conditional expression** to print the word `SELECTED` after each item $i$ for which `select[i]` is 1, and an empty string where it is 0. The condition for such an expression must be a constant expression that can be interpreted as a logical value. Remember that variables only behave as constants *after* the `solve` statement in the model section. The output produced is the following:

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

One might think of an easy and direct **heuristic** for the knapsack problem: arrange the items in descending order of their **gain/weight ratio** and select items in this order until the weight limit is reached. This **greedy strategy** seems promising because the weight limit acts as a fixed resource, and we want to maximize the gain obtained per unit of weight. The term "greedy" means that at each step, we make the most immediately beneficial choice according to some heuristic measure. Items with a larger gain/weight ratio represent a more efficient use of the weight limit.

The only issue with this strategy is the **slack weight**. We may (and usually will) have some unused weight under the limit. However, we might achieve a better overall solution by sacrificing an item with a high gain/weight ratio in order to better fill the remaining weight limit with other items. This small difference is what prevents the straightforward heuristic from being optimal and is what makes the knapsack problem computationally difficult.

Let's consider a **"relaxed" version** of the knapsack problem, where the items are actually fluids. This means we are allowed to select a **fraction** of an item into the knapsack, which gives us the same fraction of its weight and gain. For this relaxation, the binary variable can be replaced by a continuous one, as follows:

```glp
var select {i in Items}, >=0, <=1;
```

Note that this effect can also be achieved by running the original model with the `glpsol` solver and adding the `--nomip` option, like this:

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

We can observe that items C, E, and I are selected entirely, but instead of choosing J as the fourth and final item (as in the integer solution), the relaxed model chooses H completely and then item A in a **fractional ratio** (approximately $27.3\%$). This selection results in a perfect utilization of the weight limit (60) and a slightly better objective value of **17.7025** instead of 17.1. If we analyze the problem data further, it turns out that the items' decreasing order of **gain/weight ratio** is E, I, H, C, A, D, J, G, B, F. Therefore, the relaxed model performs exactly as the greedy heuristic dictates: it selects the first four items entirely and then the necessary fraction of the fifth (A) to fill the weight limit.

In contrast, the optimal solution to the actual **integer programming problem** does not choose H. Instead, it chooses J, which is much lower in the gain/weight ratio order, but it better fills the weight limit because of its larger overall weight and gain.

Now that we have seen the complications that can arise with an integer problem, let's consider another, similar problem: the **multi-way number partitioning problem** [19].





**Problem 36.**

Given a set of $N \ge 1$ **real numbers**, divide them **exhaustively** into exactly $K \ge 1$ **subsets** so that the difference between the **smallest** and **largest** sum of numbers in a subset is **minimal**.

The **multi-way number partitioning problem** can be interpreted as a modified version of the **knapsack problem** where all $N$ **items** must be packed into any one of $K$ given **knapsacks**, and this distribution shall be as **balanced** as possible. There is no **gain value** in the multi-way number partitioning problem (or, it can be interpreted as being equal to the **weight** of the item).

We will solve one example problem.

-----

**Problem 37.**

**Distribute** the $N=10$ **items** described in Problem 35, the **knapsack example problem**, into $K=3$ **knapsacks** so that the difference between the **lightest** and the **heaviest** knapsack is **minimal**.

Let's see how this can be **implemented** in **GNU MathProg**. First, there is an `Items` set and a `Weight` parameter, as before, but there is no `Gain` parameter. Instead, we **define** a single integer parameter `Knapsack_Count`, which refers to the **positive integer** $K$ in the problem description.

```
set Items;
param Weight {i in Items}, >=0;
param Knapsack_Count, integer;
set Knapsacks := 1 .. Knapsack_Count;
```

We also introduced the set `Knapsacks`. However, instead of reading this set from the data section, we **denote** each knapsack by numbers from **1 to K**. The operator `..` defines a set by the **smallest** and **largest** integer element, **enlisting** all integers in between.

Note that we require `Weight` to be **non-negative**; however, these parameters can be restricted to **integers** in general, or relaxed to take **real values**. The **model** is exactly the same in all cases.

There are **more decisions** to be made than in the original knapsack problem. For each item, we don't only decide whether it **goes to the knapsack or not**, but we now decide **which knapsack it goes into**. This can be done by defining a **binary decision variable** `select` for each pair of an **item** and a **knapsack**, denoting whether the item goes into that particular knapsack or not. These decisions determine the situation well, but **auxiliary** and **other variables** are needed to express the **objective function concisely**. Therefore, we also introduce an **auxiliary variable** `weight` for each knapsack, denoting its **total weight**, and `min_weight` and `max_weight` for the **minimal** and **maximal** knapsack weight.

```
var select {i in Items, k in Knapsacks}, binary;
var weight {k in Knapsacks};
var min_weight;
var max_weight;
```

There is only **one constraint** which establishes whether a decision about knapsacks is **feasible**: **each item must go exactly into one knapsack**, **not more and not less**. If we add some binary variables and set the sum equal to one, then its only feasible solution is when **one binary variable is 1 and all others are 0**. Therefore, the constraint is the following.

```
s.t. Partitioning {i in Items}:
sum {k in Knapsacks} select[i,k] = 1;
```

We provide **three additional constraint statements** to express the calculation of the weight of each knapsack, a **lower limit** on all knapsack weights (`min_weight`), and an **upper limit** (`max_weight`), respectively.

```
s.t. Total_Weights {k in Knapsacks}:
weight[k] = sum {i in Items} select[i,k] * Weight[i];
s.t. Total_Weight_from_Below {k in Knapsacks}:
min_weight <= weight[k];
s.t. Total_Weight_from_Above {k in Knapsacks}:
max_weight >= weight[k];
```

The **objective** can be the **difference** between the upper and lower limit.

```
minimize Difference: max_weight - min_weight;
```

This design had been used before for **minimizing errors in equations** (see Section 4.8), **maximizing minimum production volumes** (see Section 5.3), and some **cost functions** (see, for example, Sections 6.3 or 6.6). The key is that the solver is allowed **not** to assign the actual **minimum** and **maximum** weights to the variables `min_weight` and `max_weight` to obtain **feasible solutions**. It's just **not beneficial** to do so, and therefore, those solutions where these two bounds are not **strict** are **automatically ruled out**.

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

Solving the example **Problem 37** gives the following result.

```
Smallest difference: 2.5 (55.3 - 52.8)
1: C F J (53.2)
2: D E H I (55.3)
3: A B G (52.8)
```

The **ten items** could be divided into **three subsets** of roughly **equal size**. The **largest knapsack** is the second, with a weight of **55.3**, and the **smallest** is the third, with **52.8**. Note that the **order of knapsacks** is **not important**. Because **all ten items are distributed**, it is **guaranteed** that the sum of the three knapsacks is a **constant**; therefore, their **average** is also **constant** and must be in between the two limits.

Another similar, interesting, and **better-known problem** is the so-called **bin packing problem**, where all items are known, but the **knapsack sizes are fixed**. Therefore, the **number of knapsacks** (called **bins**) is to be **minimized** [20]. This could also be solved in **GNU MathProg**, but it is not detailed here.

-----

## 7.2 Tiling the Grid 

The **knapsack** and **similar problems** require items to "fit" somewhere. "Fitting" means that each item has a **weight**, and the **sum of the weights** is under a **constraint**. But what happens when **fitting is more complex**? For instance, considering the **size** or **shape** of items and their **container** is also a **common real-world question** that can lead to much more **difficult optimization problems**.

A **two-dimensional example** is the class of **tiling problems**, where copies of the **same shape** called **tiles** are used to **cover a region** in the plane. Tiles are usually **forbidden to overlap**, and the **cover** is often required to be **perfect**; that is, **all of the designated region is covered**. If we don't require **perfect covering**, then one may ask what is the **most area we can cover**, which is an **optimization problem**. Provided that there is a **single tile**, the **congruent copies** of which are used, the optimization problem simplifies to **maximizing the non-overlapping tiles** that can be put into the region.

In this section, we **restrict tiling** to the **rectangular grid** of **unit squares**. The **tile**, its **all possible positions**, and the **region to be covered** all fit onto **unit squares** of the same grid. The tile will be the **simplest cross** consisting of **five squares**. For the sake of simplicity, the **region to be covered** is a **rectangular area** (see ). Tiles cannot cover area outside the region.

 


**Problem 38.**

Determine the **maximum number of non-overlapping crosses** that can be placed in an $N \times M$ grid.

One might argue that this general problem is very specialized within the class of **tiling problems**. Indeed, many tiling problems cannot be effectively solved using mathematical programming tools. Here, the "general problem" refers to creating a general model section that can be applied to any problem instance.

The data required for this problem is minimal: only the dimensions of the rectangular area need to be specified. Let's look at some examples.

**Problem 39.**

Solve **Problem 38**, the rectangle tiling problem with crosses, for the following rectangle sizes.

**Figure 8:** Rectangular area imperfectly covered by some five-square cross tiles.

  * $6 \times 4$
  * $10 \times 10$
  * $30 \times 30$

This problem requires perhaps the shortest data sections we've seen so far. The following is for the smallest instance:

```glp
param Width := 6;
param Height := 4;
```

We use the parameter names **`Width`** and **`Height`** for the dimensions of the rectangular region to be tiled. These must be positive integers. **`Height`** represents $N$, the number of rows, and **`Width`** represents $M$, the number of columns in the area. Rows are numbered from 1 to $N$, and columns are numbered from 1 to $M$. The set of all squares, or **cells**, in the rectangular grid is the Cartesian product of the sets of rows and columns, resulting in a size of $N \cdot M$. These are defined as shown below.

```glp
param Height, integer, >=1;
param Width, integer, >=1;
set Rows := 1 .. Height;
set Cols := 1 .. Width;
set Cells := Rows cross Cols;
```

At this point, the minimum data requirements are defined in the model, but a concise implementation will require a few more definitions. Let's first determine what kind of decisions we need to make to describe a tiling.

First, we need to, "decide for all possible positions of a cross tile whether to put a tile there or not." This can be done using a **binary variable** introduced for each possible position:

```glp
var place {(r,c) in Tiles}, binary;
```

Here, the set **`Tiles`** refers to a set that hasn't been characterized yet, but it will list all possible placements of cross tiles. Decisions for this `place` variable will fully determine all the necessary properties of the tiling, but an **auxiliary variable** will also be useful.

```glp
var covered {(r,c) in Cells}, binary;
```

Here, `covered` is defined for each cell and determines whether that cell is covered by a placed tile. This helps us formulate constraints ensuring that each cell can only be covered **at most once** to prevent overlapping tiles.

As is customary, a value of **1 means yes** and **0 means no** for all of these binary variables. For instance, a `place` variable is 1 if the tile is placed at that specific position, and a `covered` variable is 1 if that specific cell is covered by some tile.

Before moving on, we must somehow characterize the set **`Tiles`** that describes all possible tile positions. Fortunately, the five-cell cross is **symmetric**: rotating or reflecting it does not result in a different orientation. This means the only difference between tile positions is their location (shifting). In short, we can refer to this simply as the **position**. Therefore, a binary variable is introduced for each possible position of the tile, and the set `Tiles` simply contains these positions.

If we wanted to tile with **asymmetric shapes** where multiple orientations are possible, we would need to define different binary decision variables for each unique orientation and position. In that scenario, the `Tiles` set would require a third index dimension to denote orientation, in addition to the two dimensions for position. But since the cross only has a single orientation, that index dimension is omitted from our model, and `Tiles` is just a two-dimensional set listing positions.

Finally, let's decide how two-dimensional coordinates will define the positioning of tiles. For this purpose, we define the **anchor point** of the cross tile as the **central cell** of the tile. The set `Tiles` will list all possible anchor points of correctly positioned tiles. This is valid because different tile positions have different anchor points.

The selection of the anchor point relative to the tile can be arbitrary, but it must be consistent throughout the model. It could even be a cell outside the tile—for example, the corner cell of the $3 \times 3$ square containing the cross tile.

The last remaining task is to determine the anchor points. We must consider all correctly positioned cross tiles in the rectangular grid. Clearly, because the anchor point is a cell *inside* the tile, the anchor point of a correctly positioned tile must also be within the rectangular grid. However, **not all cells** of the rectangular grid can be anchor points. For example, no cells along the edge of the rectangle are valid choices, as a cross centered there cannot fully cover itself without extending outside the region. Moreover, the corner cells of a rectangular grid cannot even be covered by *any* correctly positioned cross tiles.

Based on an anchor $(r,c)$, we can define all the cells of the cross tile if placed at that anchor. This is done by the **`CellsOf`** set. Note that this set statement is itself indexed over all cells (i.e., all possible anchors), meaning that $N \times M$ different sets of 5 cells each are defined.

```glp
set CellsOf {(r,c) in Cells} :=
{(r,c),(r+1,c),(r-1,c),(r,c+1),(r,c-1)};
```

The set **`Tiles`** of correct tile positions (anchor points) are those for which these 5 cells defined in `CellsOf` are all within the rectangular area.

```glp
set Tiles, within Cells :=
setof {(r,c) in Cells: CellsOf[r,c] within Cells} (r,c);
```

Of course, we could have answered the question about correct anchor points right away: they are exactly the cells that are **not on the edges**. However, this approach is chosen for two reasons:

  * Defining all cells of the placed tile and keeping only those positions that are entirely within the region to be tiled is a very **general approach**. It would work not only on arbitrary tiles but on arbitrary regions on a finite grid as well.
  * The sets `CellsOf` provide us with a **shorter model formulation**, as we will see.

The definitions for `CellsOf` and `Tiles` must be placed before the definition of the variable `place`.

We need two things to be established by constraints. The first is the calculation of the auxiliary variable `covered` for each cell. The second is that each cell can only be covered at most once. Surprisingly, both can be done with a single constraint statement, as follows:

```glp
s.t. No_Overlap {(r,c) in Cells}: covered[r,c] =
sum {(x,y) in Tiles: (r,c) in CellsOf[x,y]} place[x,y];
```

In plain terms, for each cell, we add the `place` variables of all the tiles that cover that cell. Since `place` is an integer variable, the sum exactly equals the number of tiles covering that specific cell. This number can only be zero or one; two or more is forbidden. The latter is implicitly ensured because the sum equals the single binary variable `covered[r,c]`, and since it is a binary variable, its value cannot exceed one.

Note that, in fact, the variable `covered` doesn't even need to be explicitly formulated as **binary**. The constraint ensures that its value is an integer because it's obtained as a sum of integer variables. The only required property of the variable `covered` is its **upper bound, 1**.

This insight can be useful when analyzing the complexity of the problem. Generally, the more binary variables a model has, the more difficult it is to solve. However, since `covered` doesn't necessarily have to be binary, it isn't expected to significantly increase complexity. The true integer nature and difficulty of the problem are based on the `place` variable, which denotes tile placements. Nevertheless, marking `covered` as binary might alter the solution algorithm's process.

The objective is the total number of tiles placed.

```glp
maximize Number_of_Crosses:
sum {(r,c) in Tiles} place[r,c];
```

After the `solve` statement, a useful way to print the solution is to visualize the tiling itself using character graphics.

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

Since the output is textual, we must print each row on a single line, and within a row, we print each cell denoted by the column. A single character is printed for each cell so that the entire rectangular area looks correctly aligned when viewed in a fixed-width font:

  * If a cell is **not covered**, a **dot (`.`)** is placed there.
  * If a cell is the anchor point of a **placed tile**, it is denoted by a **hash mark (`#`)**.
  * Otherwise, if the cell is covered by a cross but is **not its center**, it is denoted by a **plus sign (`+`)**.

Note the use of nested `if` operators to achieve the desired result. One might argue that an unnecessary `if` is present because both cases eventually result in a `+` sign. The key point is that we first check whether $(r,c)$ is a proper anchor point or not. Only if it is an anchor point do we then check the value of the `place[r,c]` variable. We do this because if `place[r,c]` is referenced for a non-anchor point $(r,c)$, an **"out of domain" error** would occur, as the `place` variable is only defined for anchor points (members of the set `Tiles`). Note that if an `else` value is omitted in MathProg, it is assumed to be zero.

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

Solving the model for the smallest instance, a $4 \times 6$ area, shows that no more than **two** cross tiles can fit in such a small area. One possible construction, reported by the model output, is shown below:

```
Max. Cross Tiles (4x6): 2
....+.
.+.+#+
+#+.+.
.+....
```

The medium instance of a $10 \times 10$ area is still solved very quickly. A maximum of **13** cross tiles fit in the area, and the reported solution is:

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

The large instance of $30 \times 30$ cells was included to demonstrate what happens when the model becomes genuinely large and thus cannot be solved quickly. In such cases, the solver could take an unacceptably long time to complete. Therefore, a **time limit of 60 seconds** is provided. In the command line, this can be done by adding the `--tmlim 60` argument to `glpsol`:

```bash
glpsol -m tiling.mod -d example.dat --tmlim 60
```

If the time limit option is omitted, there is no time limit. Note that the limit set this way is not a strict bound on the running time available for the solver; `glpsol` tends to slightly exceed this limit, especially if preparatory steps are lengthy.

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

Note that the original model contained a massive **1684 binary variables**. Preprocessing only removed four of them (likely the corner cells, as they can never be covered, but this is an unverified claim).

After that, the **LP relaxation** of the MILP model is solved. The rows concerning "perturbation" indicate that the solver took countermeasures to avoid **stalling**, which is a possible infinite loop in the Simplex algorithm. The presence of this message suggests that the solved LP itself is difficult, very large, or has unusual properties. The last line shows that **163.15** was the optimal solution of the LP relaxation. This is valuable information because we now know that the optimal solution of the actual MILP model **cannot be greater than 163**. The solution algorithm uses the result of the LP relaxation to set an initial bound.

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

The integer optimization begins afterward, which is generally executed using a **Branch and Bound** procedure. Branching is used to check different values of integer variables one by one, and bounding is used to eliminate branches before checking them.

Output rows are printed regularly, either periodically or after an important event, such as finding a better solution.

  * The numbers on the left, ending at 43866, denote the number of "steps" taken by the solution algorithm.
  * The column to the right of it is the currently known **best integer solution** (or "MIP," Mixed-Integer Program). This solution can only improve (increase in a maximization problem) during the search.
      * Initially, the solver had not found any integer solutions.
      * The first solution found involved **138 tiles**.
      * In 60 seconds, this was improved to **140 tiles**, at which point the optimization stopped due to the time limit.
  * The column on the far right denotes the current **best bound**. This is an upper limit on the objective of any feasible solution. This value can only decrease during the search. In the example, it is initially 163 (based on the LP relaxation) and is slightly improved to 162.

This means that even though the solution procedure didn't finish, there cannot be more than **162 tiles**.

At any time, the optimal solution lies somewhere between the best solution and the best bound. The solver constantly tries to improve both values to close the difference between them. If they are equal, the optimal solution has been found. Sometimes the current best solution is called a **lower bound** because it is a lower bound for the final optimal solution. (Note that if the objective is minimized, the same concepts are used, but all relationships are reversed.)

The relative difference between the best solution and the best bound is called the **integrality gap**, usually expressed as a percentage. The integrality gap is a measure of our certainty about the optimal solution. The solver aims to minimize the gap, eventually reaching zero.

Concluding the results of the large case, we have a feasible solution of **140 tiles**, but the true optimal solution could be as large as **162**. The gap after one minute is **$15.7\%$**. It is possible that 140 is indeed the optimal solution, but the solver has not definitively proven it. Note that these results may vary slightly depending on the machine or the version of `glpsol` used.

What options do we have for a large model that `glpsol` failed to solve optimally? The options depend on the exact situation, but it must be acknowledged that some problems are simply inherently very difficult and cannot be solved quickly.

  * **Spend More Time Solving:** Unfortunately, improvement usually slows down after a certain point. Finishing the problem may take an unacceptably long time.
  * **Formulate a Better Model:** We can try a wide range of techniques, including choosing different decision variables and applying **tightening constraints** (like cutting planes) that help the solver by eliminating parts of the search space, typically improving the model's relaxation. Sometimes, a better formulation can improve efficiency by orders of magnitude.
  * **Choose a Different Solver or Machine:** There are more powerful LP/MILP solvers available than `glpsol`. Examples of free software include CBC and lpsolve, but even stronger commercial solvers exist. `glpsol` supports exporting the model into a commonly supported format like CPLEX-LP, which most MILP solvers can read. There can be surprising performance differences between solvers.
  * **Adjust Solver Options:** Even `glpsol` has options that alter the solution algorithms and can be helpful, including enabling heuristics and non-default solution methods.

We will now demonstrate the last option: running `glpsol` again, but with the following two heuristic configuration options enabled:

  * **Feasibility Pumping** (`--fpump` option): This is a heuristic that aims to find good integer solutions early in the optimization procedure. This can help the solver later by eliminating branches with objective values that are too low.
  * **Cuts** (`--cuts` option): This allows all available cuts known to `glpsol` to be used in the model. **Cuts** are constraints automatically added to the model to improve the solution algorithm by trimming the search space. The cuts enabled by this option are the Gomory, Mixed-Integer Rounding, Clique, and Mixed Cover cuts; each of these can be individually enabled or disabled.

<!-- end list -->

```bash
glpsol -m tiling.mod -d example.dat --fpump --cuts
```

These heuristics often help solve the problem, sometimes dramatically. However, there are cases where they don't help, and the overhead might even slow down the solution process.

The output produced by `glpsol` when solving the $30 \times 30$ instance with the `--fpump` and `--cuts` options is as follows:

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
+ 5134: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (44; 0)
+ 7111: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (73; 1)
+ 8009: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (89; 1)
+ 9294: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (106; 1)
+ 10509: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (124; 1)
+ 12685: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (141; 2)
+ 14071: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (160; 2)
+ 15544: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (181; 2)
+ 16909: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (195; 3)
+ 17875: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (211; 3)
Time used: 60.2 secs. Memory used: 10.8 Mb.
+ 18551: mip = 1.530000000e+02 <= 1.620000000e+02 5.9% (225; 3)
TIME LIMIT EXCEEDED; SEARCH TERMINATED
Time used: 60.5 secs
Memory used: 13.1 Mb (13730993 bytes)
```

We can see evidence of the preprocessing and intermediate work associated with some of the cuts. However, the most significant improvement came from the **feasibility pumping**, which found a feasible solution of **153 tiles**. This is substantially better than the 140 found previously. The integrality gap is also much smaller, at only **$5.9\%$** instead of $15.7\%$.

Note that if we are uncertain about the complexity of our model, we can always omit time limits and simply terminate `glpsol` manually, as the current best solution is periodically reported in the output anyway. In this case, however, the best found solution itself is **not reported** because any subsequent printing work after the `solve` statement is skipped. In contrast, if `glpsol` stops on its own before finding the optimal solution (due to a time limit, for example), then the variables are all set according to the current best solution, and that specific solution will be printed. For example, this is the reported solution with **153 tiles** placed:

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

We can observe that the inside of the $30 \times 30$ square is almost perfectly filled with cross tiles. The gap between the best-found solution (153) and the potential best (162) remains open for now.

-----

## 7.3 Assignment Problem 

Another well-known optimization problem, the **assignment problem** [21], is presented in this section.

-----

 


**Problem 40.**

Given $N$ workers and $N$ tasks. For each worker and each task, we know how well that particular worker can execute that particular task, which is described by a cost value for that pair.

Assign each worker exactly one task so that the **total cost is maximized**.

As usual, the general problem is demonstrated through an example.

-----

**Problem 41.**

Solve Problem 40, the assignment problem, using the following data. There are $N = 7$ workers, named W1 to W7, the tasks are named T1 to T7, and the following matrix describes the costs that are incurred whenever a particular task is assigned to a particular worker.

| | T1 | T2 | T3 | T4 | T5 | T6 | T7 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **W1** | 9 | 6 | 10 | 10 | 8 | 7 | 11 |
| **W2** | 7 | 12 | 6 | 14 | 10 | 5 | 5 |
| **W3** | 8 | 9 | 7 | 11 | 10 | 15 | 6 |
| **W4** | 4 | 10 | 2 | 10 | 6 | 4 | 7 |
| **W5** | 10 | 11 | 7 | 12 | 14 | 9 | 10 |
| **W6** | 5 | 9 | 8 | 9 | 13 | 3 | 8 |
| **W7** | 7 | 12 | 7 | 7 | 11 | 10 | 9 |

Defining the input sets and parameters and implementing the data section can be done in different ways. One possibility is to only read $N$, the number of workers and tasks, and use a fixed naming convention for them, for example, numbers from 1 to $N$. But now, we want to allow the naming of workers and tasks to come from the data section, and therefore two sets named `Workers` and `Tasks` are provided. The only requirement is that these sets must have the same size; otherwise, the assignment is impossible. This is established by a `check` statement.

Next, we introduce the `Assignments` set for all possible assignments between workers and tasks. This helps in the formulation later. The `Cost` parameter is then defined for all possible assignments.

```
set Workers;
set Tasks;
check card(Workers)==card(Tasks);
set Assignments := Workers cross Tasks;
param Cost {(w,t) in Assignments};
```

Data for the example Problem 41 can be implemented as follows.

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


There is only one kind of decision to be made in the model: for each assignment, decide whether we assign that particular task to the worker or not. This is a binary variable; we name it `assign`.

```
var assign {(w,t) in Assignments}, binary;
```

There are two rules we must obey when choosing assignments: each worker must have exactly one task, and each task must have exactly one worker assigned. These are implemented as follows.

```
s.t. One_Task_Per_Worker {w in Workers}:
sum {t in Tasks} assign[w,t] = 1;
s.t. One_Worker_Per_Task {t in Tasks}:
sum {w in Workers} assign[w,t] = 1;
```

The objective is the total cost, which is obtained by adding each assignment variable multiplied by the associated cost.

```
minimize Total_Cost:
sum {(w,t) in Assignments} assign[w,t] * Cost[w,t];
```

Finally, after the `solve` statement, we print the optimal total cost, and for each worker, the task assigned. The model section is ready.

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

Note that the task assigned to the worker is printed by a `for` loop iterating over all tasks. As each worker has exactly one task assigned, this loop is guaranteed to print exactly one task, as desired.

The solution to the example problem is the following. The cost of each assignment is shown in parentheses.

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

Therefore, the smallest possible sum of assignments is 42. As usual, it is not guaranteed that the solution shown is the only optimal one.

There are plenty of things we must note about the assignment problem.

  * As we can see, the model formulation is relatively simple. The number of different feasible solutions for $N$ workers is exactly $N!$ (factorial), because the assignment of tasks to workers can be regarded as a permutation of the tasks (or the workers). For $N=7$, it is 5,040, which is not too much to check even by brute force. However, the factorial function quickly rises, in fact, quicker than exponentially. For 20 tasks, the number of solutions is $20! > 10^{18}$. Such a number of steps is not considered feasible for average computers using naive brute-force methods.
  * With mathematical programming, we can solve assignment problems much larger in size. However, this is one of the few integer programming problems for which a polynomial-time algorithmic solution exists. The **Hungarian method** [22] is specifically designed for the assignment problem and is substantially faster than using a mathematical programming tool.
  * The assignment problem also has a rare property: its Linear Programming (LP) relaxation yields the optimal result for the Mixed-Integer Linear Programming (MILP) model as well. Therefore, the integrality gap is guaranteed to be zero. This means that we do not even need binary variables; simple continuous variables with a lower bound of 0 and an upper bound of 1 suffice. The reasons behind this property are out of scope for this tutorial. Nevertheless, this is useful knowledge because the assignment problem can be solved by LP, for which the practical limits in size are usually much larger than for MILP models.
  * The assignment problem is also closely related to the transportation problem. In fact, it can be interpreted as a transportation problem with $N$ sources and $N$ demands, each having an availability and requirement of 1, and the cost matrix for the transportation problem is the same as for the assignment problem. The only difference is that the 1 unit of material cannot be split over multiple connections. But this is not even beneficial: as we previously remarked, the LP relaxation of the problem is sufficient to provide the optimal solution.
  * In general, the assignment problem can be part of more complex **optimization problems** where finding a bijection between two sets is part of the decisions. A **bijection**, also called a one-to-one correspondence, between two sets of the same size is when exactly one element from the other set is assigned to each element.
  * Another interesting property is that we can add the same number to any row or any column of the cost matrix without altering the optimal solution. The only thing that changes is the optimal objective value, which is changed exactly by the number added to or subtracted from the row or column.
  * This assignment problem shown here involves minimization, but maximization could also be a valid objective. These problems are equivalent. If costs are simply negated, we get the opposite problem, and the solution procedure remains the same.

Now, we will show one interesting extension of the problem. What happens when some decisions about assignments have already been made?




**Problem 42.**

Solve Problem 40, the assignment problem, with the addition of **a priori decisions**: some possible assignments are explicitly declared to either be used or not used.

This extension isn't unique to the assignment problem. Such considerations may arise for every real-world optimization problem. The technique we show here isn't specific either.

Our primary goal is to support **a priori decisions** without compromising the already implemented functionality. That means old data files not containing any decisions should still work.

First, we define a new parameter named **`Fixing`** to express these a priori decisions for all assignments.

```
param Fixing {(w,t) in Assignments}, in {0,1,2}, default 2;
```

This parameter has three possible values:

  * The value **0** means we **exclude** the assignment from the possible choices.
  * The value **1** means we **must use** this assignment in the solution.
  * The value **2** means that we do not decide beforehand whether we want the assignment or not; this decision is rather **left as freedom for optimization**.

Since the value 2 is set as the **default** for the parameter, if the `Fixing` variable is not mentioned at all in the data sections, the model assumes that there are **no a priori decisions**. This addresses **compatibility with old data files**.

Next, we need these decisions to be enforced. For all `Fixing` values that are either 0 or 1, we explicitly set the assignment variable (`assign`) to the `Fixing` value. The indexing goes over all possible assignments, but those possible assignments that are left to be decided are filtered out and, therefore, not fixed.

```
s.t. Fixing_Constraints {(w,t) in Assignments: Fixing[w,t]!=2}:
assign[w,t] = Fixing[w,t];
```

This completes our new model, which not only solves the assignment problem but supports a priori decisions to be made, and only optimizes over the restricted set of cases. We now demonstrate its usage with two alternative trials.

-----

**Trial 1: Prohibiting an Assignment**

First, we set the assignment **W6 to T6 fixed as zero (excluded)**. This is the only assignment decided a priori. This case is related to the original example Problem 41, because its optimal solution involves this assignment. Therefore, prohibiting this assignment forces the solver to find another solution. The data section modifications and the results are shown below.

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

It turns out that although the W6 to T6 assignment has a cost of 3 (the second smallest in the whole cost matrix), there is still an alternative solution with the objective **42** which omits it.

-----

**Trial 2: Mandating an Assignment**

Now for the second trial, set the assignment **W4 to T3 as mandatory (1)**. This is the **cheapest possible assignment** in the whole matrix with a cost of 2, but was not included in either optimal solution previously reported. This is the only a priori decision in the second trial. The added data and results are the following.

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

Surprisingly, including assigning W4 to T3 turns out to be a **poor idea**, as the optimal solution with this decision is only **43** now; 42 cannot be obtained anymore.

Further than demonstrating the usage of a priori decisions made for a model, the results show that simple **greedy heuristics** like taking the smallest cost first do not work perfectly for the assignment problem.

Finally, note that the implementation of a priori decisions by manipulating problem data—particularly for the assignment problem—is also possible:

  * If a possible assignment is assigned a very large positive cost, like a positive **big-M**, then it is not beneficial for the solver to use. Therefore, that assignment is effectively excluded.
  * If a possible assignment is assigned a very large negative cost, like a negative **big-M**, then the solver is effectively forced to use that assignment.

A priori decisions can easily make the problem **infeasible** if those decisions are contradictory. In case we implement a priori decisions by very large negative and positive big-M costs, the model will not be infeasible. Instead, it tries to select as few forbidden and as many mandatory possible assignments as possible. Assignments in the solution despite their positive big-M costs, or assignments missing despite their negative big-M costs, indicate that the assignment is not possible as described by the a priori decisions. Nevertheless, the solver does its best to minimize the objective anyway.

-----

## 7.4 Graphs and Optimization

Two basic problems from the field of **graph theory** are mentioned now which can be solved by MILP models. For readers interested in graph theory topics, we offer a good introductory book [23], but the definitions and theorems needed for the two problems are presented in this Tutorial.

A **simple graph** has **nodes** and **undirected edges**, where each edge connects two different nodes, and any two nodes are connected by at most one edge. This is in contrast with **non-simple graphs** where loops and multiple edges are allowed, and with **directed graphs**, where edges are substituted by arcs directing from one node to another.

Some further definitions are introduced that are required to understand the upcoming problem definitions:

  * A **path** in a graph is a sequence of distinct nodes where the adjacent nodes in the sequence are connected by an edge. If the first and last member of a path are connected by an edge, then together with that edge, the path forms a **cycle** (see **Figure 9**).
  * A graph is **connected** if any two of its nodes can be connected with a path. Otherwise, it is **disconnected** (see **Figure 10**). Informally, a connected graph is "one big component," and a disconnected graph consists of multiple components.
  * A **tree** is a connected graph with no cycles.
  * A **spanning subgraph** of a graph is another graph with all its nodes and the same or fewer edges.
  * A **spanning tree** of a graph is a spanning subgraph which is a tree (see **Figure 11**). Spanning trees are obtained by erasing edges of the graph until it contains no more cycles but is still connected.

Simple graphs are useful for representing the scheme of a network of connections, but sometimes the graph is extended by additional data. One common extension is **edge weight**, which is a number assigned to each edge. This leads to a **weighted simple graph**. From now on, we assume weights are positive. The two problems to be solved are the following.



**Problem 43.**

Solve the **shortest path problem** [24] on an arbitrary simple weighted graph, specified as follows: Given two nodes, find a path connecting these two nodes so that the **total weight of edges on the path is minimal**.

-----

**Problem 44.**

Solve the **minimum weight spanning tree (MST)** [25] problem on an arbitrary simple weighted graph: find the spanning tree of the graph with the **minimal total edge weight**.

-----

**Understanding the Problems**

In the **shortest path problem**, edge weights typically represent **distances** between two nodes. This is common in practice, for example, in navigation.

In the **minimum weight spanning tree problem**, weights may represent **connection establishment costs**. This problem often arises in real-world situations where a **minimal-cost connected network** must be established between a set of nodes. This is because the minimal connected spanning subgraphs are always spanning trees—we omit the proof here. But this idea is a key observation: we are looking for the minimum weight connected graph on the set of nodes, and this eventually coincides with the minimum weight spanning tree problem.

Before going on, we must note that these problems have **very efficient algorithms** that solve them in polynomial time:

  * The shortest path problem is solved by **Dijkstra’s algorithm** [26].
  * The minimum weight spanning tree problem is solved, for example, by **Kruskal’s algorithm** [27] or **Prim’s algorithm**.

Other approaches are also available. Our aim here is to show how **MILP models can be utilized for graphs**. Although a specific algorithm can be superior in efficiency, a mathematical programming model can be much easier to formulate and to adapt to more complex problems if the problem definition changes.

**Figure 12** shows an example of a simple weighted graph, which is used for demonstration.

-----

**Problem 45.**

On the graph depicted in **Figure 12**, find the shortest path between nodes **A and I**, and find the minimum weight spanning tree.

**Feasibility Analysis**

First, we analyze the problems in terms of feasibility. If a graph is **disconnected**, then there are nodes that cannot be reached by moving along edges, and there is **no connecting path**. Disconnected graphs have **no spanning trees** either. On the other hand, if a graph is **connected**, there should be paths from any node to any other, and also a spanning tree. We omit proofs of these claims here.

The graph in **Figure 12** is connected and clearly has paths and spanning trees, so feasibility is guaranteed.

**Data Implementation for the Graph**

The main idea about modeling graphs with mathematical programming tools is that edges are defined by pairs of nodes. Therefore, edges can be indexed by two-dimensional indices where both dimensions refer to the set of nodes.

We first implement a data section describing the graph in question. The set of **`Nodes`** has two important elements: the two nodes between which the shortest path is to be found. We name these as **`Start`** and **`Finish`** nodes. Note that the two roles are interchangeable. Finally, a **`Weight`** parameter describes edge weights.

```
data;
set Nodes := A B C D E F G H I;
param Start := A;
param Finish := I;

param Weight :=
A B 5
B C 7
A D 3
B E 4
C F 6
D E 6
E F 4
D G 6
E H 2
F I 8
G H 5
H I 9
B D 1
C E 8
E G 7
F H 2
;
end;
```

The parameters **`Start`** and **`Finish`** have special characteristics. They do not take numeric values as parameters usually do, but values from the set **`Nodes`**. For this reason, we mark these parameters as **symbolic**. For safety reasons, we also add $\text{in Nodes}$ to the definitions so that the data section can only provide names from the `Nodes` set previously defined. Also, we assert that the two nodes are different, by a `check` statement.

```
set Nodes;
param Start, symbolic, in Nodes;
param Finish, symbolic, in Nodes;
check Start!=Finish;
```

The notion of edges in a simple graph only allows a single, **undirected edge** between two nodes. That means edge AB and BA are the same. However, in mathematical programming, it is more convenient to refer to edges as **$(A, B)$ ordered pairs**, because it is easy to index: both $A$ and $B$ can be any node. There are two approaches to resolve this confusion:

1.  **Allow only one direction of edges:** For example, we can make a convention that for each $X < Y$, $XY$ is considered an edge, but $YX$ is not. (Here $X < Y$ refers to some kind of ordering, like lexicographical.)
2.  **Allow all ordered pairs (directed arcs):** We work with directed arcs instead of undirected edges. Later we can identify two arcs as the same edge if needed, using constraints.

We choose the latter option for two reasons. First, only allowing specific node orders for edges would complicate the data to be provided, as we cannot exchange the two nodes in the description of an edge. Second, and more importantly, **edge direction will be used in the model implementation anyway**.

A parameter **`Infty`** is introduced to serve as a very high edge cost. In both the shortest path and the minimum weight spanning tree problem, if an edge has such a cost, it is not beneficial for the solver to select. This effectively eliminates those edges from the search.

For this reason, we set $\text{Infty}$ as the default value for the **`Weight`** parameter. This makes edges not mentioned in the data section automatically excluded from the search by their very large cost.

```
param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);
```

Finally, a parameter **`W`** is introduced for the weight of an edge used in the model, which will be used in the model formulation. The $\text{min}$ operator ensures the following for all edges $XY$:

  * If neither $XY$ nor $YX$ have data provided, the weight $W$ is $\text{Infty}$; therefore, the edge is practically excluded.
  * If only one of $XY$ or $YX$ has data provided, then $W$ will be equal to that given weight. Therefore, we only have to mention each edge once in the data section, in an arbitrary order of the two nodes it connects.
  * If both $XY$ and $YX$ have data provided, then the minimum of these weights is used for both. (Note that this is not an intended functionality; we should not provide both weights in the data. This could also be asserted by a check statement.)

**Solving the Shortest Path Problem**

The main idea for the shortest path problem is to imagine a single **"droplet" of material** placed into the **`Start`** node. It will flow through the arcs of the graph to finally reach the **`Finish`** node. We expect the droplet to draw the path we are looking for. This is where the usage of arcs is more convenient than the usage of edges, because the **direction of flow is very important**.

A binary variable **`flow`** is introduced for each possible arc $(a, b)$, denoting whether the droplet flows through that arc from $a$ to $b$ or not. This variable must be binary, as the droplet cannot split.

```
var flow {a in Nodes, b in Nodes}, binary;
```

No more variables are needed, not even auxiliary ones. The question is what property the arcs must satisfy to actually form a path between the starting and finishing node?

It is a basic idea to check the **material balance** at each node of a graph with flows. In short, material balance ensures the connection between the total amount of material coming in and going out.

Now let us see how the material balance works for a single droplet. The quantity under investigation is the times the droplet **enters** the node, minus the times it **leaves**; we will call this the **balance** at the node:

  * From the starting node ($\text{Start}$), the droplet must go out. Therefore, the balance at the starting node is $\mathbf{-1}$.
  * To the ending node ($\text{Finish}$), the droplet must arrive. Therefore, the balance at the ending node is $\mathbf{1}$.
  * For any other nodes, the droplet must arrive and leave the same number of times. Therefore, the balance in any other node is $\mathbf{0}$.

With a single `s.t.` statement, we establish these balances with the following code:

```
subject to Path_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Start) then -1 else if (x==Finish) then 1 else 0;
```

This single constraint ensures that the model works. If a set of arcs is selected by these balance rules, these arcs will form some directed graph inside the original one. The balance constraints ensure that a **feasible trail** (a sequence of nodes connected by arcs, where nodes can be revisited) exists between the Start and Finish nodes.

The objective is the total weight of the selected arcs:

```
minimize Total_Weight:
sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b];
```

Note that there are two discrepancies between the path to be found and the set of arcs selected in the model:

  * The balance constraint only ensures an existing trail, but more arcs are allowed to be selected.
  * The trail is not necessarily a path, as trails may visit the same node multiple times (cycles).

However, as we have seen many times before, **optimization will eventually rule out these differences and will find an actual path**. First, it is not beneficial to select additional edges because of their positive weight. Second, trails can be trimmed to paths by cutting out cycles.

We print out the used arcs after the solve statement, and our model is now ready.

```
set Nodes;
param Start, symbolic, in Nodes;
param Finish, symbolic, in Nodes;
check Start!=Finish;
param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);
var flow {a in Nodes, b in Nodes}, binary;
subject to Path_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Start) then -1 else if (x==Finish) then 1 else 0;
minimize Total_Weight:
sum {a in Nodes, b in Nodes} flow[a,b] * W[a,b];
solve;
printf "Distance %s-%s: %g\n", Start, Finish, Total_Weight;
for {a in Nodes, b in Nodes: flow[a,b]}
{
printf "%s->%s (%g)\n", a, b, W[a,b];
}
end;
```

Now, let us find the shortest path from **A to I** in the given graph. We get the following result.

```
Distance A-I: 19
A->D (3)
B->E (4)
D->B (1)
E->H (2)
H->I (9)
```

This means the shortest path is **19**, and the path itself is **A-D-B-E-H-I**. The arcs show the direction of the path from A to I well, but unfortunately, the arcs are not in order.

The path can be seen in **Figure 13**.  We can observe that the shortest path is not the path with the minimal number of edges, and does not always go in the "cheapest" direction.

Two additional notes on the shortest path problem:

  * We could impose stricter constraints to only allow at most one incoming and outgoing arc at each node. This would eliminate trails visiting nodes multiple times, but would not eliminate unnecessary arcs (like cycles between unrelated nodes).
  * The shortest path problem in this form has the same nice property as the assignment problem: the **LP relaxation of the problem yields the optimal solution**. So the model could be a pure LP instead of an MILP. This is not surprising: if the droplet is split, all of its pieces shall still go simultaneously on the shortest path to travel the minimal distance in total.

-----

**Solving the Minimum Weight Spanning Tree (MST) Problem**

Now let us solve the minimum weight spanning tree problem on the same graph. We start with the strategy:

Recall the note that the minimal connected spanning subgraph is always a tree. Therefore, the optimization has nothing to do with cycles and tree definitions. The objective should be the **total weight of selected edges**, and the constraints shall only ensure that the graph is **connected**. Optimization will then find the minimum weight connected spanning subgraph, which eventually will be a tree.

The real question is how we can ensure by constraints that some edges form a connected graph of the nodes. We again use the idea of flows. Let us put a single droplet in **each node**, and these droplets may flow through the edges of the graph, eventually arriving into a single designated **sink node**.

  * If the graph formed by the selected edges is connected, then droplets can reach all nodes from any.
  * If the graph is disconnected, then only part of the nodes is reachable, and the flow is infeasible.

Now let us start implementing the model based on this idea. The data section can be almost the same; the only difference is that we do not define a Start and Finish node, only a single **`Sink`**. The selection of the Sink node is arbitrary; we choose **A** as the Sink node.

```
param Sink := A;
```

Edge weights are determined exactly the same way as for the shortest path problem.

```
set Nodes;
param Sink, symbolic, in Nodes;
param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);
```

We use **two kinds of decision variables** this time.

  * Variable **`use`** is defined for each arc and denotes whether the edge is selected, and points towards the Sink node (**binary**).
  * Variable **`flow`** is **continuous** and denotes how much material (eventually, how many droplets) flow through that arc.

<!-- end list -->

```
var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};
```

Without proof, we note that edges of a spanning tree can be uniquely directed towards any one of its nodes. The variable `use` will denote if the edge is selected, and it points towards the Sink node.

The following constraint ensures that for a single edge, flow in one direction is the negative of the flow in the opposite direction.

```
subject to Flow_Direction {a in Nodes, b in Nodes}:
flow[a,b] + flow[b,a] = 0;
```

A **positive flow** of droplets is only allowed in the arcs selected by the `use` variable. This is established by a big-M constraint. Note that the coefficient is the **number of nodes minus one** ($\text{card(Nodes)} - 1$). This is the maximum number of droplets in motion, as the droplet put directly on the Sink node does not need to move.

```
subject to Flow_On_Used {a in Nodes, b in Nodes}:
flow[a,b] <= use[a,b] * (card(Nodes) - 1);
```

Finally, establish the material balance of the droplets, which is the following at each node:

  * If the node is the $\text{Sink}$, then it shall **receive** the number of nodes minus one droplets. The balance is $\mathbf{1 - \text{card(Nodes)}}$.
  * For any other node, it must **send one** droplet. The balance is $\mathbf{1}$.

<!-- end list -->

```
subject to Material_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Sink) then (1-card(Nodes)) else 1;
```

It can be proven that the arc and flow selection satisfying the balance constraints provide a **connected graph**. The logic is similar to the case of the shortest paths: we can start trails at each node and move through positive flows until reaching the Sink. The sink is the only node where trails can end. Therefore, all nodes must be connected to the Sink, and consequently to each other as well.

The objective is the total weight of arcs where the flow is positive. This minimizes the arcs to be selected, resulting in a spanning tree, with all its edges directed towards the Sink.

```
minimize Total_Weight:
sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];
```

The full model is presented below.

```
set Nodes;
param Sink, symbolic, in Nodes;
param Infty, default 99999;
param Weight {a in Nodes, b in Nodes}, >0, default Infty;
param W {a in Nodes, b in Nodes} := min(Weight[a,b],Weight[b,a]);
var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};
subject to Flow_Direction {a in Nodes, b in Nodes}:
flow[a,b] + flow[b,a] = 0;
subject to Flow_On_Used {a in Nodes, b in Nodes}:
flow[a,b] <= use[a,b] * (card(Nodes) - 1);
subject to Material_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Sink) then (1-card(Nodes)) else 1;
minimize Total_Weight:
sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];
solve;
printf "Cheapest spanning tree: %g\n", Total_Weight;
for {a in Nodes, b in Nodes: use[a,b]}
{
printf "%s<-%s (%g)\n", a, b, W[a,b];
}
end;
```

Solving the example with Sink node **A** gives the following results, also visible in **Figure 14**.

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

The minimum weight spanning tree has a total weight of **31**.  We can observe that all directed paths unambiguously lead to the designated Sink node A. If another Sink was selected, then the solution graph could be the same (or another one with exactly the same objective), but the direction of the arcs would be different.

Note that droplets may be split as flows are not integers, but it is not beneficial and therefore not happening in the optimal solution. This is a similarity to the shortest path problem. However, in this case, the MILP model **cannot be relaxed into an LP**, because the selection of the arcs (`use`) is a mandatory integer part. It does not matter whether only a single or all droplets travel through an edge; its full weight must be calculated. Therefore, variable `use` needs to remain binary.

One final note about these MILP formulations: **loops** (edges of the form $(a, a)$) are silently present throughout all of the formulation. We can verify that loops are either not beneficial to be used, or using them does not make a difference, in all instances they are present.

-----

## 7.5 Traveling Salesman Problem

A well-known and notoriously difficult optimization problem and its GNU MathProg model implementation is presented here. This is the **Traveling Salesman Problem (TSP)** [28].



**Problem 46.**

Given a set of **nodes** and the **distances** between every two of them, find the **shortest cycle** that **visits all nodes**.

The goal of the **Traveling Salesperson Problem (TSP)** is to find the route an agent must take to visit a set of targets in the **least amount of time** or by traveling the **least distance**, and then return to the **starting point**. The most optimal route will be a cycle. Note that a cycle that visits all nodes of a graph is also called a **Hamiltonian cycle**. The starting node in TSP can be **arbitrary** since the cycle visits all nodes regardless.

Comparing TSP to the **knapsack problem**, while both are **NP-hard** in general, the knapsack problem tends to be solvable for a much larger number of items than the number of nodes in a TSP.

In general, the distances between two nodes can be different depending on the direction of travel, but we will assume they are **equal** throughout this section.

For simplicity, we will solve the TSP problem for nodes situated on a **plane** (see Figure 15), and an **arbitrary starting point** is also determined. The distances used are **Euclidean**, which is the ordinary definition of the distance between two points on a plane.

-----

**Problem 47.**

Find the **shortest route** starting and ending at the **green node** and visiting all **red nodes** depicted in Figure 15.

For this specific problem, instead of calculating a **distance matrix**, we'll implement a model that accepts the **planar positions** of the nodes and calculates the **Euclidean distances** accordingly. Because of this, a new type of data section formulation is introduced: the nodes and their positions are listed in a single set statement named **Node\_List**.

Another parameter, **Start**, is for the arbitrary starting node. Its role is similar to the arbitrary sink node in the minimum weight spanning tree problem (see Section 7.4)—it could be avoided, but it makes the implementation easier.

```
data;
set Node_List :=
P00 0 0
P08 0 8
P15 1 5
P22 2 2
P23 2 3
P28 2 8
P29 2 9
P31 3 1
P34 3 4
P40 4 0
P56 5 6
P60 6 0
P61 6 1
P69 6 9
P73 7 3
P90 9 0
P93 9 3
P94 9 4
P97 9 7
;
param Start := P23;
end;
```

Let's see how such a data format can be implemented in the model file. First, we need a **three-dimensional set** called **Node\_List**. Note that here we must add `dime n 3` to the definition to indicate that each element of this set has three coordinates: the name of the node, its **X** coordinate, and its **Y** coordinate in the plane, respectively.

```
set Node_List, dimen 3;
set Nodes := setof {(name,x,y) in Node_List} name;
check card(Nodes)==card(Node_List);
param X {n in Nodes} := sum {(n,x,y) in Node_List} x;
param Y {n in Nodes} := sum {(n,x,y) in Node_List} y;
```

After this, the set **Nodes** is **derived** from the list by picking each name mentioned there. Node names must be **unique** in the data section. This can be asserted by a **check statement** confirming that the **Nodes** set has the same size as **Node\_List**. If there are duplicates, the **Nodes** set will be smaller.

The numeric parameters **X** and **Y** denote the planar coordinates of the nodes. Technically, this is obtained by a `sum`. Since each node name appears in the list exactly once, the sum will result in selecting the corresponding coordinate of that particular node. The **Node\_List** set is no longer needed.

The arbitrary **Start** can be any node from the **Nodes** set.

```
param Start, symbolic, in Nodes;
```

The parameter **W** denoting the **Euclidean distances** is calculated based on the **X** and **Y** parameters. The formula for the Euclidean distance between two points $P_1 (x_1 , y_1 )$ and $P_2 (x_2 , y_2 )$ is the following. The implementation in GNU MathProg uses the `sqrt` built-in function and the operator `^` for exponentiation.

$$P_1 P_2 = \sqrt{(x_1 - x_2 )^2 + (y_1 - y_2 )^2}$$

```
param W {a in Nodes, b in Nodes} := sqrt((X[a]-X[b])^2+(Y[a]-Y[b])^2);
```

We now have all the required data defined in the model. Next, the solution strategy and appropriate decision variables must be determined.

First, observe that **TSP** is closely related to the **assignment problem** (see Section 7.3). For each node in the TSP, we must decide the **next node** in the cycle. Therefore, the solution of the TSP is an assignment from the set of nodes to itself.

The **variable `use`** for each arc and the two constraints ensure that each node has exactly one "next" and one "previous" neighbor.

```
var use {a in Nodes, b in Nodes}, binary;
subject to Path_In {b in Nodes}:
sum {a in Nodes} use[a,b] = 1;
subject to Path_Out {a in Nodes}:
sum {b in Nodes} use[a,b] = 1;
```

Applying the logic of **shortest paths**, we can start a trail and follow the direction of the only selected outgoing arc, obtaining a sequence $A_0 A_1 A_2 . . .$ of nodes. For each $i \geq 1$, the arc going *into* $A_i$ is $A_{i-1} A_i$, and the arc going *out* is $A_i A_{i+1}$. Therefore, it's impossible for the sequence to run from $A_i$ into an already visited node $A_j$, $1 \leq j < i$, because $A_j$ only has one incoming arc, $A_{j-1} A_j$, not $A_i A_j$. This means the only way the trail can end is by running into $A_0$ and closing the cycle. Ideally, we would obtain a **single cycle** of all the nodes this way (see Figure 16).

Unfortunately, this simple solution is **not sufficient**. The mistake in the above reasoning is that the cycle starting from and ending at the **Start** node does **not necessarily include all nodes**. The assignment of nodes to other nodes could potentially form not a single Hamiltonian cycle, but **two or several smaller cycles** (see Figure 17).

To prevent the case of **more than one cycle**, we must ensure **connectivity** of the graph. This is where the technique shown for the **minimum weight spanning tree** (see Section 7.4) is reused: a single "droplet" is placed at each node, and these must **flow** through the selected arcs into the **Start** node. This is possible if and only if the assignment is a **single cycle**.

Note that the resulting graph is not a tree, but the new **variable `flow`** and the corresponding constraints only guarantee **connectivity**, just as they did for the minimum weight spanning tree problem.

```
var flow {a in Nodes, b in Nodes};
subject to Flow_Direction {a in Nodes, b in Nodes}:
flow[a,b] + flow[b,a] = 0;

subject to Flow_On_Used {a in Nodes, b in Nodes}:
flow[a,b] <= use[a,b] * (card(Nodes) - 1);
subject to Material_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Start) then (1-card(Nodes)) else 1;
```

The objective is the **total weight** of the selected arcs.

```
minimize Total_Weight:
sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];
```

We have finished the model implementation. As we can see, the **TSP model** is simply a **"combination"** of the assignment problem and the minimum weight spanning tree problem. The optimization procedure does not result in a spanning tree, but a **Hamiltonian cycle** because of the assignment rules. Note that because the assignment problem can be solved by a **Linear Program (LP)**, the assignment problem can be used as a **relaxation** of the TSP problem. Solution techniques for TSP can exploit this fact.

We can once again print out the used edges one by one after the `solve` statement, though likely not in their correct order.

```
printf "Shortest Hamiltonian cycle: %g\n", Total_Weight;
for {a in Nodes, b in Nodes: use[a,b]}
{
printf "%s->%s (%g)\n", a, b, W[a,b];
}
```

Solving example **Problem 47** yields the following result.

```
Shortest Hamiltonian cycle: 44.5948
P00->P31 (3.16228)
P08->P15 (3.16228)
P15->P34 (2.23607)
P22->P00 (2.82843)
P23->P22 (1)
P28->P29 (1)
P29->P08 (2.23607)
P31->P40 (1.41421)
P34->P23 (1.41421)
P40->P60 (2)
P56->P28 (3.60555)
P60->P61 (1)
P61->P90 (3.16228)
P69->P56 (3.16228)
P73->P93 (2)
P90->P73 (3.60555)
P93->P94 (1)
P94->P97 (3)
P97->P69 (3.60555)
```

Note that although there are only **19 nodes**, it still takes some time to solve. The output of `glpsol` clearly shows how the solution was **gradually improved** to optimality.

```
Integer optimization begins...
Long-step dual simplex will be used
+
545: mip =
not found yet >=
+ 1859: >>>>>
5.969014627e+01 >=
+ 4111: >>>>>
4.777953551e+01 >=
+ 7223: >>>>>
4.576632755e+01 >=
+ 15676: >>>>>
4.459475467e+01 >=
+ 39752: mip =
4.459475467e+01 >=
+ 52815: mip =
4.459475467e+01 >=
INTEGER OPTIMAL SOLUTION FOUND
Time used:
9.4 secs
Memory used: 4.7 Mb (4954539 bytes)
```

```
-inf
2.300457897e+01
2.623268810e+01
2.722682823e+01
3.434024294e+01
4.136099600e+01
tree is empty
```

```
(1; 0)
61.5% (48; 1)
45.1% (75; 7)
40.5% (90; 32)
23.0% (154; 77)
7.3% (501; 612)
0.0% (0; 2407)
```

The optimal cycle length is **44.59**. Our manual output provides all the details about the solution but is **difficult to interpret**. Instead, a **visualization** is produced, this time by the model section itself. We will print the solution in **Scalable Vector Graphics (SVG) format** [29].

SVG is a **vector-graphical image representation format**. Instead of storing pixels, the **primitives** that make up the image are described. SVG relies on the **XML data format**. Therefore, we only need to print properly formatted XML containing the grid, the nodes, and the found TSP solution. This entire process happens **after the `solve` statement**.

Producing SVG with GNU MathProg has more spectacular public demonstrations available [30]. We are essentially using the cited approach here. The syntax of neither SVG nor XML will be explained in this Tutorial.

First, for this particular TSP, **Problem 47**, the $\mathbf{X}$ and $\mathbf{Y}$ coordinates range from $\mathbf{0}$ to $\mathbf{9}$. Therefore, the image would fit in a **500 x 500 image** with a **50-pixel distance** between grid lines, and the edges are padded by **25 pixels**. In the SVG to be produced, we reference **x** and **y** coordinates from the **top left corner**, increasing to the right and down. First, we **translate coordinates** in the TSP problem into coordinates in the SVG image as follows.

```
param PX {n in Nodes} := 25 + 50 * X[n];
param PY {n in Nodes} := 475 - 50 * Y[n];
```

We also define an **SVGFILE parameter** to contain the name of the SVG file to be produced. This defaults to `solution.svg` but can be overridden in a data section.

```
param SVGFILE, symbolic, default "solution.svg";
```

We first print an **empty string** using `printf`. However, this is not printed to the `glpsol` result but to the file we specify by adding `>SVGFILE` at the end of the `printf` statement. If we want to **append** to the end of the file instead, we should write `>>SVGFILE`, similar to redirection in the command line.

```
printf "" >SVGFILE;
```

The first `>SVGFILE` **erases the file** if it was present, but all subsequent `printf` statements must end with `>>SVGFILE` to keep the content written previously.

SVG is an XML file, and a properly formatted **header** is needed.

```
printf "<?xml version=""1.0"" standalone=""no""?>\n" >>SVGFILE;
printf "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1//EN"" " >>SVGFILE;
printf """http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"">\n" >>SVGFILE;
```

Note that GNU MathProg does not allow overly long symbolic names and character strings in code (not more than 100 characters); therefore, the work is separated into multiple `printf` statements.

Afterward, **XML tags** will be inserted. The SVG content starts with the opening of an **svg tag**, including the **width and height** of the image. Note that we have to use many `"` characters in the SVG code. These must be **escaped** as `""` if we want to print such characters with `printf` in GNU MathProg.

```
printf "<svg width=""500"" height=""500"" version=""1.0"" " >>SVGFILE;
printf "xmlns=""http://www.w3.org/2000/svg"">\n" >>SVGFILE;
```

First, a **"canvas"** is printed, which is a rectangle the same size as the entire image, providing a **uniform pale yellow background**. We can use the `&` operator in GNU MathProg to **concatenate strings** together, separating a single string into multiple lines.

```
printf "<rect x=""0"" y=""0"" width=""500"" height=""500"" " &
"stroke=""none"" fill=""rgb(255,255,208)""/>\n" >>SVGFILE;
```

First, the **grid is drawn**, consisting of **10 vertical** and **10 horizontal**, narrow black lines at the appropriate positions.

```
for {i in 0..9}
{
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
"stroke=""black"" stroke-width=""1""/>\n",
25+50*i, 475, 25+50*i, 25 >>SVGFILE;
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
"stroke=""black"" stroke-width=""1""/>\n",
25, 25+50*i, 475, 25+50*i >>SVGFILE;
}
```

Next, the **TSP solution is drawn**. A **wide, blue line segment** is placed between each pair of nodes that appear in the optimal cycle. The direction is not represented, as it does not matter anyway.

```
for {a in Nodes, b in Nodes: use[a,b]}
{
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
"stroke=""blue"" stroke-width=""3""/>\n",
PX[a], PY[a], PX[b], PY[b] >>SVGFILE;
}
```

Finally, the **nodes are printed** on top of the grid and the blue cycle. All nodes except **Start** are printed as **small black circles with red fill**.

```
for {n in Nodes: n!=Start}
{
printf "<circle cx=""%g"" cy=""%g"" r=""%g"" " &
"stroke=""black"" stroke-width=""1.5"" fill=""red""/>\n",
PX[n], PY[n], 8 >>SVGFILE;
}
```

The **Start** node is a **small black rectangle with green fill**.

```
printf "<rect x=""%g"" y=""%g"" width=""16"" height=""16"" " &
"stroke=""black"" stroke-width=""1.5"" fill=""green""/>\n",
PX[Start]-8, PY[Start]-8 >>SVGFILE;
```

Note that the **order of elements** to be printed is **important**, as it determines how they cover each other in the result. Finally, the **svg tag is closed**.

```
printf "</svg>\n" >>SVGFILE;
```

By running `glpsol` to solve TSP, **Problem 47**, we get not only the textual output but also the **SVG image file**, which shows the drawing (see Figure 18).

Note that the TSP problem has **more effective implementations** than the one shown here, and even this one could be significantly improved to find solutions faster for larger TSP problem instances. The focus here was on the **relation to the assignment problem** and the **connectivity constraints**.

Here, we show the **full model section**. Note that the **MILP model logic** is almost as large as the code responsible for the textual and SVG output.

```
set Node_List, dimen 3;
set Nodes := setof {(name,x,y) in Node_List} name;
check card(Nodes)==card(Node_List);
param X {n in Nodes} := sum {(n,x,y) in Node_List} x;
param Y {n in Nodes} := sum {(n,x,y) in Node_List} y;
param Start, symbolic, in Nodes;
param W {a in Nodes, b in Nodes} := sqrt((X[a]-X[b])^2+(Y[a]-Y[b])^2);
var use {a in Nodes, b in Nodes}, binary;
var flow {a in Nodes, b in Nodes};
subject to Path_In {b in Nodes}:
sum {a in Nodes} use[a,b] = 1;
subject to Path_Out {a in Nodes}:
sum {b in Nodes} use[a,b] = 1;
subject to Flow_Direction {a in Nodes, b in Nodes}:
flow[a,b] + flow[b,a] = 0;
subject to Flow_On_Used {a in Nodes, b in Nodes}:
flow[a,b] <= use[a,b] * (card(Nodes) - 1);
subject to Material_Balance {x in Nodes}:
sum {a in Nodes} flow[a,x] - sum {b in Nodes} flow[x,b] =
if (x==Start) then (1-card(Nodes)) else 1;
minimize Total_Weight:
sum {a in Nodes, b in Nodes} use[a,b] * W[a,b];
solve;
printf "Shortest Hamiltonian cycle: %g\n", Total_Weight;
for {a in Nodes, b in Nodes: use[a,b]}
{
printf "%s->%s (%g)\n", a, b, W[a,b];
}
param PX {n in Nodes} := 25 + 50 * X[n];
param PY {n in Nodes} := 475 - 50 * Y[n];
param SVGFILE, symbolic, default "solution.svg";
printf "" >SVGFILE;
printf "<?xml version=""1.0"" standalone=""no""?>\n" >>SVGFILE;
printf "<!DOCTYPE svg PUBLIC ""-//W3C//DTD SVG 1.1//EN"" " >>SVGFILE;
printf """http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"">\n" >>SVGFILE;
printf "<svg width=""500"" height=""500"" version=""1.0"" " >>SVGFILE;
printf "xmlns=""http://www.w3.org/2000/svg"">\n" >>SVGFILE;
printf "<rect x=""0"" y=""0"" width=""500"" height=""500"" " &
"stroke=""none"" fill=""rgb(255,255,208)""/>\n" >>SVGFILE;
for {i in 0..9}
{
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
"stroke=""black"" stroke-width=""1""/>\n",
25+50*i, 475, 25+50*i, 25 >>SVGFILE;
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
"stroke=""black"" stroke-width=""1""/>\n",
25, 25+50*i, 475, 25+50*i >>SVGFILE;
}
for {a in Nodes, b in Nodes: use[a,b]}
{
printf "<line x1=""%g"" y1=""%g"" x2=""%g"" y2=""%g"" " &
"stroke=""blue"" stroke-width=""3""/>\n",
PX[a], PY[a], PX[b], PY[b] >>SVGFILE;
}
for {n in Nodes: n!=Start}
{
printf "<circle cx=""%g"" cy=""%g"" r=""%g"" " &
"stroke=""black"" stroke-width=""1.5"" fill=""red""/>\n",
PX[n], PY[n], 8 >>SVGFILE;
}
printf "<rect x=""%g"" y=""%g"" width=""16"" height=""16"" " &
"stroke=""black"" stroke-width=""1.5"" fill=""green""/>\n",
PX[Start]-8, PY[Start]-8 >>SVGFILE;
printf "</svg>\n" >>SVGFILE;
end;
```

-----

## 7.6 MILP Models – Summary

Several optimization problems were presented where **Mixed-Integer Linear Programming (MILP)** models are an appropriate solution technique, while further capabilities of the GNU MathProg language were demonstrated.

  * The **knapsack problem** and the **multi-way number partitioning problem** are easy examples of models involving **discrete decisions** and requiring **integer variables**.
  * **Tiling** can also be addressed by MILP approaches, provided that our choices for tile placement are finite. This was demonstrated on the tiling of an arbitrary rectangle with cross-shaped tiles. Specific **set and parameter definitions** allowed for a more concise model formulation.
  * The **assignment problem** is a well-known optimization problem and was implemented as an MILP model, turning out to be no more difficult than its **Linear Program (LP) relaxation**. The functionality of making **a priori decisions** for a model was demonstrated with the assignment problem.
  * Some problems on **weighted graphs** were also addressed. The **shortest path problem** and the **minimum weight spanning tree problem** were both formulated as an MILP model using similar techniques. The core idea was the **management of imaginary material flows** through the edges of the graph.
  * Finally, the **Traveling Salesperson Problem** was solved as a combination of the **assignment problem** and the **connectivity constraints** from the minimum weight spanning tree problem. **Visual output** was also produced by the GNU MathProg code itself, in **SVG format**.

The examples shown here included some of the most common **linear programming techniques** and their possible implementations. These can be part of more complex, real-world optimization problems. **Integer programming techniques** make a much wider range of problems solvable than pure LP models, but at the cost of **exploding computational complexity**.




# Chapter 8: Solution Algorithms

So far, the focus has been on $\text{LP}$ and $\text{MILP}$ **modeling techniques** and the details of **GNU MathProg implementation**. Mathematical programming models are solved by **dedicated solvers**. Typically, the modeling procedure can be performed without knowing how these solvers operate.

Nevertheless, expertise in the **solution algorithms** themselves can be valuable during modeling. It can aid in **designing models**, **improving their efficiency**, **choosing the appropriate solver tools and configurations**, and **interpreting results** and solver outputs. Therefore, this chapter aims to provide insight into how the models we describe in a modeling language are solved behind the scenes.

Operations research has a rich body of literature from the 1970s concerning solution algorithms. We recommend some books for interested readers. First, W. L. Winston's book [31] is a widely used handbook covering the main models and algorithms. We also suggest István Maros's book on Linear Programming [32] and the book by George Dantzig [33].

In fact, **Linear Programming (LP)** is a primary technique within operations research. There are several solution methods, most notably the **Simplex Method** and its different versions. The initial version, called the **Primal Simplex Method**, was introduced by George Dantzig in 1947. We will briefly introduce it in the next section by solving a simple production problem.

---

## 8.1 The Primal Simplex Method

Consider the following table, which contains the data for a production problem:

| | P1 | P2 | P3 | P4 | P5 | Cap |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Res1 | 1 | 2 | 1 | 3 | 0 | 24 |
| Res2 | 0 | 1 | 1 | 5 | 1 | 43 |
| Res3 | 1 | 0 | 0 | 2 | 2 | 18 |
| **Profit** | **19** | **23** | **15** | **42** | **33** | |

The meaning of the data is similar to the production problems mentioned previously (see Problem 9 from Chapter 5).

We have a small factory that can produce several products ($\text{P}1, \ldots, \text{P}5$). We use three **resources** for production. Each product column shows the number of units required from each resource, respectively, to produce one unit of the corresponding product. For example, producing one unit of product $\text{P}4$ requires 3 units from $\text{Res}1$, 5 units from $\text{Res}2$, and 2 units from $\text{Res}3$. A resource can be a raw material, a human resource, electricity, etc. We can produce as much of the products as we want, provided the production doesn't exceed the available **capacities** of the resources. For example, if we produce 8 units of $\text{P}2$ and 1 unit of $\text{P}4$, the total consumption from the first resource will be $8 \cdot 2 + 1 \cdot 3 = 19$ units. The usage of the other resources is calculated similarly. We earn a certain **profit** from the production, which is a linear combination of the production plan and the profit coefficient vector. If the production vector is $x(0, 8, 0, 1, 0)$, and we introduce the profit vector $c(19, 23, 15, 42, 33)$, the earned profit would be $c \cdot x = (19, 23, 15, 42, 33) \cdot (0, 8, 0, 1, 0) = 226$. Our goal is to find a production plan that satisfies all constraints and maximizes the earned profit.

Denoting the matrix of resource coefficients by $A$ and the capacity vector by $b$, our problem can be written in the general $\text{LP}$ format:
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
In this model, writing $x \ge 0$ is a shorthand for writing out all non-negativity constraints for the $x$ variables, and the same holds for the $s$ vector. Instead of the system of equations, we can use a compact form called the **simplex tableau**, shown below.

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $s_1$ | 24 | 1 | **2** | 1 | 3 | 0 | 1 | 0 | 0 |
| $s_2$ | 43 | 0 | 1 | 1 | 5 | 1 | 0 | 1 | 0 |
| $s_3$ | 18 | 1 | 0 | 0 | 2 | 2 | 0 | 0 | 1 |
| $z$ | 0 | -19 | -23 | -15 | -42 | -33 | 0 | 0 | 0 |

Note that there are several equivalent versions of the simplex tableau. Here, we place the **basis solution** on the left-hand side, and the extra row for the **objective function** at the bottom. These specific choices are not fundamentally important.

Here, **B** stands for the **basis**, which is a maximal linearly independent set of vectors. Currently (initially), $B = \{s_1, s_2, s_3\}$, composed of the three unit vectors. The corresponding **basic feasible solution** is $x_B = (0, 0, 0, 0, 0, 24, 43, 18)$. This is a solution to the linear system; moreover, every variable is non-negative (i.e., the solution is **feasible**), and any non-zero component in the vector corresponds to a basis vector.

The tableau contains all the data, plus an extra row. How do we define the objective function's extra row? It simply contains the **negatives** of the $c$ vector coefficients.

The following theorem is crucial:

> **Theorem 1** Exactly one of the following options occurs:
>
> a) There is **no negative entry** in the last row. In this case, the corresponding basic feasible solution is **optimal**.
>
> b) There is a negative value in the last row such that there is **no positive value** in its column. In this case, there is **no optimal solution**, as the objective value is not bounded from above.
>
> c) Otherwise (there is a negative value in the last row, but for every such value, a positive value exists in its column), we can perform a **basis transformation** so that the corresponding objective value is not smaller.

Since this is only a brief overview of the simplex method, we won't prove the theorem; interested readers can find the proof in any of the suggested books. However, we will demonstrate the transformation process. Each transformation **exchanges one vector in the basis for another** not already present.

Let's assume we choose the column of $a_2$ (the most negative coefficient in the objective row, -23) for the vector that **enters the basis**. The vector that **leaves the basis** is determined by a rule called the **minimum ratio test**. We calculate the following minimum: $\min \{24/2, 43/1\}$. The numerator is taken from the current basic solution ($x_B$), and the denominator is taken from the same row but in the chosen entering column ($a_2$). We **cannot divide by zero** or a **negative value**.

The minimum is $24/2 = 12$, which means the vector in the row corresponding to 24 ($s_1$) must be chosen as the **leaving vector**. The value $\mathbf{2}$ is called the **pivot number**, which is bolded in the initial tableau.

How is the transformation performed?
* The pivot row (the $s_1$ row) is divided by the pivot value (2).
* $1/2$ times the pivot row is subtracted from the second row ($s_2$).
* $0/2$ times the pivot row is subtracted from the third row ($s_3$).
* $23/2$ times the pivot row is **added** to the objective row ($z$).

In the above calculations ($1/2$, $0/2$, and $23/2$), the numerator comes from the column of the pivot value, and the denominator is always the pivot value. The purpose of choosing these factors is to perform row operations that eliminate every element in the pivot column (other than the pivot element) to zero.

After the transformation, we get the following tableau:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_2$ | 12 | 1/2 | 1 | 1/2 | 3/2 | 0 | 1/2 | 0 | 0 |
| $s_2$ | 31 | -1/2 | 0 | 1/2 | 7/2 | 1 | -1/2 | 1 | 0 |
| $s_3$ | 18 | 1 | 0 | 0 | 2 | **2** | 0 | 0 | 1 |
| $z$ | 276 | -15/2 | 0 | -7/2 | -15/2 | -33 | 23/2 | 0 | 0 |

Now, let's choose the column of $a_5$ to enter the basis (as it has the most negative objective coefficient, $-33$). According to the minimum ratio test: $\min \{\text{N/A}, 31/1, 18/2\}$. Division by $0$ or a negative value (for $\text{a}_5$ in the $a_2$ row) is not allowed. The minimum is $18/2 = 9$. Thus, $s_3$ is the leaving vector.

After the transformation, we get:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_2$ | 12 | 1/2 | 1 | 1/2 | 3/2 | 0 | 1/2 | 0 | 0 |
| $s_2$ | 22 | -1 | 0 | 1/2 | 5/2 | 0 | -1/2 | 1 | -1/2 |
| $a_5$ | 9 | 1/2 | 0 | 0 | 1 | 1 | 0 | 0 | 1/2 |
| $z$ | 573 | 9 | 0 | **-7/2** | 51/2 | 0 | 23/2 | 0 | 33/2 |

Only one negative entry remains in the last row: the column of $a_3$ (with $-7/2$). We must choose this column to enter the basis. According to the minimum ratio test: $\min \{12/(1/2), 22/(1/2), \text{N/A}\}$. The minimum is $12/(1/2) = 24$. Thus, $a_2$ is the leaving vector.

As we've observed, the rule for the objective function change is:
* If we choose a column to enter the basis where the objective row value is **negative**, the consequence is that the **objective value increases**.
* If we choose a column where the objective row value is **positive**, the objective value will **decrease** (which we avoid since our goal is to maximize the objective).
* If we choose a column where the objective row value is **zero**, there will be **no change** in the objective value.

Note that this rule about the entering column choice and the objective change is only true if the basic solution is **non-degenerate**, meaning that if the current basis is $B(a_2, s_2, a_5)$, then all of $x_2, s_2, x_5$ are positive. If the value of the variable in the basic solution in the pivot row were zero, there would be no change in the basic solution column, so there would be no change in the objective.

Let's see what happens after the final transformation:

| **B** | **$x_B$** | **$a_1$** | **$a_2$** | **$a_3$** | **$a_4$** | **$a_5$** | **$s_1$** | **$s_2$** | **$s_3$** |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $a_3$ | 24 | 1 | 2 | 1 | 3 | 0 | 1 | 0 | 0 |
| $s_2$ | 10 | -3/2 | -1 | 0 | 1 | 0 | -1 | 1 | -1/2 |
| $a_5$ | 9 | 1/2 | 0 | 0 | 1 | 1 | 0 | 0 | 1/2 |
| $z$ | **657** | 25/2 | 7 | 0 | 36 | 0 | 15 | 0 | 33/2 |

We can see there are no more negative entries in the last row, which means (according to Theorem 1) that the current solution is **optimal**. This optimal solution is $x_B = (0, 0, 24, 0, 9 \mid 0, 10, 0)$. The vertical line separates the first five variables (the original product variables) from the last three (the slack variables), as their meanings are different. The solution means that in the optimal plan (where the profit is maximized while all constraints are satisfied), we need to produce **24 units of the third product** and **9 units of the fifth product**. Furthermore, **10 units of the second resource remain unused**; the full capacities of the other two resources are completely consumed.

We performed three transformations, but the final tableau could have been reached with only two transformations (since only $a_3$ and $a_5$ needed to replace vectors in the original basis). It is not easy to know in advance which transformations will lead to the final state in the fewest steps. However, several tricks can help. For example (for a small problem like this), it might be beneficial to choose the vector to leave the basis that results in the largest possible increase in the objective function.

Other issues can complicate the problem, such as the very rare occurrence of **"cycling,"** which means returning to a basis that was previously visited after several transformations. This case is rarely seen in practice.

Another point is that in many cases, before solving a problem, we can perform some **pre-processing**, e.g., identifying and deleting constraints that are **redundant** (meaning that removing the constraint does not change the optimal solution of the remaining system).

What happens if the factory introduces a new (a sixth) product, where the data for its resource need is given by $a_6$? We can easily realize that there's no need to repeat the entire computation. We only compute the column of the new product. The transformed form of the $a_6$ vector can be written as $B^{-1}a_6$, where $B$ is the current basis, and $B^{-1}$ is its inverse. We then insert this column vector into the tableau. If the coefficient of this new vector in the last row (calculated as $c_B B^{-1}a_6 - c_6$) is non-negative, it means producing this new product is **not advantageous**. Otherwise, this value is negative, and only this one is negative in the last row. Then, we continue the transformations as before.

For example, suppose the column of the new product is $a_6 = (1, 2, 1)^T$, where the components represent the resource consumption from the three resources for producing one unit of this new product (say, product $\text{P}6$). Furthermore, let $c_6 = 35$, which is the profit gained from producing one unit of this product.

Note that the current basis is:
$$B(a_3, s_2, a_5) = \begin{bmatrix} 1 & 0 & 0 \\ 1 & 1 & 1 \\ 0 & 0 & 2 \end{bmatrix} \quad \text{and} \quad B^{-1} = \begin{bmatrix} 1 & 0 & 0 \\ -1 & 1 & -1/2 \\ 0 & 0 & 1/2 \end{bmatrix}.$$

We can also find the inverse in the last three columns of the simplex tableau. Thus, $B^{-1}a_6 = (1, 1/2, 1/2)^T$, and $c_B B^{-1}a_6 - c_6 = (15, 0, 33) \cdot (1, 1/2, 1/2) - 35 = -7/2$. This negative value means the production of the new product is **advantageous**, and the procedure will continue, with the vector representing the new product entering the basis.

Finally, we mention an article that discusses various pivoting rules [34].

---

## 8.2 The Two-Phase (Primal) Simplex Method

Here, we will briefly introduce the **Two-Phase Method**. What has been shown previously is, in fact, the **second phase** of this method. Therefore, we need to show the **first phase**.

The goal of the first phase is to **find a basic feasible solution**. In the second phase, starting from this feasible solution, we proceed step-by-step to find an **optimal solution**. When is the first phase needed? It's needed when we are **not able to begin** with a suitable feasible solution.

We will illustrate the first phase with an example. Let's assume our $\text{LP}$ is:
$$\begin{array}{rcccccccc}
x_1 & +2x_2 & +x_3 & +3x_4 & & & & \ge & 24 \\
& x_2 & +x_3 & +5x_4 & +x_5 & & & \le & 43 \\
x_1 & & & +2x_4 & +2x_5 & & & = & 18 \\
19x_1 & +23x_2 & +15x_3 & +42x_4 & +33x_5 & = & z & \to & \max \\
& & x_i \ge 0, 1 \le i \le 5
\end{array}$$

We've slightly modified our original example. This could be interpreted as needing to use **at least 24 units** of the first resource, being able to use **at most 43 units** of the second resource (as before), and needing to consume the **entire amount** of the third resource.

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

We call $t_1$ and $t_2$ **artificial variables**; we use them, but we are "not allowed" to use them. The original equation system has a feasible solution (where all equations are satisfied with the bounded $x$ and $s$ variables) if and only if we can **eliminate the artificial variables** from the system. So, our goal is to eliminate them, which is the task of the first phase. Our technique is to introduce an **artificial (or secondary) objective function** as $\hat{z} = -t_1 - t_2$. Instead of the original objective function $z$, we will **maximize $\hat{z}$** in the first phase (using the same maximization method shown earlier). If the maximum value of $\hat{z}$ is **zero**, it means we have successfully eliminated the artificial variables, and we can continue with the second phase, where we return to the original objective function $z$. Otherwise, if the maximum of $\hat{z}$ is **negative**, it means the original $\text{LP}$ cannot be solved without the artificial variables, i.e., it **does not have a feasible solution**.

---

## 8.3 The Dual Simplex Method

Besides the Primal Simplex Method, the **Dual Simplex Method** is the other main version. We introduce it briefly. Let's consider the following $\text{LP}$:
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

At first glance, we can see that this simplex tableau is different from the previous form. There are **only non-negative values** in the last row. We call this property that the basic solution is **dual-feasible**. However, the basic solution is **not primal-feasible**; there are negative values in the $x_B$ column. In fact, all values are negative or zero, as the basic solution is $x_B = (0, 0, 0, -1, -3, -5, -7)$. If, after several transformations, we can reach a tableau that is **both dual and primal feasible**, it means we have found the optimal tableau. Note that in the Primal Simplex Method (Phase 2), we move through primal feasible solutions, while in the Dual Simplex Method, we move through dual feasible solutions.

Here is the rule for the transformation:
* We choose a row where the coordinate of the basic solution is **negative** (this basis vector will **leave the basis**).
* From this row, we must choose a **negative pivot value**.
* We apply an appropriate version of the minimum ratio test for choosing the **entering column**.

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

The **Gomory cut** is a primary tool for finding **integer solutions** for an $\text{LP}$. If we require that the variables of an $\text{LP}$ must be integer numbers, the model is called an **Integer Linear Program ($\text{ILP}$)**. In many cases, some variables are required to be integers, but others can be real values; this is called a **Mixed-Integer Linear Program ($\text{MILP}$)**.

Solving an integer (or mixed-integer) program is typically much harder. There are several tools to handle the integrality of variables; we will show only one such commonly used method. We will demonstrate the method using an example. The example comes from a book by András Prékopa, as mentioned in Tamás Szántai's manuscript [35], page 28 (in Hungarian), and also shown in Mihály Hujter's short (Hungarian) draft [36]. Note that we perform the calculations in a slightly different manner to maintain uniformity with our presentation of the Primal and Dual Simplex tableaux.

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

Let's choose a fractional variable, e.g., $x_1 = 1/8$. Let's also consider the row of this variable in the tableau, where the data means:
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

# Chapter 9: Summary

The capabilities of the **GNU MathProg modeling language** were presented using various problems. This included solving linear equation systems, the production and diet problems and their common extensions, the transportation problem, various general cost functions, and integer programming techniques through common optimization problems.

**Mathematical programming** generally offers a simple, practical solution for the class of problems it's suited for. **$\text{MILP}$** models can be used for a much wider range of cases than their purely **$\text{LP}$** counterparts. Nevertheless, both problem classes are useful in their own right.

Using our expertise in GNU MathProg gives us a **unique tool** for solving complex optimization problems. While the solution speed may not be the fastest available for a particular problem, the **ease of implementation**, **code maintenance**, and **adaptability to changes** in the problem definition make the methodology valuable for both industrial and scientific purposes.

Typically, a single **model file** is developed to address all problem instances, which are implemented in their own **data files**. The **glpsol** solver can parse the language and solve the model simultaneously, and user-defined output can also be generated.

We also provided insight into how $\text{LP}$ models can be solved by the **Simplex Method** and one technique for integer programming problems, the **Gomory cut**. These only serve as an introduction to how $\text{LP}/\text{MILP}$ solver software works in the background. While we can treat solvers as **black boxes**, a basic knowledge of them can be useful for developing mathematical programming models, improving them, and better understanding their results.

Note that there are many approaches other than the main line shown in this Tutorial. We'll mention a few concluding points:

* The GNU MathProg language and a parser/solver like glpsol can be used alone to develop and solve models, but note that the GLPK software kit offers **other features**, most notably a **callable library**. Accessing linear programming tools from a programming language can be better in the long term than using standalone GNU MathProg model files. For instance, in GNU MathProg, we cannot "change" the value of a parameter, which limits input data processing possibilities.
* Different **configurations** of the glpsol solver were only briefly touched on in this Tutorial. Applying the appropriate **heuristics** or **alternative solution methods** can speed up the search.
* The glpsol solver is an easy-to-use tool, but it's probably **not the fastest** $\text{LP}/\text{MILP}$ solver. Other free solvers may be superior if performance is an issue, for example, $\text{CBC}$ [7] or $\text{lpsolve}$ [8]. **Commercial $\text{MILP}$ solvers** can be even much better. We can use alternative solvers with GNU MathProg models, as glpsol supports exporting a model into well-known formats.
* GNU MathProg is **not the only language** for linear programming. There are dozens of other languages, each with its own class of models, input/output formats, and solvers to support.
* **$\text{LP}$ and $\text{MILP}$ are not the only mathematical programming problem classes** with general-purpose solvers. If specific **nonlinear objectives and constraints** are needed to model a situation, then we might try developing a **Nonlinear or Mixed-Integer Nonlinear Programming ($\text{NLP}$ or $\text{MINLP}$)** model in an adequate environment. Remember, more general tools can be much more costly in terms of running time.
* Mathematical programming is a powerful tool, but some problems have **much more effective algorithmic solutions**. Sometimes developing a specific algorithm can yield better results, although often at the cost of more coding.
* Throughout this Tutorial, we only solved models **in their entirety**, resulting in a final answer. Generally, mathematical programming tools can be used as **part of an algorithmic framework**. For example, a large problem can be **decomposed** into several different models that are solved separately or sequentially. Alternatively, an $\text{LP}/\text{MILP}$ model can serve as a **relaxation** for a more complex optimization problem, and as such, provide a **bound** for its objective function.

We hope the reader finds this Tutorial helpful and motivating for solving real-life optimization problems in the future.

 
