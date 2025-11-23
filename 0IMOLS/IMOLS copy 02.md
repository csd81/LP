Motivational example: fröccs
A continuous decision problem for motivation, and to discuss basic concepts and principles

---

**Prerequisites**
Ányos Jedlik was a famous Hungarian engineer and priest, best known for inventing the dynamo and a machine for efficiently producing carbonated water. According to some legends, he was also the first to come up with the idea of mixing this water with white wine to make a refreshing drink. The resulting beverage is called *fröccs*, or *spritzer* in some German-speaking countries.

Disclaimer: Writing “carbonated water” every time below would be a pain, so I’ll just use the word *soda* instead. I’m fully aware that in some countries this might mean Coke or other soft drinks, so please be aware of that and don’t start mixing Coke with white wine. (If you absolutely must, mix it with red wine to get a *Vadász*.)

---

**Problem description**
Imagine that we manage a bar that sells only the following types of fröccs, with the prices listed below:

| Name          | Translation      | Wine (dl) | Soda (dl) | Price (HUF) |
| ------------- | ---------------- | --------- | --------- | ----------- |
| Kisfröccs     | Small fröccs     | 1         | 1         | 110         |
| Nagyfröccs    | Large fröccs     | 2         | 1         | 200         |
| Hosszúlépés   | Long step        | 1         | 2         | 120         |
| Házmester     | Housekeeper      | 3         | 2         | 260         |
| Viceházmester | Vice-housekeeper | 2         | 3         | 200         |
| Krúdy fröccs  | Krúdy fröccs     | 9         | 1         | 800         |
| Sóherfröccs   | Stingy fröccs    | 1         | 9         | 200         |
| Puskás fröccs | Puskás fröccs    | 6         | 3         | 550         |

You might not be familiar with the unit *deciliter* (dl), which equals one-tenth of a liter. If you visit Hungary, wine, soda, and most other drinks are typically served in deciliters. (Strong spirits are usually measured in centiliters, cl.) As you can see, some of these drinks have cultural references: for example, the Puskás fröccs honors a famous soccer match that Hungary won against England in 1953. If you ever try fröccs in Hungary, keep in mind that prices can vary a lot from place to place. The prices above are just rough estimates for a small village bar in 2018. There are many more variants in reality, but we’ll stick to these eight for now.

After that cultural detour, let’s get back to defining our optimization problem: we have a fixed daily stock of 100 liters of wine and 150 liters of soda, and we want to maximize profit. We’ll make a few assumptions:

* Guests always ask us what to drink.
* Our guests are always thirsty.
* Guests accept “partial” servings too; for example, we can sell half a Krúdy fröccs for 400 HUF.

I’m well aware this is a very idealized and unrealistic example, but it will serve our purpose for now. Also, the profit we calculate this way will be a strict upper bound on the real profit we could achieve in a more realistic setting where these assumptions don’t hold.

---

**Trial and error approach**
Just like in the festivals example, first try to find a good solution by hand. You can do it on paper, in Excel, or using the simple tool below.

 

---

**Applying the ideas from the festivals example**
If you don’t remember them, follow the link above, reread that material, and then try to figure out for yourself which ideas can be reused here and which cannot.

---

**Brute force approach**
Our third assumption above was that we allow “proportional servings” of these drinks. It’s easy to see that this leads to an infinitely large set of possible solutions. If we restrict ourselves to rational numbers only, then the set is “just” countably infinite; if we also allow irrational proportions, then the set of solutions has the same cardinality as the real numbers. Either way, no brute force algorithm can enumerate all of them.

---

**Greedy approach**
You can usually come up with some kind of greedy strategy for almost any problem, and this one is no exception. Several versions could be designed; here are just a few examples:

* Krúdy fröccs is the most expensive drink, so sell as much of that as possible.
* Based on the wine/price ratio, Sóherfröccs is the “most expensive” (or most profitable per unit of wine), so sell as much of that as possible.
* Since we have 1.5 times as much soda as wine, wine is 3/2 times the “more valuable resource.” Based on this, we could compute a price-per-ingredient-value ratio for each drink and produce as much as possible of the one that ranks highest on that list.

Typically, a greedy algorithm would then say something like: “Next, pick the second most valuable item and sell as much as possible of that, and continue this until we can’t sell anything more.” In our case, however, we only have 2 ingredients, and every drink requires some amount of both, so there’s no natural multi-step iteration of this kind. This sort of iterative greedy approach becomes more meaningful when there are more ingredients and products, and not all products require all ingredients.

Just like with the festivals problem, a greedy strategy here will not necessarily give an optimal solution.

---

**Simplify the problem by presolve**
Some of the drink types above simply aren’t worth selling. Try to figure out which ones and why, then click the button to see if you’ve found them all.

The easiest one to notice is probably the Puskás fröccs, because it is equivalent to selling 3 Nagyfröccs. Three Nagyfröccs bring in 600 HUF, while one Puskás fröccs earns only 550 HUF.

