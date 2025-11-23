Motivational example: festivals
A discrete decision problem used for motivation, and to introduce basic concepts and principles

---

**Problem description**
Who doesn’t like music and want to hear their favorite bands live at summer festivals? In this example, that’s exactly what we want to do, while spending as little money as possible. First, fill in the fields with the names of your favorite bands or performers, or just leave my selection as is.

Haggard
Stratovarius
Epica
Dalriada
Apocalyptica
Liva
Eluveitie

Now, let’s assume there are five festivals we can attend during the summer. For simplicity, we’ll call these festivals F1, F2, etc. The table below shows which band plays at which festival.

F1	F2	F3	F4	F5
Haggard	🗸		🗸	🗸
Stratovarius	🗸	🗸	🗸		🗸
Epica	🗸	🗸		🗸	🗸
Dalriada			🗸		🗸
Apocalyptica				🗸
Liva		🗸	🗸	🗸	🗸
Eluveitie			🗸		🗸

Let’s assume for now that tickets for all festivals cost the same, and our goal is to minimize how much money we spend over the summer while still hearing each of our favorite bands at least once.

---

**Solving the problem by hand**
For a problem of this size, it’s easy to solve it in a few minutes by hand, without any software, using trial and error. Try it yourself before clicking the button below.

It looks like going only to festivals F3 and F4 gives the best solution. But how can we be sure that this is really the optimal solution? A reasonable argument is that our solution uses 2 festivals. If this weren’t optimal, then the best solution would have to use at most 1 festival. By checking each of the 5 festivals individually, it’s easy to see that none of them alone covers all of our favorite bands.

Notice that this line of reasoning would be much harder to apply if the problem were larger, say with 30 bands and 50 festivals. If our presumed optimal solution used 9 festivals, then we would need to check all 8-element subsets of the 50 festivals — a very large number:
(\binom{50}{8} = 536878650.)

Now that we are confident that {F3, F4} is optimal, another question naturally comes up: is this the only optimal solution?

It’s easy to see that {F4, F5} is also a feasible solution with 2 festivals, so we can note that:

A problem may have one or more optimal solutions at the same time.

---

**What about a larger festival problem?**
A problem of this size can easily be handled by hand, but as the number of bands and festivals grows, this quickly stops being practical. Imagine a problem with 30 bands and 50 festivals. If the “performance matrix” (which band plays where) is not trivial, solving the problem will definitely require some sort of computer support.

Even if you have no background in optimization, as long as you have basic programming skills, you should be able to write a program in your favorite language to solve this problem. Try to design such an algorithm yourself, then continue by clicking the button.

The first key observation is that for each festival we make a yes-or-no decision: we either go or we don’t. This gives us (2^{50}) different possible solutions.

Some of these solutions satisfy all the constraints of the problem (i.e., every band is seen at least once); others do not. Solutions that satisfy all constraints are usually called good or feasible solutions; the others are called bad or infeasible.

In the matrix above, selecting {F1, F3, F4} is feasible, while {F1, F3} is infeasible, because we would miss Apocalyptica. Below is the complete list of the 32 subsets (for the smaller example) and whether they are feasible or not.

none	F1	F2	F2,F1
F3	F3,F1	F3,F2	F3,F2,F1
F4	F4,F1	F4,F2	F4,F2,F1
F4,F3	F4,F3,F1	F4,F3,F2	F4,F3,F2,F1
F5	F5,F1	F5,F2	F5,F2,F1
F5,F3	F5,F3,F1	F5,F3,F2	F5,F3,F2,F1
F5,F4	F5,F4,F1	F5,F4,F2	F5,F4,F2,F1
F5,F4,F3	F5,F4,F3,F1	F5,F4,F3,F2	F5,F4,F3,F2,F1

If we already have the finite set of all solutions, we just need to select the smallest one from among the feasible solutions, for example:

```
      S = generate_solutions();
      min = infinity
      for(s in S) {
        if (feasible(s)){
          if (value(s)<min) {
            min = value(s);
          }
        }
      }
```

or, if you prefer a functional programming style:

```
(min (filter (generate_solutions) feasible) value)
```

---

**Accelerating the solution procedure**
Let’s assume we implemented the algorithm above as efficiently as possible. It’s reasonable to say that evaluating one solution takes at least as long as a single floating point operation. As of today, the fastest supercomputer is Summit, with 200 petaflops of computational power. That means that even this machine couldn’t check more than about (10^{17}) solutions per second.

