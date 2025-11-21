\[cite\_start]You're looking at a \*\*mathematical optimization problem\*\* modeled in the \*\*AMPL\*\* language, specifically designed to determine the optimal arrangement of book sets onto a set of shelves to \*\*minimize the total height\*\* of the shelving unit\[cite: 3].



The model, `books.m`, defines the problem structure, variables, and constraints, while `books.d` provides the specific data (book dimensions, shelf parameters).



Here is a breakdown of the model, its objective, and the constraints it enforces, directly addressing the scenario described in the `Feladat.txt` file.



\## 📚 Problem Description

\[cite\_start]The goal is to arrange \*\*9 book sets\*\* (each treated as an indivisible unit) onto a maximum of \*\*7 shelves\*\*\[cite: 4, 7]. The constraints are:

1\.  \[cite\_start]\*\*Minimize the height\*\* of the highest used shelf\[cite: 3].

2\.  \[cite\_start]The shelves are \*\*120 cm wide\*\*\[cite: 3].

3\.  \[cite\_start]The lowest shelf starts at \*\*50 cm\*\*\[cite: 2].

4\.  \[cite\_start]There must be an \*\*offset of 7 cm\*\* above the tallest book on any shelf\[cite: 6].

5\.  \[cite\_start]Shelf thickness is \*\*2 cm\*\*\[cite: 7].



\## 📊 Data (from `books.d` and `Feladat.txt`)



\### Book Sets

\[cite\_start]The data defines the \*\*maximum height ($\\text{maxheight}$) of books\*\* in each set and the \*\*total width ($\\text{totalwidth}$) of the set\*\*\[cite: 8, 9, 10].



| Bookset | Total Width (cm) | Max Height (cm) |

| :--- | :---: | :---: |

| Math | 100 | 20 |

| IT | 80 | 25 |

| Sport | 30 | 30 |

| Music | 50 | 30 |

| Novel | 40 | 20 |

| Tolkien | 30 | 25 |

| Feist | 50 | 20 |

| HarryPotter | 90 | 25 |

| Diploma | 70 | 40 |



---



\### Shelf Parameters



| Parameter | Value (cm) | Description |

| :--- | :---: | :--- |

| $\\text{shelfcount}$ | 7 | \[cite\_start]Maximum number of available shelves\[cite: 7]. |

| $\\text{shelfwidth}$ | 120 | \[cite\_start]The width of each shelf\[cite: 3]. |

| $\\text{shelfthickness}$ | 2 | \[cite\_start]The thickness of each shelf\[cite: 7]. |

| $\\text{lowestshelf}$ | 50 | \[cite\_start]The starting position of the first shelf\[cite: 2]. |

| $\\text{offset}$ | 7 | \[cite\_start]The minimum space above the tallest book\[cite: 6]. |

| $M$ | 1000 | A large constant (used for conditional constraints). |



---



\## 💻 AMPL Model Components



\### Variables



\* $\\text{put}\[b,s]$: \*\*Binary\*\*. Is bookset $b$ placed on shelf $s$?

\* $\\text{isused}\[s]$: \*\*Binary\*\*. Is shelf $s$ used?

\* $\\text{shelfposition}\[s]$: The height (position) of the bottom of shelf $s$.

\* $\\text{shelfheight}\[s]$: The minimum required \*clearance height\* for shelf $s$ (determined by the tallest book on it).

\* $\\text{highestshelf}$: The maximum height reached by the shelving unit.



\### Objective



The goal is to \*\*Minimize Height\*\*:

$$\\min \\text{highestshelf}$$

This variable tracks the position of the highest used shelf.



\### Constraints



| Constraint Name | Purpose | Mathematical Description |

| :--- | :--- | :--- |

| `BooksetShelfAssignment` | \[cite\_start]\*\*Each book set goes on exactly one shelf\*\*\[cite: 5]. | $\\sum\_{s} \\text{put}\[b,s] = 1$ |

| `Shelfcapacity` | \*\*Total width of books on a shelf can't exceed the shelf's width\*\* ($120 \\text{ cm}$), and only applies to used shelves. | $\\sum\_{b} \\text{totalwidth}\[b] \\cdot \\text{put}\[b,s] \\le \\text{shelfwidth} \\cdot \\text{isused}\[s]$ |

| `MaxShelfHeight` | \*\*Sets the required clearance height for the shelf\*\* based on the tallest book on it. | $\\text{shelfheight}\[s] \\ge \\text{maxheight}\[b] \\cdot \\text{put}\[b,s]$ |

| `FirtsShelf` | \[cite\_start]\*\*Sets the position of the bottom of the first shelf\*\*\[cite: 2]. | $\\text{shelfposition}\[1] = \\text{lowestshelf}$ |

| `ShelfDistances` | \[cite\_start]\*\*Defines the minimum distance between consecutive shelves\*\*\[cite: 6, 7]. It's a conditional constraint using the large constant $M$. If $\\text{isused}\[s]=1$, then $\\text{shelfposition}\[s] \\ge \\text{shelfposition}\[s-1] + \\text{shelfheight}\[s-1] + \\text{offset} + \\text{shelfthickness}$. | $\\text{shelfposition}\[s] \\ge \\text{shelfposition}\[s-1] + \\text{shelfheight}\[s-1] + \\text{offset} + \\text{shelfthickness} - M \\cdot (1-\\text{isused}\[s])$ |

| `ShelfUsage` | \*\*If a shelf is unused, all subsequent shelves must also be unused\*\* (ensuring shelves are used contiguously from the bottom). | $\\text{isused}\[s] \\le \\text{isused}\[s-1]$ |

| `HighestReach` | \*\*Updates $\\text{highestshelf}$\*\* to be the position of the highest used shelf. | $\\text{highestshelf} \\ge \\text{shelfposition}\[s] - M \\cdot (1-\\text{isused}\[s])$ |



---



\## 🎨 Visualization

The second part of the `books.m` file contains `printf` statements in a loop, which generate an \*\*SVG (Scalable Vector Graphics) output\*\* after the problem is solved. This code is designed to visually render the optimal shelving arrangement, showing the position and size of each shelf and book set.





Would you like to see the \*\*numerical results\*\* (e.g., the optimal total height and which books are on which shelf) after solving this optimization problem?

You have provided three files that together define an optimization problem for a car dealer trying to maximize profit over a week.



\* \*\*`car\\\_data.d`\*\*: The specific scenario data (prices, budget, etc.).

\* \*\*`car\\\_dealer\\\_chaotic.m`\*\*: A "naive" or complex implementation of the model using binary variables and heavy summation.

\* \*\*`car\\\_dealer\\\_nicer.m`\*\*: A streamlined, efficient implementation using state variables and flow balance.



Here is the detailed explanation of the problem and the two different modeling approaches.



---



\### 1. The Scenario (`car\\\_data.d`)



The goal is to maximize wealth (cash on hand) after \*\*7 days\*\* of trading.

\* \*\*Inventory:\*\* You trade \*\*4 types of cars\*\* (Trabant, Skoda, Wartburg, Fiat).

\* \*\*Constraints:\*\*

    \* \*\*Budget:\*\* You start with \*\*200,000 HUF\*\*.

    \* \*\*Space:\*\* You have a garage capacity of \*\*4 cars\*\*.

    \* \*\*Prices:\*\* Prices fluctuate daily. For example, a Trabant costs 120,000 on Day 1, rises to 135,000 on Day 2, and drops to 111,000 by Day 5.



---



\### 2. The "Chaotic" Approach (`car\\\_dealer\\\_chaotic.m`)



This model represents a "brute force" logical approach. While it works, it is computationally expensive and difficult to read because it recalculates the entire history of transactions for every single constraint.



\*\*Key Characteristics:\*\*

\* \*\*Split Variables:\*\* It uses separate variables for buying and selling: `buy\\\[d,c]` and `sell\\\[d,c]`.

\* \*\*Binary Constraints (Big M):\*\* To prevent buying and selling the same car on the same day (which is mathematically redundant but logically distinct), it introduces a binary variable `buyorsell` and a "Big M" constraint:

    $$buy\[d,c] \\le M \\cdot buyorsell\[d,c]$$

    This turns the problem into a \*\*MILP (Mixed Integer Linear Program)\*\*, which is generally harder to solve.

\* \*\*History Re-calculation:\*\* To check if you have enough money or cars on Day 5, the model sums up \*every\* transaction from Day 1 to Day 5.

    \* \*Example:\* The constraint `NoNegativeBalance` sums all previous sales and subtracts all previous purchases to ensure the current balance is non-negative.



---



\### 3. The "Nicer" Approach (`car\\\_dealer\\\_nicer.m`)



This model uses \*\*State Variables\*\*. Instead of recalculating the past, it simply tracks the \*state\* of the system (Money in pocket, Cars in garage) from one day to the next.



\*\*Key Improvements:\*\*

\* \*\*Unified Variable:\*\* It uses a single integer variable `buysell\\\[d,c]`.

    \* \*\*Positive value:\*\* You are buying.

    \* \*\*Negative value:\*\* You are selling.

    \* This automatically handles the "don't buy and sell at the same time" logic without binary variables.

\* \*\*State Variables (`balance` and `garage`):\*\*

    \* It introduces `balance\\\[d]` (money at end of day $d$) and `garage\\\[d,c]` (inventory at end of day $d$).

\* \*\*Flow Constraints:\*\* instead of summing history, it links today to yesterday:

    \* \*\*Money:\*\* $\\text{Balance}\_{today} = \\text{Balance}\_{yesterday} - \\text{Cost} \\cdot \\text{buysell}$

    \* \*\*Inventory:\*\* $\\text{Garage}\_{today} = \\text{Garage}\_{yesterday} + \\text{buysell}$

    \* See constraints `ConnectBalanceBuySell` and `ConnectGarageBuySell` in the file.



\### Comparison



| Feature | Chaotic Model | Nicer Model |

| :--- | :--- | :--- |

| \*\*Variables\*\* | Separate `buy` / `sell` | Single `buysell` (+/-) |

| \*\*Logic Type\*\* | MILP (Uses Binary variables) | IP (Integer Programming only) |

| \*\*Tracking\*\* | Sums history ($\\sum\_{dd=1}^d ...$) | Uses previous state ($d-1$) |

| \*\*Complexity\*\* | High (Harder to solve/debug) | Low (Clean and scalable) |



The "Nicer" model is the professional standard for this type of inventory/asset management problem.



\*\*Would you like me to run the "Nicer" model with the provided data to see what the optimal trading strategy is?\*\*

Átnézve a feladatleírást és az AMPL kódodat, a modell majdnem tökéletes, de **egy fontos korlátozás kimaradt** a kódból, ami a szövegben szerepel:

> *"sosem viszünk el egy körre **5-nél több csomagot**"*

A jelenlegi kódodban a súlykorlát (`MeetCapacity`) megvan, de a darabszám-korlát hiányzik. Ezt pótoltam az alábbi javított kódban, illetve tettem egy megjegyzést a határidő kezelésével kapcsolatban is.

### Javított AMPL Modell

A módosításokat **kommentben jelöltem** a kódon belül.

```ampl
set Places;
set Routes;

param visit {Routes,Places}, binary;

param ordercount >=0, integer;
set Orders := 1..ordercount;
param deadline{Orders} >=0,integer; # round
param weight{Orders} >=0; # kg
param place{Orders}, symbolic, in Places;

param capacity; # kg - Ez a 10 kg-os súlykorlát
param slotcount;
# ÚJ PARAMÉTER: a darabszám korlát (alapértelmezetten 5)
param max_items_per_round default 5; 

set Slots := 1 .. slotcount;

# MEGJEGYZÉS: A szöveg szerint "később van, minthogy befejeznénk". 
# Ha ez szigorú egyenlőtlenséget jelent, akkor s < deadline[o] kellene. 
# A lenti kód megengedi az s <= deadline[o]-t (azaz a határidő órájában még kézbesíthető).
# Ez a legtöbb feladatnál így helyes, ezért így hagytam.
set SlotOrder:=setof{s in Slots, o in Orders: s<=deadline[o]}(s,o);

var chose{Slots,Routes}, binary;
var deliver{SlotOrder}, binary;

# 1. Minden órában pontosan egy útvonalat választunk
s.t. ExactlyOneRouteAtEachSlot {s in Slots}:
    sum{r in Routes} chose[s,r] = 1;

# 2. Minden csomagot legfeljebb egyszer szállítunk ki
s.t. DeliveredAtMostOnce{o in Orders}:
    sum{(s,o) in SlotOrder} deliver[s,o]<=1;

# 3. Csak akkor szállítunk, ha a cím rajta van a választott útvonalon
s.t. DeliveredOnlyIfOnRoute{(s,o) in SlotOrder}:
    deliver[s,o] <= sum{r in Routes: visit[r,place[o]]} chose[s,r];

# 4. Súlykorlát (max 10 kg)
s.t. MeetCapacity{s in Slots}:
    sum{(s,o) in SlotOrder} deliver[s,o]*weight[o]<=capacity;

# 5. ÚJ KORLÁTOZÁS: Darabszám korlát (max 5 csomag)
s.t. MaxItemsConstraint{s in Slots}:
    sum{(s,o) in SlotOrder} deliver[s,o] <= max_items_per_round;


maximize DeliveredOrders: sum{(s,o) in SlotOrder} deliver[s,o];

solve;

# EREDMÉNY KIÍRATÁSA
printf "\n--- EREDMENY ---\n";
printf "Osszes kiszallitott csomag: %d\n", DeliveredOrders;

for{s in Slots}
{
    for{r in Routes:chose[s,r]==1}
    {
        printf "\nOra %d (Utvonal: %s)\n",s,r;
        printf "--------------------------\n";
        
        # Először kiírjuk a választott útvonalat
        # Majd listázzuk, hogy mit szállítunk oda
        for{(s,o) in SlotOrder: deliver[s,o]==1}
        {
             # Csak akkor írjuk ki, ha ezen a körön visszük el
             # (mivel az útvonal fix, nem kell külön iterálni a Places-en a csomagokhoz)
             printf " -> Csomag %d: Cim: %s, Suly: %.2f kg, Hatarido: %d\n", 
                    o, place[o], weight[o], deadline[o];
        }
        
        # Opcionális: Ellenőrzés (Súly és Darab)
        printf "   [Osszesen: %d db csomag, %.2f kg teher]\n", 
               sum{(s,o) in SlotOrder: deliver[s,o]==1} 1,
               sum{(s,o) in SlotOrder: deliver[s,o]==1} weight[o];
    }   
}

end;
```

-----

### A változtatások magyarázata

1.  **`param max_items_per_round default 5;`**:
    Felvettem egy új paramétert a feladatban említett *"5-nél több csomagot sosem viszünk"* szabályhoz. Bár beégethettük volna fix számként is a `constraint`-be, így elegánsabb és később könnyen módosítható, ha a futárcég szabályt vált.

2.  **`s.t. MaxItemsConstraint`**:
    Ez a hiányzó láncszem. Hasonlóan működik, mint a súlykorlát (`MeetCapacity`), de itt nem szorzunk a súllyal, hanem egyszerűen összeadjuk a bináris változókat az adott `s` idősávban (slot). Ha a változó 1, az egy darab csomagot jelent. Ennek összege nem haladhatja meg az 5-öt.

3.  **Határidő (Logikai pontosítás)**:
    A feladat azt írja: *"határideje **később** van, minthogy azt a kört befejeznénk"*.

      * A te kódodban: `s <= deadline[o]` (Megengedi az egyenlőséget).
      * Szigorú értelmezés: Ha az 1. kört 10:00-kor fejezzük be (Slot 1), és a határidő 10:00 (Deadline 1), akkor technikailag a határidő *nem később* van, hanem *pont akkor*. Ha a tanár/megrendelő nagyon szigorú, akkor `s < deadline[o]`-t kell használni a `SlotOrder` halmazban. Én meghagytam az egyenlőséget (`<=`), mert az operációkutatásban a határidő általában *inclusive* (azaz a határidő pillanatában még teljesíthető).

### Adatfájl (`.dat`) példa

Ahhoz, hogy a modellt futtatni tudd, szükséged lesz egy adatfájlra. Itt egy példa struktúra:

```ampl
data;

set Places := Astoria Deak Ferenciek Kalvin;
set Routes := Korut Belvaros;

param slotcount := 8;
param capacity := 10;

param visit: Astoria Deak Ferenciek Kalvin :=
  Korut       1      0     1         1
  Belvaros    0      1     1         0;

param ordercount := 6;

param: deadline weight place :=
1      2        3.5    Astoria
2      1        2.0    Deak
3      8        4.0    Ferenciek
4      4        1.5    Kalvin
5      5        6.0    Astoria
6      2        2.5    Astoria;
```

Szeretnéd, hogy finomítsak a `printf` kimeneten, vagy segítsek az adatfájl összeállításában is?This is a **Set Covering Problem** formulated in AMPL (A Mathematical Programming Language). The goal is to select the minimum number of festivals such that every band performs at least once at one of the selected festivals.

Here is the problem statement and the solution derived from the provided data:

---

## 🎶 Problem Interpretation

* **Sets:**
    * **Bands:** The collection of musical groups $\{a, b, c, d\}$.
    * **Festivals:** The collection of events $\{f1, f2, f3\}$.
* **Parameter:**
    * $performs_{b, f}$: A binary parameter that is 1 if **Band** $b$ performs at **Festival** $f$, and 0 otherwise.
* **Decision Variables:**
    * $y_f$: A **binary variable** which is 1 if **Festival** $f$ is selected/visited, and 0 otherwise.
* **Objective Function (Minimize):**
    * $$\min \sum_{f \in Festivals} y_f$$
    * Minimize the total number of selected festivals.
* **Constraints (BandConstraint):**
    * $$\sum_{f \in Festivals} y_f \cdot performs_{b, f} \ge 1 \quad \forall b \in Bands$$
    * For every band $b$, the sum of selected festivals where it performs must be at least 1. This ensures every band is covered by at least one selected festival.

---

## 🔎 Data Analysis

The `performs` matrix shows which bands play at which festivals:

| Band | f1 | f2 | f3 | Bands Covered at Festival |
| :--- | :- | :- | :- | :------------------------ |
| **a** | 1  | 0  | 1  |                           |
| **b** | 1  | 1  | 0  |                           |
| **c** | 1  | 0  | 0  |                           |
| **d** | 0  | 1  | 1  |                           |
| **Bands Covered** | a, b, c | b, d | a, d |                           |
| **Count** | 3  | 2  | 2  |                           |

We need to choose a combination of festivals (a set of columns) such that all bands $\{a, b, c, d\}$ are represented by a '1' in at least one of the selected columns.

---

## ✅ Optimal Solution

The minimum number of festivals required to cover all four bands is **2**.

The optimal selection of festivals is: **{f1, f2}**

### Solution Verification:

1.  **Objective Value:** $\sum y_f = y_{f1} + y_{f2} + y_{f3} = 1 + 1 + 0 = 2$.
2.  **Band Constraints:**
    * **Band a:** Performs at $f1$ (1) and $f3$ (0). Covered: $y_{f1} \cdot 1 + y_{f2} \cdot 0 + y_{f3} \cdot 1 = 1 \cdot 1 + 1 \cdot 0 + 0 \cdot 1 = \mathbf{1} \ge 1$.
    * **Band b:** Performs at $f1$ (1) and $f2$ (1). Covered: $y_{f1} \cdot 1 + y_{f2} \cdot 1 + y_{f3} \cdot 0 = 1 \cdot 1 + 1 \cdot 1 + 0 \cdot 0 = \mathbf{2} \ge 1$.
    * **Band c:** Performs at $f1$ (1). Covered: $y_{f1} \cdot 1 + y_{f2} \cdot 0 + y_{f3} \cdot 0 = 1 \cdot 1 + 1 \cdot 0 + 0 \cdot 0 = \mathbf{1} \ge 1$.
    * **Band d:** Performs at $f2$ (1) and $f3$ (1). Covered: $y_{f1} \cdot 0 + y_{f2} \cdot 1 + y_{f3} \cdot 1 = 1 \cdot 0 + 1 \cdot 1 + 0 \cdot 1 = \mathbf{1} \ge 1$.

Since all bands are covered, and it is impossible to cover all four bands with just one festival (as $f1$ covers $\{a, b, c\}$, $f2$ covers $\{b, d\}$, and $f3$ covers $\{a, d\}$), the minimum number of festivals is **2**.

Another valid optimal solution is **{f1, f3}**:
* **f1** covers $\{a, b, c\}$.
* **f3** covers $\{a, d\}$.
* Together they cover $\{a, b, c, d\}$.

Would you like to solve a similar optimization problem with different data, or explore the output of a specific AMPL solver for this problem?Ez egy **lineáris programozási** feladat, amelynek célja a **profit maximalizálása** az adott **bor és szóda korlátok** mellett.

Íme egy bontás a feladatban szereplő elemekről:

## 🔢 Változók (Termékek/Adagok)

A változók a különböző italok **adagszámát** jelölik. Mindegyiknek **nemnegatív egész számnak** kell lennie.

| Változó | Jelentése | Mértékegység |
| :--- | :--- | :--- |
| $\text{xKF}$ | Kisfröccs adag | db |
| $\text{xNF}$ | Nagyfröccs adag | db |
| $\text{xHL}$ | Hosszúlépés adag | db |
| $\text{xHM}$ | Háziherkules adag | db |
| $\text{xVHM}$ | Viceházmester adag | db |
| $\text{xKrF}$ | Krúdy-fröccs adag | db |
| $\text{xSF}$ | Sportfröccs adag | db |
| $\text{xPF}$ | Polgármester adag | db |

---

## ⚖️ Korlátozások (Erőforrások)

Két fő erőforrás korlát van: a rendelkezésre álló **bor** és **szóda** mennyisége, mindkettő **deciliterben** (dl) mérve.

### 🍷 Bor Korlát

A **maximálisan felhasznált bor** mennyisége **1000 dl** lehet. Az együtthatók az adott italokhoz szükséges bor mennyiségét mutatják deciliterben:
$$1 \cdot \text{xKF} + 2 \cdot \text{xNF} + 1 \cdot \text{xHL} + 3 \cdot \text{xHM} + 2 \cdot \text{xVHM} + 9 \cdot \text{xKrF} + 1 \cdot \text{xSF} + 6 \cdot \text{xPF} \le 1000$$

### 💧 Szóda Korlát

A **maximálisan felhasznált szóda** mennyisége **1500 dl** lehet. Az együtthatók az adott italokhoz szükséges szóda mennyiségét mutatják deciliterben:
$$1 \cdot \text{xKF} + 1 \cdot \text{xNF} + 2 \cdot \text{xHL} + 2 \cdot \text{xHM} + 3 \cdot \text{xVHM} + 1 \cdot \text{xKrF} + 9 \cdot \text{xSF} + 3 \cdot \text{xPF} \le 1500$$

---

## 🎯 Célfüggvény (Profit Maximalizálása)

A cél a **teljes profit** maximalizálása. Az együtthatók az egyes italok **profitját** (pl. Ft/adag) jelölik.

$$\text{Maximize Profit}: 90 \cdot \text{xKF} + 170 \cdot \text{xNF} + 100 \cdot \text{xHL} + 250 \cdot \text{xHM} + 180 \cdot \text{xVHM} + 650 \cdot \text{xKrF} + 140 \cdot \text{xSF} + 480 \cdot \text{xPF}$$

---

### Összefoglalás

A feladat az, hogy **mennyi adagot** kell eladni az egyes típusú fröccsökből (**xKF, xNF, ..., xPF**), hogy a **maximális profitot** érjük el, figyelembe véve, hogy összesen **legfeljebb 1000 dl bort** és **legfeljebb 1500 dl szódát** használhatunk fel.

Ez a modell egy **vegyes egészértékű lineáris programozási** (MILP) feladat.

Szeretné, ha megpróbálnám megoldani ezt a lineáris programozási feladatot valamilyen online solverrel vagy programozási nyelven?Ez egy **diszkrét optimalizálási modell**, konkrétan egy **fedési probléma** (Set Covering Problem) változata, amit kiegészít egy költségkorlát. A modell célja a **minimális beruházási költség** elérése, miközben biztosítja, hogy **minden ház fűtése megoldott** legyen, és a **fenntartási költség** ne lépjen át egy adott korlátot.

Íme a modell összetevőinek és működésének összefoglalása:

---

## 🗺️ A Modell Összefoglalása

### 1. Halmazok (Sets)
* **`Kutak`**: A rendelkezésre álló geotermikus kutak.
* **`Hazak`**: A fűtéssel ellátandó házak.

### 2. Paraméterek (Parameters)
* **`epitesi_ktg{Kutak}`**: A kút létesítési költsége (millió dh).
* **`fenntartasi_ktg{Kutak}`**: A kút éves fenntartási költsége (ezer dh/év).
* **`ellat{Hazak, Kutak}`**: Bináris paraméter; 1, ha a $k$ kút el tudja látni az $h$ házat.
* **`idotav`**: Az elemzés időtávja (év).
* **`max_fenntartas`**: A megengedett éves fenntartási költség felső korlátja (ezer dh/év). Ezt általában egy korábbi, ún. **Pareto-optimális** megoldásból veszik át, de a modellben egy szabványos korlátként működik.

### 3. Változók (Variables)
* **`megepit{Kutak}`**: **Bináris döntési változó**.
    * $1$, ha a kút építésre kerül.
    * $0$, ha nem épül meg.

---

## 🎯 Célfüggvény és Korlátok

### 1. Célfüggvény (Objective Function)
A modell célja a **minimális beruházási költség** elérése, azaz az építési költségek minimalizálása:

$$\min \text{BeruhazasiKtg}: \sum_{k \in \text{Kutak}} \text{megepit}[k] \times \text{epitesi\_ktg}[k]$$

### 2. Korlátok (Constraints)

* **`MindenkitEllatunk{h in Hazak}` (Fedési Korlát):**
    * **Minden háznak** (minden $h \in \text{Hazak}$) legalább **egy megépített kútnak** kell fedeznie a fűtését. Ez biztosítja az ellátás teljességét.
    $$\sum_{k \in \text{Kutak}} \text{megepit}[k] \times \text{ellat}[h,k] \ge 1 \quad \forall h \in \text{Hazak}$$
    * 

* **`AlacsonyabbFenntartas` (Fenntartási Költség Korlát):**
    * A **megépített kutak éves fenntartási költségeinek** összege nem haladhatja meg a megadott felső korlátot, a `max_fenntartas` értéket.
    $$\sum_{k \in \text{Kutak}} \text{megepit}[k] \times \text{fenntartasi\_ktg}[k] \le \text{max\_fenntartas}$$

---

## 🛠️ Eredmények

A modell futtatása után a program kiírja:

* **`Megepitendo kutak`**: Mely kutak kaptak $1$ értéket a `megepit` változóban, azaz melyeket kell megépíteni.
* **`Beruhazasi koltseg`**: A minimális építési költség, ami a célfüggvény optimális értéke.
* **`Fenntartasi koltseg`**: Az éves fenntartási költség összege (ellenőrzésül, hogy teljesül-e a korlát).
* **`Osszes fenntartasi koltseg`**: A fenntartási költség az `idotav` figyelembevételével (M dh).
* **`Aggregalt koltseg`**: A teljes beruházási és fenntartási költség összege az `idotav` alatt (M dh).

A modell a **legolcsóbb** (legkisebb beruházási költségű) olyan kúthalmazt választja ki, amely **minden házat ellát** és **nem lépi túl** a megadott **fenntartási költség** keretet.

Milyen konkrét adatokat szeretnél használni a futtatáshoz, vagy szeretnéd, ha részletesebben elmagyaráznám a kétcélú optimalizálással való kapcsolatát?Ez egy **lineáris programozási** modell egy pékségi ellátási lánc logisztikai problémájának megoldására, amelynek célja a **minimális benzinköltség** elérése a búza és liszt szállításakor a gazdaságoktól a pékségekig. A modell a szállítási mennyiségek optimalizálása mellett figyelembe veszi a teherautók számát és a visszautak költségét is.

## 🍞 A Modell Magyarázata

---

### 1. 🌍 Készletek (Sets)

Ezek határozzák meg a probléma fő entitásait:
* `Mezo`: A búzaforrások, a gazdaságok.
* `Malom`: A búza lisztté őrlését végző létesítmények.
* `Pek`: A lisztet felhasználó pékségek.

---

### 2. 🔢 Paraméterek (Parameters)

Ezek a rögzített bemeneti adatok:
* `tav1{Mezo, Malom}`: Távolság (km) a mezők és a malmok között.
* `tav2{Malom, Pek}`: Távolság (km) a malmok és a pékségek között.
* `orlesarany`: Azt mutatja, hogy mennyi liszt (kg) készül 1 kg búzából (pl. 0.9).
* `teherautokapacitas`: Egy teherautó maximális szállítási kapacitása (kg).
* `buza{Mezo}`: A megtermelt búza mennyisége az egyes mezőkön (kg).
* `kapacitas{Malom}`: Az egyes malmok maximális őrlési kapacitása (kg búza).
* `ures_fogyasztas`: Egy üres teherautó üzemanyag-fogyasztása (liter / 100 km).
* `valtozo_fogyasztas`: Az üzemanyag-fogyasztás növekedése rakományonként (liter / kg / 100 km).
* `benzinar`: A benzin ára (Ft / 100 km-re vetítve, de a képletben 1 Ft/literre vetítve szerepel, és az egységek átváltása a célfüggvényben történik, lásd alább).

---

### 3. 🛣️ Változók (Variables)

Ezeket kell optimalizálni:
* `fuvar1{Mezo, Malom}`, **integer**: A mező és a malom közötti szükséges teherautó fuvarok **száma**.
* `szallit1{Mezo, Malom}`: A mező és a malom között szállított búza mennyisége (kg).
* `fuvar2{Malom, Pek}`, **integer**: A malom és a pék közötti szükséges teherautó fuvarok **száma**.
* `szallit2{Malom, Pek}`: A malom és a pék között szállított liszt mennyisége (kg).

---

### 4. 🔗 Korlátozások (Constraints)

Ezek a valós logisztikai és fizikai feltételek:

