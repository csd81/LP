You've uploaded several files related to a **study scheduling optimization problem** using a modeling language like GLPK/AMPL.

Here's a breakdown of the files:

### 📑 Data Files (`.dat`)

These files define the specific parameters and constraints for the problem:

| File | Key Data Defined | Description |
| :--- | :--- | :--- |
| [cite_start]`data_0.dat` [cite: 1, 2, 3] | `Targyak`, `vizsganap`, `szukseges_ora`, `Napok`, `szabadido` | [cite_start]Defines three subjects (**DTR, IRB, KXD**) [cite: 1][cite_start], their required study hours, and exam days[cite: 1]. [cite_start]It also defines 10 days (`Napok`) [cite: 2] [cite_start]and the available free time (`szabadido`) for studying on each day[cite: 3]. |
| [cite_start]`data_1.dat` [cite: 30, 31] | `Targyak`, `vizsganap`, `szukseges_ora`, `utolso_nap`, `szabadido` | [cite_start]Similar to `data_0.dat`, using the same three subjects and available time[cite: 30]. [cite_start]It explicitly sets `utolso_nap` (last day) to **10**[cite: 31]. |
| [cite_start]`data_2.dat` [cite: 32, 33, 34] | `Targyak`, `vizsganap`, `szukseges_ora`, `utolso_nap`, `szabadido` | [cite_start]Defines a larger set of six subjects (**DTR, IRB, KXD, IRU, VIR, TOK**) [cite: 32] [cite_start]with their required study hours and exam days[cite: 32, 33]. [cite_start]It also sets `utolso_nap` to **10** [cite: 34] [cite_start]and uses the same free time schedule[cite: 34]. |

---

### 💻 Model Files (`.mod`)

These files contain the optimization models that define the variables, objective function, and constraints:

#### `model_0.mod` (Minimize Total Study Hours)

[cite_start]This model aims to schedule the necessary study hours using the absolute minimum total time possible[cite: 15].

* [cite_start]**Variables:** `tanulok[Napok, Targyak]` (hours studied on a given day for a given subject)[cite: 11, 12].
* **Constraints:**
    * [cite_start]**Available Time:** Total study time on any day cannot exceed the available free time[cite: 12].
    * [cite_start]**Preparation:** The total study time for a subject across all days must meet or exceed the required hours (`szukseges_ora`)[cite: 13].
    * [cite_start]**No Late Studying:** Study hours for a subject are zero on or after its exam day[cite: 14].
* [cite_start]**Objective:** **Minimize** the total hours spent studying (`Osszes_tanulas`)[cite: 15].

#### `model_1.mod` (Minimize Total Study Hours, Alternative Preparation Constraint)

This model is similar to `model_0.mod` but uses a different definition for the preparation constraint.

* [cite_start]**Variables:** `tanulok[Napok, Targyak]`[cite: 4, 5].
* **Constraints:**
    * [cite_start]**Available Time:** Same as `model_0.mod`[cite: 5].
    * [cite_start]**Preparation:** The total study time for a subject must meet or exceed the required hours, **but only considering days *before* the exam day** (`n < vizsganap[t]`)[cite: 6]. *Note: This constraint effectively prevents studying on or after the exam day, making the explicit 'No Late Studying' constraint from `model_0.mod` redundant.*
* [cite_start]**Objective:** **Minimize** the total hours spent studying (`Osszes_tanulas`)[cite: 7].

#### `model_2.mod` (Maximize Number of Passed Subjects)

[cite_start]This model addresses the scenario where there might not be enough time to prepare for all exams and aims to pass the maximum number of subjects[cite: 23].

* **Variables:**
    * [cite_start]`tanulok[Napok, Targyak]`[cite: 19, 20].
    * [cite_start]`atmegyek[Targyak]` (**binary** variable, 1 if the subject is passed/attempted, 0 otherwise)[cite: 20].
* **Constraints:**
    * [cite_start]**Available Time:** Total study time on any day cannot exceed the available free time[cite: 21].
    * [cite_start]**Preparation:** The total study time for a subject on days **before** the exam must meet or exceed the required hours **only if** the subject is chosen to be passed (i.e., if $atmegyek[t] = 1$)[cite: 22]. The constraint is:
        $$\sum_{n \in Napok, n < vizsganap[t]} tanulok[n,t] \ge szukseges\_ora[t] \times atmegyek[t]$$
* [cite_start]**Objective:** **Maximize** the total number of subjects passed (`Teljesitett_targyak`)[cite: 23].

***

Would you like me to try solving one of these models with a data file, or perhaps compare the results of two different models?