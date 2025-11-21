This is an **optimization model** likely written in a modeling language like AMPL or GLPK, designed to solve a **beer transportation problem** from **breweries** to **universities** at a minimum cost.

---

## 🍺 Model Description

The model determines the optimal amount of beer to transport between breweries and universities and the number of trips using different truck types to satisfy demand while respecting production capacity and minimizing transportation costs.

### 🏭 Sets and Parameters (Input Data)

These define the entities and known values of the problem:

| Set/Parameter | Description | Unit/Type | File Source |
| :--- | :--- | :--- | :--- |
| `Brewery` | Set of all breweries. | N/A | `.m` |
| `University` | Set of all universities (demand points). | N/A | `.m` |
| `Trucktype` | Set of available truck types (e.g., `small`, `large`). | N/A | `.d`, `.m` |
| `distance_km{B,U}` | Distance between brewery $B$ and university $U$. | km | `.m` |
| `production_hl{B}` | Production capacity of brewery $B$. | hectoliters (hl) | `.m` |
| `demand_hl{U}` | Beer demand at university $U$. | hectoliters (hl) | `.m` |
| `beer_density_kg_per_l` | Density of beer. | $\text{kg}/\text{liter}$ | `.m` |
| `transportation_cost_HUF_per_kg_per_km` | Cost to transport $1\text{ kg}$ over $1\text{ km}$. | $\text{HUF}/\text{kg}/\text{km}$ | `.m` |
| `truck_weight_t{T}` | Empty weight of truck type $T$. | tonnes (t) | `.d`, `.m` |
| `truck_carry_capacity_t{T}` | Payload capacity of truck type $T$. | tonnes (t) | `.d`, `.m` |

**Example Data from `pro.d`:**

| Trucktype | `truck_weight_t` (t) | `truck_carry_capacity_t` (t) |
| :--- | :--- | :--- |
| `small` | 2 | 1 |
| `large` | 3 | 2 |

---

### 🚚 Variables (Decisions)

These are the values the model must determine:

| Variable | Description | Domain |
| :--- | :--- | :--- |
| `transport_hl{B,U}` | Amount of beer transported from brewery $B$ to university $U$. | $\ge 0$ |
| `trips{B,U,T}` | Number of trips of truck type $T$ from $B$ to $U$. | $\ge 0$, **integer** |

---

### ⚖️ Constraints (Restrictions)

These limit the possible solutions:

1.  **`Brewery_capacity_hl`**: Total beer transported *out* of any brewery cannot exceed its production capacity:
    $$\sum_{u \in \text{University}} \text{transport\_hl}[b,u] \le \text{production\_hl}[b]$$
2.  **`University_demand_hl`**: Total beer transported *to* any university must meet its demand:
    $$\sum_{b \in \text{Brewery}} \text{transport\_hl}[b,u] \ge \text{demand\_hl}[u]$$
3.  **`Enough_transport_capacity_for_transported_beer_t`**: The total payload capacity provided by the truck trips must be sufficient to carry the mass of the transported beer:
    $$\frac{\text{beer\_density\_kg\_per\_l} \times \text{transport\_hl}[b,u]}{10} \le \sum_{t \in \text{Trucktype}} \text{trips}[b,u,t] \times \text{truck\_carry\_capacity\_t}[t]$$
    *Note: The left side of the inequality converts beer volume from hl (hectoliters) to tonnes. ($1 \text{ hl} = 100 \text{ L}$; $\text{density}$ is in $\text{kg}/\text{L}$. So $\text{hl} \times 100 \times \text{density}$ is mass in $\text{kg}$, dividing by $1000$ gives mass in tonnes (t). $100/1000 = 1/10$.*

---

### 💰 Objective Function (Goal)

The objective is to **minimize** the total transportation cost in $\text{HUF}$. The cost calculation includes the cost of moving both the **beer** (payload) and the **trucks** (tare weight), multiplied by the distance.

**Minimize `Transportation_cost_HUF`**:
$$\sum_{b \in \text{Brewery}, u \in \text{University}} \text{transportation\_cost\_HUF\_per\_kg\_per\_km} \times \text{distance\_km}[b,u] \times \text{TotalMass}[b,u]$$

Where $\text{TotalMass}[b,u]$ is the total mass (payload + empty truck mass for all trips) moved one way, from $B$ to $U$.

$$\text{TotalMass}[b,u] = \left( \underbrace{\text{beer\_density\_kg\_per\_l} \times 100 \times \text{transport\_hl}[b,u]}_{\text{Mass of transported beer in kg}} \right) + \left( \underbrace{\sum_{t \in \text{Trucktype}} 2 \times \text{trips}[b,u,t] \times \text{truck\_weight\_t}[t] \times 1000}_{\text{Mass of empty trucks (forward \& return trip) in kg}} \right)$$

* The term $\text{beer\_density\_kg\_per\_l} \times 100 \times \text{transport\_hl}[b,u]$ calculates the mass of the beer in **kilograms** (since $1 \text{ hl} = 100 \text{ L}$).
* The term $2 \times \text{trips}[b,u,t] \times \text{truck\_weight\_t}[t] \times 1000$ calculates the total empty truck weight in **kilograms** for all trips, multiplied by **2** because the cost includes the **empty return trip** (truck weight for the forward trip + truck weight for the return trip).

---

## 🖥️ Output (Post-Solve)

The model concludes by printing:

1.  The final minimum **Cost: `Transportation_cost_HUF`**.
2.  A detailed list of every route $(B \to U)$ with non-zero beer transport (`transport_hl` $> 0$):
    * The brewery and university names.
    * The amount of beer transported (`transport_hl`).
    * The specific number of trips for each `Trucktype` (e.g., `small:2`, `large:1`).

Would you like to provide the data files (e.g., `pro.dat`) to solve this optimization problem?