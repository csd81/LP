
set Brewery;
set University;

param  distance_km{Brewery,University} >= 0;
param  production_hl{Brewery} >= 0;
param  demand_hl{University} >= 0;
param  beer_density_kg_per_l >= 0;
param  transportation_cost_HUF_per_kg_per_km >= 0;

param  truck_weight_t >= 0;
param  truck_carry_capacity_t >= 0;

var transport_hl{Brewery,University} >= 0;
var trips{Brewery,University} >= 0;

s.t. Brewery_capacity_hl {b in Brewery}:
    sum{u in University} transport_hl[b,u] <= production_hl[b];


s.t. University_demand_hl {u in University}:
    sum{b in Brewery} transport_hl[b,u] >= demand_hl[u];

s.t. Enough_trips_for_transported_beer_t{b in Brewery, u in University}:
    beer_density_kg_per_l * transport_hl[b,u] / 10 <= trips[b,u] * truck_carry_capacity_t;


minimize Transportation_cost_HUF:
    sum{b in Brewery, u in University}
    transportation_cost_HUF_per_kg_per_km * distance_km[b,u] * (
        beer_density_kg_per_l * 100 * transport_hl[b,u]
        + 2 * trips[b,u] * truck_weight_t * 1000
    )
;



solve;

printf "\nCost: %g\n\n", Transportation_cost_HUF;


for{b in Brewery, u in University : transport_hl[b,u] > 0}
{
    printf "%s --%g[%d]--> %s \n",b,transport_hl[b,u],trips[b,u],u;
}


data;
param truck_weight_t := 3;
param truck_carry_capacity_t := 2;

set University := Sopron Gyor Budapest Veszprem Pecs Szeged;
set Brewery := Sopron Pecs Nagykanizsa Budapest;

param production_hl :=
    Sopron       100
    Pecs          80
    Nagykanizsa  150
    Budapest     200;

param demand_hl := 
    Sopron   130
    Gyor       1
    Budapest 170
    Veszprem  30
    Pecs      40
    Szeged    45;

param distance_km : Sopron Gyor Budapest Veszprem Pecs Szeged :=
    Sopron 0 96 216 149 397 383
    Pecs 397 332 239 192 0 189
    Nagykanizsa 161 195 211 154 140 374
    Budapest 216 121 0 115 239 175;
    
param beer_density_kg_per_l := 1.01; 
param transportation_cost_HUF_per_kg_per_km := 0.02; 

end;