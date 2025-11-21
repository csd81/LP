The provided files define an **optimization problem** for **planning a running schedule** over a set number of weeks. The goal is to maximize the total distance covered by selecting one route per week, subject to several constraints.

---

## 🏃‍♀️ Data File (`duhajok.dat`)

This file contains the data for the sets, parameters, and their specific values used in the model.

* **Sets:**
    * [cite_start]**Runners:** The participants: Tomi, Livi, Balazs, Kriszti, Ricsi, and Csabi[cite: 1].
    * [cite_start]**Routes:** The available running routes: Lover, Muck, Benchmark, HaromAKaroly, and Ojtozi[cite: 7].
* **Parameters:**
    * [cite_start]**max\_distance:** The **maximum distance each runner can cover** (in km)[cite: 1].
        * Tomi: 21, Livi: 9, Balazs: 24, Kriszti: 8, Ricsi: 13, Csabi: 2.
    * [cite_start]**weeks:** The **duration of the planning period** in weeks, set to 5[cite: 2].
    * [cite_start]**attendance:** A **binary matrix** indicating if a runner attends a specific week (1 for yes, blank/dot for no/zero)[cite: 3, 4, 5, 6].
    * [cite_start]**distance:** The **length of each running route** (in km)[cite: 7].
        * Lover: 5.3, Muck: 9.5, Benchmark: 13, HaromAKaroly: 21, Ojtozi: 6.
    * [cite_start]**max\_occurence:** The **maximum number of times any single route can be selected** across all weeks, set to 2[cite: 8].

---

## 📝 Model File (`planning.mod`)

This file defines the mathematical programming model, including sets, parameters, a decision variable, constraints, and the objective function.

### Sets and Parameters
[cite_start]The model re-declares the sets and parameters defined in the data file: `Runners`, `max_distance`, `weeks`, `Weeks` (derived from `weeks`), `attendance`, `Routes`, `distance`, and `max_occurence`[cite: 9, 10].

### Decision Variable
* [cite_start]**select{Weeks, Routes}**: A **binary variable** that equals **1** if the route $r$ is selected in week $w$, and **0** otherwise[cite: 10].

### Constraints
1.  [cite_start]**One\_route\_a\_week**: Ensures that **exactly one route is selected for each week** $w$[cite: 10].
    $$\sum_{r \in \text{Routes}} \text{select}[w,r] = 1$$
2.  [cite_start]**Max\_occurence\_for\_each\_ruote**: Ensures that **no single route is selected more than `max_occurence`** (2 times) across all weeks[cite: 11].
    $$\sum_{w \in \text{Weeks}} \text{select}[w,r] \le \text{max\_occurence}$$
3.  [cite_start]**Only\_compattible\_rouotes**: Ensures that a route $c$ is **NOT selected in a week $w$** if a runner $r$ attending that week ($\text{attendance}[r,w]=1$) has a **maximum distance** $\text{max\_distance}[r]$ **less than the route's distance** $\text{distance}[c]$[cite: 12]. This constraint forces the model to only pick routes compatible with *all* runners attending that week.
    $$\sum_{w \in \text{Weeks} : \text{attendance}[r,w]=1} \sum_{c \in \text{Routes}: \text{distance}[c] > \text{max\_distance}[r]} \text{select}[w,c] = 0$$

### Objective Function
* [cite_start]**TotalDistance**: The objective is to **maximize the total distance covered** over the 5 weeks[cite: 13].
    $$\text{Maximize: } \sum_{w \in \text{Weeks}, r \in \text{Routes}} \text{select}[w,r] \cdot \text{distance}[r]$$

### Output
[cite_start]After solving, the model prints the **selected route and its distance for each week**[cite: 14]. [cite_start]For each week, it also lists the **runners attending that week** along with their **maximum distance** capabilities[cite: 15, 16].

---
Would you like to know the **solution** (the planned routes and total distance) for this optimization problem?