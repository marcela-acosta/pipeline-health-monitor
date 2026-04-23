-- fails when travel end date is before travel start date
select *
from {{ ref('slv_booking_events') }}
where travel_start_date is not null
  and travel_end_date is not null
  and travel_end_date < travel_start_date