* **`MindenMezorolAmennyiVan`**: Minden mezőnek el kell szállítania a teljes megtermelt búza mennyiségét.
    $$\sum_{\text{malom}} \text{szallit1}[\text{mezo},\text{malom}] = \text{buza}[\text{mezo}]$$
* **`EgyMalombaMaxAmennyitElbir`**: Egy malomba csak a kapacitásának megfelelő mennyiségű búza szállítható.
    $$\sum_{\text{mezo}} \text{szallit1}[\text{mezo},\text{malom}] \le \text{kapacitas}[\text{malom}]$$
* **`MalombolMindentElszallit`**: A malom által feldolgozott teljes búza mennyiségének (lisztté alakítva) meg kell egyeznie az onnan elszállított teljes liszt mennyiségével.
    $$\text{orlesarany} \cdot \sum_{\text{mezo}} \text{szallit1}[\text{mezo},\text{malom}] = \sum_{\text{pek}} \text{szallit2}[\text{malom},\text{pek}]$$
* **`Teherautokszama1` és `Teherautokszama2`**: Ezek a feltételek biztosítják, hogy a fuvarok száma elegendő legyen az adott útvonalon szállítandó teljes árumennyiség elszállításához, figyelembe véve a teherautó kapacitását. Mivel a fuvarok száma egész (integer) változó, ez azt jelenti, hogy felfelé kerekíti a szükséges fuvarok számát (például ha egy fuvar is elegendő lenne, a szám 1, ha a kapacitás kétszerese kell, a szám 2, stb.).
    $$\text{fuvar1}[\text{mezo},\text{malom}] \cdot \text{teherautokapacitas} \ge \text{szallit1}[\text{mezo},\text{malom}]$$

---

### 5. 💰 Célfüggvény (Objective Function)

A cél a **Benzinkoltseg** minimalizálása. A képlet kiszámítja a teljes üzemanyagköltséget Ft-ban:

$$\text{Benzinkoltseg} = \frac{\text{benzinar}}{100} \cdot \sum_{\text{szakasz}} \left( \text{tav} \cdot \left( \underbrace{2 \cdot \text{ures\_fogyasztas} \cdot \text{fuvar}}_{\text{üres visszautak költsége}} + \underbrace{\text{szallit} \cdot \text{valtozo\_fogyasztas}}_{\text{terhelt utak extra fogyasztása}} \right) \right)$$

#### ⛽ A Költség Számítása:

A fogyasztás a távolsággal arányos, és két részből áll:

1.  **Üres visszautak költsége**: Minden fuvart meg kell tenni a célállomásra (terhelten) és onnan vissza (üresen). A képletben:
    $$2 \cdot \text{ures\_fogyasztas} \cdot \text{fuvar}$$
    *Az `ures_fogyasztas` az üres járművek fogyasztását jelenti, és a visszautak is üresen történnek. A terhelt út fogyasztásának alapja is ez, de ehhez jön hozzá a rakomány miatti plusz fogyasztás.*

2.  **Terhelt utak extra fogyasztása**: A rakomány többletfogyasztása. Ezt a szállított teljes tömeggel szorozzák:
    $$\text{szallit} \cdot \text{valtozo\_fogyasztas}$$
    *A modell feltételezése, hogy az üzemanyag-fogyasztás a terhelt szakaszon az alap üres fogyasztásból és a rakomány súlyával arányos további fogyasztásból tevődik össze. A modellt úgy közelíti, hogy a terhelt út költsége = (alap üres fogyasztás) + (rakomány miatti plusz fogyasztás), de a célfüggvényben a $2 \cdot \text{ures\_fogyasztas} \cdot \text{fuvar}$ már tartalmazza az alap fogyasztást minden útra (oda-vissza), így a $\text{szallit} \cdot \text{valtozo\_fogyasztas}$ csak a rakomány miatti **többlet** fogyasztást adja hozzá a terhelt úthoz.*

A teljes fogyasztást (literben / 100 km-re vetítve) szorozva a távolsággal (km-ben) elosztva 100-zal megkapjuk a teljes üzemanyag-fogyasztást (literben). Ezt szorozva a `benzinar` paraméterrel (Ft/liter) kapjuk meg a teljes költséget Ft-ban.

A modell célja ezen szállítási költségek **minimalizálása**.

---

## 💻 Kimenet

A modell a futtatás után kiírja a következő optimális szállítási terveket:

1.  **Mezők $\to$ Malmok**: Egy táblázat, amely megmutatja, hogy melyik mezőről melyik malomba hány fuvar (`fuvar1`) és mennyi búza (`szallit1`) szállítása optimális.
2.  **Malmok $\to$ Pékségek**: Egy táblázat, amely megmutatja, hogy melyik malomból melyik pékségbe hány fuvar (`fuvar2`) és mennyi liszt (`szallit2`) szállítása optimális.

Szeretnéd, ha futtatnám a modellt a megadott adatokkal, és megmutatnám az optimális szállítási tervet?A megadott AMPL modellt a túrajelzés-felújítás feladatának megoldására elemezzük.

## 📝 Modell Értelmezés és Elemzés

A cél a **teljes hosszon lakkozott jelzés hosszának maximalizálása** a nap végén (a rendelkezésre álló szakaszonkénti munkaidő alatt).

A munkát **6:00**-tól **22:00**-ig végzik, ami összesen **16 óra**. Mivel a munkát 2 órás szakaszokban koordinálják (100 perc munka + 20 perc szünet), a teljes 16 óra alatt $16 / 2 = 8$ munkaszakasz van.

A modell a következő feltételeket és logikát tükrözi:

### 1. Állapot- és Folyamatkövetés
A modell szakaszok (2 órás időintervallumok) szerint követi a négy munkafolyamat (*hántás*, *alapozás*, *festés*, *lakkozás*) előrehaladását $km$-ben.

* $hantaskm[sz]$, $alapkm[sz]$, $festeskm[sz]$, $lakkkm[sz]$: Az adott munkafolyamat által elért kumulatív távolság a $sz$. szakasz végén.
* Az $Init$ feltételek ($HantasInit, alapInit, \dots$) a kiindulási, 0 km-es távolságot rögzítik a $0$. szakasz végén.

### 2. Munkavégzési Korlátok

#### A. Sebesség és Haladás
* **100 perc munka:** A 2 órás szakaszból **100 percet** dolgoznak. A *Haladás* feltételek figyelembe veszik, hogy az 1 óra alatt megtett távolságot (ügyesség) **100/60**-tal kell szorozni a 100 perc alatt megtett távolság kiszámításához.
    $$L_{sz} \le L_{sz-1} + \sum_{e \in Emberek} (\text{ügyesség}_e \cdot \text{hozzárendelés}_{e, sz}) \cdot \frac{100}{60}$$
    *Ezt a modellt az $hantaskm[sz] \le hantaskm[sz-1] + \sum_{e \in Emberek} \dots$ típusú egyenlőtlenségek fejezik ki.*

#### B. Előzési Tilalom (Folyamat Sorrend)
* Egyik folyamat sem előzheti meg az előzőt. Ezt az alábbi korlátok biztosítják:
    * $alapkm[sz] \le hantaskm[sz]$ (Alapozás $\le$ Hántás)
    * $festeskm[sz] \le alapkm[sz]$ (Festés $\le$ Alapozás)
    * $lakkkm[sz] \le festeskm[sz]$ (Lakkozás $\le$ Festés)
    *Ezek kényszerítik, hogy a sebesség visszavegyen, ha utolérik az előző fázist végzőket, mivel a kumulatív távolság nem nőhet az előző fázis távolságánál nagyobbra.*

#### C. Kötelező Munkavégzés
* **Mindegyik munkafolyamaton legalább egy ember dolgozik (Minden órában $\rightarrow$ Minden szakaszban):**
    $$\sum_{e \in Emberek} \text{csinál}[e, sz, m] \ge 1$$
    *Ezt a `MindigMindentCsinalValaki` feltétel biztosítja. Mivel 6 ember van és 4 munka, így két feladaton biztosan két ember dolgozik minden szakaszban.*

#### D. Távolsági Korlát (Összegyűlés)
* **Hántás és Lakkozás közötti távolság:** Nem nőhet **1.5 km** fölé.
    *A modellben a korlát helytelenül $2 \text{ km}$-re van állítva ($hantaskm[sz] \le lakkkm[sz] + 2$), de feltételezzük, hogy a feladat írója valójában $2 \text{ km}$-t akart, vagy a $1.5 \text{ km}$ helyett el lett gépelve. A megoldásban a megadott $2 \text{ km}$ korlátot vesszük figyelembe.*
    $$hantaskm[sz] \le lakkkm[sz] + 2$$
    *Ezt a `HantasNemMehetTulMesszeALakkozastol` feltétel biztosítja.*

### 3. Célfüggvény
* **Maximalizálás:** A `lakkkm[nSzakasz]` változó maximalizálása, ami a **teljesen lakkozott útszakasz hossza** a $nSzakasz$ számú szakasz (azaz a nap) végén.

---

## 🔍 Észrevételek a Modellről

* **Időbeli szempont:** A modell jól kezeli az időt szakaszokra bontva, a 100 perces munkaidőt figyelembe véve. Mivel 6:00-tól 22:00-ig tart a munka, a szakaszok száma **$nSzakasz=8$** (ha 2 órás szakaszokkal számolunk).
* **Távolságkorlát:** A feladat $1.5 \text{ km}$-t említ, de a modell $2 \text{ km}$-t használ a $HantasNemMehetTulMesszeALakkozastol$ korlátban. Ha az eredeti feladat szövege $1.5 \text{ km}$ lett volna a cél, akkor a korlátot módosítani kellene.
* **A Sebesség Visszavétele:** Az előzési tilalom és a távolsági korlát is automatikusan kezeli a "visszavesznek a sebességükből" jelenséget. A modell (a `Haladas` korlátok és az előzési tilalom együttes hatása) optimális esetben a lassabb fázis sebességével fog haladni, ha utolérik azt.

A modell **lineáris optimalizálási (LP)** feladatként írja le a problémát (bináris változókkal **vegyes egészértékű lineáris programozás - MILP**), ami alkalmas a maximális távolság megtalálására a megadott korlátok mellett.

**A modell futtatásához szükség van az alábbi adatokra:**

1.  **$Emberek$** halmaza (Pygmea, Repkény, Droid, Bubu, Gethe, Galád).
2.  **$Munkak$** halmaza (hantas, alap, festes, lakk).
3.  **$nSzakasz$** (8).
4.  **$tav$** mátrix (a túrázók ügyessége, azaz $km/óra$).

**Mintaadatok hiányában a modellt csak értelmezni lehet, futtatni nem.**

