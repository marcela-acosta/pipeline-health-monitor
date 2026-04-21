{{ config(tags=["silver"]) }}

with bronze as (
  select *
  from {{ ref('brz_health_events') }}
)

select
  {{ generate_event_sk(['event_id', 'event_ts']) }} as event_sk,
  event_id,
  pipeline_name,
  lower(status) as status,
  event_ts,
  run_duration_seconds,
  ingested_at
from bronze
