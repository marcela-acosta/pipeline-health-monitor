-- fails if any run has negative duration
select *
from {{ ref('slv_health_events') }}
where run_duration_seconds < 0
