


set BookSets := Math IT Sport Music Novel Tolkien Feist HarryPotter Diplom;

param :          width      height    frequency :=
    Math           100          20          80
    IT              80          25          50
    Sport           30          30          10
    Music           50          30          20
    Novel           40          20          40
    Tolkien         30          25          60
    Feist           50          20          30
    HarryPotter     90          25          90
    Diplom          70          40           5
;

param shelfCount := 7;
param shelfWidth := 120;
param shelfHeight := 2;
param minDistance := 7;
param minPosition := 50;