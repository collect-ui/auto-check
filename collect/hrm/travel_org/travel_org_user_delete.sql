delete from travel_agency_user_rel
where relation_id in ({{.relation_id_list}})
