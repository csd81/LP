This is a **Bus Scheduling and People Assignment Problem** that aims to minimize the total wasted time (waiting time) for people arriving at work early.

The problem is formulated as an **Integer Linear Programming (ILP)** model.

---

## 🎯 Optimization Goal

The objective is to **minimize the total difference between the required work start time and the actual arrival time** across all people.

$$\text{Minimize: } \sum_{p \in \text{People}} (\text{workstart}[p] - \text{arrive}[p])$$

---

## 🚌 Variables and Parameters

### Parameters
* **`Stations`**: The set of bus stops (e.g., A, B, C, D).
* **`People`**: The set of people needing transport (e.g., E1 to E7).
* **`busCount`** / **`Busses`**: The number of available buses (3).
* **`traveltime`**{Stations}: Time (minutes) from the starting point (Station A) to each station.
    * *Example:* $\text{traveltime}[\text{B}] = 10$.
* **`workstart`**{People}: The required start time for work for each person.
    * *Example:* $\text{workstart}[\text{E1}] = 50$.
* **`workplace`**{People}: The destination station for each person.
    * *Example:* $\text{workplace}[\text{E1}] = \text{B}$.
* **$M$**: A large constant (300), used in Big M constraints for conditional logic.

### Variables
* **$\text{var } \text{start}\{Busses\} \ge 0$**: The **start time** (departure time from Station A) for each bus $b$. This is the primary decision variable for the buses.
* **$\text{var } \text{board}\{People, Busses\}, \text{binary}$**: A **binary decision variable** that is 1 if person $p$ boards bus $b$, and 0 otherwise. This is the primary decision variable for people assignment.
* **$\text{var } \text{arrive}\{People\} \ge 0$**: The **arrival time** of person $p$ at their workplace.

---

## 📝 Constraints

The constraints ensure that the solution is valid according to the problem rules:

1.  **EveryboardsOneBusExactly**: Each person must be assigned to exactly one bus.
    $$\sum_{b \in \text{Busses}} \text{board}[p,b] = 1 \quad \forall p \in \text{People}$$

2.  **EverybodyShouldGetToWorkOnTime**: Everyone must arrive at their workplace no later than their work start time.
    $$\text{arrive}[p] \le \text{workstart}[p] \quad \forall p \in \text{People}$$

3.  **SetArrivalTime1 & SetArrivalTime2**: These are **Big M constraints** that link the arrival time of a person ($p$) to the start time of the bus ($b$) they board.

    If person $p$ boards bus $b$ ($\text{board}[p,b] = 1$), the arrival time must be calculated as:
    $$\text{arrive}[p] = \text{start}[b] + \text{traveltime}[\text{workplace}[p]]$$

    * **SetArrivalTime1:**
        $$\text{arrive}[p] \ge \text{start}[b] + \text{traveltime}[\text{workplace}[p]] - M \cdot (1 - \text{board}[p,b])$$
        If $\text{board}[p,b] = 1$, this reduces to $\text{arrive}[p] \ge \text{start}[b] + \text{traveltime}[\text{workplace}[p]]$ (a lower bound).

    * **SetArrivalTime2:**
        $$\text{arrive}[p] \le \text{start}[b] + \text{traveltime}[\text{workplace}[p]] + M \cdot (1 - \text{board}[p,b])$$
        If $\text{board}[p,b] = 1$, this reduces to $\text{arrive}[p] \le \text{start}[b] + \text{traveltime}[\text{workplace}[p]]$ (an upper bound).

    If person $p$ does **not** board bus $b$ ($\text{board}[p,b] = 0$), the constraints become redundant ($M$ is large enough to make the inequalities trivially true), allowing $\text{arrive}[p]$ to be determined by the bus they *do* board.

---

## 💡 Solution Interpretation

The model will determine the optimal start time for each of the three buses and assign each of the seven people to one of those buses, such that:
1.  No one is late.
2.  The sum of all early arrival times (waiting time) is minimized.

The output will display the optimal departure time for each bus from Station A, the resulting arrival times at all stations, and the specific assignments and waiting times for each person.