**Kérdés:** Szeretnéd, hogy keressek vagy feltételezzek tipikus adatokat az $Emberek$ ügyességére ($tav$ mátrixra), hogy befejezzük a modellt, és futtassam, vagy elegendő a modell elemzése?```python?code_reference&code_event_index=2
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
6.  **Szombat:** Fiat ($1 \text{ Ft}$)## 🏃 Az Ultrabalaton szakaszainak kiosztása: Problémaleírás 🏆

A cél az **Ultrabalaton futóverseny szakaszainak optimális kiosztása** egy futócsapat tagjai között, hogy **minimalizáljuk a teljes futási időt**, miközben tiszteletben tartjuk a futók által megadott minimális és maximális futótávokat.

A feladat egy **bináris egészértékű programozási (BIP)** modell formájában van megfogalmazva.

---

### 📝 Modell Összetevői

#### **Adatok (Paraméterek):**

* **Futók (Futok):** A futócsapat tagjainak halmaza: **Alina, Borcsa, Csilla, Dia**.
* **Szakaszszám (szakaszszam):** A futóverseny szakaszainak teljes száma: **30**.
* **Szakaszok (Szakaszok):** A szakaszok halmaza: $1$-től $30$-ig.
* **Hossz (hossz[sz]):** Az egyes szakaszok hossza **kilométerben (km)**. (Pl. 1. szakasz: $8.3482$ km).
* **Iram (iram[f]):** Az egyes futók átlagos futási sebessége **perc/km** egységben.
    * Alina: $5.0$ p/km
    * Borcsa: $5.5$ p/km
    * Csilla: $4.5$ p/km
    * Dia: $6.0$ p/km
* **Minimum Táv (mintav[f]):** Az a **minimális táv (km)**, amit az adott futó szeretne (vagy el kell) futnia.
    * Alina: $20$ km
    * Borcsa: $15$ km
    * Csilla: $50$ km
    * Dia: $42$ km
* **Maximum Táv (maxtav[f]):** Az a **maximális táv (km)**, amit az adott futó futhat.
    * Alina: $30$ km
    * Borcsa: $80$ km
    * Csilla: $100$ km
    * Dia: $84$ km

---

#### **Döntési Változó:**

* **fut[sz, f]:** Bináris változó (0 vagy 1).
    * **$fut[sz, f] = 1$,** ha az $sz$ szakaszt az $f$ futó futja.
    * **$fut[sz, f] = 0$,** egyébként.

---

#### **Célfüggvény (Minimalizálandó):**

* **Osszido:** A teljes futási időt kell minimalizálni **percekben (p)**.
    $$\text{Minimize } \sum_{sz \in \text{Szakaszok}} \sum_{f \in \text{Futok}} fut[sz,f] \times (\text{hossz}[sz] \times \text{iram}[f])$$
    Ez a kifejezés összeadja az összes szakaszra és futóra nézve azt az időt, amit a futó az adott szakaszon eltölt (ha ő futja azt a szakaszt).

---

#### **Korlátozások (Megszorítások):**

1.  **Egy Szakaszt Egy Valaki (EgySzakasztEgyValaki):** Minden szakaszt pontosan **egy** futónak kell kiosztani.
    $$\sum_{f \in \text{Futok}} fut[sz,f] = 1 \quad \forall sz \in \text{Szakaszok}$$

2.  **Legalább Amennyit Szeretne (LegalabbAmennyitSzeretne):** Minden futónak teljesítenie kell a megadott **minimális távolságot**.
    $$\sum_{sz \in \text{Szakaszok}} fut[sz,f] \times \text{hossz}[sz] \geq \text{mintav}[f] \quad \forall f \in \text{Futok}$$

3.  **Legfeljebb Amennyit Szeretne (LegfeljebbAmennyitSzeretne):** Minden futó által teljesített távolság nem haladhatja meg a megadott **maximális távolságot**.
    $$\sum_{sz \in \text{Szakaszok}} fut[sz,f] \times \text{hossz}[sz] \leq \text{maxtav}[f] \quad \forall f \in \text{Futok}$$

A megoldó feladata, hogy a modell alapján elvégezze a kiosztást, majd kiírja a szakaszok, a futók össztávjainak és futási időinek, valamint a teljes időeredménynek a részleteit.

Milyen eredményeket szeretne látni a futók kiosztására vonatkozóan?This is a **Bus Scheduling and People Assignment Problem** that aims to minimize the total wasted time (waiting time) for people arriving at work early.

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

The output will display the optimal departure time for each bus from Station A, the resulting arrival times at all stations, and the specific assignments and waiting times for each person.This is a **car trading optimization problem**, likely written in a modeling language like **AMPL** (A Mathematical Programming Language). Since I cannot execute the `solve;` command or the following `printf` statements to find the optimal solution, I will focus on **analyzing the model and the data provided**.

---

## 🚗 Model Analysis

The problem is a **Maximization Problem** aimed at maximizing the **Final Budget** by strategically buying and selling cars over a period of $nDays$.

### Sets and Parameters

* **`Cars`**: The set of car types available for trading (Audi, Mercedes, BMW).
* **`nDays`**: The total number of days in the planning horizon (5 days).
* **`Days`**: The set of days, from 1 to $nDays$.
* **`budget`**: The initial cash available (300).
* **`garagespace`**: The maximum number of cars that can be held at any time (4).
* **`price{Cars,Days}`**: The price of each car type on each day.

### Decision Variables

* **`buy{Cars,Days}` (integer, $\ge 0$):** The number of cars of a specific type $c$ bought on day $d$.
* **`sell{Cars,Days}` (integer, $\ge 0$):** The number of cars of a specific type $c$ sold on day $d$.
* **`buyorsell{Cars,Days}` (binary):** A binary variable to enforce a constraint that on any given day, for a specific car type, you can either **buy** or **sell**, but not both simultaneously.

### Constraints

1.  **`Buyorsell1` and `Buyorsell2` (Mutually Exclusive Action):**
    * $buy[c,d] \le buyorsell[c,d] \times garagespace$
    * $sell[c,d] \le (1 - buyorsell[c,d]) \times garagespace$
    * If $buyorsell[c,d] = 1$, then $buy[c,d]$ can be up to $garagespace$ (i.e., you can **buy**), but $sell[c,d]$ must be 0 (i.e., you **cannot sell**).
    * If $buyorsell[c,d] = 0$, then $buy[c,d]$ must be 0 (i.e., you **cannot buy**), but $sell[c,d]$ can be up to $garagespace$ (i.e., you can **sell**).
    * *Note: This constraint applies per car type per day. It limits the total buy/sell quantity to `garagespace`, which is slightly redundant given the `DontExceedGarageSpace` constraint, but it's often used as a convenient upper bound for big-M constraints.*

2.  **`DontSpendMoreThanWhatYouHave` (Cash Flow/Budget):**
    * The **current cash balance** up to any day $d$ must be non-negative.
    * Current Cash = $budget + \sum_{d2=1}^{d} \sum_{c \in Cars} (price[c,d2] \times (sell[c,d2] - buy[c,d2])) \ge 0$.

3.  **`DontSellCarsYouDontHave` (Inventory):**
    * The **inventory** of any specific car $c$ up to any day $d$ must be non-negative.
    * Inventory of car $c$ = $\sum_{d2=1}^{d} (buy[c,d2] - sell[c,d2]) \ge 0$.

4.  **`DontExceedGarageSpace` (Capacity):**
    * The **total number of cars held** (total inventory across all types) at the end of any day $d$ must not exceed the garage space.
    * Total Inventory = $\sum_{d2=1}^{d} \sum_{c \in Cars} (buy[c,d2] - sell[c,d2]) \le garagespace$.

### Objective Function

* **`maximize FinalBudget`:** Maximize the final cash balance at the end of the trading period ($nDays$).
    * Final Budget = $budget + \sum_{d=1}^{nDays} \sum_{c \in Cars} (price[c,d] \times (sell[c,d] - buy[c,d]))$.

---

## 📊 Provided Data

* **`garagespace`**: 4
* **`budget`**: 300
* **`Cars`**: Audi, Mercedes, BMW
* **`nDays`**: 5

| Car | Day 1 | Day 2 | Day 3 | Day 4 | Day 5 |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Audi** | 110 | 105 | 115 | 120 | 125 |
| **Mercedes** | 90 | 95 | 85 | 80 | 90 |
| **BMW** | 120 | 128 | 115 | 118 | 120 |

### Initial Strategy Observation

The goal is to **buy low and sell high**. The most promising arbitrage opportunities are:

* **Audi:** Price increases steadily (105 to 125). Good to buy early (Day 2: 105) and sell late (Day 5: 125). **Profit: 20.**
* **Mercedes:** Price drops significantly (95 to 80) and then recovers (80 to 90). The lowest price is Day 4 (80).
    * Good to buy Day 4 (80) and sell Day 5 (90). **Profit: 10.**
    * Could also sell on Day 1 (90) if an inventory existed, but starting inventory is 0.
* **BMW:** Price fluctuates (120 $\to$ 128 $\to$ 115 $\to$ 118 $\to$ 120). Lowest price is Day 3 (115). Highest price is Day 2 (128).
    * Good to buy Day 3 (115) and sell Day 2 (128) - *impossible due to time.*
    * Good to buy Day 3 (115) and sell Day 5 (120). **Profit: 5.**
    * Good to buy Day 3 (115) and sell Day 4 (118). **Profit: 3.**

The model will determine the optimal sequence of buys and sells, respecting the **garage space (4)** and **budget (300)** constraints. The optimal solution will likely involve maximizing the total number of $\Delta P$ (price difference) trades possible within the capacity limits.

---

I cannot provide the numerical output for the buy/sell decisions (`buy[c,d]` and `sell[c,d]`) because I cannot execute the `solve;` command. I have provided a complete analysis of the optimization model and the input data.

Would you like me to hypothesize on the most likely optimal strategy based on the price data?A feltöltött **`puska.m`** fájlban leírt probléma egy **diszkrét optimalizálási feladat**, pontosabban egy **egészértékű lineáris programozási** probléma. Célja a **minimális költség** megtalálása a **puskák elkészítéséhez** négy barát segítségével, figyelembe véve bizonyos korlátozásokat.

---

## 🧐 Probléma leírása

A probléma három tárgyból (AI - Anyagismeret, Halo - Számítógéphálózatok, OS - Operációs Rendszerek) puskák elkészítéséről szól, amikre holnap ZH-t írnak. Négy barát (Dani, Kristóf, Isti, Niki) vállalhatja a puskák megírását.

### 🎯 Cél (Objective)

A cél a **minimális összköltség (sörben kifejezve)** meghatározása, amiből mind a három tárgyhoz elkészül egy puska.

### 🔢 Változók (Variables)

A döntési változók binárisak, ami azt jelenti, hogy csak 0 vagy 1 értéket vehetnek fel.

* $y_{XY}$: 1, ha az $\mathbf{X}$ személy elkészíti az $\mathbf{Y}$ tárgy puskáját, és 0, ha nem.
    * $\mathbf{X} \in \{D, K, I, N\}$ (Dani, Kristóf, Isti, Niki)
    * $\mathbf{Y} \in \{A, H, O\}$ (AI, Halo, OS)

Például, $y_{DA}$ azt jelenti, hogy **Dani** elkészíti az **AI (Anyagismeret)** puskát.

### 🍺 Költségfüggvény (Minimize)

A minimalizálandó függvény az **összes költség (Puskapenz)**. Ez a táblázatban megadott sörárak és a döntési változók szorzataiból adódik:

$$
\text{min } 10 y_{DA} + 4 y_{DH} + 4 y_{DO} + 8 y_{KA} + 5 y_{KH} + 9 y_{KO} + 2 y_{IA} + 3 y_{IH} + 15 y_{IO} + 4 y_{NA} + 3 y_{NH} + 8 y_{NO}
$$

---

## 🚫 Korlátozások (Constraints)

A problémában két fő típusú korlátozás szerepel:

### 1. 📚 Tárgyankénti követelmény (Minden tárgyból legalább 1 jegyzet)

Mindhárom tárgyhoz legalább egyvalaki el kell, hogy készítsen egy puskát.

* **AnyagIsmeret (AI):** $y_{DA} + y_{KA} + y_{IA} + y_{NA} \geq 1$
* **SzamitogepHalozatok (Halo):** $y_{DH} + y_{KH} + y_{IH} + y_{NH} \geq 1$
* **OperaciosRendszerek (OS):** $y_{DO} + y_{KO} + y_{IO} + y_{NO} \geq 1$

### 2. 👤 Személyenkénti korlátozás (Mindenkinek csak egy jegyzetre van legfeljebb ideje)

Minden barát legfeljebb egy puskát vállalhat el.

* **Dani:** $y_{DA} + y_{DH} + y_{DO} \leq 1$
* **Kristof:** $y_{KA} + y_{KH} + y_{KO} \leq 1$
* **Isti:** $y_{IA} + y_{IH} + y_{IO} \leq 1$
* **Niki:** $y_{NA} + y_{NH} + y_{NO} \leq 1$

---

A feladat az, hogy megtaláljuk a $y_{XY}$ bináris változók azon értékhalmazát, amely kielégíti az összes korlátozást, és minimalizálja a "Puskapenz" költségfüggvényt. Ez lényegében egy **optimális hozzárendelési** probléma.

Szeretnéd, hogy megpróbáljam megmondani, melyik hozzárendelés a legolcsóbb (megoldom a lineáris programot)?This is a \*\*mixed-integer linear programming (MILP)\*\* problem modeled in the \*\*AMPL\*\* language, designed to create an optimal \*\*study schedule\*\* for a student preparing for several course exams. The objective is to \*\*maximize the weighted average grade\*\* across all courses, subject to constraints on available study time, required study hours for specific grades, and context switching penalties.



---



\## 📚 Problem Components



\### 1. Sets and Parameters



| Component | Type | Description |

| :--- | :--- | :--- |

| `Courses` | \*\*Set\*\* | The list of courses the student can take (e.g., T1, T2, T3). |

| `Days` | \*\*Set\*\* | The sequence of days in the study period, from day 1 up to the last exam day. |

| `Grades` | \*\*Set\*\* | The possible numeric grades the student can receive (e.g., 2, 3, 4, 5). |

| `credits{Courses}` | Parameter | The credit value for each course. |

| `examday{Courses}` | Parameter | The day on which the exam for each course takes place. |

| `freetime{Days}` | Parameter | The total available study time (in hours) on each day. |

| `contextSwitchTime` | Parameter | The time lost (penalty) for deciding to study any course on a given day. |

| `studyhours{Courses,Grades}` | Parameter | The total minimum hours required to study for a specific course to achieve a specific grade. |

| `noPassCoefficient` | Parameter | A grade coefficient assigned to courses where the exam is \*not\* taken. |



---



\### 2. Decision Variables



| Variable | Type | Description |

| :--- | :--- | :--- |

| `takeExam{Courses}` | \*\*Binary\*\* | 1 if the student takes the exam for a course, 0 otherwise. |

| `getGrade{Courses,Grades}` | \*\*Binary\*\* | 1 if the student achieves a specific grade in a course, 0 otherwise. |

| `study{Courses,Days}` | \*\*Non-Negative\*\* | The number of hours spent studying for a specific course on a specific day. |

| `sitDown{Courses,Days}` | \*\*Binary\*\* | 1 if the student decides to study for a specific course on a specific day (i.e., incurring the context switch penalty), 0 otherwise. |



---



\### 3. Objective Function



The goal is to \*\*maximize the weighted average grade\*\*:

$$

\\text{Maximize} \\quad \\frac{\\sum\_{c \\in \\text{Courses}} \\text{credits}\[c] \\cdot \\left( \\sum\_{g \\in \\text{Grades}} g \\cdot \\text{getGrade}\[c,g] + (1 - \\text{takeExam}\[c]) \\cdot \\text{noPassCoefficient} \\right)}{\\sum\_{c \\in \\text{Courses}} \\text{credits}\[c]}

$$

This averages the expected grade (weighted by course credits) for taken exams, while applying the `noPassCoefficient` for courses where the exam is not taken.



---



\## 4. Constraints



The model uses several constraints to ensure a feasible schedule:



\* \*\*`Get\_single\_passing\_grade\_iff\_exam\_is\_taken`\*\*: If an exam is taken (`takeExam = 1`), exactly one grade must be selected (`getGrade = 1`). If the exam is not taken (`takeExam = 0`), no grade can be selected.

\* \*\*`Study\_enough\_for\_grade`\*\*: The total study time allocated to a course \*before\* its exam day must meet or exceed the required total study hours for the chosen grade.

\* \*\*`Can\_not\_study\_more\_than\_free\_time`\*\*: The total time spent studying across all courses on any given day, plus the total penalty time for context switching, cannot exceed the available `freetime` for that day. A course's exam day is automatically disallowed for study if the exam is taken.

&nbsp;   \* \*Note:\* The penalty for context switching is calculated as $\\sum\_{c \\in \\text{Courses}} \\text{sitDown}\[c,d] \\cdot \\text{contextSwitchTime}$.

\* \*\*`Can\_only\_study\_if\_sit\_down\_to\_it`\*\*: A student can only allocate study hours (`study > 0`) for a course on a day if they decide to study that course that day (`sitDown = 1`).

\* \*\*`Setting\_unnecessary\_variables\_to\_zero`\*\*: No study time can be allocated for a course on or after its exam day.



---



\## 5. Data (`data.d`)



The provided data gives specific values for the parameters:



\* \*\*Courses:\*\* T1 (4 credits, Exam Day 8), T2 (2 credits, Exam Day 5), T3 (6 credits, Exam Day 9).

\* \*\*Grades:\*\* 2, 3, 4, 5.

\* \*\*`contextSwitchTime`\*\*: 0.5 hours.

\* \*\*Required Study Hours:\*\* Varies by course and grade (e.g., T1 needs 4 hours for a grade 5).

\* \*\*`freetime`\*\*: Available hours per day (e.g., Day 1 has 3 hours, Day 8 has 9 hours).



Would you like to see the calculated \*\*optimal schedule\*\* based on this model and data?

This problem is a **linear programming model** designed to determine the **feasibility and optimal scheduling of study time** for a set of courses, constrained by the **required preparation time** for each course and the **daily available free time**.


---

## 📚 Problem Components and Goal

### 🎯 Goal
The primary objective is to find a study schedule that satisfies the minimum **required study time** for every course before its respective **exam day**, all while not exceeding the **daily available free time**. The model also includes a secondary objective to **minimize the total number of study hours**, effectively finding the *most efficient* feasible schedule.

### 📝 Key Data Parameters

The problem is defined by the following fixed data inputs, provided in the `exams1.d` file:

* **Courses:** The list of subjects that need to be studied.
    * *Example:* ExpertSystems, ComputerNetworks, Programming, Finance, DeceisonSupport.
* **$nDays$:** The total length of the exam/study period (42 days).
* **$required\_time$:** The minimum number of hours needed to prepare for each course.
    * *Example:* ExpertSystems requires 40 hours.
* **$exam\_day$:** The specific day within the $nDays$ period when the exam for a given course takes place.
    * *Example:* The ComputerNetworks exam is on Day 7.
* **$free\_time$:** The number of study hours available on each day of the period.
    * *Example:* Day 1 has 5.3 hours of free time.

---

## 📐 Mathematical Formulation

### 💡 Decision Variable
The model's variable is what we need to determine:
* **$study_{d,c}$**: The number of hours spent studying for **Course $c$** on **Day $d$**. This value must be non-negative.

### 🛑 Constraints

The solution must respect two main constraints:

1.  **$FreeTimeConstraint$**: The total time spent studying for *all* courses on any given day cannot exceed the free time available on that day.
    $$\sum_{c \in Courses} study_{d,c} \le free\_time_d \quad \text{for all } d \in Days$$

2.  **$RequiredTimeConstraint$**: The cumulative study time for a course must meet or exceed its required preparation time by the day *before* the exam.
    $$\sum_{d \in Days: d < exam\_day_c} study_{d,c} \ge required\_time_c \quad \text{for all } c \in Courses$$

### ⬇️ Objective Function

The model seeks to **minimize** the total study effort across the entire period and all courses.
$$\text{Minimize } \sum_{d \in Days, c \in Courses} study_{d,c}$$

---

## 💻 Output

The model is solved using a linear programming solver (implied by the `.m` file structure) to find the values for $study_{d,c}$ that satisfy all constraints and minimize the total study hours.

The output loop then iterates through each day and prints the optimal study schedule, showing:
* The **Day number** ($d$).
* The **Course** ($c$) being studied.
* The **Hours spent** ($\text{study}_{d,c}$) on that course for the day (only for non-zero study times).The provided file contains a **linear programming problem** (specifically, an **integer linear program** since the variables are restricted to be integers) designed to **maximize profit** from mixing different types of a beverage called "Fröccs" (a Hungarian wine spritzer).

The problem consists of the following elements:

## 🍷 Decision Variables
[cite_start]The variables represent the **non-negative integer quantity** (e.g., in liters or units) of each specific type of Fröccs to be produced[cite: 1, 2].

| Variable | Fröccs Type Name |
| :--- | :--- |
| $xSF$ | Kisfröccs (Small Fröccs) |
| $xBF$ | Nagyfröccs (Big Fröccs) |
| $xLS$ | Hosszúlépés (Long Step) |
| $xHM$ | Házmester (Caretaker) |
| $xVHM$ | Viceházmester (Vice-Caretaker) |
| $xKF$ | Kisfröccs (Small Fröccs - Appears twice, likely an error or distinct type) |
| $xRF$ | Rövidfröccs (Short Fröccs) |
| $xPF$ | Postásfröccs (Postman Fröccs) |

---

## 🍇 Constraints
[cite_start]The problem is constrained by the **limited availability** of the two main ingredients: **White Wine** and **Soda**[cite: 2, 3].

### 1. White Wine Constraint
[cite_start]The total amount of white wine used across all Fröccs types must be **less than or equal to 100** units (e.g., liters)[cite: 2]. The coefficients represent the proportion of white wine required for one unit of each Fröccs type:
[cite_start]$$0.1 xSF + 0.2 xBF + 0.1 xLS + 0.3 xHM + 0.2 xVHM + 0.9 xKF + 0.1 xRF + 0.6 xPF \le 100$$ [cite: 2]

### 2. Soda Constraint
[cite_start]The total amount of soda used across all Fröccs types must be **less than or equal to 150** units (e.g., liters)[cite: 3]. The coefficients represent the proportion of soda required for one unit of each Fröccs type:
[cite_start]$$0.1 xSF + 0.1 xBF + 0.2 xLS + 0.2 xHM + 0.3 xVHM + 0.1 xKF + 0.9 xRF + 0.3 xPF \le 150$$ [cite: 3]

---

## 💰 Objective Function
[cite_start]The goal is to **maximize the total profit**, which is calculated by multiplying the profit contribution of each Fröccs type by the quantity produced[cite: 4].

The profit function is:
[cite_start]$$\text{Maximize } 90 xSF + 170 xBF + 100 xLS + 250 xHM + 150 xVHM + 650 xKF + 180 xRF + 450 xPF$$ [cite: 4]

[cite_start]The values (90, 170, 100, etc.) are the **profit per unit** for each respective Fröccs type[cite: 4].

***

In summary, the problem asks: **How many of each Fröccs type should be produced (integer quantities) to maximize total profit, given that only 100 units of white wine and 150 units of soda are available?**

Would you like me to find the optimal solution for this linear programming problem?The problem described by the provided AMPL model (`potzh.m`) and data file (`potzh.d`) is an **Exam Scheduling and Study Planning Optimization Problem**. It seeks to maximize the total credit hours of classes passed by optimally allocating study time across a fixed number of days and deciding which classes to take exams for.

---

## 📚 Core Goal

The main objective is to **maximize the total credit hours** of the classes for which the student successfully passes the exam:

$$\text{Maximize: } \sum_{c \in \text{Classes}} \text{pass}_c \times \text{credit}_c$$

Where:
* $\text{pass}_c$ is a binary variable indicating if class $c$ is passed.
* $\text{credit}_c$ is the credit value of class $c$.

---

## 📝 Key Components and Variables

### Sets and Parameters (Input Data)

| Name | Description | Example (from `potzh.d`) |
| :--- | :--- | :--- |
| $\text{Classes}$ | The set of classes (T1, T2, ..., T6). | T1, T2, T3, T4, T5, T6 |
| $\text{credit}_c$ | The credit hours for class $c$. | T1: 2, T4: 6 |
| $\text{hours}_c$ | The total required study hours to pass class $c$. | T1: 8, T4: 15 |
| $\text{Exams}$ | The set of possible exam opportunities (1 to 4). | 1, 2, 3, 4 |
| $\text{examDay}_{c,e}$ | The day on which the $e$-th exam for class $c$ is held. | Exam 1 for T1 is on Day 1. |
| $\text{Days}$ | The set of days in the planning period (1 to 14). | 1, 2, ..., 14 |
| $\text{freetime}_d$ | The total available free study time (in hours) on day $d$. | Day 1: 6 hours, Day 8: 1 hour |
| $\text{warmup}$ | The fixed time cost (in hours) incurred *per class* studied on a given day, regardless of the study duration. | 0.5 hours |

### Decision Variables (What the model decides)

| Variable | Type | Description |
| :--- | :--- | :--- |
| $\text{study}_{c,d}$ | **Binary** | 1 if class $c$ is studied on day $d$, 0 otherwise. |
| $\text{studyhour}_{c,d}$ | **Non-Negative** | The number of hours spent studying class $c$ on day $d$. |
| $\text{pass}_c$ | **Binary** | 1 if class $c$ is passed, 0 otherwise. |
| $\text{take}_{c,e}$ | **Binary** | 1 if the student attempts the $e$-th exam for class $c$, 0 otherwise. |

---

## ⚙️ Constraints (Rules)

The problem must satisfy the following constraints:

1.  **Study Hours Limit (Study\_Studyhour):** The study hours for a class on a given day cannot exceed the total free time on that day. However, since $\text{studyhour}_{c,d}$ contributes to the daily free time limit (Constraint 4), this constraint mainly links the binary variable: $\text{studyhour}_{c,d} \le \text{study}_{c,d} \times \text{freetime}_d$. If $\text{study}_{c,d}=0$, $\text{studyhour}_{c,d}$ must be 0.
2.  **Passing Condition (Exams\_Pass):** A class is passed ($\text{pass}_c=1$) if and only if the student attempts exactly one exam for that class ($\sum_e \text{take}_{c,e} = 1$). If the class isn't passed ($\text{pass}_c=0$), no exam is taken ($\sum_e \text{take}_{c,e} = 0$).
3.  **Required Study (Study\_enough):** If a specific exam $e$ for class $c$ is attempted ($\text{take}_{c,e}=1$), the student must have accumulated at least the required total study hours ($\text{hours}_c$) *before* the exam day.
    $$\sum_{d=1}^{\text{examDay}_{c,e}-1} \text{studyhour}_{c,d} \ge \text{hours}_c \times \text{take}_{c,e}$$
4.  **Daily Time Limit (Daily\_study\_hours):** The total time spent on studying and taking exams on any given day $d$ must not exceed the available free time ($\text{freetime}_d$).
    * **Study Time:** $\sum_{c \in \text{Classes}} \text{studyhour}_{c,d}$
    * **Warmup Cost:** $\sum_{c \in \text{Classes}} \text{study}_{c,d} \times \text{warmup}$ (A fixed cost per class studied).
    * **Exam Penalty:** If an exam is taken on day $d$, all study time and warmup costs are set to zero for that day for *all* classes. This is enforced by multiplying the available free time by $(1 - \sum_{c,e: \text{examDay}_{c,e}=d} \text{take}_{c,e})$. If *any* exam is scheduled on day $d$ and taken, the right-hand side becomes 0, forcing all study hours and warmup costs to 0.

The model essentially finds the optimal combination of exam choices and daily study hour assignments that respects the time limits and study requirements to maximize the total credit hours earned.The problem described by the provided AMPL model (`potzh.m`) and data file (`potzh.d`) is an **Exam Scheduling and Study Planning Optimization Problem**. It seeks to maximize the total credit hours of classes passed by optimally allocating study time across a fixed number of days and deciding which classes to take exams for.

---

## 📚 Core Goal

The main objective is to **maximize the total credit hours** of the classes for which the student successfully passes the exam:

$$\text{Maximize: } \sum_{c \in \text{Classes}} \text{pass}_c \times \text{credit}_c$$

Where:
* $\text{pass}_c$ is a binary variable indicating if class $c$ is passed.
* $\text{credit}_c$ is the credit value of class $c$.

---

## 📝 Key Components and Variables

### Sets and Parameters (Input Data)

| Name | Description | Example (from `potzh.d`) |
| :--- | :--- | :--- |
| $\text{Classes}$ | The set of classes (T1, T2, ..., T6). | T1, T2, T3, T4, T5, T6 |
| $\text{credit}_c$ | The credit hours for class $c$. | T1: 2, T4: 6 |
| $\text{hours}_c$ | The total required study hours to pass class $c$. | T1: 8, T4: 15 |
| $\text{Exams}$ | The set of possible exam opportunities (1 to 4). | 1, 2, 3, 4 |
| $\text{examDay}_{c,e}$ | The day on which the $e$-th exam for class $c$ is held. | Exam 1 for T1 is on Day 1. |
| $\text{Days}$ | The set of days in the planning period (1 to 14). | 1, 2, ..., 14 |
| $\text{freetime}_d$ | The total available free study time (in hours) on day $d$. | Day 1: 6 hours, Day 8: 1 hour |
| $\text{warmup}$ | The fixed time cost (in hours) incurred *per class* studied on a given day, regardless of the study duration. | 0.5 hours |

### Decision Variables (What the model decides)

| Variable | Type | Description |
| :--- | :--- | :--- |
| $\text{study}_{c,d}$ | **Binary** | 1 if class $c$ is studied on day $d$, 0 otherwise. |
| $\text{studyhour}_{c,d}$ | **Non-Negative** | The number of hours spent studying class $c$ on day $d$. |
| $\text{pass}_c$ | **Binary** | 1 if class $c$ is passed, 0 otherwise. |
| $\text{take}_{c,e}$ | **Binary** | 1 if the student attempts the $e$-th exam for class $c$, 0 otherwise. |

---

## ⚙️ Constraints (Rules)

The problem must satisfy the following constraints:

1.  **Study Hours Limit (Study\_Studyhour):** The study hours for a class on a given day cannot exceed the total free time on that day. However, since $\text{studyhour}_{c,d}$ contributes to the daily free time limit (Constraint 4), this constraint mainly links the binary variable: $\text{studyhour}_{c,d} \le \text{study}_{c,d} \times \text{freetime}_d$. If $\text{study}_{c,d}=0$, $\text{studyhour}_{c,d}$ must be 0.
2.  **Passing Condition (Exams\_Pass):** A class is passed ($\text{pass}_c=1$) if and only if the student attempts exactly one exam for that class ($\sum_e \text{take}_{c,e} = 1$). If the class isn't passed ($\text{pass}_c=0$), no exam is taken ($\sum_e \text{take}_{c,e} = 0$).
3.  **Required Study (Study\_enough):** If a specific exam $e$ for class $c$ is attempted ($\text{take}_{c,e}=1$), the student must have accumulated at least the required total study hours ($\text{hours}_c$) *before* the exam day.
    $$\sum_{d=1}^{\text{examDay}_{c,e}-1} \text{studyhour}_{c,d} \ge \text{hours}_c \times \text{take}_{c,e}$$
4.  **Daily Time Limit (Daily\_study\_hours):** The total time spent on studying and taking exams on any given day $d$ must not exceed the available free time ($\text{freetime}_d$).
    * **Study Time:** $\sum_{c \in \text{Classes}} \text{studyhour}_{c,d}$
    * **Warmup Cost:** $\sum_{c \in \text{Classes}} \text{study}_{c,d} \times \text{warmup}$ (A fixed cost per class studied).
    * **Exam Penalty:** If an exam is taken on day $d$, all study time and warmup costs are set to zero for that day for *all* classes. This is enforced by multiplying the available free time by $(1 - \sum_{c,e: \text{examDay}_{c,e}=d} \text{take}_{c,e})$. If *any* exam is scheduled on day $d$ and taken, the right-hand side becomes 0, forcing all study hours and warmup costs to 0.

The model essentially finds the optimal combination of exam choices and daily study hour assignments that respects the time limits and study requirements to maximize the total credit hours earned.A megadott problémabeállítás egy **lineáris programozási** (LP) modell, amely azt célozza, hogy **maximalizálja az elérhető kreditpontokat** egy vizsgaidőszakban, figyelembe véve a rendelkezésre álló tanulási időt és a felkészüléshez szükséges időt.

---

## 📝 A Problémabeállítás Összefoglalása

### Célfüggvény (Objective)
**Maximalizálja** az elérhető kreditpontok összegét:
$$\max \sum_{t \in \text{Targyak}} \text{kredit}[t] \times \text{elmegyunk}[t]$$
A modell azt a döntést (elmegyünk-e vizsgázni) jutalmazza, amely a legtöbb kreditet hozza.

---

### Halmazok és Paraméterek

| Típus | Halmaz/Paraméter | Leírás | Érték (ha ismert) |
| :--- | :--- | :--- | :--- |
| **Halmazok** | $\text{Targyak}$ | A vizsgázandó tárgyak: 'Prog', 'Kozgaz', 'Angol' | {'Prog', 'Kozgaz', 'Angol'} |
| | $\text{Napok}$ | Az időhorizont napjai: 1-től 10-ig | 1..10 |
| **Paraméterek** | $\text{vizsgaNap}[t]$ | Adott tárgy vizsgájának napja | Prog: 7, Kozgaz: 8, Angol: 10 |
| | $\text{kredit}[t]$ | Adott tárgy kreditértéke | Alapértelmezett: 4 |
| | $\text{szuksIdo}[t]$ | A tárgy sikeres teljesítéséhez szükséges teljes tanulási idő (óra) | Alapértelmezett: 15 |
| | $\text{szabadIdo}[n]$ | A $n$. napon rendelkezésre álló szabad tanulási idő (óra) | 4. nap: 7, 5. nap: 8; Alapértelmezett: 4 |

---

### Változók (Variables)

| Változó | Típus | Leírás |
| :--- | :--- | :--- |
| $\text{tanulas}[n, t]$ | Folytonos ($\ge 0$) | Hány órát tanulunk a $t$ tárgyból a $n$. napon. |
| $\text{elmegyunk}[t]$ | Bináris ($\in \{0, 1\}$) | Döntési változó: 1, ha elmegyünk a $t$ vizsgára és sikeresen teljesítjük, 0 egyébként. |

---

### Korlátozások (Constraints)

1.  **Szabadidő Korlát** ($\text{Szabadido}[n]$):
    * **Adott napon** a tárgyakra fordított tanulási idő **nem haladhatja meg** a rendelkezésre álló szabadidőt.
    $$\forall n \in \text{Napok}: \quad \text{szabadIdo}[n] \ge \sum_{t \in \text{Targyak}} \text{tanulas}[n, t]$$

2.  **Szükséges Idő Korlát** ($\text{SzuksegesIdo}[t]$):
    * Egy tárgyra fordított **összes** tanulási idő **nem lehet több**, mint amennyi a felkészüléshez szükséges.
    $$\forall t \in \text{Targyak}: \quad \text{szuksIdo}[t] \ge \sum_{n \in \text{Napok}} \text{tanulas}[n,t]$$

3.  **Sikeres Vizsga Korlátok** ($\text{CsakSikeresVizsga}[t]$):
    * Csak akkor vizsgázhatunk sikeresen ($\text{elmegyunk}[t] = 1$), ha a vizsga napja **előtt** ( $n < \text{vizsgaNap}[t]$ ) összegyűjtött tanulási idő eléri a szükséges $\text{szuksIdo}[t]$ mennyiséget. Ez egy "big M" típusú **linearizált logikai korlát**.

    * **Eredeti Korlát:**
        * Ha $\text{elmegyunk}[t] = 1$, akkor $\sum_{n < \text{vizsgaNap}[t]} \text{tanulas}[n,t] \ge \text{szuksIdo}[t]$. (Vagyis a teljes felkészülési időt be kell fejezni a vizsga előtt.)
        $$\forall t \in \text{Targyak}: \quad \text{elmegyunk}[t] \le \frac{\sum_{n \in \text{Napok}: n < \text{vizsgaNap}[t]} \text{tanulas}[n,t]}{\text{szuksIdo}[t]}$$

    * **+1 Korlát (Memória/Hatékonyság):**
        * Ez a korlát szigorítja a feltételt: a sikeres vizsgához az **utolsó 5 napban** (vagyis $n < \text{vizsgaNap}[t]$ **ÉS** $n \ge \text{vizsgaNap}[t] - 5$) elvégzett tanulásnak is el kell érnie a szükséges időt. Ez feltételezi, hogy **5 napnál régebbi** tanulás nem számít bele a vizsga **sikeres** letételébe (memória/elfelejtés szimulálása).
        $$\forall t \in \text{Targyak}: \quad \text{elmegyunk}[t] \le \frac{\sum_{n \in \text{Napok}: n < \text{vizsgaNap}[t] \text{ és } n \ge \text{vizsgaNap}[t] - 5} \text{tanulas}[n,t]}{\text{szuksIdo}[t]}$$
        > Mivel a két $\text{CsakSikeresVizsga}$ korlát ismétléssel és módosított feltételekkel szerepel, a modell optimalizációs megoldásában **mindkét** feltételnek teljesülnie kell (azaz a szűkebb, utolsó 5 napra vonatkozó korlát az aktív).

---

### Hiányzó Bővítés (TODO)

A megjegyzésben szereplő, megvalósítatlan korlát egy lehetséges bővítést jelöl:
* $\text{JegyhezSzuksIdo}$: Különböző **jegyek** (pl. 2, 3, 4, 5) eléréséhez **különböző mennyiségű** felkészülési időt ($\text{szuksIdo}[t, j]$) igényelne, és egy $\text{szerzunk}[t, j]$ bináris változóval jelezné, hogy az adott jegyet szereztük meg. Ez a bővítés a jelenlegi beállításban **nincs implementálva**.

Összefoglalva, a modell **maximális kreditpontot** keres a tanulási órák (tanulas) optimális elosztásával a 10 napos időszak alatt, szigorúan betartva a napi órakorlátot és a vizsgák előtti tanulási idő (elsősorban az utolsó 5 napban) minimumkövetelményeit.

Would you like me to use the provided data to **calculate the optimal study plan and maximum credits** using a linear programming solver (like GLPK or Cplex, conceptually)?A megadott problémabeállítás egy **lineáris programozási** (LP) modell, amely azt célozza, hogy **maximalizálja az elérhető kreditpontokat** egy vizsgaidőszakban, figyelembe véve a rendelkezésre álló tanulási időt és a felkészüléshez szükséges időt.

---

## 📝 A Problémabeállítás Összefoglalása

### Célfüggvény (Objective)
**Maximalizálja** az elérhető kreditpontok összegét:
$$\max \sum_{t \in \text{Targyak}} \text{kredit}[t] \times \text{elmegyunk}[t]$$
A modell azt a döntést (elmegyünk-e vizsgázni) jutalmazza, amely a legtöbb kreditet hozza.

---

### Halmazok és Paraméterek

| Típus | Halmaz/Paraméter | Leírás | Érték (ha ismert) |
| :--- | :--- | :--- | :--- |
| **Halmazok** | $\text{Targyak}$ | A vizsgázandó tárgyak: 'Prog', 'Kozgaz', 'Angol' | {'Prog', 'Kozgaz', 'Angol'} |
| | $\text{Napok}$ | Az időhorizont napjai: 1-től 10-ig | 1..10 |
| **Paraméterek** | $\text{vizsgaNap}[t]$ | Adott tárgy vizsgájának napja | Prog: 7, Kozgaz: 8, Angol: 10 |
| | $\text{kredit}[t]$ | Adott tárgy kreditértéke | Alapértelmezett: 4 |
| | $\text{szuksIdo}[t]$ | A tárgy sikeres teljesítéséhez szükséges teljes tanulási idő (óra) | Alapértelmezett: 15 |
| | $\text{szabadIdo}[n]$ | A $n$. napon rendelkezésre álló szabad tanulási idő (óra) | 4. nap: 7, 5. nap: 8; Alapértelmezett: 4 |

---

### Változók (Variables)

| Változó | Típus | Leírás |
| :--- | :--- | :--- |
| $\text{tanulas}[n, t]$ | Folytonos ($\ge 0$) | Hány órát tanulunk a $t$ tárgyból a $n$. napon. |
| $\text{elmegyunk}[t]$ | Bináris ($\in \{0, 1\}$) | Döntési változó: 1, ha elmegyünk a $t$ vizsgára és sikeresen teljesítjük, 0 egyébként. |

---

### Korlátozások (Constraints)

1.  **Szabadidő Korlát** ($\text{Szabadido}[n]$):
    * **Adott napon** a tárgyakra fordított tanulási idő **nem haladhatja meg** a rendelkezésre álló szabadidőt.
    $$\forall n \in \text{Napok}: \quad \text{szabadIdo}[n] \ge \sum_{t \in \text{Targyak}} \text{tanulas}[n, t]$$

2.  **Szükséges Idő Korlát** ($\text{SzuksegesIdo}[t]$):
    * Egy tárgyra fordított **összes** tanulási idő **nem lehet több**, mint amennyi a felkészüléshez szükséges.
    $$\forall t \in \text{Targyak}: \quad \text{szuksIdo}[t] \ge \sum_{n \in \text{Napok}} \text{tanulas}[n,t]$$

3.  **Sikeres Vizsga Korlátok** ($\text{CsakSikeresVizsga}[t]$):
    * Csak akkor vizsgázhatunk sikeresen ($\text{elmegyunk}[t] = 1$), ha a vizsga napja **előtt** ( $n < \text{vizsgaNap}[t]$ ) összegyűjtött tanulási idő eléri a szükséges $\text{szuksIdo}[t]$ mennyiséget. Ez egy "big M" típusú **linearizált logikai korlát**.

    * **Eredeti Korlát:**
        * Ha $\text{elmegyunk}[t] = 1$, akkor $\sum_{n < \text{vizsgaNap}[t]} \text{tanulas}[n,t] \ge \text{szuksIdo}[t]$. (Vagyis a teljes felkészülési időt be kell fejezni a vizsga előtt.)
        $$\forall t \in \text{Targyak}: \quad \text{elmegyunk}[t] \le \frac{\sum_{n \in \text{Napok}: n < \text{vizsgaNap}[t]} \text{tanulas}[n,t]}{\text{szuksIdo}[t]}$$

    * **+1 Korlát (Memória/Hatékonyság):**
        * Ez a korlát szigorítja a feltételt: a sikeres vizsgához az **utolsó 5 napban** (vagyis $n < \text{vizsgaNap}[t]$ **ÉS** $n \ge \text{vizsgaNap}[t] - 5$) elvégzett tanulásnak is el kell érnie a szükséges időt. Ez feltételezi, hogy **5 napnál régebbi** tanulás nem számít bele a vizsga **sikeres** letételébe (memória/elfelejtés szimulálása).
        $$\forall t \in \text{Targyak}: \quad \text{elmegyunk}[t] \le \frac{\sum_{n \in \text{Napok}: n < \text{vizsgaNap}[t] \text{ és } n \ge \text{vizsgaNap}[t] - 5} \text{tanulas}[n,t]}{\text{szuksIdo}[t]}$$
        > Mivel a két $\text{CsakSikeresVizsga}$ korlát ismétléssel és módosított feltételekkel szerepel, a modell optimalizációs megoldásában **mindkét** feltételnek teljesülnie kell (azaz a szűkebb, utolsó 5 napra vonatkozó korlát az aktív).

---

### Hiányzó Bővítés (TODO)

A megjegyzésben szereplő, megvalósítatlan korlát egy lehetséges bővítést jelöl:
* $\text{JegyhezSzuksIdo}$: Különböző **jegyek** (pl. 2, 3, 4, 5) eléréséhez **különböző mennyiségű** felkészülési időt ($\text{szuksIdo}[t, j]$) igényelne, és egy $\text{szerzunk}[t, j]$ bináris változóval jelezné, hogy az adott jegyet szereztük meg. Ez a bővítés a jelenlegi beállításban **nincs implementálva**.

Összefoglalva, a modell **maximális kreditpontot** keres a tanulási órák (tanulas) optimális elosztásával a 10 napos időszak alatt, szigorúan betartva a napi órakorlátot és a vizsgák előtti tanulási idő (elsősorban az utolsó 5 napban) minimumkövetelményeit.

Would you like me to use the provided data to **calculate the optimal study plan and maximum credits** using a linear programming solver (like GLPK or Cplex, conceptually)?## 💼 Job Assignment and Scheduling Optimization Problem

This is a **binary integer programming** problem designed to **assign jobs to workers** to **minimize the total cost**, while adhering to constraints on **worker skills** and **availability**.

---

### 🎯 Objective

The goal is to **minimize the total cost** (Objective function: `minimize Cost`). The cost is calculated as the sum, over all workers and jobs, of the **worker's salary multiplied by the duration of the job** if that worker is assigned the job.

$$
\text{Minimize Cost} = \sum_{w \in \text{Workers}} \sum_{j \in \text{Jobs}} \text{salary}[w] \cdot \text{duration}[j] \cdot \text{do}[j,w]
$$

---

### 🧮 Sets, Parameters, and Variables

#### **Sets**
* **Jobs**: The set of tasks to be completed, indexed by $j$.
* **Workers**: The set of available personnel, indexed by $w$.

#### **Parameters (Input Data)**
| Parameter | Description |
| :--- | :--- |
| **nJobs** | Total number of jobs. |
| **nWorkers** | Total number of workers. |
| **required\_skill** $\{j\}$ | The minimum skill level needed for **Job** $j$. |
| **duration** $\{j\}$ | The time required to complete **Job** $j$. |
| **skill\_level** $\{w\}$ | The skill level of **Worker** $w$. |
| **salary** $\{w\}$ | The salary/cost per unit of time for **Worker** $w$. |
| **availability** $\{w\}$ | The maximum amount of time **Worker** $w$ can work. |

#### **Variables (Decision)**
* **do** $\{j, w\}$: A **binary** variable ($0$ or $1$).
    * $\text{do}[j, w] = 1$ if **Job** $j$ is assigned to **Worker** $w$.
    * $\text{do}[j, w] = 0$ otherwise.

---

### ✅ Constraints

The assignment must satisfy three main constraints:

1.  **Skill Level Constraint** (`SkillLevelConstraint`):
    * A job can only be assigned to a worker if the worker's skill level is **sufficient**.
    * If a worker's skill level is **less than** the required skill for a job ($\text{skill\_level}[w] < \text{required\_skill}[j]$), then that worker **cannot** be assigned that job ($\text{do}[j, w] = 0$).
    $$
    \text{do}[j,w] = 0 \quad \text{if } \text{skill\_level}[w] < \text{required\_skill}[j]
    $$

2.  **Worker Availability Constraint** (`WorkAsMuchAsAvailability`):
    * The total time assigned to any worker cannot exceed their maximum available time.
    * For every worker $w$, the sum of the durations of all jobs assigned to them must be **less than or equal to** their availability.
    $$
    \sum_{j \in \text{Jobs}} \text{duration}[j] \cdot \text{do}[j,w] \le \text{availability}[w] \quad \text{for all } w \in \text{Workers}
    $$

3.  **Job Completion Constraint** (`DoAllJobs`):
    * Every job must be completed.
    * For every job $j$, the sum of the assignments over all workers must **equal 1**, ensuring the job is assigned to exactly **one** worker.
    $$
    \sum_{w \in \text{Workers}} \text{do}[j,w] = 1 \quad \text{for all } j \in \text{Jobs}
    $$

---

### 📝 Summary

The model seeks the optimal, minimum-cost assignment of jobs to workers, ensuring all jobs are done, no worker is assigned a task they are under-skilled for, and no worker's total assigned work time exceeds their availability.

Would you like to know the results for a specific set of input parameters or explore how a change in a parameter, like **salary** or **skill\_level**, would affect the optimal assignment?[cite_start]The provided file contains an **AMPL (A Mathematical Programming Language)** model and data for solving a **Knapsack Problem**[cite: 1, 2].

## 🎒 Problem Description

[cite_start]The Knapsack Problem is a classic problem in **combinatorial optimization** where the goal is to choose a subset of items to include in a "knapsack" such that the **total value** of the chosen items is **maximized**, while keeping the **total mass** of the chosen items **below a specified capacity**[cite: 2].

---

## 🛠️ Model Components

The AMPL code defines the problem as follows:

### 1. Sets and Parameters
* [cite_start]**`objCount`**: The number of available objects (items)[cite: 1, 4].
* [cite_start]**`Objects`**: A set representing the items, indexed from 1 up to `objCount`[cite: 1].
* [cite_start]**`mass{Objects}`**: A parameter defining the mass (weight) of each object[cite: 1, 5].
* [cite_start]**`value{Objects}`**: A parameter defining the value (profit) of each object[cite: 1, 5].
* [cite_start]**`capacity`**: The maximum allowable mass for the knapsack[cite: 1, 6].

### 2. Variables
* [cite_start]**`take{Objects} binary`**: A **binary decision variable** for each object[cite: 1].
    * If `take[o]` is **1**, object $o$ is included in the knapsack.
    * If `take[o]` is **0**, object $o$ is not included in the knapsack.

### 3. Objective Function
* [cite_start]**`maximize totalValue: sum{o in Objects} take[o] * value[o]`**: The objective is to maximize the sum of the values of all chosen objects[cite: 2].

### 4. Constraint
* [cite_start]**`s.t. massLimit: sum{o in Objects} take[o] * mass[o] <= capacity`**: The total mass of the chosen objects must not exceed the knapsack's capacity[cite: 3].

---

## 🔢 Specific Data

[cite_start]The data provided specifies a particular instance of the problem with **5 objects** and a **capacity of 13**[cite: 4, 6].

| Object | Mass | Value |
| :----: | :--: | :---: |
| **1** | 1 | 1 |
| **2** | 2 | 3 |
| **3** | 3 | 4 |
| **4** | 9 | 8 |
| **5** | 5 | 6 |
[cite_start][cite: 5]

[cite_start]The solver will determine which objects (1 through 5) to include to get the highest total value without exceeding a total mass of 13[cite: 3].

Would you like me to find the optimal solution for this Knapsack Problem instance?The problem described by the AMPL model and its input data is a **Figure Placement and Paging Optimization Problem**.

The goal is to determine the optimal placement of **figures** (graphs, images, etc.) within a multi-page document to **minimize the total number of page turns** required for the reader to view each figure after reading its citation.

---

## 🧐 Problem Components

The document is composed of **text lines** and **figures**.

### 1. Figures and Their Properties
* The set of figures is $Figures = \{small, big, medium\}$.
* Each figure has a fixed **height** (in lines) and a specific **citation line** number in the running text where the figure is first referenced:
    * **small**: Citation on line **3**, Height **2** lines.
    * **big**: Citation on line **7**, Height **4** lines.
    * **medium**: Citation on line **10**, Height **3** lines.
* The **total lines of text** in the document is the line number of the last citation, which is $\max(\text{citeLine}) = 10$.

### 2. Paging and Layout Constraints
The document must adhere to specific formatting rules:

* **Page Size:** Each page has a maximum capacity of $\mathbf{pageSize} = 5$ lines (which can be text lines or figure height lines).
* **Empty Lines Limit:** Except for the very last page, the space used (text lines + figure height) on a page cannot be too small, ensuring no more than $\mathbf{maxEmptyLine} = 3$ empty lines on non-final used pages.
    * *Constraint*: Used Space $\ge pageSize - maxEmptyLine = 5 - 3 = 2$.
* **Sequential Pages:** Pages must be used sequentially; if page $p$ is used, page $p-1$ must also be used.
* **Total Text:** All 10 lines of text must be printed exactly once across all used pages.
* **Figure Placement:** Each figure must be placed exactly once on a page.

---

## 🎯 Optimization Criteria

The core constraints relate the citation of a figure to its placement:

### 1. Citation-Placement Order
A figure can only be placed on the page where it is cited, or a later page:
$$\mathbf{citePage}[f] \le \mathbf{placePage}[f]$$
This prevents a reader from seeing a figure before it's mentioned.

### 2. Citation Order
Figures cited earlier in the text must be placed on the same page or an earlier page than figures cited later.
$$\text{If } \mathbf{citeLine}[f_1] < \mathbf{citeLine}[f_2] \text{ then } \mathbf{placePage}[f_1] \le \mathbf{placePage}[f_2]$$
This maintains the general order of presentation.

---

## 💰 Objective Function

The objective is to **minimize the total number of page turns**. The number of page turns for a single figure $f$ is:
$$\mathbf{placePage}[f] - \mathbf{citePage}[f]$$

The total objective function to minimize is the sum of page turns for all figures:
$$\text{Minimize } \sum_{f \in Figures} (\mathbf{placePage}[f] - \mathbf{citePage}[f])$$

In essence, the model seeks the document layout that satisfies all constraints while keeping the figures as close as possible (in terms of page number) to where they are first mentioned in the text.

---

## 🛠️ Output

The output section of the AMPL code iterates through the solved pages and prints a formatted representation of the optimal document layout, showing:
* The text lines included on that page.
* Any citation markers (`->[FigureName]`) next to the text line.
* The representation of the placed figures (`# FigureName ###`).
* The empty lines on the page.

