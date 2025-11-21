A megadott problémabeállítás egy **lineáris programozási** (LP) modell, amely azt célozza, hogy **maximalizálja az elérhető kreditpontokat** egy vizsgaidőszakban, figyelembe véve a rendelkezésre álló tanulási időt és a felkészüléshez szükséges időt.

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

Would you like me to use the provided data to **calculate the optimal study plan and maximum credits** using a linear programming solver (like GLPK or Cplex, conceptually)?