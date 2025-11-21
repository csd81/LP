Here is the solution for the **Bonus Exercise**.

The challenge in the bonus exercise is changing the objective function from a "Min-Max" problem (minimize the highest point) to a weighted "Minimum Effort" problem.

### The Modeling Challenge: Linearization

The effort is defined as `|ShelfPosition - 120|`.

1.  **Absolute Value:** Optimization solvers generally dislike absolute values. We must linearize this using a standard trick involving two constraints (one for the positive difference, one for the negative).
2.  **Variable Interaction:** We need to calculate the effort for a specific book. This involves knowing which shelf the book is on (`put[b,s]`) and the height of that shelf (`position[s]`). Multiplying a binary variable by a continuous variable (`put * position`) results in a Quadratic (Non-Linear) problem.
3.  **The Solution:** We introduce a **redundant variable** `book_height[b]`. We link this variable to the shelf position using Big-M constraints. This allows us to linearize the logic: "If book $b$ is on shelf $s$, then `book_height[b]` equals `position[s]`."

### The AMPL Model (Bonus Version)

Here is the complete code. I have added the `frequency` parameter, the linearization variables, and updated the objective function.

```ampl
# --- SETS AND PARAMETERS ---
set BookSets;
param width{BookSets};
param height{BookSets};
param frequency{BookSets} default 1; # Added frequency for the bonus

param shelfCount;
set Shelves := 1..shelfCount;

param shelfWidth;
param shelfHeight;
param minDistance;
param minPosition;

# Big-M for linearization (needs to be large enough to cover max possible height)
param M := 500; 
param targetHeight := 120; # The "comfortable" height

# --- VARIABLES ---
var use{Shelves} binary; 
var position{Shelves} >= minPosition;
var put{BookSets,Shelves} binary;

var maxbookheight{Shelves} >= 0;

# Redundant variables for the bonus
var book_pos{BookSets} >= 0; # The actual height of a specific bookset
var effort{BookSets} >= 0;   # The absolute distance from 120cm

# --- CONSTRAINTS ---

# 1. Shelf Usage Order (Fill from bottom up)
s.t. ShelfUsage {s in Shelves : s != 1}:
  use[s] <= use[s-1];

# 2. Max Book Height Calculation
# If a book is on a shelf, the shelf's max height must accommodate it
s.t. MaxBookHeightSetter {b in BookSets, s in Shelves}:
  maxbookheight[s] >= height[b] * put[b,s];

# Force maxbookheight to 0 if shelf is unused (tightens the model)
s.t. ZeroHeightForUnused {s in Shelves}:
  maxbookheight[s] <= M * use[s];

# 3. Shelf Positioning
# Shelf must be above the one below it + books + gap + thickness
s.t. ShelfPositioning {s in Shelves : s != 1}:
  position[s] >= position[s-1] + maxbookheight[s-1] + shelfHeight + minDistance;

# 4. Capacity Constraint
s.t. ShelfCapacity {s in Shelves}:
  sum{b in BookSets} put[b,s] * width[b] <= shelfWidth * use[s];

# 5. Assignment Constraint (Every book must be placed)
s.t. BookSetAssignment {b in BookSets}:
  sum{s in Shelves} put[b,s] = 1;

# --- BONUS EXERCISE CONSTRAINTS ---

# 6. Link Book Position to Shelf Position
# If put[b,s] is 1, then book_pos[b] must equal position[s]
# If put[b,s] is 0, these constraints are relaxed by M
s.t. LinkPosLow {b in BookSets, s in Shelves}:
    book_pos[b] >= position[s] - M * (1 - put[b,s]);

s.t. LinkPosHigh {b in BookSets, s in Shelves}:
    book_pos[b] <= position[s] + M * (1 - put[b,s]);

# 7. Linearize Absolute Value for Effort
# effort >= val - target AND effort >= target - val
s.t. EffortCalcPos {b in BookSets}:
    effort[b] >= book_pos[b] - targetHeight;

s.t. EffortCalcNeg {b in BookSets}:
    effort[b] >= targetHeight - book_pos[b];


# --- OBJECTIVE ---
# Minimize the weighted sum of efforts
minimize TotalEffort: sum{b in BookSets} frequency[b] * effort[b];

# --- SOLVE & DISPLAY ---
solve;

# (Standard text display for verification)
display position, maxbookheight;
display {s in Shelves} {b in BookSets : put[b,s] = 1} (b, position[s], frequency[b]);

# --- SVG VISUALIZATION ---
# Note: I kept the original SVG logic but updated the loop references slightly 
# to ensure it draws correctly with the new constraints.

printf "<svg width='%d' height='%d'>", shelfWidth+50, 500; 
# Note: SVG height fixed to 500 for simplicity, or could be dynamic based on max position

for {s in Shelves : use[s]==1}
{
    # Draw the Shelf Plate
    # Y-coordinate logic: Inverted for SVG (0 is top). We map 'ground' (0) to SVG y=400.
    printf "<rect x='%d' y='%d' width='%d' height='%d' style='fill:rgb(214, 119, 36)' />",
        10, 
        400 - position[s] - shelfHeight, # Simple mapping: 400 is floor
        shelfWidth, 
        shelfHeight; 

    # Draw the Target Line (120cm)
    printf "<line x1='0' y1='%d' x2='%d' y2='%d' style='stroke:red;stroke-width:2;stroke-dasharray:5,5' />",
        400 - targetHeight, shelfWidth+20, 400 - targetHeight;

    # Draw the Books
    for {b in BookSets : put[b,s]==1}
    {
        printf "<rect x='%d' y='%d' width='%d' height='%d'",
            10 + sum{b2 in BookSets : b2 < b && put[b2,s]} width[b2],
            400 - position[s] - shelfHeight - height[b],
            width[b],
            height[b];
            
        # Color based on frequency (Darker = Higher Frequency)
        printf " style='fill:rgb(%d,%d,80);stroke:black;stroke-width:1' />",
            200 - (frequency[b]*1.5), # Simple color scaling
            200 - (frequency[b]*1.5);

        # Text Label
        printf "<text x='%d' y='%d' font-family='Verdana' font-size='10' fill='white'>%s</text>",
            15 + sum{b2 in BookSets : b2 < b && put[b2,s]} width[b2],
            400 - position[s] - shelfHeight - height[b] + 15,
            b;
    }
}
printf "</svg>";
```

### Data Update (`.dat`)

To make the bonus meaningful, you need to define the `frequency` parameter in your data section. I have assigned high frequencies to Math and Harry Potter, and low frequencies to Diplomas (which we rarely look at).

```ampl
data;
-
```

### Why this works

1.  **Floating Shelves:** The constraint `position[s] >= position[s-1] ...` is an inequality. This allows the solver to leave large gaps between shelves if necessary. For example, it might place Shelf 1 at 50cm, but Shelf 2 at 110cm (leaving a huge gap), just so the high-frequency books on Shelf 2 are closer to the ideal 120cm line.
2.  **Redundant Variable `book_pos`:** This allows us to calculate the cost per book. The constraints `LinkPosLow` and `LinkPosHigh` ensure that `book_pos[b]` acts exactly like a pointer to the `position` of the shelf the book is assigned to.
3.  **Visualizing:** I added a red dashed line in the SVG code to represent the 120cm "Ideal Height" so you can visually verify that the darkest (most frequent) books cluster around that line.

Would you like me to explain further how the "Big-M" linearization works mathematically?