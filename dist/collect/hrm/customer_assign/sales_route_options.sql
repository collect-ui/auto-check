select
  rs.route_id as value,
  (r.route_name || '（' || r.route_code || '）') as label
from travel_agency_route_sales_rel rs
join travel_agency_route r on r.route_id = rs.route_id and ifnull(r.status,'normal')='normal'
where rs.agency_id = {{.agency_id}}
  and rs.sales_user_id = {{.sales_user_id}}
  and ifnull(rs.status,'normal')='normal'
order by r.route_name asc
