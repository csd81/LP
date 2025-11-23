Advanced GMPL Models for Motivational Examples
Advanced GMPL models of the motivational examples

**Prerequisites**
Advanced GMPL techniques: data/logic decoupling

We have already built the advanced model for the Festivals example. In this exercise, try doing the same for the Fröccs example.

---

## Advanced GMPL Model for the Fröccs Example

Start by creating a more general model where the fröccs types are provided as data. The first step is to identify the required sets and parameter definitions.

### Mathematical notation → GMPL code

**Sets and parameters**

```
set FroccsTypes;
param price{FroccsTypes};
param soda_stock;
param wine_stock;
param soda_content{FroccsTypes};
param wine_content{FroccsTypes};
```

The second step is to define the variables, constraints, and the objective function of the general model.

### Mathematical notation → GMPL code

**Variables**

```
var quantity{FroccsTypes} >= 0;
```

**Constraints**

```
s.t. SodaUsage: sum{f in FroccsTypes} quantity[f] * soda_content[f] <= soda_stock;

s.t. WineUsage: sum{f in FroccsTypes} quantity[f] * wine_content[f] <= wine_stock;
```

**Objective function**

```
maximize Income: sum{f in FroccsTypes} price[f] * quantity[f];
```

Finally, provide the data for the model in a data file:

```
set FroccsTypes :=
  kisfroccs
  nagyfroccs
  hosszulepes
  hazmester
  vicehazmester
  krudyfroccs
  soherfroccs
  puskasfroccs
  ;

param price :=
  kisfroccs     110
  nagyfroccs    200
  hosszulepes   120
  hazmester     260
  vicehazmester 200
  krudyfroccs   800
  soherfroccs   200
  puskasfroccs  550
  ;

param soda_stock := 1500;
param wine_stock := 1000;

param soda_content :=
  kisfroccs     1
  nagyfroccs    1
  hosszulepes   2
  hazmester     2
  vicehazmester 3
  krudyfroccs   1
  soherfroccs   9
  puskasfroccs  3
  ;

param wine_content :=
  kisfroccs     1
  nagyfroccs    2
  hosszulepes   1
  hazmester     3
  vicehazmester 2
  krudyfroccs   9
  soherfroccs   1
  puskasfroccs  6
  ;
```

---

## More General Product-Mix Model

This model is still very specific to beverages made from soda and wine. If we had a problem with different products that require certain amounts of various raw materials—and if all prices, stocks, and usage rates were provided—the model would look almost identical. So now create a model where the ingredients are not hardcoded; instead, they are given as a set.

```
set Products;
set Ingredients;

param price{Products};
param stock{Ingredients};
param content{Products,Ingredients};

var quantity{Products} >= 0;

s.t. IngredientUsage{i in Ingredients}:
  sum{p in Products} quantity[p] * content[p,i] <= stock[i];

maximize Income:
  sum{p in Products} price[p] * quantity[p];

data;

set Products :=
  kisfroccs
  nagyfroccs
  hosszulepes
  hazmester
  vicehazmester
  krudyfroccs
  soherfroccs
  puskasfroccs
  ;

set Ingredients :=
  soda
  wine
  ;

param price :=
  kisfroccs     110
  nagyfroccs    200
  hosszulepes   120
  hazmester     260
  vicehazmester 200
  krudyfroccs   800
  soherfroccs   200
  puskasfroccs  550
  ;

param stock :=
  soda 1500
  wine 1000
  ;

param content :
                soda  wine :=
  kisfroccs     1     1
  nagyfroccs    1     2
  hosszulepes   2     1
  hazmester     2     3
  vicehazmester 3     2
  krudyfroccs   1     9
  soherfroccs   9     1
  puskasfroccs  3     6
  ;

end;
```

---

## More General Product-Mix Model (Festival Version)

To test your skills, try creating a generic model for a more advanced version of the festival example.

1. **Warm-up:**
   Include the ticket price of each festival and change the objective to minimize total cost instead of simply minimizing the number of festivals.

2. **Next step:**
   Assign dates to each festival and add a constraint that you cannot attend two festivals at the same time.

3. **Challenge:**
   Extend the model with an additional feature of your choice to make it more realistic.

---

## Final Notes

The main purpose of this exercise was to get comfortable with writing generic models and using GMPL’s syntax effectively.
