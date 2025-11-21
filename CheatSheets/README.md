[cite_start]This is an **AMPL (A Mathematical Programming Language)** model and data file that sets up and solves an optimization problem, likely a form of the **assignment problem**. [cite: 1, 2, 3, 4]

[cite_start]The goal is to **assign each class to exactly one student for preparation** while ensuring **each student prepares at most one class**, and **minimizing the total number of "beers" (a cost proxy)**. [cite: 2, 1]

Here's a breakdown of the components:

## 🔢 Sets and Parameters

* **Sets:**
    * [cite_start]`Students`: The set of potential preparers (Miguel, Quim, Ferran, Daniel, Marta, Ivan). [cite: 1, 4]
    * [cite_start]`Classes`: The set of classes that need preparation (Energy, Const, Auto, Fabr, OM). [cite: 1, 5]
* **Parameter:**
    * `beer{Students,Classes}`: A cost matrix representing the number of "beers" (cost) for a specific student to prepare a specific class. [cite_start]This is the objective function coefficient. [cite: 1, 5, 6]

## 📝 Variables

* **Decision Variable:**
    * [cite_start]`var prepare{Students,Classes} binary`: A **binary variable** which equals 1 if student $s$ is assigned to prepare class $c$, and 0 otherwise. [cite: 1]

## 🎯 Objective Function

* [cite_start]`minimize TotalBeers`: The goal is to minimize the **total cost (number of beers)**, calculated as the sum of the `beer` cost multiplied by the assignment decision `prepare` for all student-class pairs. [cite: 2]
    $$\min \sum_{s \in \text{Students}} \sum_{c \in \text{Classes}} \text{beer}[s,c] \times \text{prepare}[s,c]$$

## ⛓️ Constraints

* [cite_start]`Class_constraint{c in Classes}`: Ensures that **each class $c$ is prepared by exactly one student** ($\sum_{s \in \text{Students}} \text{prepare}[s,c] = 1$). [cite: 1]
* [cite_start]`Student_constraint{s in Students}`: Ensures that **each student $s$ prepares at most one class** ($\sum_{c \in \text{Classes}} \text{prepare}[s,c] \le 1$). [cite: 2]

## 🛠️ Solution and Output

* [cite_start]`solve`: Instructs AMPL to find the optimal assignment. [cite: 3]
* **Output Loop:** After solving, it prints the optimal assignment: which student prepares which class and the associated minimum cost in beers. [cite_start]It only prints the pairs where the binary variable `prepare` is equal to 1. [cite: 3]

## 📊 Data

[cite_start]The `param beer (tr):` section provides the specific cost matrix for the assignment. [cite: 5] [cite_start]The classes are listed in rows, and the students are in columns, showing the cost to assign that student to that class. [cite: 5, 6]

Would you like me to find the **optimal assignment** and the **minimum number of beers** based on this data?