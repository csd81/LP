[cite_start]This is a **classic transportation linear programming model** used to minimize the total shipping cost of products from **factories (Gyarak)** to **pubs (Kocsmak)**, subject to supply and demand constraints[cite: 5, 8].

---

## 🏭 Components and Data

The model uses the following sets and parameters, which are defined in `data.dat` and declared in `modell.mod`:

* **Sets**
    * [cite_start]**Gyarak (Factories/Sources):** Locations where the product is manufactured and stored: Sopron, Tata, Puski, Rabapordany[cite: 1, 5].
    * [cite_start]**Kocsmak (Pubs/Destinations):** Locations that demand the product: Szekesfehervar, Koszeg, Papa[cite: 1, 5].
* **Parameters (Data)**
    * [cite_start]**igeny (Demand):** The required amount of product at each pub[cite: 2, 5].
        * Koszeg: 350
        * Papa: 450
        * Szekesfehervar: 600
    * [cite_start]**keszlet (Supply/Inventory):** The maximum amount of product available at each factory[cite: 3, 5].
        * Sopron: 1000
        * Tata: 150
        * Puski: 200
        * Rabapordany: 400
    * [cite_start]**uthossz (Distance/Cost):** The unit shipping cost (represented by distance) from each factory to each pub[cite: 4, 5].

---

## 📐 Mathematical Model

### 1. Decision Variables

* [cite_start]**szallit[gy, k]:** The non-negative quantity of product to be shipped from factory `gy` to pub `k`[cite: 5].

### 2. Objective Function

[cite_start]The goal is to **minimize the total shipping cost**[cite: 8].

[cite_start]$$\text{Minimize } Z = \sum_{gy \in \text{Gyarak}} \sum_{k \in \text{Kocsmak}} \text{szallit}[gy, k] \times \text{uthossz}[gy, k] \quad \text{[cite: 8]}$$

### 3. Constraints

* [cite_start]**Keszlet\_korlatozas (Supply Constraint):** For every factory (`gy`), the total amount of product shipped out to all pubs must be less than or equal to the available inventory (`keszlet`) at that factory[cite: 6].
    [cite_start]$$\sum_{k \in \text{Kocsmak}} \text{szallit}[gy, k] \leq \text{keszlet}[gy] \quad \forall gy \in \text{Gyarak} \quad \text{[cite: 6]}$$

* [cite_start]**Igeny\_korlatozas (Demand Constraint):** For every pub (`k`), the total amount of product shipped in from all factories must be greater than or equal to the required demand (`igeny`) at that pub[cite: 7].
    [cite_start]$$\sum_{gy \in \text{Gyarak}} \text{szallit}[gy, k] \geq \text{igeny}[k] \quad \forall k \in \text{Kocsmak} \quad \text{[cite: 7]}$$

---

## 🖥️ Execution and Output

[cite_start]The `modell.mod` file includes the command to **solve** the optimization problem and then prints the results[cite: 9, 10].

* [cite_start]The `solve` command finds the optimal shipping plan (`szallit[gy, k]` values) that minimizes the total cost while satisfying all constraints[cite: 9].
* [cite_start]The subsequent `printf` loop iterates through all factories (`Gyarak`) and prints the quantity of product shipped to each pub (`Kocsmak`) *only if* the shipped amount is greater than zero, detailing the optimal flow[cite: 10].


Would you like me to find the optimal solution by running this model?