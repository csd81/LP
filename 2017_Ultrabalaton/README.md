## 🏃 Az Ultrabalaton szakaszainak kiosztása: Problémaleírás 🏆

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

Milyen eredményeket szeretne látni a futók kiosztására vonatkozóan?