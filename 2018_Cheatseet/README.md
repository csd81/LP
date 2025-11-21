A feltöltött **`puska.m`** fájlban leírt probléma egy **diszkrét optimalizálási feladat**, pontosabban egy **egészértékű lineáris programozási** probléma. Célja a **minimális költség** megtalálása a **puskák elkészítéséhez** négy barát segítségével, figyelembe véve bizonyos korlátozásokat.

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

Szeretnéd, hogy megpróbáljam megmondani, melyik hozzárendelés a legolcsóbb (megoldom a lineáris programot)?