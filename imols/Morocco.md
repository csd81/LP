The problem is to determine the optimal amounts of petrol to purchase at each available station during a car trip from Oujda, Morocco, to Capetown, South Africa, in order to **minimize the total fuel cost**.

---

## ⛽ Problem Parameters

* **Total Trip Distance:** 11,000 km.
* **Car Tank Capacity:** 70 liters.
* **Initial Fuel:** The tank is full (70 liters) at the start in Oujda.
* **Fuel Consumption Rate:** 7.5 liters per 100 km.
* **Safety Requirement:** At all times, including upon arrival at any petrol station, the car must have enough fuel for an **additional 50 km**.

## 📍 Petrol Stations and Data

The trip involves **22 petrol stations**. The data for each station's distance from Oujda and the price of petrol is as follows:

| Petrol Station | Distance from Oujda (km) | Price of Petrol (Dh/l) |
| :--- | :---: | :---: |
| Algeria1 | 320 | 100 |
| Algeria2 | 840 | 90 |
| Algeria3 | 1350 | 70 |
| Algeria4 | 2000 | 80 |
| Algeria5 | 2580 | 100 |
| Algeria6 | 3170 | 90 |
| Niger1 | 3560 | 120 |
| Niger2 | 4080 | 130 |
| Nigeria1 | 4660 | 140 |
| Nigeria2 | 5180 | 120 |
| Cameroon | 5500 | 150 |
| Gabon | 5950 | 160 |
| Congo1 | 6479 | 110 |
| Congo2 | 6990 | 130 |
| Angola1 | 7440 | 120 |
| Angola2 | 7960 | 130 |
| Angola3 | 8410 | 120 |
| Namibia1 | 8730 | 140 |
| Namibia2 | 9250 | 150 |
| Namibia3 | 9770 | 130 |
| SouthAfrica1 | 10350 | 140 |
| SouthAfrica2 | 10670 | 120 |

---

## 🎯 Optimization Goal

Determine **where and how much** petrol to purchase at each of the 22 stations (the decision variables) to **minimize the total cost** while satisfying the constraints on tank capacity and the safety fuel requirement.