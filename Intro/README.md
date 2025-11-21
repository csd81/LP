The provided files describe a **Minimum Completion Time Job Assignment Problem**, which is modeled as a **Mixed-Integer Linear Programming (MILP)** problem.

---

## 💾 Data File (`data.dat`)

The data file defines the sets of workers and jobs, and the time (in hours) each person takes to complete each job.

* [cite_start]**Sets Defined[cite: 1]:**
    * **People:** Three workers: **Julcsi**, **Balazs**, and **Erno**.
    * **Jobs:** Twenty jobs labeled **F1** through **F20**.
* [cite_start]**Parameter Defined[cite: 2]:**
    * **`hours`:** A table showing the time required (in hours) for each person to complete each job. [cite_start]For example, Julcsi takes 11.38 hours for job F1, Balazs takes 8.17 hours, and Erno takes 3.79 hours[cite: 2].

---

## 🛠️ Model File (`milp.mod`)

The model file defines the objective and constraints for the MILP problem. The goal is to minimize the time until the very last job is completed by any person, often called the **makespan**.

### 1. Variables

* [cite_start]**`do{Jobs,People}`:** A **binary variable** (0 or 1)[cite: 3].
    * $do[j, p] = 1$ if person $p$ is assigned to job $j$.
    * $do[j, p] = 0$ otherwise.
* [cite_start]**`work_hours{People}`:** A non-negative continuous variable representing the **total working hours** for each person $p$[cite: 3].
* [cite_start]**`finish_time`:** A non-negative continuous variable representing the **time the last person finishes their assigned work** (the makespan)[cite: 3].

### 2. Constraints

* [cite_start]**Every Job Must Be Done By One Person[cite: 4]:**
    $$\sum_{p \in \text{People}} do[j, p] = 1 \quad \forall j \in \text{Jobs}$$
    [cite_start]This ensures that every job $j$ is assigned to exactly one person $p$[cite: 4].

* [cite_start]**Calculate Work Hours[cite: 5]:**
    $$work\_hours[p] = \sum_{j \in \text{Jobs}} hours[j, p] \times do[j, p] \quad \forall p \in \text{People}$$
    [cite_start]This constraint calculates the total work time for each person $p$ by summing the hours of all jobs assigned to them[cite: 5].

* [cite_start]**Set Finish Time[cite: 6]:**
    $$finish\_time \geq work\_hours[p] \quad \forall p \in \text{People}$$
    [cite_start]This forces the `finish_time` variable to be greater than or equal to the total work hours of *every* person[cite: 6].

### 3. Objective

* **Minimize Finish Time:**
    $$\text{Minimize} \quad finish\_time$$
    [cite_start]Since `finish_time` must be greater than or equal to the maximum total work hours of any person (the bottleneck), minimizing this variable minimizes the **maximum completion time** (the makespan) for the entire set of jobs[cite: 6].

Would you like to know the **optimal assignment** of jobs to people and the minimum finish time?