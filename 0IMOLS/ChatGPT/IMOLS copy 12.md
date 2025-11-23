
# Under the hood: Branch and Bound algorithm

## General framework algorithm for solving discrete problems.

**Prerequisites**
Brute force approach and enumeration of feasible solutions

We saw in the festivals example that brute force is a potentially extremely slow, yet valid, method for finding an optimal solution when the search space is discrete and finite. We also mentioned several acceleration ideas, some of which can be applied more generally. Let’s now focus on enumerating only the feasible solutions.

Enumerating all solutions was straightforward in the festivals example—traversing all subsets of a set is easy. We only need to count from 0 to
2ⁿ − 1
and interpret each number’s binary representation as a subset indicator. However, many of those subsets are infeasible, and things become more complicated when we want to generate only feasible solutions. Try to figure out an approach yourself, or click the button below.

There are many ways to do this, but a simple approach would follow these steps:

We either go to F1 or not.

If we don’t go to F1, we either go to F2 or not.
If we don’t go to either F1 or F2, we either go to F3 or not.
If we don’t go to F1, F2, or F3, we must go to F4 because that’s the last option for Apocalyptica and Haggard.
If we go to F4 but not to F1, F2, or F3, we must go to F5, as that is the last option for several bands.
We go to F4 and F5 but not to F1, F2, or F3. There are no decisions left, and we have a solution with 2 festivals.
If we don’t go to F1 or F2 but go to F3, we must go to F4 because that’s the last option for Apocalyptica and Haggard.
If we go to F3 and F4 but not to F1 or F2, we either go to F5 or not.
If we go to F3 and F4 but not F1, F2, or F5, we have a solution with two festivals.
If we go to F3, F4, and F5 but not F1 or F2, we have a solution with three festivals.
If we go to F2 but not to F1, we can either go to F3 or not...
If we go to F1, we either go to F2 or not...

A tree-style enumeration of the feasible solutions appears in the approach above:

* The root of the tree represents the case where no decisions have been made.
* The leaves represent solutions where all decisions have been made.
* At each non-leaf node, a decision is made, with all possible outcomes “encoded” in its children.

```
No decision
  go to F1
    ...
  don’t go to F1
      go to F2
        ...
      don’t go to F2
           go to F3
           go to F4
           go to F5      don’t go to F5
      don’t go to F3
           go to F4
           go to F5
```

Another way to view the same tree is:

* The root represents the set of all feasible solutions.
* The leaves are individual solutions (more precisely: solution sets containing a single element).
* At each non-leaf node, a decision is made that divides the node’s set into subsets, which become its children.

---

### The “Branch” part

The approach described above generalizes to any problem with discrete decisions:

1. Take the set of all feasible solutions and assign it to the root node of a tree.
2. For each tree node whose set is not a singleton, select a decision that must be made and partition the node’s set so that each subset contains the solutions corresponding to a specific decision outcome. Assign these subsets to the children. Do not create children for empty subsets.
3. If a node’s set is a singleton, it becomes a leaf, and the solution can be evaluated.

Note that in general, Branch and Bound algorithms do not require the branching step to produce disjoint subsets—only subsets whose union covers the original set. Empty subsets may also be represented and further partitioned into empty subsets, and singleton sets may be partitioned into empty and singleton sets for reasons explained later.

In practice, the sets assigned to nodes are usually not generated or partitioned explicitly. Instead, we maintain the outcomes of previous decisions, and at each node, we somehow check whether:

1. There exists at least one feasible solution consistent with the previous decision outcomes.
2. If yes, whether there is more than one solution in that set.

These checks do not have to be 100% precise, but they must identify empty and singleton sets with complete certainty. It is acceptable for the “emptiness tester” to say “I’m not sure” and treat the set as non-empty, but it must never declare a non-empty set empty. The same applies for detecting singletons.

Given this branching algorithm, we can extend it with a minimum search over the leaves.

---

### The “Bound” part

Consider a simple shortest-path problem: I currently live in Győr, and my parents live in Nagykanizsa. Let’s assume I want to drive home using the shortest possible route, using only main roads (1- or 2-digit numbers) and avoiding highways to skip tolls.

This problem can obviously be solved optimally and efficiently using Dijkstra’s algorithm. Thus, the approach shown here is purely illustrative, not a recommended method for this problem type.

A simple way to split all feasible routes into subsets is to make a decision about the first segment of the route, which could be:

* Driving on road 1 to Mosonmagyaróvár
* Driving on road 85 to Csorna
* Driving on road 83 to Városlőd
* Driving on road 82 to Veszprém
* Driving on road 81 to Kisbér
* Driving on road 1 (in the opposite direction) to Komárom

