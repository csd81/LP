The problem described by the AMPL model and its input data is a **Figure Placement and Paging Optimization Problem**.

The goal is to determine the optimal placement of **figures** (graphs, images, etc.) within a multi-page document to **minimize the total number of page turns** required for the reader to view each figure after reading its citation.

---

## 🧐 Problem Components

The document is composed of **text lines** and **figures**.

### 1. Figures and Their Properties
* The set of figures is $Figures = \{small, big, medium\}$.
* Each figure has a fixed **height** (in lines) and a specific **citation line** number in the running text where the figure is first referenced:
    * **small**: Citation on line **3**, Height **2** lines.
    * **big**: Citation on line **7**, Height **4** lines.
    * **medium**: Citation on line **10**, Height **3** lines.
* The **total lines of text** in the document is the line number of the last citation, which is $\max(\text{citeLine}) = 10$.

### 2. Paging and Layout Constraints
The document must adhere to specific formatting rules:

* **Page Size:** Each page has a maximum capacity of $\mathbf{pageSize} = 5$ lines (which can be text lines or figure height lines).
* **Empty Lines Limit:** Except for the very last page, the space used (text lines + figure height) on a page cannot be too small, ensuring no more than $\mathbf{maxEmptyLine} = 3$ empty lines on non-final used pages.
    * *Constraint*: Used Space $\ge pageSize - maxEmptyLine = 5 - 3 = 2$.
* **Sequential Pages:** Pages must be used sequentially; if page $p$ is used, page $p-1$ must also be used.
* **Total Text:** All 10 lines of text must be printed exactly once across all used pages.
* **Figure Placement:** Each figure must be placed exactly once on a page.

---

## 🎯 Optimization Criteria

The core constraints relate the citation of a figure to its placement:

### 1. Citation-Placement Order
A figure can only be placed on the page where it is cited, or a later page:
$$\mathbf{citePage}[f] \le \mathbf{placePage}[f]$$
This prevents a reader from seeing a figure before it's mentioned.

### 2. Citation Order
Figures cited earlier in the text must be placed on the same page or an earlier page than figures cited later.
$$\text{If } \mathbf{citeLine}[f_1] < \mathbf{citeLine}[f_2] \text{ then } \mathbf{placePage}[f_1] \le \mathbf{placePage}[f_2]$$
This maintains the general order of presentation.

---

## 💰 Objective Function

The objective is to **minimize the total number of page turns**. The number of page turns for a single figure $f$ is:
$$\mathbf{placePage}[f] - \mathbf{citePage}[f]$$

The total objective function to minimize is the sum of page turns for all figures:
$$\text{Minimize } \sum_{f \in Figures} (\mathbf{placePage}[f] - \mathbf{citePage}[f])$$

In essence, the model seeks the document layout that satisfies all constraints while keeping the figures as close as possible (in terms of page number) to where they are first mentioned in the text.

---

## 🛠️ Output

The output section of the AMPL code iterates through the solved pages and prints a formatted representation of the optimal document layout, showing:
* The text lines included on that page.
* Any citation markers (`->[FigureName]`) next to the text line.
* The representation of the placed figures (`# FigureName ###`).
* The empty lines on the page.

Would you like to **run the model** to see the optimal page layout, or perhaps **adjust one of the input parameters**?