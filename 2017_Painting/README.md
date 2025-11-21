A megadott AMPL modellt a túrajelzés-felújítás feladatának megoldására elemezzük.

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

**Kérdés:** Szeretnéd, hogy keressek vagy feltételezzek tipikus adatokat az $Emberek$ ügyességére ($tav$ mátrixra), hogy befejezzük a modellt, és futtassam, vagy elegendő a modell elemzése?