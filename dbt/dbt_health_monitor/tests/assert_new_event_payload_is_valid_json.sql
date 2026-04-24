-- fails when any new silver event payload is not valid JSON
with all_new_events as (
  select 'slv_cancellation_events' as model_name, event_payload
  from {{ ref('slv_cancellation_events') }}

  union all

  select 'slv_flight_events' as model_name, event_payload
  from {{ ref('slv_flight_events') }}

  union all

  select 'slv_hotel_events' as model_name, event_payload
  from {{ ref('slv_hotel_events') }}

  union all

  select 'slv_marketing_events' as model_name, event_payload
  from {{ ref('slv_marketing_events') }}

  union all

  select 'slv_payment_events' as model_name, event_payload
  from {{ ref('slv_payment_events') }}

  union all

  select 'slv_review_events' as model_name, event_payload
  from {{ ref('slv_review_events') }}

  union all

  select 'slv_search_events' as model_name, event_payload
  from {{ ref('slv_search_events') }}

  union all

  select 'slv_support_events' as model_name, event_payload
  from {{ ref('slv_support_events') }}
)

select *
from all_new_events
where event_payload is null
  or safe.parse_json(event_payload) is null