Would you like to **run the model** to see the optimal page layout, or perhaps **adjust one of the input parameters**?This is a **Mathematical Programming Model** written in a language like **AMPL** (A Mathematical Programming Language) or a similar algebraic modeling language. It represents a **product design and market segmentation optimization problem**.

The goal is to decide which **components** to include in a product (or service) to **maximize total income** from different customer **groups**, considering their needs and willingness to pay.

---

## ⚙️ Model Components

### 📦 Sets
* **`set Components;`**: A collection of available components that can be included in the product (e.g., "CPU," "RAM," "Camera").
* **`set Groups;`**: A collection of potential customer groups or market segments (e.g., "Students," "Professionals," "Gamers").

### 📊 Parameters (Input Data)
These define the characteristics and constraints of the problem.
* **`param price{Components};`**: The **cost** of each component.
* **`param needs{Groups,Components} binary;`**: A binary matrix where $needs[g,c] = 1$ if **Group $g$ requires Component $c$** to be satisfied, and $0$ otherwise.
* **`param maxpay{Groups};`**: The **maximum price** each customer group $g$ is willing to pay for the product.
* **`param population{Groups};`**: The **size** of each customer group $g$.
* **`param sellprice;`**: The **fixed price** at which the product will be sold to *any* group.
* **`param maxcomponentprice;`**: The **maximum total cost allowed** for all selected components.

### 🎯 Variables (Decisions)
These are the values the solver determines.
* **`var use{Components} binary;`**: A **binary decision variable**. $use[c] = 1$ if **Component $c$ is included** in the product, and $0$ otherwise.
* **`var buy{Groups} binary;`**: A **binary decision variable**. $buy[g] = 1$ if the product is **sold to Group $g$** (i.e., this group is successfully targeted), and $0$ otherwise.

---

## 🔒 Constraints (Rules)

Constraints restrict the feasible solutions based on business and market logic.

* **`s.t. DontBuyIfNeededComponentIsMissing{g in Groups, c in Components : needs[g,c]=1}:`**
    * **Rule:** If a group $g$ needs component $c$ (i.e., $needs[g,c]=1$), then the group can only buy the product if that component is included.
    * **Expression:** $buy[g] \le use[c]$
    * **Interpretation:** If $use[c]=0$ (component is missing), then $buy[g]$ *must* be $0$. If $use[c]=1$ (component is included), $buy[g]$ *can* be $1$.

* **`s.t. DontBuyIfTooExpensive{g in Groups: sellprice > maxpay[g]}:`**
    * **Rule:** If the fixed `sellprice` of the product is **higher** than Group $g$'s maximum willingness to pay (`maxpay[g]`), then the product cannot be sold to this group.
    * **Expression:** $buy[g] = 0$
    * **Interpretation:** This constraint is set *only* for groups that are priced out immediately, forcing the decision variable $buy[g]$ to zero.

* **`s.t. DontSpendTooMuchOnComponents:`**
    * **Rule:** The **total cost** of all included components cannot exceed a predetermined budget (`maxcomponentprice`).
    * **Expression:** $\sum_{c \in Components} price[c] \times use[c] \le maxcomponentprice$
    * **Interpretation:** Limits the total cost of the physical components used to build the product.

---

## 📈 Objective Function (Goal)

* **`maximize Income:`**
    * **Goal:** Maximize the total revenue generated from all targeted groups.
    * **Expression:** $\sum_{g \in Groups} buy[g] \times sellprice \times population[g]$
    * **Interpretation:** The income from Group $g$ is $sellprice \times population[g]$ *only if* $buy[g]=1$ (the group is targeted). The model selects the components and target groups that yield the highest total income.

---

## 📝 Post-Solution Reporting

The final `printf` statements display the results after the model is solved:
1.  Lists the **selected components** (`c` where $use[c]=1$).
2.  Lists the **targeted groups** (`g` where $buy[g]=1$) and their populations.
3.  Calculates and prints the **total number of people** the product is sold to and the **total income** generated.

This model essentially finds the **optimal feature set (components)** that balances the cost of components against the revenue potential from market segments that require those features and can afford the selling price.This code is an **AMPL (A Mathematical Programming Language)** model designed to solve a binary optimization problem, likely a scheduling or resource allocation problem, to **maximize profit** subject to a daily **resource capacity constraint**.

The model defines the planning horizon, available resources, a set of potential orders, and the objective function.

## 📅 Time and Resources

These lines define the temporal scope and resource supply:
* `param nDays >= 0, integer;`
    * Declares a **parameter** named `nDays` representing the total number of days in the planning horizon. It must be a non-negative integer.
* `set Days := 1..nDays;`
    * Defines a **set** named `Days` that is indexed from 1 up to the value of `nDays`. This set will be used to index daily parameters and constraints.
* `param arrive{Days} >= 0;`
    * Declares a **parameter** named `arrive`, indexed over the set `Days`. `arrive[d]` represents the amount of **resource** that **arrives** or becomes available on day $d$. It must be non-negative.

---

## 🛍️ Orders and Decisions

These lines define the set of possible orders and the binary decision variables:
* `set Orders;`
    * Defines an unordered **set** named `Orders`, representing all potential orders that can be fulfilled.
* `param need{Orders};`
    * Declares a **parameter** named `need`, indexed over the set `Orders`. `need[o]` represents the amount of resource **required** to fulfill order $o$.
* `param day{Orders};`
    * Declares a **parameter** named `day`, indexed over the set `Orders`. `day[o]` represents the **day** by which order $o$ must be fulfilled (its due date or fulfillment day).
* `param profit{Orders};`
    * Declares a **parameter** named `profit`, indexed over the set `Orders`. `profit[o]` is the **profit** gained if order $o$ is fulfilled.
* `var do{Orders} binary;`
    * Declares a **binary decision variable** named `do`, indexed over the set `Orders`.
    * `do[o]` will be **1** if order $o$ is chosen to be fulfilled, and **0** otherwise.

---

## ⚖️ Objective and Constraint

These lines define the goal of the optimization and the core limitation:

### **Objective Function**
* `maximize Profit: sum{o in Orders} profit[o]*do[o];`
    * This is the **objective function**, which the model attempts to **maximize**.
    * It is named `Profit`.
    * The total profit is the sum of the profit of each order $o$ (`profit[o]`) multiplied by the decision to fulfill it (`do[o]`).

### **Resource Constraint**
* `s.t. ResourceBalance{d in Days};`
    * Declares a **set of constraints** named `ResourceBalance`, indexed over each day $d$ in the set `Days`.
    * This constraint ensures that for *any given day* $d$, the cumulative resource required by all chosen orders due on or before day $d$ does not exceed the cumulative resource arrived up to and including day $d$.

$$
\sum_{o \in Orders : day[o] \le d} need[o] \cdot do[o] \le \sum_{d2 \in 1..d} arrive[d2]
$$

* **Left Side (Demand/Usage):** `sum{o in Orders : day[o]<=d} need[o]*do[o]`
    * The total resource needed for all selected orders (`do[o] = 1`) whose fulfillment day (`day[o]`) is less than or equal to the current day $d$.
* **Right Side (Supply/Availability):** `sum{d2 in 1..d} arrive[d2]`
    * The total resource that has arrived (cumulative supply) from day 1 up to the current day $d$.

The model essentially chooses the combination of orders that maximizes the total profit while respecting the cumulative daily resource availability.

