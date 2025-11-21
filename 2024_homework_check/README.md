The provided files, **ut.mod** and **ut.dat**, define and populate an **optimization model** likely written in the **AMPL (A Mathematical Programming Language)** syntax. [cite_start]This model aims to maximize the completion of a final work step, **Lakkozas (Lacquering)**, within a fixed timeframe of **8 hours**[cite: 9, 10].

Here is a breakdown of the model's components and constraints:

## 🧑‍💻 Model Sets and Parameters

| Identifier | Type | Description | Values (from ut.dat) | Source |
| :--- | :--- | :--- | :--- | :--- |
| **dolgozok** | Set | [cite_start]The set of **workers**[cite: 1]. | [cite_start]Kitti, Medard, Gergo, Balazs, Iza [cite: 8] [cite_start]| [cite: 1, 8] |
| **munkafolyamatok** | Set | [cite_start]The set of **work processes/steps**[cite: 1]. | [cite_start]Hantolas, Alapozas, Pirosfestes, Lakkozas [cite: 8] [cite_start]| [cite: 1, 8] |
| **elsomunka** | Parameter (Symbolic) | [cite_start]The **first** work step[cite: 1]. | [cite_start]Hantolas [cite: 9] [cite_start]| [cite: 1, 9] |
| **utolsomunka** | Parameter (Symbolic) | [cite_start]The **last** work step[cite: 1]. | [cite_start]Lakkozas [cite: 9] [cite_start]| [cite: 1, 9] |
| **elozo** | Parameter (Symbolic) | [cite_start]The **preceding** work step for any step *m* (where *m* is not *elsomunka*)[cite: 2]. | [cite_start]Alapozas $\to$ Hantolas, Pirosfestes $\to$ Alapozas, Lakkozas $\to$ Pirosfestes [cite: 9] [cite_start]| [cite: 2, 9] |
| **ora** | Parameter | [cite_start]The total number of time periods (hours)[cite: 2]. | [cite_start]8 [cite: 9] [cite_start]| [cite: 2, 9] |
| **orak** | Set | [cite_start]The set of time periods $1, 2, \dots, \text{ora}$[cite: 2]. | [cite_start]$1, 2, \dots, 8$ [cite: 9] [cite_start]| [cite: 2, 9] |
| **sebesseg** | Parameter | [cite_start]The **speed** or productivity of each worker for each work step[cite: 2]. | [cite_start]See table below [cite: 10] [cite_start]| [cite: 2, 10] |
| **munkaora** | Parameter | [cite_start]The contribution of a worker's effort in one time period to the **progress** of a task (between 0 and 1)[cite: 3]. | [cite_start]0.75 [cite: 10] [cite_start]| [cite: 3, 10] |
| **maxtavolsag** | Parameter | [cite_start]A constraint on the **maximum allowed progress gap**[cite: 3]. | [cite_start]10 [cite: 3] [cite_start]| [cite: 3] |

---

### **Worker Speeds ($sebesseg$)**
| Worker | Hantolas (Sanding) | Alapozas (Priming) | Pirosfestes (Red Painting) | Lakkozas (Lacquering) | Source |
| :--- | :--- | :--- | :--- | :--- |
| Kitti | 2 | 6 | 7 | [cite_start]3 | [cite: 10] |
| Medard | 7 | 5 | 4 | [cite_start]2 | [cite: 10] |
| Gergo | 5 | 2 | 5 | [cite_start]4 | [cite: 10] |
| Balazs | 6 | 3 | 2 | [cite_start]8 | [cite: 10] |
| Iza | 3 | 4 | 8 | [cite_start]6 | [cite: 10] |

---

## 📐 Decision Variables

* [cite_start]**dolgozas{orak, dolgozok, munkafolyamatok} binary;**: A **binary decision variable** that equals 1 if worker $d$ is working on work step $m$ during time period $o$, and 0 otherwise[cite: 3].
* [cite_start]**elorehaladas{orak $\cup$ {0}, munkafolyamatok} $\ge$ 0;**: A non-negative variable representing the **cumulative progress/completion** of work step $m$ up to and including time period $o$ (with an initial state at $o=0$)[cite: 3].

---

## ⚖️ Objective and Constraints

### **Objective Function**
$$Maximize \quad kesz: \quad elorehaladas[ora, utolsomunka]$$
[cite_start]The goal is to **maximize the total completion** of the final work step, **Lakkozas**, by the end of the last time period ($ora=8$)[cite: 7, 9].

### **Constraints**

* [cite_start]**csak\_egy\_feladat**[cite: 4]: For any time period $o$ and worker $d$, the worker can be assigned to at most **one** work step.
    $$\sum_{m \in \text{munkafolyamatok}} dolgozas[o, d, m] \le 1$$
* [cite_start]**elorehaladas\_kezdet**[cite: 5]: The initial progress of all work steps at time $o=0$ is **zero**.
    $$elorehaladas[0, m] = 0$$
* [cite_start]**munka\_elorehaladas**[cite: 5]: The progress of work step $m$ at time $o$ is the progress from the previous time period ($o-1$) plus the contribution of the workers assigned to it in period $o$. The contribution is determined by the $\text{munkaora}$ value (0.75) multiplied by the total speed of the workers assigned to $m$.
    $$elorehaladas[o, m] \le elorehaladas[o-1, m] + \text{munkaora} \times \sum_{d \in \text{dolgozok}} dolgozas[o, d, m] \times \text{sebesseg}[d, m]$$
* [cite_start]**megelozo\_folyamat**[cite: 6]: For any work step $m$ (that is not the first step), the **progress of $m$ cannot exceed the progress of its preceding step** ($\text{elozo}[m]$). This enforces the sequential nature of the tasks (e.g., Pirosfestes can't get ahead of Alapozas).
    $$elorehaladas[o, m] \le elorehaladas[o, elozo[m]]$$
* [cite_start]**max\_tavolsag**[cite: 7]: The difference in progress between the **first** work step (**Hantolas**) and the **last** work step (**Lakkozas**) must not exceed a maximum distance ($\text{maxtavolsag}=10$). This acts as a buffer or capacity constraint to prevent the initial work from getting too far ahead of the final step.
    $$elorehaladas[o, \text{elsomunka}] - elorehaladas[o, \text{utolsomunka}] \le \text{maxtavolsag}$$

This model is a type of **resource-constrained scheduling/production optimization problem**, determining the optimal assignment of workers to tasks over time to maximize the final output, respecting task dependencies and resource limits.

Would you like to analyze a specific solution from this model, or have me explain one of the constraints in more detail?