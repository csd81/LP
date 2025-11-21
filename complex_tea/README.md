[cite_start]The uploaded files describe a **tea transportation optimization problem** formulated for a mathematical programming solver like GLPK or AMPL[cite: 5, 14]. [cite_start]This model minimizes the total transportation cost of shipping tea from various farms (supply) to different markets (demand) using a fleet of vehicles with specific capacities and weights[cite: 5, 7].

---

## 🗺️ Data Description (`tea_data.dat`)

The `tea_data.dat` file defines the specific parameters and sets for the model:

* [cite_start]**Farms (Supply Locations):** `Kapuvar`, `Sarvar`, and `Kaposvar`[cite: 1].
* [cite_start]**Supply:** The amount of tea available at each farm, in kg[cite: 1, 2]:
    * Kapuvar: 75 kg
    * Sarvar: 125 kg
    * Kaposvar: 150 kg
* [cite_start]**Markets (Demand Locations):** `Sopron`, `Gyor`, `Budapest`, and `Nagykanizsa`[cite: 2].
* [cite_start]**Demand:** The required amount of tea at each market, in kg[cite: 2, 3]:
    * Sopron: 30 kg
    * Gyor: 60 kg
    * Budapest: 120 kg
    * Nagykanizsa: 40 kg
* **Total Supply vs. Total Demand:**
    * Total Supply: $75 + 125 + 150 = 350$ kg
    * Total Demand: $30 + 60 + 120 + 40 = 250$ kg
    * Since total supply (350 kg) is greater than total demand (250 kg), this is an **unbalanced transportation problem** where not all available tea will be shipped.
* [cite_start]**Distance:** The distance matrix (in km) between each farm and market[cite: 3, 4]:

| Farm | Sopron (km) | Gyor (km) | Budapest (km) | Nagykanizsa (km) |
| :--- | :---------- | :-------- | :------------ | :--------------- |
| Kapuvar | 30 | 40 | 170 | 150 |
| Sarvar | 80 | 100 | 200 | 111 |
| Kaposvar | 240 | 210 | 180 | 70 |

---

## 📐 Model Formulation (`complex_tea.mod`)

[cite_start]The `complex_tea.mod` file defines the sets, parameters, variables, constraints, and objective function for the optimization problem [cite: 5-14]:

### Sets and Parameters
* [cite_start]**Sets:** `Farms`, `Markets`, and `Vehicles`[cite: 5, 7]. The `Vehicles` set is defined in the model file but must be populated in a separate data file (not provided here).
* **Parameters:**
    * [cite_start]`supply{Farms}`: Tea available at each farm (kg)[cite: 5].
    * [cite_start]`demand{Markets}`: Tea required at each market (kg)[cite: 5].
    * [cite_start]`distance{Farms,Markets}`: Distance between each farm and market (km)[cite: 5, 6].
    * [cite_start]`weight{Vehicles}`: The weight of each vehicle (kg)[cite: 7].
    * [cite_start]`capacity{Vehicles}`: The maximum carrying capacity of each vehicle (kg)[cite: 7].
    * [cite_start]`transport_cost`: A constant cost parameter, defaulted to 1 Ft/kg/km (Hungarian Forint per kg per km)[cite: 7].

### Variables
* [cite_start]**`travel{Farms,Markets,Vehicles}`**: The **integer** number of times a specific vehicle type travels from a farm to a market[cite: 7].
* [cite_start]**`transport{Farms,Markets}`**: The total amount of tea (kg) transported from a farm to a market[cite: 7].

### Constraints
1.  [cite_start]**Supply Constraint (`Supply_can_not_be_overreached`)**: The total amount of tea shipped out from a farm must be less than or equal to the farm's available supply[cite: 8].
    $$\sum_{m \in Markets} \text{transport}[f,m] \leq \text{supply}[f] \quad \text{for each } f \in Farms$$
2.  [cite_start]**Demand Constraint (`Demand_must_be_met`)**: The total amount of tea shipped into a market must be greater than or equal to the market's required demand[cite: 9].
    $$\sum_{f \in Farms} \text{transport}[f,m] \geq \text{demand}[m] \quad \text{for each } m \in Markets$$
3.  [cite_start]**Vehicle Capacity Constraint (`Vehicle_capacity`)**: The total tea transported on a route must not exceed the combined capacity of all vehicles traveling that route[cite: 10].
    $$\text{transport}[f,m] \leq \sum_{v \in Vehicles} \text{capacity}[v] \times \text{travel}[f,m,v] \quad \text{for each } f \in Farms, m \in Markets$$

### Objective Function (Minimize Cost)
The objective is to **minimize the total transportation cost**. [cite_start]The total cost has two components, both calculated per km travelled[cite: 12]:

1.  **Tea Transportation Cost**: The cost of shipping the tea itself (based on the amount of tea).
2.  **Vehicle Travel Cost**: The cost associated with the vehicle's weight (empty weight cost) for the round trip (hence the factor of **2**).

$$
\min \text{Transportation\_cost} = \text{transport\_cost} \times \sum_{f, m} \text{distance}[f,m] \times \left( \text{transport}[f,m] + 2 \times \sum_{v} \text{weight}[v] \times \text{travel}[f,m,v] \right)
$$

### Output
[cite_start]After solving, the model prints the optimal solution, showing the amount of tea transported ($\text{transport}[f,m]$) between each farm and market, and the specific number of vehicles ($\text{travel}[f,m,v]$) used for that shipment [cite: 14-16].

---

Would you like to provide the vehicle data to **solve this optimization problem**?