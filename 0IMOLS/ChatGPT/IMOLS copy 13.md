# Practice example: Bookshelf
## A test-level example suitable for an end-of-semester assessment


### The Problem

We’ve recently moved into a new apartment and are struggling to arrange our books neatly on our shelves. The shelving system is adjustable: it contains seven shelf boards whose heights we can choose freely. For this example, assume the boards can be positioned anywhere above 50 cm, not only at fixed holes. Each board is 120 cm wide, 20 cm deep, and 2 cm thick.

Our books are grouped into sets—math books, IT books, Tolkien novels, the Harry Potter series, diplomas of former students, and so on. For each set, we know the total width and the height of the tallest book.

Our goal is to place the sets on the shelves so that the highest point we ever need to reach is as low as possible. To keep everything tidy, we don’t want to split any sets across shelves, and we want at least a 7 cm clearance between the tallest book on a shelf and the shelf above it. We also don’t have to use all seven shelf boards if they’re unnecessary.

---

### Problem Data

The raw data for the problem is shown below:

```
set BookSets := Math IT Sport Music Novel Tolkien Feist HarryPotter Diplom;

param :          width      height :=
    Math           100          20
    IT              80          25
    Sport           30          30
    Music           50          30
    Novel           40          20
    Tolkien         30          25
    Feist           50          20
    HarryPotter     90          25
    Diplom          70          40
;

param shelfCount := 7;

param shelfWidth := 120;
param shelfHeight := 2;

param minDistance := 7;
param minPosition := 50;
```

---

### (One) Optimal Solution

To help you verify your model, here is one optimal arrangement. Naturally, many permutations yield the same objective value. It’s also easy to see that swapping shelves below the top one won’t change the objective.

```
Novel
Feist
Math
IT
Sport
Tolkien
HarryPotter
Music
Diplom
```

---

### The Model

Try creating the model yourself. Tip: use redundant variables to represent shelf positions and the tallest book on each shelf.

---

### Input Data Declaration

```
set BookSets;
param width{BookSets};
param height{BookSets};

param shelfCount;
set Shelves := 1..shelfCount;

param shelfWidth;
param shelfHeight;

param minDistance;
param minPosition;

param M := 500;
```

---

### Variables

```
var use{Shelves} binary;
var position{Shelves} >= minPosition;
var put{BookSets,Shelves} binary;

var maxbookheight{Shelves} >= 0;
var maxusedshelf;
```

---

### Constraints

**If a shelf is used, all shelves below it must also be used**

```
s.t. ShelfUsage {s in Shelves : s != 1}:
  use[s] <= use[s-1];
```

**If a shelf is used, it must be placed higher than the one below it (including max book height + 7 cm)**

```
s.t. MaxBookHeightSetter {b in BookSets, s in Shelves}:
  maxbookheight[s] >= height[b] * put[b,s];

s.t. ShelfPositioning {s in Shelves : s != 1}:
  position[s] >= position[s-1] + maxbookheight[s-1] + shelfHeight + minDistance;
```

**Only place book sets on shelves that are used; ensure shelf capacity is respected**

```
s.t. ShelfCapacity {s in Shelves}:
  sum{b in BookSets} put[b,s] * width[b] <= shelfWidth * use[s];
```

**Each book set must be placed on exactly one shelf**

```
s.t. BookSetAssignment {b in BookSets}:
  sum{s in Shelves} put[b,s] = 1;
```

**Determine the height of the topmost used shelf**

```
s.t. MaxUsedShelf {s in Shelves}:
  maxusedshelf >= position[s] - M * (1 - use[s]);
```

---

### Objective Function

```
minimize topShelfHeight: maxusedshelf;
```

---

### Display Statements

```
solve;

printf "<svg width='%d' height='%d'>", 
       shelfWidth+20,
       (sum{ss in Shelves:
            (ss==shelfCount && use[ss]==1) ||
            (use[ss]==1 && use[ss+1]==0)}
            (position[ss] + maxbookheight[ss] + shelfHeight) - position[1]) + 20;

for {s in Shelves : use[s]==1}
{
  printf "<rect x='%d' y='%d' width='%d' height='%d' style='fill:rgb(214,119,36)' />",
         10,
         10 + sum{ss in Shelves:
              (ss==shelfCount && use[ss]==1) ||
              (use[ss]==1 && use[ss+1]==0)}
              (position[ss] + maxbookheight[ss] + shelfHeight) - position[s] - shelfHeight,
         shelfWidth,
         shelfHeight;

  for {b in BookSets : put[b,s]==1}
  {
    printf "<rect x='%d' y='%d' width='%d' height='%d'",
           10 + sum{b2 in BookSets : b2<b && put[b2,s]} width[b2],
           10 + sum{ss in Shelves:
                (ss==shelfCount && use[ss]==1) ||
                (use[ss]==1 && use[ss+1]==0)}
                (position[ss] + maxbookheight[ss] + shelfHeight)
                - (position[s] + shelfHeight) - height[b],
           width[b],
           height[b];

    printf " style='fill:rgb(%d,%d,80);stroke:black;stroke-width:1' />",
           (1 - height[b]/maxbookheight[s]) * 100 + 155,
           50 + 200 * width[b] / shelfWidth;

    printf "<text x='%d' y='%d' font-family='Verdana' font-size='6' fill='white'>%s</text>",
           15 + sum{b2 in BookSets : b2<b && put[b2,s]} width[b2],
           23 + sum{ss in Shelves:
                (ss==shelfCount && use[ss]==1) ||
                (use[ss]==1 && use[ss+1]==0)}
                (position[ss] + maxbookheight[ss] + shelfHeight)
                - (position[s] + shelfHeight) - height[b],
           b;
  }
}

printf "</svg>";
```

These display statements generate the SVG visualization seen earlier.

---

### Bonus Exercise

Assume each book set comes with a frequency value indicating how many times per year you retrieve a book from it. The most comfortable reaching height is 120 cm; any height above or below that requires extra “effort,” proportional to the distance from 120 cm. Arrange the shelves and book sets to minimize your total annual effort.
