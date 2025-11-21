```python?code_reference&code_event_index=2
import numpy as np
from scipy.optimize import linear_sum_assignment

# Cost matrix for the 5 cars (rows) and 5 weekdays (columns: Hetfo, Kedd, Szerda, Csutortok, Pentek)
# The costs are in HUF (Ft).

# Rows: Wartburg, Lada, Fiat, Trabant, Skoda
# Columns: Hetfo, Kedd, Szerda, Csutortok, Pentek
cost_matrix = np.array([
    [60000, 65000, 61000, 66000, 60000],  # Wartburg
    [50000, 55000, 63000, 60000, 52000],  # Lada
    [30000, 32000, 33000, 30000, 27000],  # Fiat
    [70000, 65000, 77000, 85000, 100000], # Trabant
    [65000, 70000, 75000, 90000, 70000]   # Skoda
])

# Use the Hungarian algorithm (linear_sum_assignment) to find the minimum cost assignment
row_ind, col_ind = linear_sum_assignment(cost_matrix)

# Calculate the minimum cost for the 5x5 assignment
min_cost_5x5 = cost_matrix[row_ind, col_ind].sum()

# Car and day names for easier interpretation
cars = ['Wartburg', 'Lada', 'Fiat', 'Trabant', 'Skoda']
days = ['Hetfo', 'Kedd', 'Szerda', 'Csutortok', 'Pentek']

# Determine the assignment and the cost for each car
assignment = []
for i in range(len(row_ind)):
    car_index = row_ind[i]
    day_index = col_ind[i]
    cost = cost_matrix[car_index, day_index]
    assignment.append((cars[car_index], days[day_index], cost))

# The sixth day is Szombat (Saturday) with a cost of 1 Ft for any car.
# Since the problem requires buying 5 cars on 5 distinct days out of 6,
# and one car must be bought for 1 Ft on Szombat to minimize the total cost,
# the total minimum cost will be the minimum cost of the 5x5 assignment plus 1 Ft.
total_min_cost = min_cost_5x5 + 1

# The car bought on Szombat must be the one *not* included in the 5x5 assignment.
# But here, all 5 cars are included in the 5x5 assignment for the weekdays.
# This means the optimal solution is to buy one of the cars on Szombat for 1 Ft,
# and the remaining 4 cars on 4 distinct weekdays, leaving one weekday unused.

# Let's adjust the interpretation:
# The minimum total cost is indeed min_cost_5x5 + 1. The optimal solution is one of the 5 cars
# is *not* bought on the weekday in the optimal 5x5 assignment and is instead bought on Szombat for 1 Ft.
# We need to find which car has the lowest cost difference (cost on the optimal weekday - 1)
# but since the weekday costs are so high (30000+) compared to 1, any car can be chosen
# for Szombat and the cost will be min_cost_5x5 + 1, *if we remove the cheapest element*.

# Let's verify the cost elements of the optimal 5x5 assignment
print(f"Optimal 5x5 assignment cost elements: {cost_matrix[row_ind, col_ind]}")
print(f"Minimum cost for the 5x5 assignment (C_match): {min_cost_5x5} Ft")

# Find the cheapest purchase among the 5x5 assignment
min_purchase_index = np.argmin(cost_matrix[row_ind, col_ind])
car_to_move = cars[row_ind[min_purchase_index]]
day_to_free = days[col_ind[min_purchase_index]]
cost_to_save = cost_matrix[row_ind[min_purchase_index], col_ind[min_purchase_index]]

# The car with the minimum cost in the 5x5 assignment is the one we should move to Szombat,
# as the total cost saving is max(cost_to_save - 1).
# Since cost_to_save is the smallest, the total cost will be the smallest by moving it to Szombat.

# Total Minimum Cost is C_match - cost_to_save + 1
min_total_cost = min_cost_5x5 - cost_to_save + 1

print(f"Car to move to Szombat: {car_to_move} (bought on {day_to_free} for {cost_to_save} Ft in 5x5 match)")
print(f"Total minimum cost (C_match - cost_to_save + 1): {min_total_cost} Ft")

# The final assignments:
# The 4 assignments remaining from the 5x5 match
final_assignment = []
for i in range(len(row_ind)):
    if i != min_purchase_index:
        final_assignment.append((cars[row_ind[i]], days[col_ind[i]], cost_matrix[row_ind[i], col_ind[i]]))
# The one moved to Szombat
final_assignment.append((car_to_move, 'Szombat', 1))

print("Final optimal assignment:")
for car, day, cost in sorted(final_assignment, key=lambda x: x[1]):
    print(f"A {car}-t {day} napon vesszük meg {cost} Ft-ért.")
print(f"Összköltség: {min_total_cost} Ft")

# Save the final assignment to a CSV file as requested by the guidelines for providing data outputs
import pandas as pd
df_assignment = pd.DataFrame(final_assignment, columns=['Car', 'Day', 'Cost'])
df_assignment.to_csv('optimal_car_purchase_plan.csv', index=False)

```

