
set FroccsTypes;

param price{FroccsTypes};

param soda_stock; 
param wine_stock; 

param soda_content{FroccsTypes};
param wine_content{FroccsTypes};

var quantity{FroccsTypes} >= 0;

s.t. SodaUsage:
  sum{f in FroccsTypes} quantity[f] * soda_content[f] <= soda_stock;

s.t. WineUsage:
  sum{f in FroccsTypes} quantity[f] * wine_content[f] <= wine_stock;

maximize Income:
  sum{f in FroccsTypes} price[f] * quantity[f];

solve;

display Income;

data;
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

end;
