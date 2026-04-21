{{ config(tags=["gold"]) }}

with events as (
  select *
  from {{ ref('slv_health_events') }}
)

select
  pipeline_name,
  date(event_ts) as event_date,
  count(*) as total_runs,
  countif(status = 'success') as successful_runs,
  countif(status = 'failed') as failed_runs,
  avg(run_duration_seconds) as avg_run_duration_seconds
from events
group by 1, 2
