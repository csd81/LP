Ez egy **diszkrét optimalizálási modell**, konkrétan egy **fedési probléma** (Set Covering Problem) változata, amit kiegészít egy költségkorlát. A modell célja a **minimális beruházási költség** elérése, miközben biztosítja, hogy **minden ház fűtése megoldott** legyen, és a **fenntartási költség** ne lépjen át egy adott korlátot.

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

Milyen konkrét adatokat szeretnél használni a futtatáshoz, vagy szeretnéd, ha részletesebben elmagyaráznám a kétcélú optimalizálással való kapcsolatát?