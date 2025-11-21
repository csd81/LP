
set
set

param   >= 0;
param   >= 0;
param   >= 0;
param   >= 0;
param   >= 0;

param   >= 0;
param   >= 0;

var >= 0;
var >= 0;

s.t. Brewery_capacity_hl 

s.t. University_demand_hl

s.t. Enough_trips_for_transported_beer_t


minimize Transportation_cost_HUF:





solve;

printf "\nCost: %g\n\n", Transportation_cost_HUF;


for{b in Brewery, u in University : transport_hl[b,u] > 0}
{
    printf "%s --%g[%d]--> %s \n",b,transport_hl[b,u],trips[b,u],u;
}

end;