select a.*
from travel_chat_contact a
where 1=1
{% if  .agency_id %}
and a.agency_id = {{.agency_id}}
{% endif %}
