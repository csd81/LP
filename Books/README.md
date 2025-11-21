\[cite\_start]You're looking at a \*\*mathematical optimization problem\*\* modeled in the \*\*AMPL\*\* language, specifically designed to determine the optimal arrangement of book sets onto a set of shelves to \*\*minimize the total height\*\* of the shelving unit\[cite: 3].



The model, `books.m`, defines the problem structure, variables, and constraints, while `books.d` provides the specific data (book dimensions, shelf parameters).



Here is a breakdown of the model, its objective, and the constraints it enforces, directly addressing the scenario described in the `Feladat.txt` file.



\## 📚 Problem Description

\[cite\_start]The goal is to arrange \*\*9 book sets\*\* (each treated as an indivisible unit) onto a maximum of \*\*7 shelves\*\*\[cite: 4, 7]. The constraints are:

1\.  \[cite\_start]\*\*Minimize the height\*\* of the highest used shelf\[cite: 3].

2\.  \[cite\_start]The shelves are \*\*120 cm wide\*\*\[cite: 3].

3\.  \[cite\_start]The lowest shelf starts at \*\*50 cm\*\*\[cite: 2].

4\.  \[cite\_start]There must be an \*\*offset of 7 cm\*\* above the tallest book on any shelf\[cite: 6].

5\.  \[cite\_start]Shelf thickness is \*\*2 cm\*\*\[cite: 7].



\## 📊 Data (from `books.d` and `Feladat.txt`)



\### Book Sets

\[cite\_start]The data defines the \*\*maximum height ($\\text{maxheight}$) of books\*\* in each set and the \*\*total width ($\\text{totalwidth}$) of the set\*\*\[cite: 8, 9, 10].



| Bookset | Total Width (cm) | Max Height (cm) |

| :--- | :---: | :---: |

| Math | 100 | 20 |

| IT | 80 | 25 |

| Sport | 30 | 30 |

| Music | 50 | 30 |

| Novel | 40 | 20 |

| Tolkien | 30 | 25 |

| Feist | 50 | 20 |

| HarryPotter | 90 | 25 |

| Diploma | 70 | 40 |



---



\### Shelf Parameters



| Parameter | Value (cm) | Description |

| :--- | :---: | :--- |

| $\\text{shelfcount}$ | 7 | \[cite\_start]Maximum number of available shelves\[cite: 7]. |

| $\\text{shelfwidth}$ | 120 | \[cite\_start]The width of each shelf\[cite: 3]. |

| $\\text{shelfthickness}$ | 2 | \[cite\_start]The thickness of each shelf\[cite: 7]. |

| $\\text{lowestshelf}$ | 50 | \[cite\_start]The starting position of the first shelf\[cite: 2]. |

| $\\text{offset}$ | 7 | \[cite\_start]The minimum space above the tallest book\[cite: 6]. |

| $M$ | 1000 | A large constant (used for conditional constraints). |



---



\## 💻 AMPL Model Components



\### Variables



\* $\\text{put}\[b,s]$: \*\*Binary\*\*. Is bookset $b$ placed on shelf $s$?

\* $\\text{isused}\[s]$: \*\*Binary\*\*. Is shelf $s$ used?

\* $\\text{shelfposition}\[s]$: The height (position) of the bottom of shelf $s$.

\* $\\text{shelfheight}\[s]$: The minimum required \*clearance height\* for shelf $s$ (determined by the tallest book on it).

\* $\\text{highestshelf}$: The maximum height reached by the shelving unit.



\### Objective



The goal is to \*\*Minimize Height\*\*:

$$\\min \\text{highestshelf}$$

This variable tracks the position of the highest used shelf.



\### Constraints



| Constraint Name | Purpose | Mathematical Description |

| :--- | :--- | :--- |

| `BooksetShelfAssignment` | \[cite\_start]\*\*Each book set goes on exactly one shelf\*\*\[cite: 5]. | $\\sum\_{s} \\text{put}\[b,s] = 1$ |

| `Shelfcapacity` | \*\*Total width of books on a shelf can't exceed the shelf's width\*\* ($120 \\text{ cm}$), and only applies to used shelves. | $\\sum\_{b} \\text{totalwidth}\[b] \\cdot \\text{put}\[b,s] \\le \\text{shelfwidth} \\cdot \\text{isused}\[s]$ |

| `MaxShelfHeight` | \*\*Sets the required clearance height for the shelf\*\* based on the tallest book on it. | $\\text{shelfheight}\[s] \\ge \\text{maxheight}\[b] \\cdot \\text{put}\[b,s]$ |

| `FirtsShelf` | \[cite\_start]\*\*Sets the position of the bottom of the first shelf\*\*\[cite: 2]. | $\\text{shelfposition}\[1] = \\text{lowestshelf}$ |

| `ShelfDistances` | \[cite\_start]\*\*Defines the minimum distance between consecutive shelves\*\*\[cite: 6, 7]. It's a conditional constraint using the large constant $M$. If $\\text{isused}\[s]=1$, then $\\text{shelfposition}\[s] \\ge \\text{shelfposition}\[s-1] + \\text{shelfheight}\[s-1] + \\text{offset} + \\text{shelfthickness}$. | $\\text{shelfposition}\[s] \\ge \\text{shelfposition}\[s-1] + \\text{shelfheight}\[s-1] + \\text{offset} + \\text{shelfthickness} - M \\cdot (1-\\text{isused}\[s])$ |

| `ShelfUsage` | \*\*If a shelf is unused, all subsequent shelves must also be unused\*\* (ensuring shelves are used contiguously from the bottom). | $\\text{isused}\[s] \\le \\text{isused}\[s-1]$ |

| `HighestReach` | \*\*Updates $\\text{highestshelf}$\*\* to be the position of the highest used shelf. | $\\text{highestshelf} \\ge \\text{shelfposition}\[s] - M \\cdot (1-\\text{isused}\[s])$ |



---



\## 🎨 Visualization

The second part of the `books.m` file contains `printf` statements in a loop, which generate an \*\*SVG (Scalable Vector Graphics) output\*\* after the problem is solved. This code is designed to visually render the optimal shelving arrangement, showing the position and size of each shelf and book set.





Would you like to see the \*\*numerical results\*\* (e.g., the optimal total height and which books are on which shelf) after solving this optimization problem?

