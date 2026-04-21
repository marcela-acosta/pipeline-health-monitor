{{ config(tags=["bronze"]) }}

select
  cast(null as string) as event_id,
  cast(null as string) as pipeline_name,
  cast(null as string) as status,
  cast(null as timestamp) as event_ts,
  cast(null as int64) as run_duration_seconds,
  cast(null as timestamp) as ingested_at
where false
