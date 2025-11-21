## 📝 Task Description: Currency Exchange Optimization

[cite_start]The task is to **maximize the final balance of USD (United States Dollar) after a period of five days**, by optimally deciding how much of each currency to exchange into others on each day[cite: 7]. [cite_start]This is an optimization problem formulated using an algebraic modeling language (likely AMPL, given the syntax)[cite: 4].

---

### ⚙️ Model Components

The model includes the following sets, parameters, and variables:

#### Sets
* [cite_start]**Currencies**: The set of available currencies for exchange, defined as **USD**, **BTC** (Bitcoin), and **HUF** (Hungarian Forint)[cite: 1].
* [cite_start]**Days**: The set of five days for the exchange period, defined as **1, 2, 3, 4, 5**[cite: 1].

#### Parameters
* [cite_start]**initial\_money**: The starting amount of each currency on Day 1. The initial balance is **10 USD**, **0 HUF**, and **0 BTC**[cite: 2].
* [cite_start]**dollar\_value**: The value of 1 unit of each currency in USD on each day[cite: 3, 4].

| Currency | Day 1 | Day 2 | Day 3 | Day 4 | Day 5 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **USD** | 1 | 1 | 1 | 1 | 1 |
| **HUF** | 350 | 380 | 420 | 410 | 415 |
| **BTC** | 49 | 200 | 120 | 180 | 60 |

#### Variables
* **exchange{Currencies, Currencies, Days}**: The amount of a source currency to exchange into a target currency on a specific day. [cite_start]This amount must be non-negative[cite: 4].
* **balance{Currencies, Days}**: The total amount of each currency held at the end of each day. [cite_start]This amount must be non-negative[cite: 4].

#### Objective Function
* [cite_start]**Maximize Dollars**: The goal is to maximize the final balance of **USD** at the end of the last day (Day 5)[cite: 7].

$$
[cite_start]\text{Maximize: } \text{balance['USD', card(Days)]} \quad \text{(i.e., balance['USD', 5])} \text{ [cite: 7]}
$$

#### Constraints
* [cite_start]**set\_balance\_first\_day**: Calculates the balance for each currency on **Day 1**[cite: 5]:
    * [cite_start]It starts with the **initial\_money**[cite: 5].
    * [cite_start]It **adds** the value gained from incoming exchanges (source currency $\text{cc}$ into target currency $\text{c}$)[cite: 5]. [cite_start]The exchange amount is converted to USD value using $1/\text{dollar\_value}[\text{cc}, 1]$ and then back to the target currency's $\text{c}$ value using $\text{dollar\_value}[\text{c}, 1]$[cite: 5].
    * [cite_start]It **subtracts** the amount spent on outgoing exchanges (source currency $\text{c}$ into target currency $\text{cc}$)[cite: 5].

* [cite_start]**set\_balance\_other\_days**: Calculates the balance for each currency on **Day 2 through Day 5**[cite: 6]:
    * [cite_start]It starts with the **balance** from the previous day ($\text{balance}[\text{c}, \text{d}-1]$)[cite: 6].
    * [cite_start]It applies the same logic for **adding** value from incoming exchanges and **subtracting** the amount spent on outgoing exchanges as the first day's constraint, using the dollar values for the current day $\text{d}$[cite: 6].

---

[cite_start]Would you like me to identify the most volatile currency based on the provided dollar values[cite: 3]?