This is a description of a **classic transportation problem** modeled using the **AMPL (A Mathematical Programming Language)** system.

The files represent the **model definition (`clever.mod`)**, the **input data (`clever.dat`)**, and the **solution output (`clever.txt`)**.

---

## 💻 Model Definition (`clever.mod`)

The model defines a linear program to minimize the cost of transporting goods from supply points to demand points.

### 📝 Key Components

* **Sets:**
    * [cite_start]`Supplies`: The locations where the goods originate[cite: 1].
    * [cite_start]`Demands`: The locations where the goods are needed[cite: 1].
* **Parameters (Input Data):**
    * [cite_start]`supply{Supplies}`: The available quantity of goods at each supply location[cite: 1].
    * [cite_start]`demand{Demands}`: The required quantity of goods at each demand location[cite: 1].
    * [cite_start]`distance{Supplies,Demands}`: The cost (or distance) to transport one unit of goods between a supply and a demand location[cite: 1].
* **Variable:**
    * [cite_start]`transport{Supplies,Demands}`: The decision variable representing the non-negative quantity of goods to transport from each supply point $s$ to each demand point $d$[cite: 1].
* **Objective Function (Minimization):**
    * [cite_start]`Transportation_cost`: The goal is to minimize the total cost, which is the sum of the product of the `distance` and the quantity of goods to `transport` for every possible supply-demand route[cite: 4].
    $$\text{Minimize } \sum_{s \in \text{Supplies}} \sum_{d \in \text{Demands}} \text{distance}[s,d] \cdot \text{transport}[s,d]$$
* **Constraints:**
    * [cite_start]`Max_Supply`: The total amount of goods transported *out* of any supply location $s$ must be less than or equal to the available `supply` at that location[cite: 2].
        $$\forall s \in \text{Supplies}: \sum_{d \in \text{Demands}} \text{transport}[s,d] \le \text{supply}[s]$$
    * [cite_start]`Min_Demand`: The total amount of goods transported *into* any demand location $d$ must be greater than or equal to the required `demand` at that location[cite: 3].
        $$\forall d \in \text{Demands}: \sum_{s \in \text{Supplies}} \text{transport}[s,d] \ge \text{demand}[d]$$

---

## 📊 Data File (`clever.dat`)

This file provides the specific data for the transportation problem.

* [cite_start]**Supplies:** Sopron, Pecs, Nagykanizsa[cite: 9].
* [cite_start]**Supply Quantities:** Sopron (1000), Pecs (500), Nagykanizsa (200)[cite: 9].
* [cite_start]**Demands:** Sopron, Veszprem, Gyor, Pecs, Szombathely[cite: 10].
* [cite_start]**Demand Quantities:** Sopron (250), Veszprem (350), Gyor (500), Pecs (500), Szombathely (100)[cite: 10].
    * *Note:* The total supply (1700) is slightly greater than the total demand (1700), indicating a balanced problem where all demand can be met.
* [cite_start]**Distance Matrix:** A table of the unit transportation costs between supply (rows) and demand (columns) locations[cite: 11, 12].

---

## ✅ Solution Output (`clever.txt`)

This file shows the optimal `transport` quantities determined by solving the linear program, which minimizes the total transportation cost. [cite_start]It lists the non-zero transportation routes[cite: 6].

| From (Supply) | To (Demand) | Quantity Transported |
| :--- | :--- | :--- |
| [cite_start]**Sopron** [cite: 8] | [cite_start]Sopron [cite: 8] | 250 |
| | [cite_start]Veszprem [cite: 8] | 150 |
| | [cite_start]Gyor [cite: 8] | 500 |
| | [cite_start]Szombathely [cite: 8] | 100 |
| [cite_start]**Pecs** [cite: 8] | [cite_start]Pecs [cite: 8] | 500 |
| [cite_start]**Nagykanizsa** [cite: 8] | [cite_start]Veszprem [cite: 8] | 200 |

