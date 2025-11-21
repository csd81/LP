[cite_start]That file contains an **Optimization Model** written in a modeling language (likely AMPL or a similar syntax)[cite: 1, 2, 3, 4].

[cite_start]The model, named `froccs`, appears to be a **Maximization Problem** [cite: 4] designed to determine the optimal quantities of three different types of mixed drinks, likely a Hungarian spritzer called "fröccs," to maximize profit based on limited ingredients (wine and soda water).

---

### 📝 Model Components

* **Variables (Decision Variables):** These are the quantities of each type of fröccs to be produced, and they must be non-negative integers (meaning you can only make whole drinks).
    * [cite_start]$KF$: Quantity of the first type of fröccs (Kisföccs) [cite: 1]
    * [cite_start]$NF$: Quantity of the second type of fröccs (Nagyfröccs) [cite: 1]
    * [cite_start]$HL$: Quantity of the third type of fröccs (Hosszúlépés) [cite: 1]

* **Objective Function (Maximize):** The goal is to maximize the total profit generated from selling these three types of drinks.
    $$\text{Profit} = 200 \cdot KF + 380 \cdot NF + 220 \cdot HL$$
    [cite_start]This suggests the profit per unit is **200** for $KF$, **380** for $NF$, and **220** for $HL$[cite: 4].

* **Constraints (Subject To - s.t.):** These limit the total amount of ingredients used.
    * **Bor (Wine) Constraint:** The total amount of wine used cannot exceed 1000 units.
        $$KF + 2 \cdot NF + HL \le 1000$$
        * [cite_start]$KF$ uses **1 unit** of wine[cite: 2].
        * [cite_start]$NF$ uses **2 units** of wine[cite: 2].
        * [cite_start]$HL$ uses **1 unit** of wine[cite: 2].
    * **Szóda (Soda Water) Constraint:** The total amount of soda water used cannot exceed 1500 units.
        $$KF + NF + 2 \cdot HL \le 1500$$
        * [cite_start]$KF$ uses **1 unit** of soda[cite: 3].
        * [cite_start]$NF$ uses **1 unit** of soda[cite: 3].
        * [cite_start]$HL$ uses **2 units** of soda[cite: 3].

---

### 🎯 Goal

[cite_start]The model seeks to find the non-negative integer values for $KF$, $NF$, and $HL$ that yield the **highest total profit** [cite: 4] [cite_start]without exceeding the available stock of **1000 units of wine** [cite: 2] [cite_start]and **1500 units of soda water**[cite: 3].

Would you like me to identify the type of optimization problem this is?