This is a \*\*mixed-integer linear programming (MILP)\*\* problem modeled in the \*\*AMPL\*\* language, designed to create an optimal \*\*study schedule\*\* for a student preparing for several course exams. The objective is to \*\*maximize the weighted average grade\*\* across all courses, subject to constraints on available study time, required study hours for specific grades, and context switching penalties.



---



\## 📚 Problem Components



\### 1. Sets and Parameters



| Component | Type | Description |

| :--- | :--- | :--- |

| `Courses` | \*\*Set\*\* | The list of courses the student can take (e.g., T1, T2, T3). |

| `Days` | \*\*Set\*\* | The sequence of days in the study period, from day 1 up to the last exam day. |

| `Grades` | \*\*Set\*\* | The possible numeric grades the student can receive (e.g., 2, 3, 4, 5). |

| `credits{Courses}` | Parameter | The credit value for each course. |

| `examday{Courses}` | Parameter | The day on which the exam for each course takes place. |

| `freetime{Days}` | Parameter | The total available study time (in hours) on each day. |

| `contextSwitchTime` | Parameter | The time lost (penalty) for deciding to study any course on a given day. |

| `studyhours{Courses,Grades}` | Parameter | The total minimum hours required to study for a specific course to achieve a specific grade. |

| `noPassCoefficient` | Parameter | A grade coefficient assigned to courses where the exam is \*not\* taken. |



---



\### 2. Decision Variables



| Variable | Type | Description |

| :--- | :--- | :--- |

| `takeExam{Courses}` | \*\*Binary\*\* | 1 if the student takes the exam for a course, 0 otherwise. |

| `getGrade{Courses,Grades}` | \*\*Binary\*\* | 1 if the student achieves a specific grade in a course, 0 otherwise. |

| `study{Courses,Days}` | \*\*Non-Negative\*\* | The number of hours spent studying for a specific course on a specific day. |

| `sitDown{Courses,Days}` | \*\*Binary\*\* | 1 if the student decides to study for a specific course on a specific day (i.e., incurring the context switch penalty), 0 otherwise. |



---



\### 3. Objective Function



The goal is to \*\*maximize the weighted average grade\*\*:

$$

\\text{Maximize} \\quad \\frac{\\sum\_{c \\in \\text{Courses}} \\text{credits}\[c] \\cdot \\left( \\sum\_{g \\in \\text{Grades}} g \\cdot \\text{getGrade}\[c,g] + (1 - \\text{takeExam}\[c]) \\cdot \\text{noPassCoefficient} \\right)}{\\sum\_{c \\in \\text{Courses}} \\text{credits}\[c]}

$$

This averages the expected grade (weighted by course credits) for taken exams, while applying the `noPassCoefficient` for courses where the exam is not taken.



---



\## 4. Constraints



The model uses several constraints to ensure a feasible schedule:



\* \*\*`Get\_single\_passing\_grade\_iff\_exam\_is\_taken`\*\*: If an exam is taken (`takeExam = 1`), exactly one grade must be selected (`getGrade = 1`). If the exam is not taken (`takeExam = 0`), no grade can be selected.

\* \*\*`Study\_enough\_for\_grade`\*\*: The total study time allocated to a course \*before\* its exam day must meet or exceed the required total study hours for the chosen grade.

\* \*\*`Can\_not\_study\_more\_than\_free\_time`\*\*: The total time spent studying across all courses on any given day, plus the total penalty time for context switching, cannot exceed the available `freetime` for that day. A course's exam day is automatically disallowed for study if the exam is taken.

&nbsp;   \* \*Note:\* The penalty for context switching is calculated as $\\sum\_{c \\in \\text{Courses}} \\text{sitDown}\[c,d] \\cdot \\text{contextSwitchTime}$.

\* \*\*`Can\_only\_study\_if\_sit\_down\_to\_it`\*\*: A student can only allocate study hours (`study > 0`) for a course on a day if they decide to study that course that day (`sitDown = 1`).

\* \*\*`Setting\_unnecessary\_variables\_to\_zero`\*\*: No study time can be allocated for a course on or after its exam day.



---



\## 5. Data (`data.d`)



The provided data gives specific values for the parameters:



\* \*\*Courses:\*\* T1 (4 credits, Exam Day 8), T2 (2 credits, Exam Day 5), T3 (6 credits, Exam Day 9).

\* \*\*Grades:\*\* 2, 3, 4, 5.

\* \*\*`contextSwitchTime`\*\*: 0.5 hours.

\* \*\*Required Study Hours:\*\* Varies by course and grade (e.g., T1 needs 4 hours for a grade 5).

\* \*\*`freetime`\*\*: Available hours per day (e.g., Day 1 has 3 hours, Day 8 has 9 hours).



Would you like to see the calculated \*\*optimal schedule\*\* based on this model and data?