Házmester is a bit trickier. It’s equivalent to selling one Kisfröccs plus one Nagyfröccs. That combination would give us 310 HUF, whereas a Házmester only brings in 260 HUF. Similarly, instead of selling Viceházmester, it’s better to sell one Kisfröccs and one Hosszúlépés, which yields 230 HUF instead of 200 HUF.

The remaining types are:

| Name         | Wine (dl) | Soda (dl) | Price (HUF) |
| ------------ | --------- | --------- | ----------- |
| Kisfröccs    | 1         | 1         | 110         |
| Nagyfröccs   | 2         | 1         | 200         |
| Hosszúlépés  | 1         | 2         | 120         |
| Krúdy fröccs | 9         | 1         | 800         |
| Sóherfröccs  | 1         | 9         | 200         |

Another easy observation is that if we sell one Nagyfröccs and one Hosszúlépés, that uses 3 dl of wine and 3 dl of soda and generates 320 HUF of income. That’s less than selling 3 Kisfröccs for 330 HUF using exactly the same amount of ingredients. This means Nagyfröccs and Hosszúlépés will definitely not appear together in an optimal solution. Similarly, selling 10 Kisfröccs is better than selling one Krúdy fröccs plus one Sóherfröccs.

As a result, we know that in the optimal solution at most 3 different types of fröccs will be sold, but we can’t remove any more rows from the table just yet.

What we did when we eliminated some fröccs types was to “cook up” a recipe for how to reproduce that drink using other types in a way that yields more profit. If we order the remaining types by their wine/soda ratio, we get:

| Name         | Wine/Soda ratio | Wine (dl) | Soda (dl) | Price (HUF) |
| ------------ | --------------- | --------- | --------- | ----------- |
| Krúdy fröccs | 9               | 9         | 1         | 800         |
| Nagyfröccs   | 2               | 2         | 1         | 200         |
| Kisfröccs    | 1               | 1         | 1         | 110         |
| Hosszúlépés  | 0.5             | 1         | 2         | 120         |
| Sóherfröccs  | 0.111           | 1         | 9         | 200         |

It’s easy to see that any fröccs type can be “cooked up” using a stronger and a weaker drink. If there are three types with decreasing wine/soda ratio A, B, C, then there exist non-negative numbers
λ_A, λ_C such that

λ_A · A + λ_C · C = B.

Here A, B, and C represent their ingredient vectors (wine, soda).

For example, consider Krúdy fröccs (A), Nagyfröccs (B), and Kisfröccs (C). Their ingredient vectors are:

A = (9, 1)
B = (2, 1)
C = (1, 1)

We want

(9, 1) · λ_A + (1, 1) · λ_C = (2, 1),

which leads to the system

9 · λ_A + 1 · λ_C = 2
1 · λ_A + 1 · λ_C = 1

The solution is

λ_A = 1/8 and λ_C = 7/8.

This means that one Nagyfröccs can be represented as 1/8 Krúdy fröccs plus 7/8 Kisfröccs (in terms of total ingredients). The profit from such a “mixture” would be

(1/8) · 800 + (7/8) · 110 = 196.25 HUF,

which is less than the actual price of a Nagyfröccs (200 HUF). This shows that selling Krúdy fröccs and Kisfröccs together is not a profitable combination.

Without explicitly stating it earlier, this is essentially the logic we used to show that Krúdy and Sóherfröccs are not a good pair, nor are Nagyfröccs and Hosszúlépés. The other possible outcome of solving such a system would be that the middle one (B) is less profitable than the mixture of A and C, in which case B could be eliminated.

Try eliminating some other fröccs types using this approach.

This kind of elimination is a glimpse into the logic behind the simplex method, which we’ll discuss later. If the stronger and weaker drinks are in the “basis,” the difference between the price of the middle drink and the price of the corresponding mixture will later be called the *shadow price*.

---

**Investigate only feasible solutions**
As discussed earlier for the brute-force approach, there are infinitely many possible solutions. The same is true even for the feasible ones, so this idea alone doesn’t help much. However, we could shrink the search space considerably by looking only at solutions that completely use up at least one of the ingredients. Such solutions can’t be improved by adding a little more of some drink on top, so a lot of clearly suboptimal solutions can be ignored.

Even then, if we look at just Kisfröccs and Nagyfröccs, it’s still easy to see there are infinitely many ways to use up all of our wine stock. Try to find such solutions yourself, and prove that there are infinitely many of them.

---

**Final notes**
This problem seems more difficult than the festivals example, because allowing proportional servings makes the number of solutions infinite. At this point, we might think that restricting the problem to whole servings only would make it easier, since the number of solutions would then be finite and, at least in principle, enumerable in a finite amount of time. Surprisingly, as we’ll see in later lectures, the opposite is true.
