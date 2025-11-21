[cite_start]A feladat a Győr Sziget városrészében tartandó karácsonyi vásár és rendezvénysorozat kapcsán létesítendő **10 darab belvárosi buszjárat útvonalának optimalizálása**[cite: 1, 2, 7].

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

Szeretnéd, hogy kiszámoljam a járatok útvonalait és az össztávolságot a megadott adatok alapján, figyelembe véve a szorgalmi feladatot is?