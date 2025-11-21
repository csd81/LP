## 💼 Job Assignment and Scheduling Optimization Problem

This is a **binary integer programming** problem designed to **assign jobs to workers** to **minimize the total cost**, while adhering to constraints on **worker skills** and **availability**.

---

### 🎯 Objective

The goal is to **minimize the total cost** (Objective function: `minimize Cost`). The cost is calculated as the sum, over all workers and jobs, of the **worker's salary multiplied by the duration of the job** if that worker is assigned the job.

$$
\text{Minimize Cost} = \sum_{w \in \text{Workers}} \sum_{j \in \text{Jobs}} \text{salary}[w] \cdot \text{duration}[j] \cdot \text{do}[j,w]
$$

---

### 🧮 Sets, Parameters, and Variables

#### **Sets**
* **Jobs**: The set of tasks to be completed, indexed by $j$.
* **Workers**: The set of available personnel, indexed by $w$.

#### **Parameters (Input Data)**
| Parameter | Description |
| :--- | :--- |
| **nJobs** | Total number of jobs. |
| **nWorkers** | Total number of workers. |
| **required\_skill** $\{j\}$ | The minimum skill level needed for **Job** $j$. |
| **duration** $\{j\}$ | The time required to complete **Job** $j$. |
| **skill\_level** $\{w\}$ | The skill level of **Worker** $w$. |
| **salary** $\{w\}$ | The salary/cost per unit of time for **Worker** $w$. |
| **availability** $\{w\}$ | The maximum amount of time **Worker** $w$ can work. |

#### **Variables (Decision)**
* **do** $\{j, w\}$: A **binary** variable ($0$ or $1$).
    * $\text{do}[j, w] = 1$ if **Job** $j$ is assigned to **Worker** $w$.
    * $\text{do}[j, w] = 0$ otherwise.

---

### ✅ Constraints

The assignment must satisfy three main constraints:

1.  **Skill Level Constraint** (`SkillLevelConstraint`):
    * A job can only be assigned to a worker if the worker's skill level is **sufficient**.
    * If a worker's skill level is **less than** the required skill for a job ($\text{skill\_level}[w] < \text{required\_skill}[j]$), then that worker **cannot** be assigned that job ($\text{do}[j, w] = 0$).
    $$
    \text{do}[j,w] = 0 \quad \text{if } \text{skill\_level}[w] < \text{required\_skill}[j]
    $$

2.  **Worker Availability Constraint** (`WorkAsMuchAsAvailability`):
    * The total time assigned to any worker cannot exceed their maximum available time.
    * For every worker $w$, the sum of the durations of all jobs assigned to them must be **less than or equal to** their availability.
    $$
    \sum_{j \in \text{Jobs}} \text{duration}[j] \cdot \text{do}[j,w] \le \text{availability}[w] \quad \text{for all } w \in \text{Workers}
    $$

3.  **Job Completion Constraint** (`DoAllJobs`):
    * Every job must be completed.
    * For every job $j$, the sum of the assignments over all workers must **equal 1**, ensuring the job is assigned to exactly **one** worker.
    $$
    \sum_{w \in \text{Workers}} \text{do}[j,w] = 1 \quad \text{for all } j \in \text{Jobs}
    $$

---

### 📝 Summary

The model seeks the optimal, minimum-cost assignment of jobs to workers, ensuring all jobs are done, no worker is assigned a task they are under-skilled for, and no worker's total assigned work time exceeds their availability.

Would you like to know the results for a specific set of input parameters or explore how a change in a parameter, like **salary** or **skill\_level**, would affect the optimal assignment?