For our earlier example with 50 festivals, the full search would take more than (2^{50} / 10^{17}) seconds. Since (2^{10} \approx 10^{3}), that works out to about 10 milliseconds. That might sound fine for an average computer, but not for the fastest supercomputer of our time. And if the problem size grew to, say, 100 festivals, even this supercomputer would need more than 300,000 years.

Clearly, if we want to handle this kind of problem at practical sizes within a reasonable time, we need to speed things up using better ideas.

---

**Idea 1: Use a Greedy algorithm**
A natural intuition is that festivals with many bands should be prioritized and selected first. A simple algorithm based on this idea could work like this:

1. Select and include the festival with the most bands.
2. Remove the bands that are covered by the selected festival.
3. If there is at least one band left uncovered, go back to Step 1.

Applied to our original problem, this algorithm would first select either F3, F4, or F5, since all three cover 5 bands. This tie has to be broken somehow in the algorithm; we’ll always choose the leftmost festival. So F3 is selected first, and Haggard, Stratovarius, Dalriada, Liva, and Eluveitie are removed from the list, reducing the table to:

F1	F2	F4	F5
Epica	🗸	🗸	🗸	🗸
Apocalyptica			🗸

Since there are still two bands left, the algorithm continues by choosing the festival that covers the most of them, which is F4. Once we select F4, all bands are covered, so we end up with the solution {F3, F4}.

For this specific example, this so-called Greedy algorithm happens to give the optimal solution. For some classes of problems, we can prove that a greedy approach always finds an optimal solution. However, this problem is not one of those. It’s not hard to construct an example where this algorithm produces a suboptimal solution. Try to build such an example yourself.

F1	F2	F3
Haggard	🗸		🗸
Stratovarius		🗸	🗸
Epica	🗸		🗸
Dalriada		🗸	🗸
Apocalyptica	🗸
Liva		🗸

It’s easy to see that the optimal solution here is {F1, F2}, but the Greedy algorithm would first choose F3 and then include the other two as well.

In this setting, the Greedy algorithm is considered a heuristic: it usually gives a reasonably good solution quickly, but it cannot guarantee optimality (even if in some cases it still finds the optimal solution).

---

**Idea 2: Make inevitable decisions right away**
Looking back at the original problem, it’s obvious that Apocalyptica is rather “picky,” since they only play at F4. Therefore, F4 must be on our festival list no matter what. This decision can be made with 100% certainty without sacrificing optimality.

A less obvious observation is that F2 is dominated by F5: every band that plays at F2 also plays at F5, and F5 may cover even more bands. Even if there were an optimal solution that includes F2, there would also be an optimal solution where F5 is selected instead of F2. So we can safely ignore F2 from the start and reduce the size of the problem accordingly.

Simplifications of this kind are often implemented as a *presolve* procedure in modern optimization software. In the best case, they can solve the problem outright; in the worst case, the problem remains unchanged.

These simple tricks can usually be applied recursively. Note that F3 does not dominate F1 in the same way F5 dominates F2, because Epica plays at F1 but not at F3. However, once F4 is selected due to Apocalyptica, Epica becomes irrelevant (we’ll see them at F4 anyway). After selecting F4, F1 becomes dominated by F3 and can be dropped. Similarly, F3 and F5 become equivalent once F4 is included, so one of them can also be eliminated.

For this specific instance, these two straightforward presolve techniques are enough to solve the problem optimally.

---

**Idea 3: Investigate only feasible solutions**
In this particular example, half of all possible solutions were infeasible (see above). That means we’re wasting computation time checking many solutions that definitely won’t be optimal. In real-world problems, the proportion of infeasible solutions is often even higher, so it’s very attractive to design an approach that generates only feasible solutions.

Exploring this idea in depth is beyond our current scope, so we won’t present such an algorithm here — but you should be able to design one and implement it in your preferred programming language.

---

**Idea 4: Choose the order in which solutions are explored**
Since we care only about the smallest feasible subset of festivals, it makes sense to design the algorithm so that it first checks all single-festival subsets, then all 2-festival subsets, then all 3-festival subsets, and so on. That way, as soon as we find a feasible solution, we can declare it optimal and stop.

Unfortunately, the “best” search order or subproblem selection strategy can vary wildly between problem classes. In this particular class, if the optimal solution requires all festivals, then this algorithm would still end up checking all possible solutions.

---

**Final notes**
This problem class is known as the *Set Covering Problem*, which we have dressed up in a festival–band story. This problem class is known to be NP-Complete, meaning that unless P = NP, we cannot expect any “fast” algorithm that solves all large instances efficiently.
