

s.t. Material_Balance_Production {m in Materials}: usage_production[m] = sum {c in Recipes} Recipe_Ratio[c,m] * volume[c];

s.t. Material_Balance_Orders {m in Materials}: usage_orders[m] = sum {o in Orders} Order_Material_Flow[o,m] * ordcnt[o];

s.t. Material_Balance_Total_Raws_1 {r in Raws}: usage_total[r] = usage_orders[r] + usage_market[r];

s.t. Material_Balance_Total_Raws_2 {r in Raws}: usage_total[r] = usage_production[r] + usage_leftover[r];


s.t. Material_Balance_Total_Products_1 {p in Products}: usage_total[p] = usage_production[p];

s.t. Material_Balance_Total_Products_2 {p in Products}: usage_total[p] = usage_orders[p] + usage_market[p];
 
s.t. Total_Costs_Calc: total_costs = sum {r in Raws} Value[r] * usage_market[r] + sum {o in Orders: Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

s.t. Total_Revenue_Calc: total_revenue = sum {p in Products} Value[p] * usage_market[p] - sum {o in Orders: !Order_Pay_Before[o]} Order_Cash_Flow[o] * ordcnt[o];

 
