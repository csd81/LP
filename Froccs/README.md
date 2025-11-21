Ez egy **lineáris programozási** feladat, amelynek célja a **profit maximalizálása** az adott **bor és szóda korlátok** mellett.

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

Szeretné, ha megpróbálnám megoldani ezt a lineáris programozási feladatot valamilyen online solverrel vagy programozási nyelven?