You can learn more about how to set up, run, and interpret AMPL models in an introductory tutorial like this one: [AMPL Tutorial - YouTube](https://www.youtube.com/watch?v=6XBoPbfsk_M).


http://googleusercontent.com/youtube_content/0
# Igaz-hamis kérdések

1. Egy MILP modellben minden változónak egészértékűnek kell lennie.
2. LP modellekben legalább annyi egyenlőtlenségnek kell lenni, mint ahány egyenlet van.
3. Nem lehet optimális megoldás egy LP/MILP feladat esetében az, ha minden változó értéke 0.
4. A big-M korlátozások csak LP modellekben fordulhatnak elő.
5. A (szimplex) második fázis feladata, hogy találjon egy bázismegoldást.
6. GMPL-ben a var deklarációknak mindenképp a param-ok után kell lennie.
7. A magyar módszert a set covering (halmzlefedési) feladat megoldására dolgozták ki.

# Gyakorlati feladat

## Bemelegítő / elégséges szint

Célunk egy cég esetén úgy eldönteni az elvállalt munkákat, hogy közben a profitunkat maximalizáljuk.

A cégünk egyetlen nyersanyagból, szuperbigyóból gyárt különböző termékeket. A termelésünket megadott mennyiségű napra szeretnénk megtervezni. Minden napra adott, hogy mennyi szuperbigyó érkezik aznap be hozzánk. (A szupebigyót kilóban, nem darabban mérjük.)

Vannak megrendelések, amikről eldönthetjük, hogy elvállaljuk-e őket, vagy sem. Minden megrendeléshez adott, hogy melyik nap kellene legyártani, hogy mennyi szuperbigyóra van hozzá szükség, és hogy mennyi profitot eredményezne. 

Szuperbigyót természetesen tudunk raktározni.

## Lehetséges bővítések

1. A szuperbigyó raktározásra van felső kapacitásunk. Ha egy nap ennél több marad meg belőle, akkor az elveszik.
2. Többféle nyersanyaggal dolgozunk, és minden termékhez adott, hogy melyikből mennyit használ, valamint mindegyikről adott, hogy menyit raktározunk el. 
3. A szuperbigyóra (vagy adott esetben a többi nyersanyagra is) adott, hogy hány napig lehet raktározni anélkül, hogy megromlana.
4. Adott áron tudunk venni plusz szuperbigyót bármelyik nap.
5. Minden megrendeléshez adott, hogy hány óráig tart elkészíteni, és egy nap maximum 16 órányit tudjuk dolgoztatni a gépet.This code is an **AMPL (A Mathematical Programming Language)** model designed to solve a binary optimization problem, likely a scheduling or resource allocation problem, to **maximize profit** subject to a daily **resource capacity constraint**.

The model defines the planning horizon, available resources, a set of potential orders, and the objective function.

## 📅 Time and Resources

These lines define the temporal scope and resource supply:
* `param nDays >= 0, integer;`
    * Declares a **parameter** named `nDays` representing the total number of days in the planning horizon. It must be a non-negative integer.
* `set Days := 1..nDays;`
    * Defines a **set** named `Days` that is indexed from 1 up to the value of `nDays`. This set will be used to index daily parameters and constraints.
* `param arrive{Days} >= 0;`
    * Declares a **parameter** named `arrive`, indexed over the set `Days`. `arrive[d]` represents the amount of **resource** that **arrives** or becomes available on day $d$. It must be non-negative.

---

## 🛍️ Orders and Decisions

These lines define the set of possible orders and the binary decision variables:
* `set Orders;`
    * Defines an unordered **set** named `Orders`, representing all potential orders that can be fulfilled.
* `param need{Orders};`
    * Declares a **parameter** named `need`, indexed over the set `Orders`. `need[o]` represents the amount of resource **required** to fulfill order $o$.
* `param day{Orders};`
    * Declares a **parameter** named `day`, indexed over the set `Orders`. `day[o]` represents the **day** by which order $o$ must be fulfilled (its due date or fulfillment day).
* `param profit{Orders};`
    * Declares a **parameter** named `profit`, indexed over the set `Orders`. `profit[o]` is the **profit** gained if order $o$ is fulfilled.
* `var do{Orders} binary;`
    * Declares a **binary decision variable** named `do`, indexed over the set `Orders`.
    * `do[o]` will be **1** if order $o$ is chosen to be fulfilled, and **0** otherwise.

---

## ⚖️ Objective and Constraint

These lines define the goal of the optimization and the core limitation:

### **Objective Function**
* `maximize Profit: sum{o in Orders} profit[o]*do[o];`
    * This is the **objective function**, which the model attempts to **maximize**.
    * It is named `Profit`.
    * The total profit is the sum of the profit of each order $o$ (`profit[o]`) multiplied by the decision to fulfill it (`do[o]`).

### **Resource Constraint**
* `s.t. ResourceBalance{d in Days};`
    * Declares a **set of constraints** named `ResourceBalance`, indexed over each day $d$ in the set `Days`.
    * This constraint ensures that for *any given day* $d$, the cumulative resource required by all chosen orders due on or before day $d$ does not exceed the cumulative resource arrived up to and including day $d$.

$$
\sum_{o \in Orders : day[o] \le d} need[o] \cdot do[o] \le \sum_{d2 \in 1..d} arrive[d2]
$$

* **Left Side (Demand/Usage):** `sum{o in Orders : day[o]<=d} need[o]*do[o]`
    * The total resource needed for all selected orders (`do[o] = 1`) whose fulfillment day (`day[o]`) is less than or equal to the current day $d$.
* **Right Side (Supply/Availability):** `sum{d2 in 1..d} arrive[d2]`
    * The total resource that has arrived (cumulative supply) from day 1 up to the current day $d$.

The model essentially chooses the combination of orders that maximizes the total profit while respecting the cumulative daily resource availability.

You can learn more about how to set up, run, and interpret AMPL models in an introductory tutorial like this one: [AMPL Tutorial - YouTube](https://www.youtube.com/watch?v=6XBoPbfsk_M).


http://googleusercontent.com/youtube_content/0
This file defines and populates an **optimization model**, likely for a **product manufacturing or component selection problem**, using the **AMPL** modeling language. [cite_start]The goal is to **maximize total profit** by deciding which component parts to build in and which customer groups to sell to[cite: 5].

Here is an explanation of the model's components:

---

## ⚙️ Model Components

### Sets and Parameters

[cite_start]These elements define the input data and structure of the problem[cite: 1, 2].

| Set/Parameter | Description | Data (from source file) |
| :--- | :--- | :--- |
| **`set Parts`** | The set of available component parts. | [cite_start]`GPS, HRM, SPO2, ACC, NFC` [cite: 6] |
| **`param unit_price{Parts}`** | The cost of each individual component part. | [cite_start]Varies: GPS=10000, ACC=20000, etc. [cite: 6] |
| **`set Groups`** | The set of potential customer groups. | [cite_start]`G1, G2, G3, G4, G5, G6` [cite: 7] |
| **`param needs{Groups, Parts}`** | Binary parameter (0 or 1) indicating if a group needs a specific part to be built in. | [cite_start]Specified in the `needs` table [cite: 7] |
| **`param max_price{Groups}`** | The maximum price a group is willing to pay. | [cite_start]Varies: G1=93000, G2=86000, etc. [cite: 8] |
| **`param size{Groups}`** | The size or potential demand from each group. | [cite_start]Varies: G1=13665, G2=13132, etc. [cite: 8] |
| **`param target_price`** | The fixed selling price for the product. | [cite_start]$87,500$ [cite: 9] |
| **`param max_component_price`** | The maximum allowed total cost for the built-in components. | [cite_start]$36,000$ [cite: 2, 9] |

---

## 🎯 Decision Variables

[cite_start]These are the binary variables the optimization solver will determine[cite: 2].

* **`var buildin{Parts} binary`**: $1$ if the part is selected to be built into the product, $0$ otherwise.
* **`var buy{Groups} binary`**: $1$ if the product is sold to this customer group, $0$ otherwise.

---

## 🧮 Objective Function

* [cite_start]**`maximize Profit: sum{g in Groups} buy[g]*target_price*size[g];`** [cite: 5]
    * **Goal:** Maximize the total revenue (which acts as profit, assuming fixed costs are sunk or negligible in this formulation).
    * **Calculation:** The revenue from a group is `buy[g]` (0 or 1) $\times$ `target_price` $\times$ `size[g]`.

---

## 📏 Constraints

The constraints define the rules and limitations of the problem.

1.  [cite_start]**`MaxPartPriceConstraint`** [cite: 3]
    $$\sum_{p \in \text{Parts}} \text{unit\_price}[p] \times \text{buildin}[p] \le \text{max\_component\_price}$$
    * [cite_start]**Rule:** The total cost of all selected built-in components (`buildin[p]=1`) must not exceed the maximum allowable component budget ($36,000$)[cite: 3, 9].

2.  [cite_start]**`WillNotBuyIfTooExpensive`** [cite: 4]
    * **Rule:** For any group $g$ where the product's selling price (`target_price` = $87,500$) is greater than the group's maximum willingness to pay (`max_price[g]`), the variable `buy[g]` must be $0$.
    * *Example:* If a group's `max_price` is $86,000$, and `target_price` is $87,500$, this constraint forces `buy[g] = 0$. [cite_start]Group G2, G3, G5 are immediately excluded by this constraint because their `max_price` ($86000, $81000, $87000 respectively) is less than `target_price` ($87500$)[cite: 4, 8, 9].

3.  [cite_start]**`WontBuyIfNeededPartIsNotBuiltIn`** [cite: 4]
    * **Rule:** For every group $g$ and every part $p$ that group needs (`needs[g, p] == 1$), the part must be built in (`buildin[p] = 1$) if the group is to be sold the product (`buy[g] = 1$).
    * **Simply put:** You can only sell to a group if *all* the components they require are included in the product design.

This model seeks to find the combination of built-in components (`buildin`) and served customer groups (`buy`) that maximizes the total revenue while respecting the component cost budget and meeting the required component needs for all served groups.

Would you like to know the **solution** (the optimal choice of parts and groups) based on this data?## 🧩 Problem Setup: Curriculum Scheduling Optimization

[cite_start]The goal is to create an ideal curriculum schedule by assigning courses to $n$ semesters, optimizing for certain criteria while adhering to several constraints[cite: 1]. The problem is formulated as a Mixed-Integer Linear Program (MILP) and implemented using the provided AMPL code.

---

### 📚 Core Entities

* **Courses (`Courses` set):** The list of all subjects that must be scheduled.
    * Each course has associated **credits** and weekly **contact hours**.
    * [cite_start]**Prerequisites (`depends` parameter):** Defined dependencies specify which courses must precede others[cite: 2].
* **Semesters (`Semesters` set):** The time periods (from 1 to $n$) into which the courses must be scheduled. [cite_start]The total number of semesters is fixed at $n=3$ in the data section[cite: 22, 29].

---

### ✅ Constraints

The following restrictions must be satisfied by the final schedule:

1.  [cite_start]**Scheduling:** Every course must be scheduled exactly once across all semesters (`EachCourseOnce`)[cite: 14].
2.  **Prerequisites:** A course (c2) that depends on another course (c1) must be taken in a *later* semester than its prerequisite. [cite_start]Taking the dependent course earlier or in the same semester is forbidden (`DontMakeDependentEarlier`)[cite: 4, 17].
3.  **Maximum Gap:** There cannot be a gap of more than two semesters between a course (c1) and a course (c2) that depends on it. If $s_1$ is the semester for c1, c2 must be in semester $s_2 \le s_1+3$. [cite_start]The current model enforces $s_2 \le s_1+3$ (`DontStudyMuchEarlier`), which means a maximum gap of 2 semesters (since $s_2 = s_1+1$ is zero gap, $s_2 = s_1+2$ is one gap, $s_2 = s_1+3$ is two gaps)[cite: 4, 18].
4.  [cite_start]**Semester Credit Limits:** The total credits in any semester must be between 25 and 35, inclusive (`SatisfySemesterCreditLimitations`)[cite: 3, 15, 25].
    * $25 \le \sum \text{credits} \le 35$
5.  [cite_start]**Semester Hour Limits:** The total weekly contact hours in any semester must be between 17 and 23, inclusive (`SatisfySemesterHourLimitations`)[cite: 3, 16, 25].
    * $17 \le \sum \text{hours} \le 23$

---

### 🎯 Objective Function

[cite_start]The primary objective is to **minimize the total weekly contact hours** scheduled in the **last two semesters**[cite: 5, 19].

$$\text{Minimize: } \sum_{c \in \text{Courses}} \sum_{s > nSemester-2}^{nSemester} \text{schedule}[s,c] \times \text{hours}[c]$$

---

### 📝 Additional Requirements (Not Implemented in Current Code)

The problem description includes several "plus tasks" that are **not yet reflected** in the provided AMPL model, but should be considered for a complete solution:

* [cite_start]**Minimizing "Reactivation Work" (Cost):** A cost is incurred when a dependent course (A) is scheduled more than one semester after its prerequisite (B)[cite: 6].
    * [cite_start]**1-Semester Gap:** Cost = $5 \times \text{credits}[B]$[cite: 7].
    * [cite_start]**2-Semester Gap:** Cost = $8 \times \text{credits}[B]$[cite: 8].
    * [cite_start]**Reactivation Rule:** If multiple courses depend on B in the same semester, the cost is incurred only once[cite: 9].
    * [cite_start]**Cost Reduction:** If there is a 2-semester gap, but B was already "reactivated" (a course depending on B was taken with a 1-semester gap) in the previous semester, the multiplier is 5 instead of 8[cite: 10].
* [cite_start]**Reactivation Time Limit:** The total time spent on reactivation work in any semester has an upper limit of 70 hours[cite: 10].
* [cite_start]**Elective Blocks:** The curriculum includes elective "blocks" that are not single courses but require a minimum number of credits to be completed[cite: 10].
    * [cite_start]**Hours Calculation:** The workload is $2/3 \times \text{credits}$[cite: 11].
    * [cite_start]**Splitting:** Blocks can be split across semesters, but each part must be at least 2 hours or 3 credits in size[cite: 12].
    * [cite_start]**Dependencies:** Blocks also have prerequisite dependencies[cite: 11].# Igaz-hamis kérdések

1. Egy MILP modellben minden változónak binárisnak kell lennie.
2. LP modellekben legalább annyi korlátozásnak kell lenni, mint ahány változó van.
3. Előfordulhat, hogy egy LP modellnek pontosan 42 megoldása van.
4. A szimplex módszer őnmagában elég MILP feladatok megoldására.
5. A (szimplex) első fázis feladata, hogy megtalálja az optimális megoldást.
6. A GMPL case-insensitive nyelv.
7. MILP-eket könnyebben (gyorsabban) meg lehet oldani, mint LP-ket.

# Gyakorlati feladat

## Bemelegítő / elégséges szint

A célunk a Gazdinfós képzés terembeosztását megcsinálni.

Adottak:
 - Termek, és minden teremre:
   - a kapacitás
   - a bérleti díj / rezsiköltség egy órára
 - A kurzusok, és minden kurzusra:
   - az óraszám
   - a kurzust felvett hallgatók száma

Egyelőre csak egy napot szeretnénk beosztani, reggel 8-tól delután 4-ig. A cél, hogy minél kevesebb terembérleti díjat kelljen fizetni. Ebben a körben még nem kell megmondani, melyik óra mikor kezdődik, csak hogy melyik kurzus hol lesz.

## Lehetséges bővítések

1. Azt is pontosan meg kell mondani, hogy melyik óra mikor kezdődjön. 
2. Az előzőre épülve: adott az oktatóknak egy halmaza, valamint minden tárgyhoz, hogy ki tartja. Értelemszerűen egy oktató nem tud egyszerre két helyen lenni.
3. Mindegyik kurzushoz adott, hogy melyik évfolyam számára van, és a hallgatók sem tudnak egyszerre két helyen lenni.
4. Nem egy napot, hanem egy egész hetet kell beütemezni, és minden oktatóhoz adott, hogy melyik napokon ér rá, melyiken nem.
5. Vannak géptermek és sima termek, és vannak kurzusok, amik géptermeket igényelnek.
6. A cél nem a terembérleti díj minimalizálása, hanem a hallgatók által átlagosan az egyetemen töltött idő minimalizálása. Ehhez minden évfolyamhoz adott egy hallgatói létszám. 
[cite_start]The provided file contains an **AMPL (A Mathematical Programming Language)** model and its associated data, which describes an **optimization problem** for transporting cars[cite: 1, 2].

[cite_start]The core goal of the problem is to **maximize the total number of cars that can be successfully mounted** onto a transporter[cite: 8].

Here is a breakdown of the model, the variables, parameters, and constraints:

## 📐 Model Parameters and Sets

The model defines the following sets and parameters:

* [cite_start]**`Cars`**: The set of cars to be transported, indexed from $1$ to **`nCars`** (299 cars in the data)[cite: 1].
* **`dist{Cars}`**: The **wheelbase (tengelytavolsag)** of each car $c$, which must be non-negative. [cite_start]This is the crucial characteristic of each car[cite: 1].
* [cite_start]**`Mounts`**: The set of available mounting points on the transporter, indexed from $1$ to **`nMount`** (3 mounting points in the data)[cite: 1].
* [cite_start]**`maxd`**: The maximum allowed distance between a car's axle and its mounting point (20 in the data)[cite: 1, 10].
* [cite_start]**`mind`**: The minimum required distance between any two adjacent mounting points (50 in the data)[cite: 2, 10, 5].
* [cite_start]**`M`**: A large number defined as $2 \times \max_{c \in Cars} (\text{dist}[c])$[cite: 2]. This is used in the big-M formulation of the conditional constraints.

---

## 🔢 Variables

The model uses the following variables:

* **`pos{Mounts}`**: The **position** of each mounting point $m$ on the transporter. [cite_start]This is a non-negative continuous variable, and the optimization will determine the ideal positions[cite: 3].
* **`ok{Cars}`**: A **binary** variable for each car $c$. [cite_start]$\text{ok}[c] = 1$ if car $c$ is successfully mounted (is "ok"), and $0$ otherwise[cite: 3].
* **`mount{Cars,Mounts}`**: A **binary** variable. [cite_start]$\text{mount}[c,m] = 1$ if car $c$ is mounted to mounting point $m$, and $0$ otherwise[cite: 3].

---

## 🔒 Constraints

The constraints define the rules for mounting the cars:

### 1. Car Must Be "OK" to Be Mounted

* [cite_start]**`IfNotOKDontMount{c in Cars, m in Mounts}`**: A car $c$ can only be mounted to point $m$ if the car is designated as "ok"[cite: 3].
    * [cite_start]$\text{mount}[c,m] \le \text{ok}[c]$ [cite: 3]

### 2. "OK" Car Must Be Mounted

* **`IfOKMountSomewhere{c in Cars}`**: If a car $c$ is designated as "ok" ($\text{ok}[c]=1$), it must be mounted to at least one mounting point. [cite_start]Since the problem implicitly seeks to maximize the number of cars, a car that is "ok" will be mounted to exactly one point in a practical solution[cite: 4].
    * [cite_start]$\sum_{m \in \text{Mounts}} \text{mount}[c,m] \ge \text{ok}[c]$ [cite: 4]

### 3. Minimum Mounting Distance

* [cite_start]**`MinimumMountDistance{m in Mounts : m!=1}`**: The mounting points must be ordered, and the distance between consecutive mounting points must meet the minimum distance requirement **`mind`** (50 in the data)[cite: 5, 10].
    * [cite_start]$\text{pos}[m] - \text{pos}[m-1] \ge \text{mind}$ [cite: 5]

### 4. Mounting Position vs. Car Wheelbase

* **`IfMountedGoodDistance1/2`**: These are conditional constraints using the **Big-M formulation**. [cite_start]They ensure that if a car $c$ is mounted to point $m$ ($\text{mount}[c,m]=1$), the car's **wheelbase (`dist[c]`)** must fall within an acceptable range defined by the mounting point's position (`pos[m]`) and the tolerance (`maxd`)[cite: 6, 7].
    * If $\text{mount}[c,m]=1$, then:
        * [cite_start]Lower bound: $\text{pos}[m] - 2 \times \text{maxd} \le \text{dist}[c]$ [cite: 6]
        * [cite_start]Upper bound: $\text{dist}[c] \le \text{pos}[m] + 2 \times \text{maxd}$ [cite: 7]
    * The constraints are formulated as:
        * [cite_start]$\text{pos}[m] - 2 \times \text{maxd} - M \times (1-\text{mount}[c,m]) \le \text{dist}[c]$ [cite: 6]
        * [cite_start]$\text{dist}[c] \le \text{pos}[m] + 2 \times \text{maxd} + M \times (1-\text{mount}[c,m])$ [cite: 7]

---

## 🎯 Objective

[cite_start]The objective is to **maximize the total number of "OK" cars**, which means maximizing the number of cars that can be successfully mounted while respecting all constraints[cite: 8].

$$
\text{Maximize TotalOKCars} : \sum_{c \in \text{Cars}} \text{ok}[c]
[cite_start]$$ [cite: 8]

[cite_start]The problem is to find the optimal positions for the **3 mounting points** ($\text{pos}[1], \text{pos}[2], \text{pos}[3]$) [cite: 1, 10] [cite_start]such that the maximum number of cars with varying wheelbases (`dist[c]`) can be mounted[cite: 1, 8].


Would you like me to analyze which cars are mounted by the optimal solution for a given set of mounting points?This is an **Ampl (A Mathematical Programming Language)** model and data file, which describes an **assignment and scheduling problem** likely designed to maximize the completion of a series of tasks over a fixed time period, considering worker speeds and task dependencies.

Here is an explanation of the model components:

## 📐 Model Variables and Parameters

### Sets
* [cite_start]`People`: The set of workers available to perform tasks[cite: 10].
* [cite_start]`Tasks`: The set of tasks to be completed (e.g., `hantas`, `alapfestes`, `jelzesfestes`, `lakkozas`)[cite: 11].
* [cite_start]`Hours`: The set of time steps (hours) from 1 up to `nHours`[cite: 1].

### Parameters (Inputs)
* `previous{Tasks}`: A symbolic parameter defining the **predecessor** (prerequisite) for each task. [cite_start]For example, `alapfestes` (base painting) requires `hantas` (plastering/smoothening) to be finished[cite: 11]. [cite_start]The model includes a placeholder/fix for the first task: `hantas hantas`[cite: 11].
* [cite_start]`lasttask`: A symbolic parameter defining the **final task** in the sequence, which is the one whose completion is maximized (`lakkozas` / varnishing)[cite: 12].
* [cite_start]`nHours`: The total number of hours available for the project (e.g., 8 hours)[cite: 12].
* [cite_start]`speed{People,Tasks}`: The rate at which each person can perform a specific task (e.g., in km/h)[cite: 2, 13].
* [cite_start]`efficiency`: A constant factor (between 0 and 1) applied to all work speeds, representing overall system efficiency (e.g., 0.8)[cite: 2, 12].

### Variables (Outputs)
* `do{Hours,People,Tasks}`: A **binary** decision variable. [cite_start]$do[o, e, f] = 1$ if person $e$ is working on task $f$ during hour $o$; otherwise, it is 0[cite: 2].
* [cite_start]`progress{Hours union {0},Tasks}`: A continuous variable representing the **cumulative completion** of task $f$ at the end of hour $o$, measured in "km"[cite: 2, 3].

---

## 🏗️ Constraints and Objective

### Constraints
1.  [cite_start]`OneTaskPerPerson`: Ensures that each person can only be assigned to a **maximum of one task** in any given hour[cite: 4].
    $$\sum_{f \in Tasks} do[o,e,f] \le 1 \quad \forall e \in People, o \in Hours$$
2.  [cite_start]`ProgressIsZeroAtStart`: Initializes the progress of all tasks to **zero** at the start of the project (hour 0)[cite: 5].
    $$progress[0,f] = 0 \quad \forall f \in Tasks$$
3.  `Progress`: Calculates the cumulative progress for task $f$ at the end of hour $o$. [cite_start]The new progress is the previous progress plus the sum of the work done by all people assigned to that task in hour $o$, scaled by their individual speed and the overall efficiency factor[cite: 5].
    $$progress[o,f] \le progress[o-1,f] + \sum_{e \in People} do[o,e,f] \cdot speed[e,f] \cdot efficiency$$
4.  `TaskPrecedence`: Enforces the **task dependencies**. [cite_start]The progress of a task $f$ in any hour $o$ cannot exceed the progress of its required predecessor task, $previous[f]$, at the same hour[cite: 6].
    $$progress[o,f] \le progress[o,previous[f]] \quad \forall o \in Hours, f \in Tasks$$

### Objective Function
* [cite_start]`maximize CompleteProgress`: The goal of the optimization model is to **maximize the total progress** achieved for the `lasttask` (i.e., `lakkozas`) by the end of the entire time period, $nHours$[cite: 7].

---

## 📊 Output and Data

### Output Block
The `for` loops after the `solve` command are used to display the results for each hour (`o`). It shows:
* The hour number.
* For each task (`f`):
    * [cite_start]The progress transition (e.g., `(2.00 -> 2.50)`)[cite: 8].
    * [cite_start]A list of people (`e`) who were assigned to work on that specific task in that hour (`do[o,e,f]==1`)[cite: 9, 10].

### Data Block
This section provides the concrete input data for the sets and parameters defined in the model:
* [cite_start]**People** (Andi, Bela, Cili, etc.)[cite: 10].
* [cite_start]**Tasks** (`hantas`, `alapfestes`, `jelzesfestes`, `lakkozas`)[cite: 11].
* [cite_start]**Precedence** defining the task flow (e.g., `jelzesfestes` follows `alapfestes`)[cite: 11].
* [cite_start]**Total Hours** ($nHours = 8$)[cite: 12].
* [cite_start]**Efficiency** ($0.8$)[cite: 12].
* [cite_start]A **Speed Matrix** showing each person's speed for each task[cite: 13, 14].

This model will be solved by a mathematical programming solver to find the optimal assignment of people to tasks over the 8 hours that maximizes the completion of the final task, while respecting the one-task-per-person rule and the task prerequisites.

Would you like to explore the solution output for this model, or modify any of the input parameters?[cite_start]The provided AMPL model file, `parallel_machines.mod`, describes a **parallel machine scheduling problem with release (arrival) times**[cite: 1].

[cite_start]The objective is to **minimize the makespan** [cite: 7][cite_start], which is the completion time of the last task[cite: 4].

## ⚙️ Model Components

---

### **Sets and Parameters**
* [cite_start]**Tasks:** The set of jobs/tasks to be scheduled[cite: 1].
* [cite_start]**Machines:** The set of identical parallel machines, defined by `1..machine_count`[cite: 1].
* [cite_start]**arrival\_time{Tasks}**: The time at which a task becomes available for processing (release time)[cite: 1].
* [cite_start]**processing\_time{Tasks}**: The duration required to process each task[cite: 1].
* [cite_start]**machine\_count**: The number of parallel machines available[cite: 1].
* [cite_start]**M**: A sufficiently large Big M constant, calculated as the sum of all arrival and processing times, ensuring it's larger than any feasible makespan[cite: 2].

---

### **Decision Variables**
* [cite_start]**starting\_time{Tasks}**: The time at which task $t$ begins processing[cite: 3].
* [cite_start]**makespan**: The maximum completion time among all tasks[cite: 4]. This is the value to be minimized.
* [cite_start]**assign{Tasks,Machines}**: A binary variable that is **1** if task $t$ is assigned to machine $m$, and **0** otherwise[cite: 3].
* **preceeds{TaskPairs}**: A binary variable for every pair of tasks $(t1, t2)$ where $t1 < t2$. [cite_start]It is **1** if task $t1$ must finish before task $t2$ can start on the *same machine*, and **0** otherwise[cite: 3].

---

### **Constraints**
1.  [cite_start]**CanNotStartTooEarly**: Ensures a task can only start at or after its specified arrival time[cite: 3]:
    $$starting\_time[t] \ge arrival\_time[t]$$
2.  [cite_start]**SetMakespan**: Defines the makespan as the maximum completion time ($starting\_time[t] + processing\_time[t]$) over all tasks[cite: 4]:
    $$makespan \ge starting\_time[t] + processing\_time[t]$$
3.  [cite_start]**SingleMachineAssignment**: Ensures that every task is assigned to exactly one machine[cite: 7]:
    $$\sum_{m \in Machines} assign[t,m] = 1$$
4.  **BigMFirst** and **BigMSecond**: These two constraints use the **Big M formulation** to model the non-preemptive scheduling requirement: if two tasks, $t1$ and $t2$, are assigned to the *same machine* ($assign[t1,m]=1$ and $assign[t2,m]=1$), they cannot overlap in time. One must precede the other.
    * [cite_start]**BigMFirst** [cite: 5] enforces that if $t1$ is assigned to machine $m$ and precedes $t2$ on $m$ ($preceeds[t1,t2]=1$), then $t2$'s start time must be after $t1$'s completion time:
        $$starting\_time[t2]\ge starting\_time[t1]+processing\_time[t1]$$
    * [cite_start]**BigMSecond** [cite: 6] enforces the opposite: if $t2$ is assigned to machine $m$ and precedes $t1$ on $m$ ($1-preceeds[t1,t2]=1$), then $t1$'s start time must be after $t2$'s completion time:
        $$starting\_time[t1]\ge starting\_time[t2]+processing\_time[t2]$$

---

## 🎨 Visualization
[cite_start]The model includes code to output the solution as an **SVG (Scalable Vector Graphics) Gantt chart**[cite: 9, 10, 11, 12, 13, 14]. This chart graphically displays the task assignments and schedules on the machines over time.


***

Would you like to solve this model with a specific set of task and machine data?[cite_start]The provided AMPL model file, `parallel_machines.mod`, describes a **parallel machine scheduling problem with release (arrival) times**[cite: 1].

[cite_start]The objective is to **minimize the makespan** [cite: 7][cite_start], which is the completion time of the last task[cite: 4].

## ⚙️ Model Components

---

### **Sets and Parameters**
* [cite_start]**Tasks:** The set of jobs/tasks to be scheduled[cite: 1].
* [cite_start]**Machines:** The set of identical parallel machines, defined by `1..machine_count`[cite: 1].
* [cite_start]**arrival\_time{Tasks}**: The time at which a task becomes available for processing (release time)[cite: 1].
* [cite_start]**processing\_time{Tasks}**: The duration required to process each task[cite: 1].
* [cite_start]**machine\_count**: The number of parallel machines available[cite: 1].
* [cite_start]**M**: A sufficiently large Big M constant, calculated as the sum of all arrival and processing times, ensuring it's larger than any feasible makespan[cite: 2].

---

### **Decision Variables**
* [cite_start]**starting\_time{Tasks}**: The time at which task $t$ begins processing[cite: 3].
* [cite_start]**makespan**: The maximum completion time among all tasks[cite: 4]. This is the value to be minimized.
* [cite_start]**assign{Tasks,Machines}**: A binary variable that is **1** if task $t$ is assigned to machine $m$, and **0** otherwise[cite: 3].
* **preceeds{TaskPairs}**: A binary variable for every pair of tasks $(t1, t2)$ where $t1 < t2$. [cite_start]It is **1** if task $t1$ must finish before task $t2$ can start on the *same machine*, and **0** otherwise[cite: 3].

---

### **Constraints**
1.  [cite_start]**CanNotStartTooEarly**: Ensures a task can only start at or after its specified arrival time[cite: 3]:
    $$starting\_time[t] \ge arrival\_time[t]$$
2.  [cite_start]**SetMakespan**: Defines the makespan as the maximum completion time ($starting\_time[t] + processing\_time[t]$) over all tasks[cite: 4]:
    $$makespan \ge starting\_time[t] + processing\_time[t]$$
3.  [cite_start]**SingleMachineAssignment**: Ensures that every task is assigned to exactly one machine[cite: 7]:
    $$\sum_{m \in Machines} assign[t,m] = 1$$
4.  **BigMFirst** and **BigMSecond**: These two constraints use the **Big M formulation** to model the non-preemptive scheduling requirement: if two tasks, $t1$ and $t2$, are assigned to the *same machine* ($assign[t1,m]=1$ and $assign[t2,m]=1$), they cannot overlap in time. One must precede the other.
    * [cite_start]**BigMFirst** [cite: 5] enforces that if $t1$ is assigned to machine $m$ and precedes $t2$ on $m$ ($preceeds[t1,t2]=1$), then $t2$'s start time must be after $t1$'s completion time:
        $$starting\_time[t2]\ge starting\_time[t1]+processing\_time[t1]$$
    * [cite_start]**BigMSecond** [cite: 6] enforces the opposite: if $t2$ is assigned to machine $m$ and precedes $t1$ on $m$ ($1-preceeds[t1,t2]=1$), then $t1$'s start time must be after $t2$'s completion time:
        $$starting\_time[t1]\ge starting\_time[t2]+processing\_time[t2]$$

---

## 🎨 Visualization
[cite_start]The model includes code to output the solution as an **SVG (Scalable Vector Graphics) Gantt chart**[cite: 9, 10, 11, 12, 13, 14]. This chart graphically displays the task assignments and schedules on the machines over time.


***

Would you like to solve this model with a specific set of task and machine data?## 📝 Task Description

The objective of this task is to solve a smart watch production and pricing optimization problem using the provided AMPL model (`smartwatch.mod`) and data file (`smartwatch.dat`).

[cite_start]The model aims to **maximize the total profit** from selling a smart watch [cite: 10] by making two main decisions:
1.  [cite_start]**Which components to include** in the smart watch[cite: 3].
2.  [cite_start]**What price to set** for the smart watch (`sellprice`)[cite: 6].

### Key Constraints and Variables:

* **Components and Cost:**
    * [cite_start]A set of available components (`Components`) is defined, each having a price (`price`)[cite: 14, 15].
    * [cite_start]A binary variable `use[c]` determines if a component $c$ is included (`1`) or not (`0`)[cite: 3].
    * [cite_start]The total cost of the selected components must not exceed a maximum budget (`maxcomponentprice`)[cite: 1, 3, 19].
    [cite_start]$$\sum_{c \in Components} price[c] \cdot use[c] \le maxcomponentprice \text{ [cite: 3]}$$
* **Groups and Needs:**
    * [cite_start]The market is segmented into groups (`Groups`), each with a maximum acceptable price (`maxpay`) and a population[cite: 17].
    * [cite_start]The binary parameter `needs[g,c]` indicates if group $g$ requires component $c$[cite: 1, 16].
    * [cite_start]The binary variable `buy[g]` determines if group $g$ purchases the smart watch (`1`) or not (`0`)[cite: 6].
* **Purchasing Logic:**
    * [cite_start]A group $g$ can only buy the smart watch if all components it requires are included in the product[cite: 4]:
        [cite_start]$$\text{If } needs[g,c]=1 \text{ then } use[c] \ge buy[g] \text{ [cite: 4]}$$
    * [cite_start]A group $g$ can only buy the smart watch if the set selling price is less than or equal to their maximum willingness to pay (`maxpay[g]`)[cite: 5, 6].
        [cite_start]$$maxpay[g] \ge sellprice - M \cdot (1 - buy[g]) \text{ [cite: 6]}$$
        [cite_start]*(Where $M$ is a large constant used for linearization[cite: 2].)*
* **Profit Calculation:**
    * [cite_start]The profit from a purchasing group $g$ is the profit per unit ($\text{sellprice} - \sum price[c] \cdot use[c]$) multiplied by the group's population[cite: 7, 8].
    * [cite_start]The model uses auxiliary constraints (`Bilinear_profit_1` to `Bilinear_profit_3`) to correctly calculate the profit (`profit[g]`) while handling the **bilinear term** (selling price $\times$ population $\times$ buy/not buy) and ensuring profit is zero if the group does not buy[cite: 7, 8, 9].
* **Objective:**
    * [cite_start]Maximize the total profit, which is the sum of profits from all buying groups[cite: 10].
    [cite_start]$$\text{Maximize } \sum_{g \in Groups} profit[g] \text{ [cite: 10]}$$

[cite_start]The task is to execute the optimization and report the following results[cite: 11, 12, 13]:
* The final set of **used components** and their prices.
* The **groups that purchase** the smart watch and their populations.
* The optimal **selling price** (`sellprice`).
* The maximum **total profit** (`Profit`).

---
Would you like me to run this optimization model now?## 📝 Task Description

The objective of this task is to solve a smart watch production and pricing optimization problem using the provided AMPL model (`smartwatch.mod`) and data file (`smartwatch.dat`).

[cite_start]The model aims to **maximize the total profit** from selling a smart watch [cite: 10] by making two main decisions:
1.  [cite_start]**Which components to include** in the smart watch[cite: 3].
2.  [cite_start]**What price to set** for the smart watch (`sellprice`)[cite: 6].

### Key Constraints and Variables:

* **Components and Cost:**
    * [cite_start]A set of available components (`Components`) is defined, each having a price (`price`)[cite: 14, 15].
    * [cite_start]A binary variable `use[c]` determines if a component $c$ is included (`1`) or not (`0`)[cite: 3].
    * [cite_start]The total cost of the selected components must not exceed a maximum budget (`maxcomponentprice`)[cite: 1, 3, 19].
    [cite_start]$$\sum_{c \in Components} price[c] \cdot use[c] \le maxcomponentprice \text{ [cite: 3]}$$
* **Groups and Needs:**
    * [cite_start]The market is segmented into groups (`Groups`), each with a maximum acceptable price (`maxpay`) and a population[cite: 17].
    * [cite_start]The binary parameter `needs[g,c]` indicates if group $g$ requires component $c$[cite: 1, 16].
    * [cite_start]The binary variable `buy[g]` determines if group $g$ purchases the smart watch (`1`) or not (`0`)[cite: 6].
* **Purchasing Logic:**
    * [cite_start]A group $g$ can only buy the smart watch if all components it requires are included in the product[cite: 4]:
        [cite_start]$$\text{If } needs[g,c]=1 \text{ then } use[c] \ge buy[g] \text{ [cite: 4]}$$
    * [cite_start]A group $g$ can only buy the smart watch if the set selling price is less than or equal to their maximum willingness to pay (`maxpay[g]`)[cite: 5, 6].
        [cite_start]$$maxpay[g] \ge sellprice - M \cdot (1 - buy[g]) \text{ [cite: 6]}$$
        [cite_start]*(Where $M$ is a large constant used for linearization[cite: 2].)*
* **Profit Calculation:**
    * [cite_start]The profit from a purchasing group $g$ is the profit per unit ($\text{sellprice} - \sum price[c] \cdot use[c]$) multiplied by the group's population[cite: 7, 8].
    * [cite_start]The model uses auxiliary constraints (`Bilinear_profit_1` to `Bilinear_profit_3`) to correctly calculate the profit (`profit[g]`) while handling the **bilinear term** (selling price $\times$ population $\times$ buy/not buy) and ensuring profit is zero if the group does not buy[cite: 7, 8, 9].
* **Objective:**
    * [cite_start]Maximize the total profit, which is the sum of profits from all buying groups[cite: 10].
    [cite_start]$$\text{Maximize } \sum_{g \in Groups} profit[g] \text{ [cite: 10]}$$

[cite_start]The task is to execute the optimization and report the following results[cite: 11, 12, 13]:
* The final set of **used components** and their prices.
* The **groups that purchase** the smart watch and their populations.
* The optimal **selling price** (`sellprice`).
* The maximum **total profit** (`Profit`).

---
Would you like me to run this optimization model now?## 🚘 Task Description: Car Trading Optimization

The provided files define an optimization problem for maximizing money by trading a set of cars over a number of days. This is a classic **inventory and finance management** problem.

### 📝 Model (`model_1.mod`) Breakdown

The AMPL model defines the sets, parameters, and variables necessary to formulate this trading strategy:

* **Sets:**
    * [cite_start]$Cars$: The types of cars that can be traded[cite: 1].
    * [cite_start]$Days$: A sequence of days for the trading period, defined from 1 up to $nDays$[cite: 1].
* **Parameters:**
    * [cite_start]$nDays$: The total number of days in the trading period[cite: 1].
    * [cite_start]$price\{Days, Cars\}$: The price of each car on a specific day[cite: 1].
    * [cite_start]$inital\_money$: The starting capital[cite: 1].
* **Decision Variables (Integers $\ge 0$):**
    * [cite_start]$sell\{Days, Cars\}$: The number of a specific car type to **sell** on a given day[cite: 1].
    * [cite_start]$buy\{Days, Cars\}$: The number of a specific car type to **buy** on a given day[cite: 2].
* **Constraints:**
    * [cite_start]$Dont\_overspend$: Ensures that the total cash on hand never drops below zero on **any** given day[cite: 2]. [cite_start]The current cash is calculated as the initial money plus the cumulative profit/loss from all past transactions up to the `current_day`[cite: 2].
    * [cite_start]$Dont\_sell\_what\_you\_dont\_have$: Ensures that the number of a specific car type sold on a given day cannot exceed the cumulative net stock (buys minus sells) up to that day[cite: 3].
* **Objective Function:**
    * [cite_start]$maximize \ Money\_at\_end$: The goal is to maximize the final amount of money after all transactions over all days[cite: 4]. [cite_start]This is calculated as the initial money plus the total cumulative profit/loss from all buys and sells across the entire period[cite: 4].

### 📊 Data (`data.dat`) Breakdown

The data file provides the concrete values for the model parameters:

* [cite_start]**Trading Period:** $nDays$ is set to **28**[cite: 5].
* [cite_start]**Car Types:** The set $Cars$ includes **BMW, Mazda, Smart, Opel, and Audi**[cite: 5].
* [cite_start]**Initial Capital:** $inital\_money$ is set to **40** (units are not specified, likely monetary units)[cite: 5].
* [cite_start]**Prices:** The $price$ parameter table provides the daily price for each of the five car types over the 28 days[cite: 6, 7].

The task is to find the optimal trading strategy (the daily number of cars to buy or sell for each car type) that maximizes the final money while adhering to the budget and inventory constraints.

---

Would you like me to identify the most volatile car price or the day with the highest price for a specific car?The provided files define an **optimization problem** for **planning a running schedule** over a set number of weeks. The goal is to maximize the total distance covered by selecting one route per week, subject to several constraints.

---

## 🏃‍♀️ Data File (`duhajok.dat`)

This file contains the data for the sets, parameters, and their specific values used in the model.

* **Sets:**
    * [cite_start]**Runners:** The participants: Tomi, Livi, Balazs, Kriszti, Ricsi, and Csabi[cite: 1].
    * [cite_start]**Routes:** The available running routes: Lover, Muck, Benchmark, HaromAKaroly, and Ojtozi[cite: 7].
* **Parameters:**
    * [cite_start]**max\_distance:** The **maximum distance each runner can cover** (in km)[cite: 1].
        * Tomi: 21, Livi: 9, Balazs: 24, Kriszti: 8, Ricsi: 13, Csabi: 2.
    * [cite_start]**weeks:** The **duration of the planning period** in weeks, set to 5[cite: 2].
    * [cite_start]**attendance:** A **binary matrix** indicating if a runner attends a specific week (1 for yes, blank/dot for no/zero)[cite: 3, 4, 5, 6].
    * [cite_start]**distance:** The **length of each running route** (in km)[cite: 7].
        * Lover: 5.3, Muck: 9.5, Benchmark: 13, HaromAKaroly: 21, Ojtozi: 6.
    * [cite_start]**max\_occurence:** The **maximum number of times any single route can be selected** across all weeks, set to 2[cite: 8].

---

## 📝 Model File (`planning.mod`)

This file defines the mathematical programming model, including sets, parameters, a decision variable, constraints, and the objective function.

### Sets and Parameters
[cite_start]The model re-declares the sets and parameters defined in the data file: `Runners`, `max_distance`, `weeks`, `Weeks` (derived from `weeks`), `attendance`, `Routes`, `distance`, and `max_occurence`[cite: 9, 10].

### Decision Variable
* [cite_start]**select{Weeks, Routes}**: A **binary variable** that equals **1** if the route $r$ is selected in week $w$, and **0** otherwise[cite: 10].

### Constraints
1.  [cite_start]**One\_route\_a\_week**: Ensures that **exactly one route is selected for each week** $w$[cite: 10].
    $$\sum_{r \in \text{Routes}} \text{select}[w,r] = 1$$
2.  [cite_start]**Max\_occurence\_for\_each\_ruote**: Ensures that **no single route is selected more than `max_occurence`** (2 times) across all weeks[cite: 11].
    $$\sum_{w \in \text{Weeks}} \text{select}[w,r] \le \text{max\_occurence}$$
3.  [cite_start]**Only\_compattible\_rouotes**: Ensures that a route $c$ is **NOT selected in a week $w$** if a runner $r$ attending that week ($\text{attendance}[r,w]=1$) has a **maximum distance** $\text{max\_distance}[r]$ **less than the route's distance** $\text{distance}[c]$[cite: 12]. This constraint forces the model to only pick routes compatible with *all* runners attending that week.
    $$\sum_{w \in \text{Weeks} : \text{attendance}[r,w]=1} \sum_{c \in \text{Routes}: \text{distance}[c] > \text{max\_distance}[r]} \text{select}[w,c] = 0$$

### Objective Function
* [cite_start]**TotalDistance**: The objective is to **maximize the total distance covered** over the 5 weeks[cite: 13].
    $$\text{Maximize: } \sum_{w \in \text{Weeks}, r \in \text{Routes}} \text{select}[w,r] \cdot \text{distance}[r]$$

### Output
[cite_start]After solving, the model prints the **selected route and its distance for each week**[cite: 14]. [cite_start]For each week, it also lists the **runners attending that week** along with their **maximum distance** capabilities[cite: 15, 16].

---
Would you like to know the **solution** (the planned routes and total distance) for this optimization problem?The provided files define an **optimization problem** for **planning a running schedule** over a set number of weeks. The goal is to maximize the total distance covered by selecting one route per week, subject to several constraints.

---

## 🏃‍♀️ Data File (`duhajok.dat`)

This file contains the data for the sets, parameters, and their specific values used in the model.

* **Sets:**
    * [cite_start]**Runners:** The participants: Tomi, Livi, Balazs, Kriszti, Ricsi, and Csabi[cite: 1].
    * [cite_start]**Routes:** The available running routes: Lover, Muck, Benchmark, HaromAKaroly, and Ojtozi[cite: 7].
* **Parameters:**
    * [cite_start]**max\_distance:** The **maximum distance each runner can cover** (in km)[cite: 1].
        * Tomi: 21, Livi: 9, Balazs: 24, Kriszti: 8, Ricsi: 13, Csabi: 2.
    * [cite_start]**weeks:** The **duration of the planning period** in weeks, set to 5[cite: 2].
    * [cite_start]**attendance:** A **binary matrix** indicating if a runner attends a specific week (1 for yes, blank/dot for no/zero)[cite: 3, 4, 5, 6].
    * [cite_start]**distance:** The **length of each running route** (in km)[cite: 7].
        * Lover: 5.3, Muck: 9.5, Benchmark: 13, HaromAKaroly: 21, Ojtozi: 6.
    * [cite_start]**max\_occurence:** The **maximum number of times any single route can be selected** across all weeks, set to 2[cite: 8].

---

## 📝 Model File (`planning.mod`)

This file defines the mathematical programming model, including sets, parameters, a decision variable, constraints, and the objective function.

### Sets and Parameters
[cite_start]The model re-declares the sets and parameters defined in the data file: `Runners`, `max_distance`, `weeks`, `Weeks` (derived from `weeks`), `attendance`, `Routes`, `distance`, and `max_occurence`[cite: 9, 10].

### Decision Variable
* [cite_start]**select{Weeks, Routes}**: A **binary variable** that equals **1** if the route $r$ is selected in week $w$, and **0** otherwise[cite: 10].

### Constraints
1.  [cite_start]**One\_route\_a\_week**: Ensures that **exactly one route is selected for each week** $w$[cite: 10].
    $$\sum_{r \in \text{Routes}} \text{select}[w,r] = 1$$
2.  [cite_start]**Max\_occurence\_for\_each\_ruote**: Ensures that **no single route is selected more than `max_occurence`** (2 times) across all weeks[cite: 11].
    $$\sum_{w \in \text{Weeks}} \text{select}[w,r] \le \text{max\_occurence}$$
3.  [cite_start]**Only\_compattible\_rouotes**: Ensures that a route $c$ is **NOT selected in a week $w$** if a runner $r$ attending that week ($\text{attendance}[r,w]=1$) has a **maximum distance** $\text{max\_distance}[r]$ **less than the route's distance** $\text{distance}[c]$[cite: 12]. This constraint forces the model to only pick routes compatible with *all* runners attending that week.
    $$\sum_{w \in \text{Weeks} : \text{attendance}[r,w]=1} \sum_{c \in \text{Routes}: \text{distance}[c] > \text{max\_distance}[r]} \text{select}[w,c] = 0$$

### Objective Function
* [cite_start]**TotalDistance**: The objective is to **maximize the total distance covered** over the 5 weeks[cite: 13].
    $$\text{Maximize: } \sum_{w \in \text{Weeks}, r \in \text{Routes}} \text{select}[w,r] \cdot \text{distance}[r]$$

### Output
[cite_start]After solving, the model prints the **selected route and its distance for each week**[cite: 14]. [cite_start]For each week, it also lists the **runners attending that week** along with their **maximum distance** capabilities[cite: 15, 16].

---
Would you like to know the **solution** (the planned routes and total distance) for this optimization problem?The provided files, `szinezes.dat` and `szinezes.mod`, define a **graph coloring problem** using a mathematical programming formulation, likely for use with a solver like GLPK or AMPL. The goal is to assign a color to each country such that no two bordering countries share the same color.

Here's a breakdown of the content in each file:

## 🗺️ `szinezes.dat` (Data File)

This file defines the set of **nodes (countries)** and the set of **edges (borders)**, which together form a **graph**.

* [cite_start]**`Countries` set**: Lists the countries to be colored: $\text{CR}$ (Croatia), $\text{SL}$ (Slovenia), $\text{HU}$ (Hungary), $\text{AT}$ (Austria), $\text{SK}$ (Slovakia), $\text{CZ}$ (Czechia), $\text{DE}$ (Germany), $\text{CH}$ (Switzerland)[cite: 1].
    * [cite_start]`set Countries := CR SL HU AT SK CZ DE CH;` [cite: 1]
* **`Borders` set**: Lists the pairs of countries that share a border (i.e., the edges of the graph). [cite_start]For example, $\text{HU}$ borders $\text{AT}$ and $\text{SK}$[cite: 2].
    * [cite_start]`set Borders := (HU,AT) (HU,SK) ... (CR,HU);` [cite: 2]

## 🎨 `szinezes.mod` (Model File)

This file defines the decision variables, constraints, and objective function for the coloring problem.

### Decision Variables

The model uses four sets of **binary variables** (0 or 1), one for each of the four possible colors. [cite_start]The variables are indexed by the set of `Countries`[cite: 3].

* **$K[c]$**: **Kék (Blue)** - 1 if country $c$ is colored blue, 0 otherwise.
* **$P[c]$**: **Piros (Red)** - 1 if country $c$ is colored red, 0 otherwise.
* **$Z[c]$**: **Zöld (Green)** - 1 if country $c$ is colored green, 0 otherwise.
* **$F[c]$**: **Fekete (Black)** - 1 if country $c$ is colored black, 0 otherwise.

### Constraints

The constraints enforce that the coloring is both complete and valid.

1.  [cite_start]**"Every country must have a color"** ($\text{Minden\_országnak\_legyen\_színe}$)[cite: 4]:
    * For every country $c$ in `Countries`, exactly one color variable must be equal to 1.
    * [cite_start]$$K[c] + P[c] + Z[c] + F[c] = 1$$ [cite: 4]

2.  **Color Separation Constraints** (No two bordering countries can have the same color):
    * These constraints apply to every pair of bordering countries $(c_1, c_2)$ in the `Borders` set. The sum of the two countries' color variables for any single color must be at most 1, meaning they cannot both be 1 (the same color).
    * [cite_start]**No Red Neighbors** ($\text{Nem\_lehetnek\_piros\_szomszédok}$): $P[c_1] + P[c_2] \le 1$ [cite: 5]
    * [cite_start]**No Green Neighbors** ($\text{Nem\_lehetnek\_zöld\_szomszédok}$): $Z[c_1] + Z[c_2] \le 1$ [cite: 5]
    * [cite_start]**No Blue Neighbors** ($\text{Nem\_lehetnek\_kék\_szomszédok}$): $K[c_1] + K[c_2] \le 1$ [cite: 6]
    * [cite_start]**No Black Neighbors** ($\text{Nem\_lehetnek\_fekete\_szomszédok}$): $F[c_1] + F[c_2] \le 1$ [cite: 6]

### Objective Function

* [cite_start]**`minimize Placeholder: 1;`** [cite: 7]
    * [cite_start]The objective is simply to minimize the constant value of 1. This indicates that the problem is a **satisfiability problem**—the goal is **only to find a feasible solution** (a valid coloring), and the objective function itself is meaningless beyond forcing the solver to find *any* solution that satisfies all constraints[cite: 7].

---

In summary, the files implement a mathematical model to determine if the eight Central European countries listed can be colored using at most **four colors** (blue, red, green, black) such that no two adjacent countries share the same color.

Would you like me to try and find a valid coloring for these countries based on this model?[cite_start]This is a **classic transportation linear programming model** used to minimize the total shipping cost of products from **factories (Gyarak)** to **pubs (Kocsmak)**, subject to supply and demand constraints[cite: 5, 8].

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


Would you like me to find the optimal solution by running this model?Based on the provided AMPL model file, here is a description of the optimization problem it aims to solve:

### 📚 Optimization Problem: Exam Study Scheduling

[cite_start]This is a **scheduling and resource allocation** problem designed to maximize a student's weighted average grade across several subjects, given a limited amount of study time over a set number of days[cite: 1, 9]. [cite_start]The decision is whether to **pass** each subject and, if so, how to **schedule study time** for it[cite: 2].

---

### 📝 Key Components

#### [cite_start]**Parameters (Input Data)[cite: 1]:**

* [cite_start]**`nDays`**: The total number of days available for studying (e.g., 10 days)[cite: 1, 12].
* [cite_start]**`Subjects`**: The set of subjects the student is taking (e.g., Energy, Architecture, OperationsManagement)[cite: 1, 12].
* [cite_start]**`freetime{Days}`**: The maximum number of study hours available on each day (e.g., 8 hours on Day 1, 10 hours on Day 2, etc.)[cite: 1, 14].
* [cite_start]**`grade5{Subjects}`**: The *minimum total hours* of study required to achieve a passing grade (5.0) in each subject (e.g., 15 hours for Energy)[cite: 1, 12].
* [cite_start]**`credit{Subjects}`**: The credit weight of each subject[cite: 1, 13].
* [cite_start]**`examday{Subjects}`**: The day on which the exam for each subject is scheduled[cite: 1, 13].

#### [cite_start]**Decision Variables[cite: 2]:**

* **`pass{Subjects}`**: A **binary** variable:
    * 1 if the student decides to pass the subject.
    * 0 if the student decides not to pass the subject.
* [cite_start]**`study{Subjects, Days}`**: A **non-negative** variable representing the number of hours spent studying subject $s$ on day $d$[cite: 2].

#### [cite_start]**Objective Function[cite: 9]:**

[cite_start]The goal is to **maximize the Weighted Average Grade**[cite: 9]:

$$
\text{Maximize: } \frac{\sum_{s \in \text{Subjects}} \text{credit}[s] \times 5 \times \text{pass}[s]}{\sum_{s \in \text{Subjects}} \text{credit}[s]}
$$

* [cite_start]This objective assumes that passing a subject (`pass[s]=1`) results in a grade of **5.0** (the highest possible) and failing a subject (`pass[s]=0`) results in a grade of **0.0** (since the objective term becomes 0)[cite: 9].

#### [cite_start]**Constraints[cite: 3, 4, 6, 8]:**

1.  [cite_start]**Do Not Exceed Free Time**: The total study time across all subjects on any given day cannot exceed the available free time for that day[cite: 3].
    $$\sum_{s \in \text{Subjects}} \text{study}[s,d] \le \text{freetime}[d] \quad \text{for all } d \in \text{Days}$$

2.  [cite_start]**Do Not Study After Exam**: Study time is only allocated on days *before* the exam day[cite: 4].
    $$\text{study}[s,d] = 0 \quad \text{for all } s \in \text{Subjects}, d \ge \text{examday}[s]$$

3.  [cite_start]**Study Enough for Grade**: If the student decides to pass a subject (`pass[s]=1`), the total study hours accumulated *before* the exam must be at least the required amount (`grade5[s]`)[cite: 5, 6].
    $$\sum_{d < \text{examday}[s]} \text{study}[s,d] \ge \text{grade5}[s] \times \text{pass}[s] \quad \text{for all } s \in \text{Subjects}$$

4.  [cite_start]**Don't Waste Time**: If the student decides **not** to pass a subject (`pass[s]=0`), the total study time allocated to that subject across all days must be zero (this is enforced by multiplying the study time by a large number like 999 which acts as a technical upper bound, and setting the right side to 0 when `pass[s]=0`)[cite: 7, 8].
    $$\sum_{d \in \text{Days}} \text{study}[s,d] \le \text{pass}[s] \times 999 \quad \text{for all } s \in \text{Subjects}$$

---

### 💡 In essence:

The model determines the **optimal set of exams to pass** and the **day-by-day study schedule** to achieve the highest possible weighted average grade, while respecting the daily time limits and the minimum required study hours for each subject to pass.

---

Would you like to know the **optimal study schedule** if this model were solved, or perhaps have the **data section** explained in more detail?[cite_start]That file contains an **Optimization Model** written in a modeling language (likely AMPL or a similar syntax)[cite: 1, 2, 3, 4].

[cite_start]The model, named `froccs`, appears to be a **Maximization Problem** [cite: 4] designed to determine the optimal quantities of three different types of mixed drinks, likely a Hungarian spritzer called "fröccs," to maximize profit based on limited ingredients (wine and soda water).

---

### 📝 Model Components

* **Variables (Decision Variables):** These are the quantities of each type of fröccs to be produced, and they must be non-negative integers (meaning you can only make whole drinks).
    * [cite_start]$KF$: Quantity of the first type of fröccs (Kisföccs) [cite: 1]
    * [cite_start]$NF$: Quantity of the second type of fröccs (Nagyfröccs) [cite: 1]
    * [cite_start]$HL$: Quantity of the third type of fröccs (Hosszúlépés) [cite: 1]

* **Objective Function (Maximize):** The goal is to maximize the total profit generated from selling these three types of drinks.
    $$\text{Profit} = 200 \cdot KF + 380 \cdot NF + 220 \cdot HL$$
    [cite_start]This suggests the profit per unit is **200** for $KF$, **380** for $NF$, and **220** for $HL$[cite: 4].

* **Constraints (Subject To - s.t.):** These limit the total amount of ingredients used.
    * **Bor (Wine) Constraint:** The total amount of wine used cannot exceed 1000 units.
        $$KF + 2 \cdot NF + HL \le 1000$$
        * [cite_start]$KF$ uses **1 unit** of wine[cite: 2].
        * [cite_start]$NF$ uses **2 units** of wine[cite: 2].
        * [cite_start]$HL$ uses **1 unit** of wine[cite: 2].
    * **Szóda (Soda Water) Constraint:** The total amount of soda water used cannot exceed 1500 units.
        $$KF + NF + 2 \cdot HL \le 1500$$
        * [cite_start]$KF$ uses **1 unit** of soda[cite: 3].
        * [cite_start]$NF$ uses **1 unit** of soda[cite: 3].
        * [cite_start]$HL$ uses **2 units** of soda[cite: 3].

---

### 🎯 Goal

[cite_start]The model seeks to find the non-negative integer values for $KF$, $NF$, and $HL$ that yield the **highest total profit** [cite: 4] [cite_start]without exceeding the available stock of **1000 units of wine** [cite: 2] [cite_start]and **1500 units of soda water**[cite: 3].

Would you like me to identify the type of optimization problem this is?[cite_start]That file contains an **Optimization Model** written in a modeling language (likely AMPL or a similar syntax)[cite: 1, 2, 3, 4].

[cite_start]The model, named `froccs`, appears to be a **Maximization Problem** [cite: 4] designed to determine the optimal quantities of three different types of mixed drinks, likely a Hungarian spritzer called "fröccs," to maximize profit based on limited ingredients (wine and soda water).

---

### 📝 Model Components

* **Variables (Decision Variables):** These are the quantities of each type of fröccs to be produced, and they must be non-negative integers (meaning you can only make whole drinks).
    * [cite_start]$KF$: Quantity of the first type of fröccs (Kisföccs) [cite: 1]
    * [cite_start]$NF$: Quantity of the second type of fröccs (Nagyfröccs) [cite: 1]
    * [cite_start]$HL$: Quantity of the third type of fröccs (Hosszúlépés) [cite: 1]

* **Objective Function (Maximize):** The goal is to maximize the total profit generated from selling these three types of drinks.
    $$\text{Profit} = 200 \cdot KF + 380 \cdot NF + 220 \cdot HL$$
    [cite_start]This suggests the profit per unit is **200** for $KF$, **380** for $NF$, and **220** for $HL$[cite: 4].

* **Constraints (Subject To - s.t.):** These limit the total amount of ingredients used.
    * **Bor (Wine) Constraint:** The total amount of wine used cannot exceed 1000 units.
        $$KF + 2 \cdot NF + HL \le 1000$$
        * [cite_start]$KF$ uses **1 unit** of wine[cite: 2].
        * [cite_start]$NF$ uses **2 units** of wine[cite: 2].
        * [cite_start]$HL$ uses **1 unit** of wine[cite: 2].
    * **Szóda (Soda Water) Constraint:** The total amount of soda water used cannot exceed 1500 units.
        $$KF + NF + 2 \cdot HL \le 1500$$
        * [cite_start]$KF$ uses **1 unit** of soda[cite: 3].
        * [cite_start]$NF$ uses **1 unit** of soda[cite: 3].
        * [cite_start]$HL$ uses **2 units** of soda[cite: 3].

---

### 🎯 Goal

[cite_start]The model seeks to find the non-negative integer values for $KF$, $NF$, and $HL$ that yield the **highest total profit** [cite: 4] [cite_start]without exceeding the available stock of **1000 units of wine** [cite: 2] [cite_start]and **1500 units of soda water**[cite: 3].

Would you like me to identify the type of optimization problem this is?[cite_start]This file defines a **mixed-integer linear programming (MILP)** problem that deals with **facility location and logistics**, specifically determining which **depots** to build and how to use them to satisfy the **demand** of various **barracks** while minimizing the total cost[cite: 1, 2, 3, 7].

Here is a breakdown of the model components:

## 📐 Sets and Parameters
| Element | Description | Units/Type | Source |
| :--- | :--- | :--- | :--- |
| `set Barracks` | The set of locations with a demand for the commodity. | - [cite_start]| [cite: 1] |
| `set Depots` | The set of potential locations where a depot can be built. | - [cite_start]| [cite: 1] |
| `param fix_cost{Depots}` | The fixed cost of building and operating a depot. | [cite_start]\$/l | [cite: 1] |
| `param prop_cost{Depots}` | The cost proportional to the size/volume handled by the depot. | [cite_start]\$ | [cite: 1] |
| `param demand{Barracks}` | The required amount (demand) of the commodity at each barracks. [cite_start]| l | [cite: 1, 2] |
| `param connected{Depots,Barracks}` | A binary parameter indicating if a depot is connected to (can supply) a barracks. [cite_start]| binary (0/1) | [cite: 2] |
| `param M` | A large constant, calculated as the total sum of demand across all barracks. [cite_start]| l | [cite: 3] |

---

## 🔢 Decision Variables
| Variable | Description | Type/Constraint | Source |
| :--- | :--- | :--- | :--- |
| `var build{Depots}` | Binary variable: **1** if the depot is built, **0** otherwise. [cite_start]| binary (0/1) | [cite: 2] |
| `var size{Depots}` | The total amount (size/volume) transported *from* a specific depot. | [cite_start]$\ge 0$ (l) | [cite: 2, 3] |
| `var transport{Depots,Barracks}` | The amount of commodity transported from depot $d$ to barracks $b$. | [cite_start]$\ge 0$ (l) | [cite: 3] |

---

## ⛓️ Constraints
The problem is constrained by the following requirements:

1.  [cite_start]**Satisfy Demand (`Satisfy_demand_v2`):** The total amount of commodity transported to each barracks must meet or exceed its demand[cite: 4].
    $$\sum_{d \in Depots: connected[d,b]=1} transport[d,b] \ge demand[b] \quad \forall b \in Barracks$$
    [cite_start]*(Note: `Satisfy_demand` is redundant/an alternative formulation for the same demand satisfaction requirement [cite: 3, 4]).*

2.  [cite_start]**Define Depot Size (`Set_size_variable`):** The size of each depot is defined as the total amount it transports to all connected barracks[cite: 5].
    $$size[d] = \sum_{b \in Barracks: connected[d,b] = 1} transport[d,b] \quad \forall d \in Depots$$

3.  [cite_start]**Link Size and Build Status (`Omly_use_builded_depots`):** A depot can only transport a non-zero amount if it has been built (`build[d] = 1`)[cite: 6]. This is enforced using the "Big M" technique, where $M$ is the maximum possible size (total demand) a depot could have.
    $$size[d] \le M \cdot build[d] \quad \forall d \in Depots$$

---

## 🎯 Objective Function
The goal is to **minimize** the total cost, which consists of two parts:
1.  **Fixed Cost:** The cost of building a depot (incurred only if `build[d]=1`).
2.  **Proportional Cost:** The cost proportional to the volume (`size[d]`) transported by the depot.

[cite_start]$$\min \sum_{d \in Depots} (build[d] \cdot fix\_cost[d] + size[d] \cdot prop\_cost[d]) \quad \text{[cite: 7]}$$

***

Would you like to analyze a specific constraint or variable, or perhaps see how to formulate a similar problem?This task appears to be a **Mixed-Integer Linear Programming (MILP)** problem designed to optimize a gym workout plan.

The goal is to determine the optimal number of repetitions for each exercise to minimize the total training time, while ensuring that the total "effect" on each muscle group stays within specified minimum and maximum limits.

Here is a breakdown of the components:

### 🏋️ Optimization Goal
* [cite_start]**Minimize Total Training Time:** The objective is to minimize the total time spent exercising[cite: 10]. [cite_start]This is calculated by multiplying the number of repetitions for each exercise by its corresponding duration and summing these values[cite: 10, 3, 6].
    * **Objective Function:**
        $$\min \sum_{e \in \text{Exercise}} \text{repetition}[e] \times \text{duration}[e]$$

### 💪 Variables
* [cite_start]**`repetition{Exercise}`:** The core decision variable, representing the number of times each exercise will be performed[cite: 7, 8].
    * [cite_start]It must be **non-negative** and an **integer**[cite: 8].

### 📝 Data and Parameters

* **Sets:**
    * [cite_start]**`Musclegroup`:** The set of muscle groups being targeted (e.g., chest, abdomen, biceps, back)[cite: 1, 6].
    * [cite_start]**`Exercise`:** The set of available exercises (e.g., curl, benchpress, squat, plank, latpull, legpress)[cite: 1, 6].
* **Parameters:**
    * [cite_start]**`effect{Exercise, Musclegroup}`:** The "effect" or effectiveness of one repetition of a specific exercise on a specific muscle group (e.g., the effect of `curl` on the `chest` is 1.29)[cite: 2, 6].
    * [cite_start]**`duration{Exercise}`:** The time taken to perform one repetition of a specific exercise (in time units, presumably seconds or minutes)[cite: 3, 6].
    * [cite_start]**`min_effect{Musclegroup}`:** The minimum required total effect that must be achieved for each muscle group[cite: 4, 7].
    * [cite_start]**`max_effect{Musclegroup}`:** The maximum allowed total effect for each muscle group[cite: 5, 7].

### 🚧 Constraints
The constraints ensure the workout provides adequate, but not excessive, stimulation to each muscle group:

1.  [cite_start]**Minimum Effect Constraint (`Min_effect_for_musclegroups`):** For every muscle group, the sum of the effects of all repetitions must be greater than or equal to the minimum required effect[cite: 8].
    * $$\sum_{e \in \text{Exercise}} \text{repetition}[e] \times \text{effect}[e,m] \ge \text{min\_effect}[m] \quad \forall m \in \text{Musclegroup}$$

2.  [cite_start]**Maximum Effect Constraint (`Max_effect_for_musclegroups`):** For every muscle group, the sum of the effects of all repetitions must be less than or equal to the maximum allowed effect[cite: 9].
    * $$\sum_{e \in \text{Exercise}} \text{repetition}[e] \times \text{effect}[e,m] \le \text{max\_effect}[m] \quad \forall m \in \text{Musclegroup}$$

Would you like me to find the optimal number of repetitions for each exercise based on the provided data?[cite_start]A feladat a Győr Sziget városrészében tartandó karácsonyi vásár és rendezvénysorozat kapcsán létesítendő **10 darab belvárosi buszjárat útvonalának optimalizálása**[cite: 1, 2, 7].

[cite_start]A járatok a Rába és a Mosoni-Duna túloldalán lévő állomásokról indulnak a Sziget célpontjai felé[cite: 3]. [cite_start]Az útvonalak a kiindulópont (start) és a célállomás (cél) közötti, folyón átívelő hidak igénybevételével állnak össze[cite: 7].

### 🎯 Cél
[cite_start]Az útvonalakat úgy kell meghatározni, hogy **a járatok úthosszainak összege minimális legyen**[cite: 7].

### 🚧 Korlátok
1.  [cite_start]**Hídkapacitás:** A két oldal között három híd (Jedlik híd, Rába kettős híd, Petőfi híd) kapacitása limitálja, hogy hány buszjárat használhatja az adott hidat[cite: 4, 5].
    * [cite_start]Jedlik Híd kapacitása: 7 járat [cite: 92]
    * [cite_start]Rába Kettős Híd kapacitása: 3 járat [cite: 92]
    * [cite_start]Petőfi Híd kapacitása: 3 járat [cite: 92]
2.  [cite_start]**Egy járat – egy híd:** Minden járatnak pontosan egy hidat kell használnia[cite: 82].
3.  [cite_start]**Kossuth híd:** A Dunakapu tér melletti Kossuth híd kapacitása korlátlannak tekintendő (de ez a modellben nincs direktben kezelve, csak a három híd)[cite: 6].

### 📝 Elvárt Kimenet
A megoldásnak ki kell írnia:
* [cite_start]Az egyes járatok útvonalait (**start - híd - cél**)[cite: 8].
* [cite_start]Az útvonalak **össztávolságát**[cite: 8].

---

### ⭐ Szorgalmi Feladat (Megerősítve a modellfájlban)
[cite_start]Az egyik hidat le kell zárni az utcavásár miatt[cite: 9, 10].
* [cite_start]**Döntés:** El kell dönteni, hogy **melyik híd legyen lezárva** (azaz hol nem járhat busz)[cite: 10, 11].
* [cite_start]**Optimalizálás:** Az optimalizálási modellnek kell meghoznia ezt a döntést[cite: 11].
* [cite_start]**Kimenet:** A lezárt hidat jelezni kell a kimeneten[cite: 11, 87].

[cite_start]Ez a szorgalmi feladat a **Jedlik híd, Kettős híd, és Petőfi híd** közül választ egyet, amelyet lezár[cite: 89, 84].

[cite_start]**A modell (hidak.mod) ezen szorgalmi feladattal együtt, egy hidat lezárva optimalizál.** [cite: 84, 85]

Szeretnéd, hogy kiszámoljam a járatok útvonalait és az össztávolságot a megadott adatok alapján, figyelembe véve a szorgalmi feladatot is?[cite_start]A feladat a Győr Sziget városrészében tartandó karácsonyi vásár és rendezvénysorozat kapcsán létesítendő **10 darab belvárosi buszjárat útvonalának optimalizálása**[cite: 1, 2, 7].

[cite_start]A járatok a Rába és a Mosoni-Duna túloldalán lévő állomásokról indulnak a Sziget célpontjai felé[cite: 3]. [cite_start]Az útvonalak a kiindulópont (start) és a célállomás (cél) közötti, folyón átívelő hidak igénybevételével állnak össze[cite: 7].

### 🎯 Cél
[cite_start]Az útvonalakat úgy kell meghatározni, hogy **a járatok úthosszainak összege minimális legyen**[cite: 7].

### 🚧 Korlátok
1.  [cite_start]**Hídkapacitás:** A két oldal között három híd (Jedlik híd, Rába kettős híd, Petőfi híd) kapacitása limitálja, hogy hány buszjárat használhatja az adott hidat[cite: 4, 5].
    * [cite_start]Jedlik Híd kapacitása: 7 járat [cite: 92]
    * [cite_start]Rába Kettős Híd kapacitása: 3 járat [cite: 92]
    * [cite_start]Petőfi Híd kapacitása: 3 járat [cite: 92]
2.  [cite_start]**Egy járat – egy híd:** Minden járatnak pontosan egy hidat kell használnia[cite: 82].
3.  [cite_start]**Kossuth híd:** A Dunakapu tér melletti Kossuth híd kapacitása korlátlannak tekintendő (de ez a modellben nincs direktben kezelve, csak a három híd)[cite: 6].

### 📝 Elvárt Kimenet
A megoldásnak ki kell írnia:
* [cite_start]Az egyes járatok útvonalait (**start - híd - cél**)[cite: 8].
* [cite_start]Az útvonalak **össztávolságát**[cite: 8].

---

### ⭐ Szorgalmi Feladat (Megerősítve a modellfájlban)
[cite_start]Az egyik hidat le kell zárni az utcavásár miatt[cite: 9, 10].
* [cite_start]**Döntés:** El kell dönteni, hogy **melyik híd legyen lezárva** (azaz hol nem járhat busz)[cite: 10, 11].
* [cite_start]**Optimalizálás:** Az optimalizálási modellnek kell meghoznia ezt a döntést[cite: 11].
* [cite_start]**Kimenet:** A lezárt hidat jelezni kell a kimeneten[cite: 11, 87].

[cite_start]Ez a szorgalmi feladat a **Jedlik híd, Kettős híd, és Petőfi híd** közül választ egyet, amelyet lezár[cite: 89, 84].

[cite_start]**A modell (hidak.mod) ezen szorgalmi feladattal együtt, egy hidat lezárva optimalizál.** [cite: 84, 85]

Szeretnéd, hogy kiszámoljam a járatok útvonalait és az össztávolságot a megadott adatok alapján, figyelembe véve a szorgalmi feladatot is?[cite_start]The provided files define and provide data for an **Assignment Problem**[cite: 1, 7].

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

Would you like me to solve this assignment problem based on the provided model and data?Hello! Based on the provided `.dat` and `.mod` files, the task described is a classic **Transportation Problem** in linear programming.

Here is a breakdown of the components:

### 🚛 Transportation Problem Details

The goal is to determine the optimal way to transport goods from a set of **Sources** to a set of **Destinations** while minimizing the total transportation cost.

* [cite_start]**Objective (Minimize):** The total transportation cost[cite: 7]. [cite_start]This is calculated by multiplying the $distance$ between each Source and Destination by the $transport$ quantity for that route and summing them all up[cite: 7].

* [cite_start]**Decision Variables:** The quantity of goods to $transport$ from each Source ($s$) to each Destination ($d$), denoted as $transport[s,d]$, where the quantity must be non-negative[cite: 4].

### 📝 Key Constraints and Data

| Component | Set/Parameter | Description | Constraint |
| :--- | :--- | :--- | :--- |
| **Sources** | `Sources` | [cite_start]The origins of the goods (A, B, C)[cite: 1]. | |
| **Capacity** | `capacity{s}` | [cite_start]The maximum supply available at each Source (A: 50, B: 150, C: 250)[cite: 1]. | [cite_start]The total quantity of goods shipped *from* any Source ($s$) must be less than or equal to its capacity[cite: 5]. |
| **Destinations** | `Destinations` | [cite_start]The required endpoints for the goods (D, E, F, G)[cite: 2]. | |
| **Demand** | `demand{d}` | [cite_start]The required amount of goods at each Destination (D: 75, E: 125, F: 130, G: 120)[cite: 2]. | [cite_start]The total quantity of goods received *at* any Destination ($d$) must be greater than or equal to its demand[cite: 6]. |
| **Cost/Distance** | `distance{s,d}` | [cite_start]The cost (represented by distance) to transport one unit of goods from Source $s$ to Destination $d$[cite: 3, 4]. | [cite_start]Used in the objective function to calculate the total cost[cite: 7]. |

The model aims to find the values for $transport[s,d]$ that satisfy all capacity and demand constraints while resulting in the lowest possible total transportation cost.

---
Would you like to know the total supply and demand to check if the problem is balanced?## 📝 Task Description: Currency Exchange Optimization

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

[cite_start]Would you like me to identify the most volatile currency based on the provided dollar values[cite: 3]?The provided files describe a **Minimum Completion Time Job Assignment Problem**, which is modeled as a **Mixed-Integer Linear Programming (MILP)** problem.

---

## 💾 Data File (`data.dat`)

The data file defines the sets of workers and jobs, and the time (in hours) each person takes to complete each job.

* [cite_start]**Sets Defined[cite: 1]:**
    * **People:** Three workers: **Julcsi**, **Balazs**, and **Erno**.
    * **Jobs:** Twenty jobs labeled **F1** through **F20**.
* [cite_start]**Parameter Defined[cite: 2]:**
    * **`hours`:** A table showing the time required (in hours) for each person to complete each job. [cite_start]For example, Julcsi takes 11.38 hours for job F1, Balazs takes 8.17 hours, and Erno takes 3.79 hours[cite: 2].

---

## 🛠️ Model File (`milp.mod`)

The model file defines the objective and constraints for the MILP problem. The goal is to minimize the time until the very last job is completed by any person, often called the **makespan**.

### 1. Variables

* [cite_start]**`do{Jobs,People}`:** A **binary variable** (0 or 1)[cite: 3].
    * $do[j, p] = 1$ if person $p$ is assigned to job $j$.
    * $do[j, p] = 0$ otherwise.
* [cite_start]**`work_hours{People}`:** A non-negative continuous variable representing the **total working hours** for each person $p$[cite: 3].
* [cite_start]**`finish_time`:** A non-negative continuous variable representing the **time the last person finishes their assigned work** (the makespan)[cite: 3].

### 2. Constraints

* [cite_start]**Every Job Must Be Done By One Person[cite: 4]:**
    $$\sum_{p \in \text{People}} do[j, p] = 1 \quad \forall j \in \text{Jobs}$$
    [cite_start]This ensures that every job $j$ is assigned to exactly one person $p$[cite: 4].

* [cite_start]**Calculate Work Hours[cite: 5]:**
    $$work\_hours[p] = \sum_{j \in \text{Jobs}} hours[j, p] \times do[j, p] \quad \forall p \in \text{People}$$
    [cite_start]This constraint calculates the total work time for each person $p$ by summing the hours of all jobs assigned to them[cite: 5].

* [cite_start]**Set Finish Time[cite: 6]:**
    $$finish\_time \geq work\_hours[p] \quad \forall p \in \text{People}$$
    [cite_start]This forces the `finish_time` variable to be greater than or equal to the total work hours of *every* person[cite: 6].

### 3. Objective

* **Minimize Finish Time:**
    $$\text{Minimize} \quad finish\_time$$
    [cite_start]Since `finish_time` must be greater than or equal to the maximum total work hours of any person (the bottleneck), minimizing this variable minimizes the **maximum completion time** (the makespan) for the entire set of jobs[cite: 6].

Would you like to know the **optimal assignment** of jobs to people and the minimum finish time?This is a description of a **classic transportation problem** modeled using the **AMPL (A Mathematical Programming Language)** system.

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

# Döntéstámogató rendszerek ZH - Nyílt nap treasure hunt
2023.12.07.

A Soproni Egyetem nyílt napján kincsvadászatot szervezünk az érdeklődő középiskolásoknak. A játék lényege, hogy minden feladat megoldása egy clue-t tartalmaz, ami alapján a diákok el tudnak menni a kampusz (és a környék) egy más pontjára, ahol egy újabb feladat vár rájuk. Az utolsó feladat megoldása után a diákoknak vissza kell térnie a GT épületbe, ahol a megoldásokat bemutatva megkapják a jutalmukat.

Számunkra adott a helyszínek listája (sorrenddel együtt), illetve hogy ott milyen típusú feladat vár majd a diákokra. Korábban felmértük a résztvevő diákok gyaloglási és feladatmegoldási sebességét feladattípusonként. Amit meghatározhatunk, az az egyes pontokon a feladatok nehézségi szintje annak érdekében, hogy minél közelebb legyenek időben egymáshoz a teljesítések, és senki ne csússzon ki a 3 órás időkeretből. 

# Adatok

Hallgatók: András, Béla, Cili, Dani, Eszter, Fanni, Gábor, Hanna

Feladattípusok: kódfejtés, grafilogika, puzzle, Einstein feladvány, szókereső

Pontok, feladattípusok és távolságok a következő pontig:
- GT épület (rajt) - kódfejtés - 300 m
- Ligneum - grafilogika - 500 m
- Csille - puzzle - 400 m
- RK/UK - Einstein feladvány - 2600 m
- Sörház dombi kilátó - kódfejtés - 1000 m
- AMI - grafilogika - 1500 m
- BPK - szókereső - 1800 m 
- LKK - puzzle - 1500 m

A feladatok nehézségi szintjei 1-10 közötti egész számok lehetnek.

A résztvevő hallgatók adatai:

| Hallgató | Gyaloglási sebesség (km/h) | Kódfejtés (perc) | Grafilogika (perc) | Puzzle (perc) | Einstein feladvány (perc) | Szókereső (perc) |
|----------|---------------------------|------------------|--------------------|---------------|---------------------------|------------------|
| András   | 4                         | 5                | 10                 | 15            | 20                        | 25               |
| Béla     | 5                         | 10               | 15                 | 20            | 25                        | 30               |
| Cili     | 4.5                       | 15               | 20                 | 25            | 30                        | 35               |
| Dani     | 5.5                       | 10               | 5                  | 20            | 25                        | 15               |
| Eszter   | 4.5                       | 5                | 20                 | 15            | 15                        | 25               |
| Fanni    | 5                         | 10               | 15                 | 20            | 25                        | 30               |
| Gábor    | 5.5                       | 15               | 20                 | 25            | 30                        | 35               |
| Hanna    | 4                         | 15               | 10                 | 15            | 20                        | 10               |




A feladvány megoldási sebességet úgy kell érteni, hogy hogy egy közepes, 5-ös szintíű feladat megoldásához mennyi időre van szükségük. Minden további szint 10%-kal növeli a megoldási időt, és lefele minden szint ennyivel csökkenti. Például egy 7-es szintű feladat megoldásához 20%-kal több időre van szükség, mint egy 5-ös szintű feladat megoldásához.

A rendelkezésre álló idő 5 óra.

# Szorgalmi feladatok
 - Mi dönthetjük el, hogy melyik ponton milyen feladatok legyenek, minden feladattípusnak szerepelnie kell, és két egymást követő ponton nem lehet ugyanaz a feladat.
 - 5 percenként indítjuk a hallgatókat adott sorrendben, és az a cél, hogy minimális legyen az átfedési idő a pontokon / minden pontnak adott a kapcitása, és egyszerre nem lehet ott több ember.
 - Az indítás sorrendjét is mi határozzuk meg.
 - A pontok sorrendjét is mi határozzuk meg.
 - A pontok sorrendje változhat személyenként.## 📝 Model Description Comparison

[cite_start]The two optimization models, **xfactor.mod** and **xfactor2.mod**, are designed to maximize revenue from SMS votes in a talent show by strategically choosing which two contestants *duel* (párbajoznak) each week and who gets eliminated (*kiesik*)[cite: 7, 31]. [cite_start]The revenue for a round comes from the total SMS supporters of the two contestants who duel[cite: 5, 29, 22, 49].

Both models share many core constraints, ensuring the integrity and structure of the competition:

* [cite_start]**Contestants and Rounds:** Both models define the set of contestants (`Versenyzok`) and the rounds (`Fordulok`)[cite: 1, 11, 35, 36].
    * [cite_start]*Note:* The data file **xfactor.dat** specifies 6 contestants, meaning there will be 5 rounds ($\text{card(Versenyzok)} - 1$)[cite: 1, 11, 36].
* [cite_start]**Dueling and Elimination:** In every round, exactly **two** contestants must duel [cite: 14, 39][cite_start], and exactly **one** contestant must be eliminated[cite: 15, 40].
* [cite_start]**Relationship:** Only a contestant who duels can be eliminated[cite: 13, 38].
* [cite_start]**Survival:** A contestant can be eliminated only once[cite: 16, 41].
* [cite_start]**Exclusion:** Once a contestant is eliminated, they cannot duel in subsequent rounds[cite: 17, 18, 19, 42, 43, 44].
* [cite_start]**Objective:** Maximize the total SMS revenue, calculated as the sum of SMS supporters of all dueling contestants across all rounds[cite: 7, 22, 31, 49].

---

## ⚖️ Key Difference: Elimination Rule

The models differ critically in the rule governing which of the two dueling contestants is eliminated.

### 1. **xfactor2.mod (Scenario 1: TV Club Rules)**

* [cite_start]This model adheres to the **"TV-Klub" public rules**[cite: 2, 3, 4, 5].
* [cite_start]**Rule:** The contestant with the **fewer** pre-surveyed SMS supporters *must* be the one who is eliminated when two contestants duel[cite: 5, 29, 21].
* [cite_start]**Constraint:** The model includes a constraint (`A_kevesebb_smssel_rendelkezo_essen_ki`) that enforces the elimination of the less popular contestant based on the `sms` parameter[cite: 20, 21]. [cite_start]The logic is: if $v_1$ and $v_2$ duel and $\text{sms}[v_1] > \text{sms}[v_2]$, then $v_2$ must be eliminated ($\text{kiesik}[v_2, f] = 1$)[cite: 20, 21].

### 2. **xfactor.mod (Scenario 2: Full Control)**

* [cite_start]This model utilizes the **non-public "business model"** where the producers have full control over the results[cite: 30].
* [cite_start]**Rule:** The producers can arbitrarily decide who the two dueling contestants are, **and** which of them is eliminated, **regardless** of their popularity (SMS supporter count)[cite: 30].
* **Constraint:** The model **lacks** the `A_kevesebb_smssel_rendelkezo_essen_ki` constraint.

---

## 🚫 Additional Constraint in xfactor.mod

[cite_start]Because **xfactor.mod** gives the producers the power to save less popular contestants, it introduces an extra constraint **for the sake of appearances** (`A látszat érdekében`)[cite: 34]:

* [cite_start]**Rule:** No contestant can survive (win a duel) more than **twice**[cite: 34, 47, 48].
* [cite_start]**Constraint:** The constraint `Mindenki_legfeljebb_ketszer_nyerhet` limits the number of times a contestant can duel and *not* be eliminated to a maximum of 2[cite: 47, 48].
    * [cite_start]$\sum_{f \in \text{Fordulok}} (\text{parbajozik}[v,f] - \text{kiesik}[v,f]) \le 2$[cite: 48].
* [cite_start]A related constraint is also included to ensure that if a contestant duels a third time, they *must* be eliminated (`Ha_harmadjara_parbajozik_akkor_ki_kell_esnie`)[cite: 37, 45, 46].

---

| Feature | xfactor.mod (Full Control) | xfactor2.mod (TV Club Rules) |
| :--- | :--- | :--- |
| **SMS/Elimination Rule** | [cite_start]Producers decide who is eliminated, regardless of SMS count[cite: 30]. | [cite_start]The contestant with the *fewer* SMS supporters **must** be eliminated[cite: 5, 21]. |
| **Max Duels Won** | [cite_start]Maximum 2 times per contestant[cite: 34, 48]. | **No** explicit limit on wins/survivals. |
| **Constraint on Elimination** | **No** constraint tying elimination to popularity. | [cite_start]**Includes** `A_kevesebb_smssel_rendelkezo_essen_ki`[cite: 21]. |
| **Constraint on Wins** | [cite_start]**Includes** `Mindenki_legfeljebb_ketszer_nyerhet` and `Ha_harmadjara_parbajozik_akkor_ki_kell_esnie`[cite: 46, 48]. | **No** such constraints. |## 📝 Model Description Comparison

[cite_start]The two optimization models, **xfactor.mod** and **xfactor2.mod**, are designed to maximize revenue from SMS votes in a talent show by strategically choosing which two contestants *duel* (párbajoznak) each week and who gets eliminated (*kiesik*)[cite: 7, 31]. [cite_start]The revenue for a round comes from the total SMS supporters of the two contestants who duel[cite: 5, 29, 22, 49].

Both models share many core constraints, ensuring the integrity and structure of the competition:

* [cite_start]**Contestants and Rounds:** Both models define the set of contestants (`Versenyzok`) and the rounds (`Fordulok`)[cite: 1, 11, 35, 36].
    * [cite_start]*Note:* The data file **xfactor.dat** specifies 6 contestants, meaning there will be 5 rounds ($\text{card(Versenyzok)} - 1$)[cite: 1, 11, 36].
* [cite_start]**Dueling and Elimination:** In every round, exactly **two** contestants must duel [cite: 14, 39][cite_start], and exactly **one** contestant must be eliminated[cite: 15, 40].
* [cite_start]**Relationship:** Only a contestant who duels can be eliminated[cite: 13, 38].
* [cite_start]**Survival:** A contestant can be eliminated only once[cite: 16, 41].
* [cite_start]**Exclusion:** Once a contestant is eliminated, they cannot duel in subsequent rounds[cite: 17, 18, 19, 42, 43, 44].
* [cite_start]**Objective:** Maximize the total SMS revenue, calculated as the sum of SMS supporters of all dueling contestants across all rounds[cite: 7, 22, 31, 49].

---

## ⚖️ Key Difference: Elimination Rule

The models differ critically in the rule governing which of the two dueling contestants is eliminated.

### 1. **xfactor2.mod (Scenario 1: TV Club Rules)**

* [cite_start]This model adheres to the **"TV-Klub" public rules**[cite: 2, 3, 4, 5].
* [cite_start]**Rule:** The contestant with the **fewer** pre-surveyed SMS supporters *must* be the one who is eliminated when two contestants duel[cite: 5, 29, 21].
* [cite_start]**Constraint:** The model includes a constraint (`A_kevesebb_smssel_rendelkezo_essen_ki`) that enforces the elimination of the less popular contestant based on the `sms` parameter[cite: 20, 21]. [cite_start]The logic is: if $v_1$ and $v_2$ duel and $\text{sms}[v_1] > \text{sms}[v_2]$, then $v_2$ must be eliminated ($\text{kiesik}[v_2, f] = 1$)[cite: 20, 21].

### 2. **xfactor.mod (Scenario 2: Full Control)**

* [cite_start]This model utilizes the **non-public "business model"** where the producers have full control over the results[cite: 30].
* [cite_start]**Rule:** The producers can arbitrarily decide who the two dueling contestants are, **and** which of them is eliminated, **regardless** of their popularity (SMS supporter count)[cite: 30].
* **Constraint:** The model **lacks** the `A_kevesebb_smssel_rendelkezo_essen_ki` constraint.

---

## 🚫 Additional Constraint in xfactor.mod

[cite_start]Because **xfactor.mod** gives the producers the power to save less popular contestants, it introduces an extra constraint **for the sake of appearances** (`A látszat érdekében`)[cite: 34]:

* [cite_start]**Rule:** No contestant can survive (win a duel) more than **twice**[cite: 34, 47, 48].
* [cite_start]**Constraint:** The constraint `Mindenki_legfeljebb_ketszer_nyerhet` limits the number of times a contestant can duel and *not* be eliminated to a maximum of 2[cite: 47, 48].
    * [cite_start]$\sum_{f \in \text{Fordulok}} (\text{parbajozik}[v,f] - \text{kiesik}[v,f]) \le 2$[cite: 48].
* [cite_start]A related constraint is also included to ensure that if a contestant duels a third time, they *must* be eliminated (`Ha_harmadjara_parbajozik_akkor_ki_kell_esnie`)[cite: 37, 45, 46].

---

| Feature | xfactor.mod (Full Control) | xfactor2.mod (TV Club Rules) |
| :--- | :--- | :--- |
| **SMS/Elimination Rule** | [cite_start]Producers decide who is eliminated, regardless of SMS count[cite: 30]. | [cite_start]The contestant with the *fewer* SMS supporters **must** be eliminated[cite: 5, 21]. |
| **Max Duels Won** | [cite_start]Maximum 2 times per contestant[cite: 34, 48]. | **No** explicit limit on wins/survivals. |
| **Constraint on Elimination** | **No** constraint tying elimination to popularity. | [cite_start]**Includes** `A_kevesebb_smssel_rendelkezo_essen_ki`[cite: 21]. |
| **Constraint on Wins** | [cite_start]**Includes** `Mindenki_legfeljebb_ketszer_nyerhet` and `Ha_harmadjara_parbajozik_akkor_ki_kell_esnie`[cite: 46, 48]. | **No** such constraints. |# Optimalizálási ismeretek ZH
2024.11.26.

## Elméleti kérdések

 - Hány fázisa van a szimplex módszernek?
 - Milyen relációk megengedettek MILP modellek korlátozásaiban, amik LP-ben nem?
 - Milyen veszélye van, ha az big `M` értéket túl nagyra választjuk?
 - Igaz / Hamis?
    * LP modellnek lehet pontosan megszámlálhatóan végtelen optimális megoldása.
    * MILP modellnek lehet pontosan 2 optimális megoldása.
    * A szimplex harmadik fázisa a megtalált optimális megoldás mellé második optimális megoldást keres.
    * A `solve;` előtt nem szerepelhetnek a változók értékeire vonatkozó szűrések.

## Gyakorlati feladat: Dalriada set list

A méltán híres soproni banda, Dalriada következő koncertjén eljátszandó számok listáját kell összeállítanunk. A koncert mindenképpen 10 számból fog állni, és a hosszának 60 és 80 perc közöttinek kell lennie, a számok között fél percnyi szünettel. 

Minden számról ismert a hossza, a népszerűsége, valamint hogy a banda mely tagjai számára "megterhelő" eljátszani. A célunk, hogy az eljátszott számok össznépszerűsége minél több legyen, de nem követhet egymást három szám úgy, hogy bármelyik zenész/énekes számára mindegyik nehéz legyen.

<table>
    <tr>
        <td rowspan = 3>Szám</td>
        <td rowspan = 3>Hossz</td>
        <td rowspan = 3>Popularitás</td>
        <td rowspan = 3>Album</td>
        <td colspan = 6>Nehézség</td>
    </tr>
    <tr>
        <td>Ficzek András</td>
        <td>Binder Laura</td>
        <td>Németh-Szabó Mátyás</td>
        <td>Molnár István </td>
        <td>Szabó „Szög” Gergely </td>
        <td>Monostori Ádám</td>
    </tr>
    <tr>
        <td>ének, gitár</td>
        <td>ének</td>
        <td>gitár</td>
        <td>basszusgitár</td>
        <td>billentyűs hangszerek</td>
        <td>dob</td>
    </tr>
    <tr>
        <td>A walesi bárdok</td>
        <td>18:40</td>
        <td>61</td>
        <td>Fergeteg</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Téli ének</td>
        <td>5:50</td>
        <td>100</td>
        <td>Jégbontó</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Hajdútánc</td>
        <td>4:58</td>
        <td>87</td>
        <td>Ígéret</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Táltosének</td>
        <td>4:55</td>
        <td>55</td>
        <td>Kikelet</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Virrasztó</td>
        <td>4:50</td>
        <td>70</td>
        <td>Jégbontó</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Hamu és Gyász</td>
        <td>5:51</td>
        <td>87</td>
        <td>Áldás</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Ágnes Asszony</td>
        <td>13:21</td>
        <td>58</td>
        <td>Arany-album</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Napisten hava</td>
        <td>6:44</td>
        <td>58</td>
        <td>Napisten hava</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Galamb</td>
        <td>5:41</td>
        <td>91</td>
        <td>Mesék, Álmok, Regék</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Táltosok álma</td>
        <td>7:32</td>
        <td>71</td>
        <td>Nyárutó</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Tavaszköszöntő</td>
        <td>3:19</td>
        <td>54</td>
        <td>Szelek</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Tűzhozó</td>
        <td>4:00</td>
        <td>66</td>
        <td>Kikelet</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Kinizsi mulatsága</td>
        <td>4:19</td>
        <td>40</td>
        <td>Ígéret</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Hajnalpír</td>
        <td>4:24</td>
        <td>65</td>
        <td>Szelek</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Borivók éneke</td>
        <td>4:33</td>
        <td>57</td>
        <td>Napisten hava</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Világfa</td>
        <td>4:42</td>
        <td>86</td>
        <td>Áldás</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Betyár-altató</td>
        <td>6:24</td>
        <td>90</td>
        <td>Őszelő</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
    </tr>
    <tr>
        <td>Huszáros</td>
        <td>6:15</td>
        <td>77</td>
        <td>Őszelő</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>A Dudás</td>
        <td>5:32</td>
        <td>87</td>
        <td>Napisten hava</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Hazatérés</td>
        <td>4:43</td>
        <td>56</td>
        <td>Forrás</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
    </tr>
</table># Optimalizálási ismeretek pótZH
2024.12.13.


## Gyakorlati feladat: Erdős Pál Tehetséggondozó hétvége órarend

Az [Erdős Pál Matematikai Tehetséggondozó ](https://erdosprogram.hu/) több hétvégén tart matematika iránt érdeklődő középiskolás diákoknak versenyekre felkészítő foglalkozásokat Veszprémben. Minen hétvégén minden évfolyamnak 7 db másfél órás foglalkozást tartanak a program tanárai. Minden hétvégén mások az előadások, illetve minden oktatónak megvan a saját szakterülete, azaz hogy milyen témákban tud órát tartani.

A következő, januári hétvége előadásai, a hozzá tartozó oktatók, valamint a tábor programja lentebb megtalálhatók.

A cél olyan órarend készítése, ahol minimális az oktatók elszállásolásából fakadó költség. A PE központi kollégiumban egy éjszakára fejenként a szállás 15000 HUF. Értelemszerűen: 
 - Egy oktató nem száll meg, ha csak egy nap vannak órái. 
 - Ha minden órája két egymást követő nap van, akkor 1 éjszakát kell elszállásolni.
 - Ha pénteken és vasárnap is van órája, akkor 2 éjszakát kell fizetni.

Feltételezhető, hogy se a diákok, se az oktatók nem tudnak osztódni, és [ilyenje](https://harrypotter.fandom.com/wiki/Time-Turner) sincs senkinek.

### Tábor programja

**PÉNTEK**

 * 12.00 – 14.00 Érkezés a kollégiumba, regisztráció 
 * 14.00 – 14.25 Rövid megbeszélés a foglalkozások helyszínén 
 * 14.30 – 16.00 Órarend szerinti foglalkozások.
 * 16.30 – 18.00 Órarend szerinti foglalkozások.        
 * 18.00 – 18.30 Vacsora                      
 * 18.30 – 20.00 Öntevékeny klubfoglalkozás, szabadidő.
 * 20.00 – 21.30 Filmklub, a film címe: Macskafogó         
 * 21.30 – 22.30 Készülődés a lefekvéshez.    
 * 22.30               Takarodó

**SZOMBAT**

 * 7.00 –   7.45 Reggeli          
 * 8.30 – 10.00 Órarend szerinti foglalkozások.        
 * 10.30 – 12.00 Órarend szerinti foglalkozások.       
 * 12.00 – 12.45 Ebéd              
 * 12.45 – 16.30 Szabad program, ennek keretében jó idő esetén
 * 13.25 – 14.40 Séta a városban       
 * 16.30 – 18.00 Órarend szerinti foglalkozások.
 * 18.10 – 18.45 Vacsora          
 * 18.45 – 22.00 Öntevékeny klubfoglalkozás, játék.
 * 19.30 – 20.30 Kvíz játék          
 * 22.00 – 22.30 Készülődés a lefekvéshez      
 * 22.30               Takarodó

**VASÁRNAP**

 * 7.00 –   7.45 Reggeli          
 * 8.00 –   9.30 Órarend szerinti foglalkozások         
 * 9.45 – 11.15 Órarend szerinti foglalkozások         
 * 11.30 –          Ebéd, hazautazás

### Előadás tematikák

| 9. osztály| |
| --- | --- |
| Hasznos háromszög-geometriai ismeretek | Kubatov Antal | 
| Háromszögek egybevágóságával kapcsolatos feladatok | Sagmeister Ádám |
| Diofantoszi egyenletek  | Kiss Géza |
| Mersenne prímek, tökéletes számok | Katz Sándor |
| Egyenlőtlenségek| Ábrahám Gábor |
| Toricelli pont, talpponti háromszög  | Árki Tamás |
| Logikai feladatok| Hegyháti Máté |


| 10. osztály| |
| --- | --- |
| Magasabb fokú algebrai egyenletek  | Mészáros Anna |
| Gráfok 1. | Erdős Gábor |
| Vektorok 3. | Pintér Ferenc |
| Diofantoszi egyenletek  | Kiss Géza |
| Algebrai szélsőérték feladatok  | Éles András |
| Párhuzamos szelők, ...., szögfelező tétel | Fonyó Lajos |
| Rendezési egyenlőtlenség  | Kocsis Szilveszter |


| 11. osztály| |
| --- | --- |
| Cauchy-egyenlőtlenség  | Sagmeister Ádám |
| Egyenlőtlenségek | Sagmeister Ádám |
| Kombinatorikai feladatok | Hegyháti Máté|
| Skaláris szorzat geometriai alkalmazás | Kocsis Szilveszter |
| Gráfok csúcsainak színezése| Erdős Gábor |
| Komplex számok trigonometrikus alakja  | Kiss Géza |
| Hasonlósággal kapcsolatos geometriai feladatok  | Éles András |


| 12. osztály| |
| --- | --- |
| Csomszkij tétel és alkalmazásai | Erdős Gábor |
| Jensen egyenlőtlenség | Ábrahám Gábor |
| Koordinátageometriai módszerek | Kubatov Antal |
| Vektoriális szorzás  | Kocsis Szilveszter |
| Kúpszeletek érintői  | Árki Tamás |
| Síkbeli feladatok térben  | Fonyó Lajos |
| Szimmediánok 2. | Katz Sándor|


# Bónusz feladat

Legyen paraméterezhető, hogy melyik évfolyamból hány párhuzamos csoport van.The files you've provided relate to an optimization problem concerning the creation of a setlist for a Dalriada concert.

[cite_start]The problem, outlined in the Hungarian document (`zh.md`), is to create a concert setlist of **10 songs** (`setLength = 10` in `tracklist.mod` [cite: 20]) with the following constraints and objective:

### 🎸 Concert Constraints & Objective

* [cite_start]**Set Length:** Exactly 10 songs[cite: 20].
* [cite_start]**Duration:** The total concert duration must be between **60 and 80 minutes**[cite: 21, 23].
    * [cite_start]The duration includes a **30-second break** between songs[cite: 20, 21, 23].
    * [cite_start]60 minutes = 3600 seconds ($\text{minDuration}$ [cite: 20]).
    * [cite_start]80 minutes = 4800 seconds ($\text{maxDuration}$ [cite: 21]).
* [cite_start]**Song Usage:** Each song can be played at most once[cite: 25].
* [cite_start]**Difficulty/Fatigue:** No three consecutive songs can be "difficult" (a difficulty value of 1) for **any** musician[cite: 24]. [cite_start]This is enforced by setting `max_difficult` for all musicians to 2[cite: 21].
* [cite_start]**Objective:** **Maximize** the total popularity of the selected songs[cite: 26].

### 📝 Data Overview

The data contains information about 6 musicians and 20 songs:

* [cite_start]**Musicians**[cite: 1]:
    * Andras, Laura, Matyas, Istvan, Szog, Adam.
* [cite_start]**Songs**[cite: 1]:
    * 20 songs, including "Teli\_enek", "Galamb", "Huszaros", etc.
* [cite_start]**Song Parameters**[cite: 2, 3, 4, 5, 6]:
    * [cite_start]`duration` (in seconds): E.g., "A\_walesi\_bardok" is 1120s[cite: 2].
    * [cite_start]`popularity` (unitless): E.g., "Teli\_enek" is 100[cite: 2].
* [cite_start]**Difficulty Parameter**[cite: 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]:
    * Binary value (1 = difficult, 0 = not difficult) for each Song and Musician. [cite_start]E.g., "Teli\_enek" is difficult (1) for Andras, Laura, and Matyas[cite: 7, 8].

### ✅ Optimal Solution (`dalriada.txt`)

The file `dalriada.txt` shows the optimal setlist found by the optimization model:

* [cite_start]**Total Popularity:** 846[cite: 18].
* **Setlist:**
    1.  [cite_start]Galamb (5:41, Popularity 91) [cite: 18]
    2.  [cite_start]Taltosok\_alma (7:32, Popularity 71) [cite: 18]
    3.  [cite_start]A\_Dudas (5:32, Popularity 87) [cite: 18]
    4.  [cite_start]Hajdutanc (4:58, Popularity 87) [cite: 18]
    5.  [cite_start]Teli\_enek (5:50, Popularity 100) [cite: 18]
    6.  [cite_start]Betyar\_altato (6:24, Popularity 90) [cite: 18]
    7.  [cite_start]Huszaros (6:15, Popularity 77) [cite: 18]
    8.  [cite_start]Vilagfa (4:42, Popularity 86) [cite: 18]
    9.  [cite_start]Hamu\_es\_Gyasz (5:51, Popularity 87) [cite: 18]
    10. [cite_start]Virraszto (4:50, Popularity 70) [cite: 18]

The total duration of this optimal setlist is approximately **70 minutes and 25 seconds** (57:15 + 4:50 + 9 * 0:30, which is $3445s + 270s = 3715s \approx 61\text{ min } 55\text{ sec}$ total play time, or $3715s + 9 \times 30s = 3985s \approx 66\text{ min } 25\text{ sec}$ including breaks).

Would you like me to check any specific constraint (like the difficulty/fatigue constraint) for a musician in the optimal setlist, or elaborate on any of the theoretical questions in `zh.md`?The user has provided two AMPL model files (`ErdosTabor2.mod`, `ErdosTabor.mod`), two data files (`ErdosTabor_januar.dat`, `ErdosTabor_januar2.dat`), and a description of an optimization problem (`potZH.pdf`, `potZH.md`) concerning the scheduling of classes for the **Erdős Pál Tehetséggondozó** mathematics weekend camp.

## 🎯 Optimization Problem Goal

[cite_start]The primary goal is to create a class schedule that **minimizes the total cost of accommodation** for the lecturers[cite: 24, 25].

[cite_start]The accommodation cost is determined by the number of nights a lecturer must stay at the central PE dormitory, where one night costs 15,000 HUF per person[cite: 25]. [cite_start]The number of nights is determined by the days a lecturer has classes[cite: 26, 27, 28]:
* [cite_start]**0 nights:** If the lecturer only has classes on a single day (Friday, Saturday, or Sunday)[cite: 26].
* [cite_start]**1 night:** If the lecturer has classes on two consecutive days (e.g., Friday and Saturday, or Saturday and Sunday)[cite: 27].
* [cite_start]**2 nights:** If the lecturer has classes on non-consecutive days (Friday and Sunday)[cite: 28].

[cite_start]The camp runs over a weekend (Friday, Saturday, Sunday)[cite: 31, 41, 54].

---

## 📝 Problem Constraints and Data

### Constraints (Scheduling Rules)
The models enforce the following scheduling rules:
1.  [cite_start]**All classes must be taught:** Each lecturer must teach the number of classes assigned to them for each group (grade level)[cite: 4, 79].
2.  [cite_start]**Groups have exactly one class at a time:** For any given class slot, each student group (9, 10, 11, 12) must be taught by exactly one lecturer[cite: 5, 80].
3.  [cite_start]**Lecturers teach at most one class at a time:** A lecturer can be assigned to teach at most one class slot across all groups at any given time[cite: 6, 81].

### Camp Schedule and Classes
[cite_start]The camp takes place over **3 days** (`dayCount = 3`): Friday, Saturday, and Sunday[cite: 31, 41, 54, 70].

* [cite_start]Each grade level (Group: 9, 10, 11, 12) has **7 classes** in total over the weekend[cite: 21, 75].
* [cite_start]Each class lasts **1.5 hours** (`classDuration = 1.5`)[cite: 21, 76].
* The class slots are scheduled at specific times:
    | Day | Class Slot | Start Time | End Time |
    | :--- | :--- | :--- | :--- |
    | Friday | 1 | 14:30 (14.5) | 16:00 (16.0) |
    | Friday | 2 | 16:30 (16.5) | 18:00 (18.0) |
    | Saturday | 3 | 8:30 (32.5) | 10:00 (34.0) |
    | Saturday | 4 | 10:30 (34.5) | 12:00 (36.0) |
    | Saturday | 5 | 16:30 (40.5) | 18:00 (42.0) |
    | Sunday | 6 | 8:00 (56.0) | 9:30 (57.5) |
    | Sunday | 7 | 9:45 (57.75) | 11:15 (59.25) |
    *Times are given in hours from the start of Friday (12:00, or $t=12$ in hours) in the data file `ErdosTabor_januar2.dat` but are typically just counted sequentially from $t=0$ in the model for the purpose of scheduling and duration calculation. [cite_start]The `start` times given in `ErdosTabor_januar2.dat` are $14.5, 16.5, 32.5, 34.5, 40.5, 56, 57.75$[cite: 75, 76].

### Lecturers and Class Assignments

[cite_start]The lecturers and their teaching assignments for the groups (grades) are defined in the `classes` parameter[cite: 67, 72]. The total number of classes taught by each lecturer is the sum of classes assigned to them across groups.

| Lecturer | Gr 9 | Gr 10 | Gr 11 | Gr 12 | Total Classes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Kubatov** | 1 | 0 | 0 | 1 | 2 |
| **Sagmeister** | 1 | 0 | 2 | 0 | 3 |
| **Kiss** | 1 | 1 | 1 | 0 | 3 |
| **Katz** | 1 | 0 | 0 | 1 | 2 |
| **Abraham** | 1 | 0 | 0 | 1 | 2 |
| **Arki** | 1 | 0 | 0 | 1 | 2 |
| **Hegyhati** | 1 | 0 | 1 | 0 | 2 |
| **Meszaros** | 0 | 1 | 0 | 0 | 1 |
| **Erdos** | 0 | 1 | 1 | 1 | 3 |
| **Pinter** | 0 | 1 | 0 | 0 | 1 |
| **Eles** | 0 | 1 | 1 | 0 | 2 |
| **Fonyo** | 0 | 1 | 0 | 1 | 2 |
| **Kocsis** | 0 | 1 | 1 | 1 | 3 |

---

## 🛠️ Model Analysis

Two different AMPL models are provided, each attempting to solve a related optimization problem:

### 1. `ErdosTabor.mod` (Minimizing Nights/Cost)

[cite_start]This model directly addresses the primary optimization goal: **minimizing the total number of nights** of accommodation for all lecturers (`TotalNights`)[cite: 83].

* [cite_start]**Decision Variable:** `nights[l]` is a non-negative integer variable representing the number of nights lecturer $l$ needs to stay[cite: 79].
* [cite_start]**Objective Function:** $\min \sum_{l \in \text{Lecturers}} \text{nights}[l]$[cite: 83].
* [cite_start]**Core Constraint (Accommodation Logic):** The constraint `Lecutrers_must_sleep_between_taught_classes_on_diffent_days` determines the number of nights based on the days a lecturer has classes[cite: 82].
    * It uses the day index $d$ (1=Friday, 2=Saturday, 3=Sunday) to calculate the minimum number of nights required between any two classes on different days, $d_1$ and $d_2$:
        $$\text{nights}[l] \ge (d_2 - d_1) - \text{dayCount} \cdot \left( 2 - \sum_{g} \text{teach}[l, g, d_1, c_1] - \sum_{g} \text{teach}[l, g, d_2, c_2] \right)$$
    * If lecturer $l$ teaches on day $d_1$ (class $c_1$) and day $d_2$ (class $c_2$ with $d_2 > d_1$), the bracketed term is $2-1-1=0$, and the constraint is $\text{nights}[l] \ge d_2 - d_1$.
        * [cite_start]If classes are on Day 1 (Friday) and Day 2 (Saturday), $d_2-d_1 = 1 \implies \text{nights}[l] \ge 1$ (1 night)[cite: 27].
        * [cite_start]If classes are on Day 1 (Friday) and Day 3 (Sunday), $d_2-d_1 = 2 \implies \text{nights}[l] \ge 2$ (2 nights)[cite: 28].
    * If the lecturer does not teach on $d_1$ or $d_2$, the bracketed term is $1$ or $2$, and the constraint becomes loose. The minimization objective will ensure `nights[l]` takes the smallest necessary value.

### 2. `ErdosTabor2.mod` (Minimizing Presence Time)

[cite_start]This model solves a related problem: **minimizing the total time all lecturers spend at the camp** (`TotalPresence`)[cite: 1, 11]. This is likely an intermediate or alternative approach, as the problem statement explicitly asks to minimize the cost of *accommodation* (nights).

* **Decision Variables:**
    * `arrive[l]`: The time lecturer $l$ arrives (before their first class starts).
    * `depart[l]`: The time lecturer $l$ departs (after their last class ends).
* [cite_start]**Objective Function:** $\min \sum_{l \in \text{Lecturers}} (\text{depart}[l] - \text{arrive}[l])$[cite: 11].
* **Core Constraints:**
    * [cite_start]`Lecturer_must_arrive_before_taught_class`: $\text{arrive}[l] \le \text{start}[c] + M \cdot (1 - \sum_{g} \text{teach}[l, g, c])$[cite: 7]. This ensures arrival time is less than or equal to the start time of any class taught by $l$. The term with a large constant $M$ makes the constraint loose for classes $l$ doesn't teach.
    * [cite_start]`Lecturer_must_depart_after_taught_class`: $\text{depart}[l] \ge (\text{start}[c] + \text{classDuration}) \cdot \text{teach}[l, g, c]$[cite: 9]. This ensures departure time is greater than or equal to the end time of any class taught by $l$.

**Note:** Minimizing total presence time (`ErdosTabor2.mod`) will generally result in a schedule that also minimizes the required nights, but it's not the exact objective requested. `ErdosTabor.mod` directly models the accommodation costs.This is an **optimization model** written in a modeling language like **AMPL (A Mathematical Programming Language)**, designed to solve a classic **Transportation Problem**.

---

## 🏭 Description of the Model

The model aims to find the most cost-effective way to **transport** goods from a set of **Factories** (supply points) to a set of **Universities** (demand points), subject to supply and demand constraints. The cost is based on the distance between each factory and university.

### 📝 Key Components

### 1. Sets and Parameters (Input Data)

These elements define the structure and the numerical data of the problem:

* **`set Factories;`**
    * Defines the collection of supply locations.
* **`set Universities;`**
    * Defines the collection of demand locations.
* **`param supply{Factories} >= 0;`**
    * The **maximum quantity** of a product that each factory `f` can supply.
* **`param demand{Universities} >= 0;`**
    * The **minimum quantity** of a product that each university `u` requires.
* **`param distance{Factories,Universities} >= 0;`**
    * The **cost (or distance)** of transporting one unit of the product from a specific factory `f` to a specific university `u`. This is the cost coefficient for the objective function.

### 2. Decision Variables

The core of what the model needs to determine:

* **`var transport{Factories,Universities} >= 0;`**
    * The **quantity of goods** to be transported from factory `f` to university `u`. This is the **decision variable** whose optimal values the solver will determine.

### 3. Constraints

These define the required restrictions on the solution:

* **`s.t. Supply_constraint{f in Factories}:`**
    * `sum{u in Universities} transport[f,u] <= supply[f];`
    * **Interpretation:** For every factory `f`, the total amount of goods shipped *out* to all universities must be **less than or equal to** that factory's maximum supply.

* **`s.t. Demand_constraint{u in Universities}:`**
    * `sum{f in Factories} transport[f,u] >= demand[u];`
    * **Interpretation:** For every university `u`, the total amount of goods shipped *in* from all factories must be **greater than or equal to** that university's required demand.

### 4. Objective Function

This is the goal the model aims to achieve:

* **`minimize Transportation_cost:`**
    * `sum{f in Factories, u in Universities} distance[f,u] * transport[f,u];`
    * **Interpretation:** The goal is to **minimize** the total transportation cost, which is calculated as the sum of (cost per unit * quantity transported) for every factory-university pair.

### 5. Execution and Output

These commands instruct the modeling language (e.g., AMPL) on what to do:

* **`solve;`**
    * Tells the program to invoke an appropriate **Linear Programming (LP)** solver to find the optimal values for the `transport[f,u]` variables.
* **`for {f in Factories} { ... }`**
    * This section prints the final results. It iterates through all factory-university pairs and uses `printf` to display the optimal shipment quantity (`transport[f,u]`) **only if** the quantity is non-zero.

---

## 🎯 Purpose and Mathematical Type

The model is a **Linear Programming (LP)** problem because the objective function and all constraints are **linear** functions of the decision variables. It specifically represents a **balanced or unbalanced transportation problem**, which is a fundamental problem in the field of **Operations Research**.

Would you like to provide the **data (supply, demand, and distances)** for the Factories and Universities so I can solve this transportation problem for you?The provided files, **ut.mod** and **ut.dat**, define and populate an **optimization model** likely written in the **AMPL (A Mathematical Programming Language)** syntax. [cite_start]This model aims to maximize the completion of a final work step, **Lakkozas (Lacquering)**, within a fixed timeframe of **8 hours**[cite: 9, 10].

Here is a breakdown of the model's components and constraints:

## 🧑‍💻 Model Sets and Parameters

| Identifier | Type | Description | Values (from ut.dat) | Source |
| :--- | :--- | :--- | :--- | :--- |
| **dolgozok** | Set | [cite_start]The set of **workers**[cite: 1]. | [cite_start]Kitti, Medard, Gergo, Balazs, Iza [cite: 8] [cite_start]| [cite: 1, 8] |
| **munkafolyamatok** | Set | [cite_start]The set of **work processes/steps**[cite: 1]. | [cite_start]Hantolas, Alapozas, Pirosfestes, Lakkozas [cite: 8] [cite_start]| [cite: 1, 8] |
| **elsomunka** | Parameter (Symbolic) | [cite_start]The **first** work step[cite: 1]. | [cite_start]Hantolas [cite: 9] [cite_start]| [cite: 1, 9] |
| **utolsomunka** | Parameter (Symbolic) | [cite_start]The **last** work step[cite: 1]. | [cite_start]Lakkozas [cite: 9] [cite_start]| [cite: 1, 9] |
| **elozo** | Parameter (Symbolic) | [cite_start]The **preceding** work step for any step *m* (where *m* is not *elsomunka*)[cite: 2]. | [cite_start]Alapozas $\to$ Hantolas, Pirosfestes $\to$ Alapozas, Lakkozas $\to$ Pirosfestes [cite: 9] [cite_start]| [cite: 2, 9] |
| **ora** | Parameter | [cite_start]The total number of time periods (hours)[cite: 2]. | [cite_start]8 [cite: 9] [cite_start]| [cite: 2, 9] |
| **orak** | Set | [cite_start]The set of time periods $1, 2, \dots, \text{ora}$[cite: 2]. | [cite_start]$1, 2, \dots, 8$ [cite: 9] [cite_start]| [cite: 2, 9] |
| **sebesseg** | Parameter | [cite_start]The **speed** or productivity of each worker for each work step[cite: 2]. | [cite_start]See table below [cite: 10] [cite_start]| [cite: 2, 10] |
| **munkaora** | Parameter | [cite_start]The contribution of a worker's effort in one time period to the **progress** of a task (between 0 and 1)[cite: 3]. | [cite_start]0.75 [cite: 10] [cite_start]| [cite: 3, 10] |
| **maxtavolsag** | Parameter | [cite_start]A constraint on the **maximum allowed progress gap**[cite: 3]. | [cite_start]10 [cite: 3] [cite_start]| [cite: 3] |

---

### **Worker Speeds ($sebesseg$)**
| Worker | Hantolas (Sanding) | Alapozas (Priming) | Pirosfestes (Red Painting) | Lakkozas (Lacquering) | Source |
| :--- | :--- | :--- | :--- | :--- |
| Kitti | 2 | 6 | 7 | [cite_start]3 | [cite: 10] |
| Medard | 7 | 5 | 4 | [cite_start]2 | [cite: 10] |
| Gergo | 5 | 2 | 5 | [cite_start]4 | [cite: 10] |
| Balazs | 6 | 3 | 2 | [cite_start]8 | [cite: 10] |
| Iza | 3 | 4 | 8 | [cite_start]6 | [cite: 10] |

---

## 📐 Decision Variables

* [cite_start]**dolgozas{orak, dolgozok, munkafolyamatok} binary;**: A **binary decision variable** that equals 1 if worker $d$ is working on work step $m$ during time period $o$, and 0 otherwise[cite: 3].
* [cite_start]**elorehaladas{orak $\cup$ {0}, munkafolyamatok} $\ge$ 0;**: A non-negative variable representing the **cumulative progress/completion** of work step $m$ up to and including time period $o$ (with an initial state at $o=0$)[cite: 3].

---

## ⚖️ Objective and Constraints

### **Objective Function**
$$Maximize \quad kesz: \quad elorehaladas[ora, utolsomunka]$$
[cite_start]The goal is to **maximize the total completion** of the final work step, **Lakkozas**, by the end of the last time period ($ora=8$)[cite: 7, 9].

### **Constraints**

* [cite_start]**csak\_egy\_feladat**[cite: 4]: For any time period $o$ and worker $d$, the worker can be assigned to at most **one** work step.
    $$\sum_{m \in \text{munkafolyamatok}} dolgozas[o, d, m] \le 1$$
* [cite_start]**elorehaladas\_kezdet**[cite: 5]: The initial progress of all work steps at time $o=0$ is **zero**.
    $$elorehaladas[0, m] = 0$$
* [cite_start]**munka\_elorehaladas**[cite: 5]: The progress of work step $m$ at time $o$ is the progress from the previous time period ($o-1$) plus the contribution of the workers assigned to it in period $o$. The contribution is determined by the $\text{munkaora}$ value (0.75) multiplied by the total speed of the workers assigned to $m$.
    $$elorehaladas[o, m] \le elorehaladas[o-1, m] + \text{munkaora} \times \sum_{d \in \text{dolgozok}} dolgozas[o, d, m] \times \text{sebesseg}[d, m]$$
* [cite_start]**megelozo\_folyamat**[cite: 6]: For any work step $m$ (that is not the first step), the **progress of $m$ cannot exceed the progress of its preceding step** ($\text{elozo}[m]$). This enforces the sequential nature of the tasks (e.g., Pirosfestes can't get ahead of Alapozas).
    $$elorehaladas[o, m] \le elorehaladas[o, elozo[m]]$$
* [cite_start]**max\_tavolsag**[cite: 7]: The difference in progress between the **first** work step (**Hantolas**) and the **last** work step (**Lakkozas**) must not exceed a maximum distance ($\text{maxtavolsag}=10$). This acts as a buffer or capacity constraint to prevent the initial work from getting too far ahead of the final step.
    $$elorehaladas[o, \text{elsomunka}] - elorehaladas[o, \text{utolsomunka}] \le \text{maxtavolsag}$$

This model is a type of **resource-constrained scheduling/production optimization problem**, determining the optimal assignment of workers to tasks over time to maximize the final output, respecting task dependencies and resource limits.

Would you like to analyze a specific solution from this model, or have me explain one of the constraints in more detail?This is an **optimization model** likely written in a modeling language like AMPL or GLPK, designed to solve a **beer transportation problem** from **breweries** to **universities** at a minimum cost.

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

Would you like to provide the data files (e.g., `pro.dat`) to solve this optimization problem?[cite_start]This is an **AMPL (A Mathematical Programming Language)** model and data file that sets up and solves an optimization problem, likely a form of the **assignment problem**. [cite: 1, 2, 3, 4]

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

Would you like me to find the **optimal assignment** and the **minimum number of beers** based on this data?# Elméleti feladatok, illetve a megoldások feltöltése
Itt: https://szelearning.sze.hu/course/view.php?id=3163

# Alap feladat közepes jegyért

Egy megépítendő áruház sorait szeretnénk megtervezni úgy, hogy minél kevésbé legyen "hosszú" az áruházunk.

A terület szélességét ismerjük, és ebből bemenetként adott, hogy hány sorral tervezhetünk. Tudjuk továbbá azt is, hogy hány kasszát kell beépíteni. Minden kassza egy sornyi szélességet foglal el, a hossza pedig adott. Értelemszerűen, azoknak a soroknak ennyivel rövidebbeknek kell lennie, amelyik végén kassza van.

Tehát a layout valami ilyesmi például 7 sor és 3 kassza esetén, ahol minden kassza hossza most itt 4, a (nem kasszás) sorok hossza pedig 10.

```bash
 $$$  $$$  $$$   ##   ##   ##   ##
 $$$  $$$  $$$   ##   ##   ##   ##
 $$$  $$$  $$$   ##   ##   ##   ##
 $$$  $$$  $$$   ##   ##   ##   ##
  ##   ##   ##   ##   ##   ##   ##
  ##   ##   ##   ##   ##   ##   ##
  ##   ##   ##   ##   ##   ##   ##
  ##   ##   ##   ##   ##   ##   ##
  ##   ##   ##   ##   ##   ##   ##
  ##   ##   ##   ##   ##   ##   ##
```

Vannak különböző termékcsoportjaink, amikhez adott, hogy egy soron hány méternyi helyet foglalnának el. (Feltételezzük, hogy minden sor két oldalas, és ez a szám már a kétoldalas pakolás esetén értendő.) Egy termékcsoport termékei nem oszthatók szét több sorba.

A feladat úgy megtervezni az áruház pakolását, hogy a sorokat (és ezáltal az épületet) minél rövidebbre tudjuk venni. Az épület hosszát most egyszerűen úgy vesszük, mint a leghosszabb sor hosszát (amibe most értelemszerűen a kassza hosszát is belevesszük, ha van a sorban).

## Példa bemenet

```ampl
param nRows         :=   3;
param cashierCount  :=   1;
param cashierLength := 2.5;

set ProductGroups :=  Group1 Group2 Group3 Group4 Group5 Group6 Group7 Group8;

param space :=
Group1	0.04
Group2	0.62
Group3	0.13
Group4	1.28
Group5	0.56
Group6	0.21
Group7	1.39
Group8	1.47
;
```

Ezekre az adatokra a helyes kimenet: `2.750000`

## Technikai megjegyzés

Ez a szint automatikusan, egy script által lesz javítva, ezért:
 - a modell fájl neve maradjon `model.mod`, és csak ez legyen feltöltve moodle-re (semmi zip és társai)
 - a feltöltött modell fájlban semmiképpen ne szerepeljen data section, mert azt külön fájlból fogja beszedni a script
 - ha tesztelési célzattal voltak további kiiratások, azok feltöltés előtt legyenek kikommentezve

# Kibővített feladat jobb jegyért

Ebben a feladatban már nem az áruház hosszának minimalizálása a cél, ez bemeneti paraméterként adott. A cél most a "manipulált bevétel" maximalizálása.

Manipulált bevétel alatt abból az eladásból származó bevételt értjük, amikor a vásárló megvesz valamit, amit eredetileg nem akart, de mivel meglátta, ezért megveszi.

## Bemenet

Az alap szinthez képest további bemeneti adatok:
 - minden termékcsoporthoz egy átlagos termékár
 - olyan termékcsoport párok halmaza, amiket muszáj ugyanarra a sorra tenni
 - olyan termékcsoport párok halmaza, amiket tilos ugyanarra a sorra tenni
 - a sorok maximális hossza
 - vásárlói csoportok halmaza, valamint mindegyikre:
   - a csoportba tartozó emberek száma
   - annak a valószínűsége, hogy egy ebbe a csoportba tartozó vásárló megvesz valamit, amire nincs szüksége, ha látja
   - melyik termékeket szeretné eleve megvenni

## Manipulálás

Az egyszerűség kedvéért feltételezzük, hogy egy termékcsoportot akkor lát egy vásárló, ha azon a soron van legalább egy másik termékcsoport, amiből akar vásárolni. Ebben az esetben a megadott valószínűséggel megvesz ott egy terméket. Szintén az egyszerűség kedvéért feltételezhetjük, hogy az egy termékcsoportban lévő termékek közül egyenletes eloszlás szerint választnak és csak egy terméket, így ha vásárolnak, akkor a keletkezett (manipulált) többletbevételt tekinthetjük egy darab átlagos termékárnak abból a termékcsoportból.

Szintén az egyszerűség kedvéért feltételezzük, hogy a kasszához való beállás nem eredményez az ahhoz tartozó soron ilyesmit. Nem foglalkozunk azzal sem, hogy egy soron belül melyik termékcsoport hol van, vagy hogy a sorok milyen sorrendben vannak egymás mellett, hogy lehet végigmenni rajtuk, stb.


## Példa bemenet

```ampl
param nRows         :=   6;
param cashierCount  :=   1;
param cashierLength := 2.5;
param maxRowLength  :=   4;

set ProductGroups := Group1	Group2	Group3	Group4	Group5	Group6	Group7	Group8	Group9	Group10	Group11	Group12	Group13	Group14	Group15	Group16	Group17	Group18	Group19	Group20;

param:
                space   averagePrice:=
    Group1	    0.94	282.00
    Group2	    1.12	108.00
    Group3	    0.21	226.00
    Group4	    1.99	264.00
    Group5	    0.70	103.00
    Group6	    0.47	180.00
    Group7	    0.32	219.00
    Group8	    0.86	140.00
    Group9	    1.10	262.00
    Group10	    1.86	127.00
    Group11	    0.18	146.00
    Group12	    0.07	142.00
    Group13	    0.23	152.00
    Group14	    1.55	228.00
    Group15	    1.23	231.00
    Group16	    1.97	123.00
    Group17	    0.68	208.00
    Group18	    1.31	94.00
    Group19	    0.38	93.00
    Group20	    0.56	268.00
;

set MustBeTogether := (Group1,Group2) , (Group12,Group8), (Group9,Group6), (Group3,Group2);
set MustBeSeparated := (Group19,Group20), (Group18,Group16), (Group13,Group11);

set CustomerGroups := CGroup1 CGroup2 CGroup3 CGroup4 CGroup5 CGroup6 CGroup7 CGroup8;

param :
            count   probabilityToBuy :=
    CGroup1	32234	0.171868755564931
    CGroup2	54057	0.006530116263574
    CGroup3	57460	0.296577903833505
    CGroup4	28400	0.218939432473207
    CGroup5	25697	0.235654179732287
    CGroup6	39766	0.239887826996717
    CGroup7	34504	0.032609542717186
    CGroup8	28175	0.165773679595818
;


param buys (tr) :
            CGroup1	CGroup2	CGroup3	CGroup4	CGroup5	CGroup6	CGroup7	CGroup8 :=
    Group1	0	    1	    0	    1	    0	    0	    0	    0
    Group2	0	    0	    0	    0	    0	    0	    0	    0
    Group3	1	    1	    0	    0	    0	    0	    1	    1
    Group4	1	    1	    0	    0	    0	    0	    0	    0
    Group5	1	    0	    0	    0	    0	    1	    0	    0
    Group6	0	    0	    1	    0	    0	    0	    0	    0
    Group7	0	    1	    1	    1	    0	    0	    0	    0
    Group8	1	    1	    0	    0	    0	    0	    0	    0
    Group9	0	    0	    0	    1	    1	    0	    0	    1
    Group10	0	    1	    0	    0	    1	    0	    1	    1
    Group11	0	    1	    1	    0	    0	    1	    0	    0
    Group12	1	    1	    1	    0	    0	    0	    0	    0
    Group13	0	    1	    1	    0	    1	    0	    0	    0
    Group14	0	    1	    1	    0	    1	    0	    0	    0
    Group15	1	    0	    1	    0	    1	    1	    0	    0
    Group16	0	    1	    0	    0	    1	    0	    0	    1
    Group17	0	    1	    0	    0	    1	    0	    0	    0
    Group18	0	    0	    1	    0	    1	    0	    0	    1
    Group19	0	    0	    0	    0	    1	    0	    0	    0
    Group20	0	    1	    0	    0	    0	    0	    1	    0
;
```

## Ellenőrzés

Ennek a szintnek az ellenőrzése manuálisan történik. Egyrészt azért, mert a megvalósítás minőségén múlik az, hogy négyest, vagy ötöst érdemel-e a kód. Másrészt nálam most több mint negyed órája fut a `glpsol` és még mindig van 7.6% gap:

```
Time used: 1020.1 secs.  Memory used: 217.9 Mb.
+3700251: mip =   1.150311899e+08 <=   1.238165285e+08   7.6% (156403; 24195)
+3711974: mip =   1.150311899e+08 <=   1.238116038e+08   7.6% (156930; 24289)
+3724329: mip =   1.150311899e+08 <=   1.238066442e+08   7.6% (157449; 24383)
+3736844: mip =   1.150311899e+08 <=   1.238012925e+08   7.6% (157945; 24477)
```

Kérem, hogy a "bepróbálkozásokat" kerüljük. Ez alatt értem az olyan kódot, ami
 - szintaktikai hibás
 - nem tudja legenerálni a modellt a megadott `data.dat`-tal
 - egyértelműen nem mutat érdemi haladást az alapszinthez képest.

# Github Actions

Ha valaki leforkolja ezt a repót, majd felpusholja a megoldását, akkor 4 CI teszt fog lefutni:
  - helyes megoldások tesztelése az alapfeladatra
  - modellgenerálás szintaktikai tesztje a kibővített feladatra[cite_start]The uploaded files describe a **tea transportation optimization problem** formulated for a mathematical programming solver like GLPK or AMPL[cite: 5, 14]. [cite_start]This model minimizes the total transportation cost of shipping tea from various farms (supply) to different markets (demand) using a fleet of vehicles with specific capacities and weights[cite: 5, 7].

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

Would you like to provide the vehicle data to **solve this optimization problem**?LibreOffice Basic
=================

This directory contains an example demonstrating how to call the GLPK
library from LibreOffice.

The code was written for LibreOffice 32bit version 5.3 beta. For
execution it requires the stdcall GLPK dynamic link library to be in
the search path for binaries.

From the administration for Basic macros choose the library import and
import script.xlb. This will create a macro libray GLPK. Module lp
contains the macro lp.

The macro creates a linear problem, solves it, and shows the result in
a message box.You've uploaded several files related to a **study scheduling optimization problem** using a modeling language like GLPK/AMPL.

Here's a breakdown of the files:

### 📑 Data Files (`.dat`)

These files define the specific parameters and constraints for the problem:

| File | Key Data Defined | Description |
| :--- | :--- | :--- |
| [cite_start]`data_0.dat` [cite: 1, 2, 3] | `Targyak`, `vizsganap`, `szukseges_ora`, `Napok`, `szabadido` | [cite_start]Defines three subjects (**DTR, IRB, KXD**) [cite: 1][cite_start], their required study hours, and exam days[cite: 1]. [cite_start]It also defines 10 days (`Napok`) [cite: 2] [cite_start]and the available free time (`szabadido`) for studying on each day[cite: 3]. |
| [cite_start]`data_1.dat` [cite: 30, 31] | `Targyak`, `vizsganap`, `szukseges_ora`, `utolso_nap`, `szabadido` | [cite_start]Similar to `data_0.dat`, using the same three subjects and available time[cite: 30]. [cite_start]It explicitly sets `utolso_nap` (last day) to **10**[cite: 31]. |
| [cite_start]`data_2.dat` [cite: 32, 33, 34] | `Targyak`, `vizsganap`, `szukseges_ora`, `utolso_nap`, `szabadido` | [cite_start]Defines a larger set of six subjects (**DTR, IRB, KXD, IRU, VIR, TOK**) [cite: 32] [cite_start]with their required study hours and exam days[cite: 32, 33]. [cite_start]It also sets `utolso_nap` to **10** [cite: 34] [cite_start]and uses the same free time schedule[cite: 34]. |

---

### 💻 Model Files (`.mod`)

These files contain the optimization models that define the variables, objective function, and constraints:

#### `model_0.mod` (Minimize Total Study Hours)

[cite_start]This model aims to schedule the necessary study hours using the absolute minimum total time possible[cite: 15].

* [cite_start]**Variables:** `tanulok[Napok, Targyak]` (hours studied on a given day for a given subject)[cite: 11, 12].
* **Constraints:**
    * [cite_start]**Available Time:** Total study time on any day cannot exceed the available free time[cite: 12].
    * [cite_start]**Preparation:** The total study time for a subject across all days must meet or exceed the required hours (`szukseges_ora`)[cite: 13].
    * [cite_start]**No Late Studying:** Study hours for a subject are zero on or after its exam day[cite: 14].
* [cite_start]**Objective:** **Minimize** the total hours spent studying (`Osszes_tanulas`)[cite: 15].

#### `model_1.mod` (Minimize Total Study Hours, Alternative Preparation Constraint)

This model is similar to `model_0.mod` but uses a different definition for the preparation constraint.

* [cite_start]**Variables:** `tanulok[Napok, Targyak]`[cite: 4, 5].
* **Constraints:**
    * [cite_start]**Available Time:** Same as `model_0.mod`[cite: 5].
    * [cite_start]**Preparation:** The total study time for a subject must meet or exceed the required hours, **but only considering days *before* the exam day** (`n < vizsganap[t]`)[cite: 6]. *Note: This constraint effectively prevents studying on or after the exam day, making the explicit 'No Late Studying' constraint from `model_0.mod` redundant.*
* [cite_start]**Objective:** **Minimize** the total hours spent studying (`Osszes_tanulas`)[cite: 7].

#### `model_2.mod` (Maximize Number of Passed Subjects)

[cite_start]This model addresses the scenario where there might not be enough time to prepare for all exams and aims to pass the maximum number of subjects[cite: 23].

* **Variables:**
    * [cite_start]`tanulok[Napok, Targyak]`[cite: 19, 20].
    * [cite_start]`atmegyek[Targyak]` (**binary** variable, 1 if the subject is passed/attempted, 0 otherwise)[cite: 20].
* **Constraints:**
    * [cite_start]**Available Time:** Total study time on any day cannot exceed the available free time[cite: 21].
    * [cite_start]**Preparation:** The total study time for a subject on days **before** the exam must meet or exceed the required hours **only if** the subject is chosen to be passed (i.e., if $atmegyek[t] = 1$)[cite: 22]. The constraint is:
        $$\sum_{n \in Napok, n < vizsganap[t]} tanulok[n,t] \ge szukseges\_ora[t] \times atmegyek[t]$$
* [cite_start]**Objective:** **Maximize** the total number of subjects passed (`Teljesitett_targyak`)[cite: 23].

***

Would you like me to try solving one of these models with a data file, or perhaps compare the results of two different models?