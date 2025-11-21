## 📝 Model Description Comparison

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
| **Constraint on Wins** | [cite_start]**Includes** `Mindenki_legfeljebb_ketszer_nyerhet` and `Ha_harmadjara_parbajozik_akkor_ki_kell_esnie`[cite: 46, 48]. | **No** such constraints. |