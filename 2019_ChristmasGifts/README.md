The problem described by the provided AMPL model (`potzh.m`) and data file (`potzh.d`) is an **Exam Scheduling and Study Planning Optimization Problem**. It seeks to maximize the total credit hours of classes passed by optimally allocating study time across a fixed number of days and deciding which classes to take exams for.

---

## 📚 Core Goal

The main objective is to **maximize the total credit hours** of the classes for which the student successfully passes the exam:

$$\text{Maximize: } \sum_{c \in \text{Classes}} \text{pass}_c \times \text{credit}_c$$

Where:
* $\text{pass}_c$ is a binary variable indicating if class $c$ is passed.
* $\text{credit}_c$ is the credit value of class $c$.

---

## 📝 Key Components and Variables

### Sets and Parameters (Input Data)

| Name | Description | Example (from `potzh.d`) |
| :--- | :--- | :--- |
| $\text{Classes}$ | The set of classes (T1, T2, ..., T6). | T1, T2, T3, T4, T5, T6 |
| $\text{credit}_c$ | The credit hours for class $c$. | T1: 2, T4: 6 |
| $\text{hours}_c$ | The total required study hours to pass class $c$. | T1: 8, T4: 15 |
| $\text{Exams}$ | The set of possible exam opportunities (1 to 4). | 1, 2, 3, 4 |
| $\text{examDay}_{c,e}$ | The day on which the $e$-th exam for class $c$ is held. | Exam 1 for T1 is on Day 1. |
| $\text{Days}$ | The set of days in the planning period (1 to 14). | 1, 2, ..., 14 |
| $\text{freetime}_d$ | The total available free study time (in hours) on day $d$. | Day 1: 6 hours, Day 8: 1 hour |
| $\text{warmup}$ | The fixed time cost (in hours) incurred *per class* studied on a given day, regardless of the study duration. | 0.5 hours |

### Decision Variables (What the model decides)

| Variable | Type | Description |
| :--- | :--- | :--- |
| $\text{study}_{c,d}$ | **Binary** | 1 if class $c$ is studied on day $d$, 0 otherwise. |
| $\text{studyhour}_{c,d}$ | **Non-Negative** | The number of hours spent studying class $c$ on day $d$. |
| $\text{pass}_c$ | **Binary** | 1 if class $c$ is passed, 0 otherwise. |
| $\text{take}_{c,e}$ | **Binary** | 1 if the student attempts the $e$-th exam for class $c$, 0 otherwise. |

---

## ⚙️ Constraints (Rules)

The problem must satisfy the following constraints:

1.  **Study Hours Limit (Study\_Studyhour):** The study hours for a class on a given day cannot exceed the total free time on that day. However, since $\text{studyhour}_{c,d}$ contributes to the daily free time limit (Constraint 4), this constraint mainly links the binary variable: $\text{studyhour}_{c,d} \le \text{study}_{c,d} \times \text{freetime}_d$. If $\text{study}_{c,d}=0$, $\text{studyhour}_{c,d}$ must be 0.
2.  **Passing Condition (Exams\_Pass):** A class is passed ($\text{pass}_c=1$) if and only if the student attempts exactly one exam for that class ($\sum_e \text{take}_{c,e} = 1$). If the class isn't passed ($\text{pass}_c=0$), no exam is taken ($\sum_e \text{take}_{c,e} = 0$).
3.  **Required Study (Study\_enough):** If a specific exam $e$ for class $c$ is attempted ($\text{take}_{c,e}=1$), the student must have accumulated at least the required total study hours ($\text{hours}_c$) *before* the exam day.
    $$\sum_{d=1}^{\text{examDay}_{c,e}-1} \text{studyhour}_{c,d} \ge \text{hours}_c \times \text{take}_{c,e}$$
4.  **Daily Time Limit (Daily\_study\_hours):** The total time spent on studying and taking exams on any given day $d$ must not exceed the available free time ($\text{freetime}_d$).
    * **Study Time:** $\sum_{c \in \text{Classes}} \text{studyhour}_{c,d}$
    * **Warmup Cost:** $\sum_{c \in \text{Classes}} \text{study}_{c,d} \times \text{warmup}$ (A fixed cost per class studied).
    * **Exam Penalty:** If an exam is taken on day $d$, all study time and warmup costs are set to zero for that day for *all* classes. This is enforced by multiplying the available free time by $(1 - \sum_{c,e: \text{examDay}_{c,e}=d} \text{take}_{c,e})$. If *any* exam is scheduled on day $d$ and taken, the right-hand side becomes 0, forcing all study hours and warmup costs to 0.

The model essentially finds the optimal combination of exam choices and daily study hour assignments that respects the time limits and study requirements to maximize the total credit hours earned.