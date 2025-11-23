Advanced GMPL Techniques 2: Some Handy Tricks
Default values, display statements, derived parameters, etc.

---

### Prerequisites

Advanced GMPL Techniques: Data/Logic Decoupling

This lesson introduces a handful of useful GMPL language features that can significantly improve the clarity and maintainability of your models. None of these features enable anything mathematically new—you could already express the same logic without them. Their purpose is strictly to make writing, reading, and debugging a model more convenient. You never *have* to use these features; include them only when they genuinely simplify your work.

We’ll use all of these occasionally later, so you should at least be able to understand them even if you decide not to incorporate them yourself.

---

## Default Values for Parameters

Imagine you have a model used with hundreds of data files, and there’s a 0-dimensional parameter—say, a tax rate—that is identical across nearly all of them except for a few special cases.

With what we’ve covered so far, you have two options:

1. Provide the parameter value in every single data file.
2. Maintain a second model in which that parameter is fixed, and use that version for most cases.

Option 1 is straightforward but leads to unnecessary repetition, and if the real-world value changes (like a new tax rate), every affected data file must be updated.

Option 2 isn’t better—now you must maintain two model files and keep them synchronized, which is error-prone.

A cleaner approach is to define a *default value*:

* If the data file does not provide a value, the default is used.
* If the data file *does* provide one, it overrides the default.
* If the real-world value changes, you update only one place.

Syntax:

```
param Pname{...} default numericvalue;
```

Defaults are also helpful when most indices of a parameter share a “natural default.” For example, initial stock is often zero for nearly every product except a few.

**Model:**

```
set Products;
param initial_stock{Products} default 0;
```

**Data:**

```
set Products := p1 p2 p3 p4 p5 p6 p7 p8 p9 p10;
param initial_stock :=
  p3 100
  p7 45
  ;
```

Defaults also work for two-dimensional parameters. Suppose certain machine/task combinations are not feasible, and you want to assign a large processing time (e.g., 1000) to represent that.

**Model:**

```
set Tasks;
set Machines;
param processing_time{Tasks, Machines} default 1000;
```

**Data:**

```
set Tasks := t1 t2 t3 t4 t5;
set Machines := m1 m2 m3;

param processing_time :
        m1  m2  m3 :=
    t1  1   .   2
    t2  3   .   .
    t3  1   2   3
    t5  .   5   4
    ;
```

A dot means “no value given”—the default applies. Omitting an entire index (like t4) is equivalent to filling the row with dots.

---

## Transpose

A classic beginner error is mixing up the index order for 2-D parameters, leading to “out of domain” errors.

Fixing occurrences in the model (replacing `p[b,t]` with `p[t,b]`) is tedious but manageable.

The real headache appears when the data section matrix is transposed incorrectly, especially in large tables.

Example:

```
set A;
set B;
param p{A,B};
...

data;

set A := a1 a2 a3 a4;
set B := b1 b2 b3;

param p :
      a1  a2  a3  a4 :=
  b1  12  34  54  12
  b2  98  87  76  65
  b3  78  65  67  43
  ;
```

Fix options:

1. Manually transpose the matrix.
2. Change the parameter declaration (swap index order).
3. Add `(tr)` before the colon:

```
param p (tr) :
   ...
```

Choose whichever makes sense in your workflow.

---

## Parameter Safety Checks

If a parameter must obey certain conditions (e.g., nonnegativity), declare that constraint directly:

```
param processing_time{Tasks, Machines} >= 0;
```

This doesn’t change model logic but ensures you get an error if bad data is provided.

---

## Measurement Units

Comments documenting units are always a good idea, but sometimes you receive data in different units across data files. You want a single model that handles both without duplicate versions.

Example:

```
set Cities;
param distance_mile{Cities, Cities} >= 0, default 0;
param distance_km{c1 in Cities, c2 in Cities} >= 0,
      default distance_mile[c1,c2] * 1.6;
```

Use `distance_km` everywhere in constraints.

* If the data file provides `distance_km`, no conversion occurs.
* If it provides only `distance_mile`, `distance_km` is auto-computed.
* If neither is provided, all distances default to zero—be careful.

---

## Displaying Results in a Human-Friendly Form

In many practical models, only a few variables have meaningful (nonzero) values in the optimal solution. GMPL supports a “display section” between the model and data sections to output results cleanly.

Example:

```
set FroccsTypes;
...
var quantity{FroccsTypes} >= 0;
...
maximize Income: sum {f in FroccsTypes} price[f]*quantity[f];

solve;

printf "Overall profit: %g\n\n", Income;

for {f in FroccsTypes : quantity[f] != 0}
{
  printf "Produce %g portions from %s.\n", quantity[f], f;
}

data;
```

Sample output:

```
Overall profit: 115625

Produce 937.5 portions from kisfroccs
Produce 62.5 portions from soherfroccs
```

Important notes:

* **Always call `solve;`** before display logic—after solving, variables hold actual numeric values.
* `printf` uses C-style formatting: `%s` for strings, `%d` for integers, `%g` for floating-point values.
* Loops can include filters (`: quantity[f] != 0`) or can be written using `if`-like structures.

GMPL lacks an actual `if` statement but you can simulate conditional execution using a hack:

```
for {{0} : quantity[f] != 0}
{
  ...
}
```

A singleton set triggers the loop body exactly once when the condition is true.

---

## Output as Input for Another Tool

Formatting for human readability is great, but often you want machine-readable output—CSV, LaTeX table code, SVG diagrams, etc.

You can direct the display section output into a separate file using:

```
glpsol -m model.mod -d data.dat -y myoutput.txt
```

Everything printed is captured in `myoutput.txt`, ready for Excel, scripts, or downstream processing.

Typical use cases:

* Exporting CSV files for spreadsheet tools.
* Generating LaTeX table markup automatically.
* Producing SVG files for visualization.
* Automatically generating new model/data files in hierarchical workflows.

---

## Final Notes

The GMPL features introduced in this lesson are practical enhancements that help make modeling and analysis cleaner and more transparent. Use them when they simplify your work—avoid them when they add unnecessary complication.
