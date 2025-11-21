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

Szeretnéd, hogy finomítsak a `printf` kimeneten, vagy segítsek az adatfájl összeállításában is?