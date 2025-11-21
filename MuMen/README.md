[cite_start]The provided files define and provide data for an **Assignment Problem**[cite: 1, 7].

## 📝 Task Description

[cite_start]The task is to **assign people (Emberek) to subjects (Targyak)** in a way that minimizes the total sum of costs (represented by the parameter `sor`)[cite: 4, 7].

### 1. Variables and Data

* **Sets:**
    * [cite_start]`Emberek`: The set of people (Sari, Pista, Gizi, Laci, Mari, Jozsi)[cite: 1, 7].
    * [cite_start]`Targyak`: The set of subjects (Matek, Vallgazd, MinBizt, VIR, Dontes, Valszam)[cite: 1, 7].
* **Parameter:**
    * [cite_start]`sor{Targyak, Emberek}`: A non-negative cost matrix where `sor[e,t]` represents the cost or 'effort' for person `e` to do subject `t` (e.g., number of hours, pages, or general effort required for note-taking)[cite: 1, 8]. [cite_start]The data shows 6 people and 6 subjects[cite: 7].
* **Decision Variable:**
    * [cite_start]`megcsinal{Emberek, Targyak} binary`: A binary variable that is 1 if person `e` is assigned to subject `t`, and 0 otherwise[cite: 1].

### 2. Constraints

The model ensures a one-to-one assignment:

* [cite_start]**Minden\_targyat\_egyszer** (Every subject once): Each subject `t` must be assigned to exactly one person[cite: 2].
    $$\sum_{e \in \text{Emberek}} \text{megcsinal}[e,t] = 1 \quad \forall t \in \text{Targyak}$$
* [cite_start]**Minden\_ember\_egyet** (Every person one): Each person `e` must be assigned to exactly one subject[cite: 3].
    $$\sum_{t \in \text{Targyak}} \text{megcsinal}[e,t] = 1 \quad \forall e \in \text{Emberek}$$

### 3. Objective

[cite_start]The goal is to **minimize** the total cost (`Osszes\_megvett\_sor`)[cite: 4].

$$\text{Minimize} \quad \sum_{e \in \text{Emberek}, t \in \text{Targyak}} \text{sor}[e,t] \cdot \text{megcsinal}[e,t]$$

### 4. Output

[cite_start]The solution should print the assignment for each person and subject where the assignment variable `megcsinal` is 1[cite: 5, 6].

> **Example Output Structure:** "%s csinalja meg a %s targy jegyzetet." (meaning: "%s does the notes for subject %s.") [cite_start][cite: 5]

---

**In summary, the task is to find the minimum cost assignment of the 6 people to the 6 subjects, ensuring everyone gets exactly one subject and every subject is covered exactly once.**

Would you like me to solve this assignment problem based on the provided model and data?