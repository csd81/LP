This problem is a **linear programming model** designed to determine the **feasibility and optimal scheduling of study time** for a set of courses, constrained by the **required preparation time** for each course and the **daily available free time**.


---

## 📚 Problem Components and Goal

### 🎯 Goal
The primary objective is to find a study schedule that satisfies the minimum **required study time** for every course before its respective **exam day**, all while not exceeding the **daily available free time**. The model also includes a secondary objective to **minimize the total number of study hours**, effectively finding the *most efficient* feasible schedule.

### 📝 Key Data Parameters

The problem is defined by the following fixed data inputs, provided in the `exams1.d` file:

* **Courses:** The list of subjects that need to be studied.
    * *Example:* ExpertSystems, ComputerNetworks, Programming, Finance, DeceisonSupport.
* **$nDays$:** The total length of the exam/study period (42 days).
* **$required\_time$:** The minimum number of hours needed to prepare for each course.
    * *Example:* ExpertSystems requires 40 hours.
* **$exam\_day$:** The specific day within the $nDays$ period when the exam for a given course takes place.
    * *Example:* The ComputerNetworks exam is on Day 7.
* **$free\_time$:** The number of study hours available on each day of the period.
    * *Example:* Day 1 has 5.3 hours of free time.

---

## 📐 Mathematical Formulation

### 💡 Decision Variable
The model's variable is what we need to determine:
* **$study_{d,c}$**: The number of hours spent studying for **Course $c$** on **Day $d$**. This value must be non-negative.

### 🛑 Constraints

The solution must respect two main constraints:

1.  **$FreeTimeConstraint$**: The total time spent studying for *all* courses on any given day cannot exceed the free time available on that day.
    $$\sum_{c \in Courses} study_{d,c} \le free\_time_d \quad \text{for all } d \in Days$$

2.  **$RequiredTimeConstraint$**: The cumulative study time for a course must meet or exceed its required preparation time by the day *before* the exam.
    $$\sum_{d \in Days: d < exam\_day_c} study_{d,c} \ge required\_time_c \quad \text{for all } c \in Courses$$

### ⬇️ Objective Function

The model seeks to **minimize** the total study effort across the entire period and all courses.
$$\text{Minimize } \sum_{d \in Days, c \in Courses} study_{d,c}$$

---

## 💻 Output

The model is solved using a linear programming solver (implied by the `.m` file structure) to find the values for $study_{d,c}$ that satisfy all constraints and minimize the total study hours.

The output loop then iterates through each day and prints the optimal study schedule, showing:
* The **Day number** ($d$).
* The **Course** ($c$) being studied.
* The **Hours spent** ($\text{study}_{d,c}$) on that course for the day (only for non-zero study times).