```text?code_stdout&code_event_index=2
Optimal 5x5 assignment cost elements: [61000 52000 30000 65000 65000]
Minimum cost for the 5x5 assignment (C_match): 273000 Ft
Car to move to Szombat: Fiat (bought on Csutortok for 30000 Ft in 5x5 match)
Total minimum cost (C_match - cost_to_save + 1): 243001 Ft
Final optimal assignment:
A Skoda-t Hetfo napon vesszük meg 65000 Ft-ért.
A Trabant-t Kedd napon vesszük meg 65000 Ft-ért.
A Lada-t Pentek napon vesszük meg 52000 Ft-ért.
A Wartburg-t Szerda napon vesszük meg 61000 Ft-ért.
A Fiat-t Szombat napon vesszük meg 1 Ft-ért.
Összköltség: 243001 Ft

```

[file-tag: code-generated-file-0-1763733716084432693]

A feladat egy minimális költségű hozzárendelési probléma (Minimum Cost Bipartite Matching) megoldását kéri. Mivel Szombaton (Szombat) az összes autó ára rendkívül alacsony ($1 \text{ Ft}$), az optimális megoldásnak tartalmaznia kell a Szombati vásárlást, amivel a teljes költség minimalizálható.

A megoldás lépései a következők:

1.  Megállapítjuk, hogy az összköltség minimalizálása érdekében az 5 autóból **egyet Szombaton kell megvenni $1 \text{ Ft}$-ért**.
2.  A fennmaradó 4 autót a 5 hétköznapból (Hetfo, Kedd, Szerda, Csutortok, Pentek) 4 különböző napon kell megvenni, minimalizálva az összköltséget.
3.  Ez egy $5 \times 5$-ös hozzárendelési probléma megoldásával egyenértékű a hétköznapi árakra, majd a legolcsóbb hétköznapi vásárlást át kell helyezni Szombatra.

A feladatot a **Magyar Algoritmus** (Hungarian Algorithm) segítségével oldottam meg, ami az optimális hozzárendelést adja a költségmátrixra.

A hétköznapi árak (Ft-ban):

| Autó | Hetfo | Kedd | Szerda | Csutortok | Pentek |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Wartburg** | 60000 | 65000 | 61000 | 66000 | 60000 |
| **Lada** | 50000 | 55000 | 63000 | 60000 | 52000 |
| **Fiat** | 30000 | 32000 | 33000 | 30000 | 27000 |
| **Trabant** | 70000 | 65000 | 77000 | 85000 | 100000 |
| **Skoda** | 65000 | 70000 | 75000 | 90000 | 70000 |

-----

## Optimális Vásárlási Terv

Az $5 \times 5$-ös hozzárendelés minimális költsége $273000 \text{ Ft}$ lenne, de mivel Szombaton az árak $1 \text{ Ft}$, a legolcsóbb hétköznapi vásárlást (a $5 \times 5$-ös optimális hozzárendelésből) Szombatra tesszük át.

A legolcsóbb vásárlás a hétköznapi optimális hozzárendelésben a **Fiat Csütörtökön** $30000 \text{ Ft}$-ért. Ezt átmozgatjuk Szombatra, így a megtakarítás $30000 - 1 = 29999 \text{ Ft}$.

Az **összes minimális költség** a következőképpen alakul:
$$\text{Összköltség} = 273000 \text{ Ft} - 30000 \text{ Ft} + 1 \text{ Ft} = 243001 \text{ Ft}$$

A minimális költséggel járó vásárlási terv a következő:

  * A **Skoda-t Hetfo napon** vesszük meg $65000 \text{ Ft}$-ért.
  * A **Trabant-t Kedd napon** vesszük meg $65000 \text{ Ft}$-ért.
  * A **Wartburg-t Szerda napon** vesszük meg $61000 \text{ Ft}$-ért.
  * A **Lada-t Pentek napon** vesszük meg $52000 \text{ Ft}$-ért.
  * A **Fiat-t Szombat napon** vesszük meg $1 \text{ Ft}$-ért.

A **Csutortok** nap marad fel nem használt nap a hétköznapok közül.

A vásárlási terv adatai az alábbi CSV fájlban találhatóak:

\<file\_link path="optimal\_car\_purchase\_plan.csv"\>optimal\_car\_purchase\_plan.csv\</file\_link\>

-----

## Összegzés

**A minimális összköltség $243001 \text{ Ft}$.**

Az optimális vásárlási terv (napok szerinti sorrendben):

1.  **Hetfo:** Skoda ($65000 \text{ Ft}$)
2.  **Kedd:** Trabant ($65000 \text{ Ft}$)
3.  **Szerda:** Wartburg ($61000 \text{ Ft}$)
4.  **Csutortok:** (Nincs vásárlás)
5.  **Pentek:** Lada ($52000 \text{ Ft}$)
6.  **Szombat:** Fiat ($1 \text{ Ft}$)