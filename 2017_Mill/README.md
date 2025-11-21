Ez egy **lineáris programozási** modell egy pékségi ellátási lánc logisztikai problémájának megoldására, amelynek célja a **minimális benzinköltség** elérése a búza és liszt szállításakor a gazdaságoktól a pékségekig. A modell a szállítási mennyiségek optimalizálása mellett figyelembe veszi a teherautók számát és a visszautak költségét is.

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

Szeretnéd, ha futtatnám a modellt a megadott adatokkal, és megmutatnám az optimális szállítási tervet?