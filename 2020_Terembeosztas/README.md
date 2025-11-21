## 🧩 Problem Setup: Curriculum Scheduling Optimization

[cite_start]The goal is to create an ideal curriculum schedule by assigning courses to $n$ semesters, optimizing for certain criteria while adhering to several constraints[cite: 1]. The problem is formulated as a Mixed-Integer Linear Program (MILP) and implemented using the provided AMPL code.

---

### 📚 Core Entities

* **Courses (`Courses` set):** The list of all subjects that must be scheduled.
    * Each course has associated **credits** and weekly **contact hours**.
    * [cite_start]**Prerequisites (`depends` parameter):** Defined dependencies specify which courses must precede others[cite: 2].
* **Semesters (`Semesters` set):** The time periods (from 1 to $n$) into which the courses must be scheduled. [cite_start]The total number of semesters is fixed at $n=3$ in the data section[cite: 22, 29].

---

### ✅ Constraints

The following restrictions must be satisfied by the final schedule:

1.  [cite_start]**Scheduling:** Every course must be scheduled exactly once across all semesters (`EachCourseOnce`)[cite: 14].
2.  **Prerequisites:** A course (c2) that depends on another course (c1) must be taken in a *later* semester than its prerequisite. [cite_start]Taking the dependent course earlier or in the same semester is forbidden (`DontMakeDependentEarlier`)[cite: 4, 17].
3.  **Maximum Gap:** There cannot be a gap of more than two semesters between a course (c1) and a course (c2) that depends on it. If $s_1$ is the semester for c1, c2 must be in semester $s_2 \le s_1+3$. [cite_start]The current model enforces $s_2 \le s_1+3$ (`DontStudyMuchEarlier`), which means a maximum gap of 2 semesters (since $s_2 = s_1+1$ is zero gap, $s_2 = s_1+2$ is one gap, $s_2 = s_1+3$ is two gaps)[cite: 4, 18].
4.  [cite_start]**Semester Credit Limits:** The total credits in any semester must be between 25 and 35, inclusive (`SatisfySemesterCreditLimitations`)[cite: 3, 15, 25].
    * $25 \le \sum \text{credits} \le 35$
5.  [cite_start]**Semester Hour Limits:** The total weekly contact hours in any semester must be between 17 and 23, inclusive (`SatisfySemesterHourLimitations`)[cite: 3, 16, 25].
    * $17 \le \sum \text{hours} \le 23$

---

### 🎯 Objective Function

[cite_start]The primary objective is to **minimize the total weekly contact hours** scheduled in the **last two semesters**[cite: 5, 19].

$$\text{Minimize: } \sum_{c \in \text{Courses}} \sum_{s > nSemester-2}^{nSemester} \text{schedule}[s,c] \times \text{hours}[c]$$

---

### 📝 Additional Requirements (Not Implemented in Current Code)

The problem description includes several "plus tasks" that are **not yet reflected** in the provided AMPL model, but should be considered for a complete solution:

* [cite_start]**Minimizing "Reactivation Work" (Cost):** A cost is incurred when a dependent course (A) is scheduled more than one semester after its prerequisite (B)[cite: 6].
    * [cite_start]**1-Semester Gap:** Cost = $5 \times \text{credits}[B]$[cite: 7].
    * [cite_start]**2-Semester Gap:** Cost = $8 \times \text{credits}[B]$[cite: 8].
    * [cite_start]**Reactivation Rule:** If multiple courses depend on B in the same semester, the cost is incurred only once[cite: 9].
    * [cite_start]**Cost Reduction:** If there is a 2-semester gap, but B was already "reactivated" (a course depending on B was taken with a 1-semester gap) in the previous semester, the multiplier is 5 instead of 8[cite: 10].
* [cite_start]**Reactivation Time Limit:** The total time spent on reactivation work in any semester has an upper limit of 70 hours[cite: 10].
* [cite_start]**Elective Blocks:** The curriculum includes elective "blocks" that are not single courses but require a minimum number of credits to be completed[cite: 10].
    * [cite_start]**Hours Calculation:** The workload is $2/3 \times \text{credits}$[cite: 11].
    * [cite_start]**Splitting:** Blocks can be split across semesters, but each part must be at least 2 hours or 3 credits in size[cite: 12].
    * [cite_start]**Dependencies:** Blocks also have prerequisite dependencies[cite: 11].