A child node is created for each of these 6 options; for example, the fourth node represents all solutions that start with Győr–Veszprém–... For each node, branching continues in the same manner; for instance, the route Győr–Veszprém can continue with:

* Driving on road 8 to Városlőd
* Driving on road 77 to Lesencetomaj
* Driving on road 73 to Csopak
* Driving on road 8 to the junction near Litér

We do not list the option of driving road 82 back to Győr, as circular routes are irrelevant.

This process continues for all nodes until we reach Nagykanizsa. If the partial route of a node already ends in Nagykanizsa, that node must be a leaf, since that route is the only circular-free feasible solution beginning with that prefix. The route length can then be evaluated in the minimum search.

However, the approach is inefficient. Suppose we have already found the following leaf:
“Győr – Veszprém – Csopak – Balatonederics – Keszthely – Fenékpuszta – Balatonszentgyörgy – Nagykanizsa”
with length 217 km.

When we find this solution, there may be other unexplored nodes with partial routes, such as:
“Győr – Komárom – Budapest – Szolnok.”

Following the earlier naive procedure, we would create two child nodes (branching on the next segment) to Jászberény or Törökszentmiklós.

But we can observe that the route to Szolnok is already 227 km long—longer than the feasible solution we found earlier. Therefore, there is no reason to explore this subtree, as all its solutions must be worse than the one already found. We can prune this node (this subset of solutions) and move on.

What we did here was assign a lower bound to all solutions in that subtree and prune the subtree when the bound exceeded the best solution found so far. This idea generalizes to any problem class if we can compute a lower bound for a subset of solutions.

A general pseudo-code outline of the Branch-and-Bound framework is as follows:

---

Set
**min** = ∞
Let
S = {S}, where S is the set of all feasible solutions.

While S is not empty:
 Select and remove an element from S and call it P
 If the lower bound on P exceeds **min**, prune P and continue
 Otherwise:
  If P is a singleton, check its value and update **min**
  If P is not a singleton, find a decision to further partition it, creating
  P₁, P₂, …, and add the non-empty subsets to S

If **min** is not infinity, an optimal solution exists; otherwise, no feasible solution exists.

---

Note that this is a framework algorithm used for many problem classes. Details must be specified, such as:

* How P is selected (i.e., the rule for choosing the next node)
* Which decision is selected for branching
* How the bound function works
* How to determine whether P is a singleton or empty

For the illustration above, we used the length of the “already traveled path” as a lower bound and branched based on the next segment.

If the problem is a maximization problem, we need upper bounds, and we prune P if its bound is lower than the current best solution (max). Bound functions typically must return the exact value for singleton sets. With that property, no extra check is needed when P is a singleton—its bound already reveals whether it improves the best known value.

---

### Note about bounding functions

The *tightness* of the bounding function is often the most important factor affecting algorithmic efficiency. If the bound is loose—meaning it is far from the actual best value in P—pruning will occur deeper in the tree, forcing unnecessary exploration.

Returning to the previously pruned path “Győr – Komárom – Budapest – Szolnok”:
its parent was “Győr – Komárom – Budapest”, which had seven siblings. The bound for this parent is 126 km—far below the already found 217 km solution. Thus, all eight children are generated. Intuitively, looking at the map, Budapest is east of Győr while Nagykanizsa is southwest, so this is clearly a bad direction. Still, we must generate the children—and maybe grandchildren—to prove this, because our bound is not tight.

Our previous bound did not include any estimation for the remaining distance still to travel after the current endpoint. But it is easy to provide such a bound: add the geographical distance from the endpoint of the current path to Nagykanizsa.

For the “Győr – Komárom – Budapest” node, the Budapest–Nagykanizsa distance is 190 km.
Adding them: 126 + 190 = 316 km.
This is a valid lower bound, since any completion of that route must be at least 190 km longer. 316 km is far greater than 217, so with this tighter bound we can prune the node “Győr – Komárom – Budapest” itself, without generating its children or grandchildren.

Note that we may prune “Győr – Komárom – Budapest” only if we already have a solution shorter than 316 km. Thus, the strategy used to explore the tree can be as important as having a tight bound.

It seems we should always push for tighter and tighter bounds to shrink the B&B tree as much as possible. However, tighter bounds often require more complex calculations. A slightly tighter bound might not prune enough nodes to compensate for the extra computation cost at each node. Choosing the best-performing bound is nontrivial and often done statistically.

---

### Final notes

The purpose of this lecture is to give a brief insight into how the discrete part of an optimization problem is typically handled by a solver.

 