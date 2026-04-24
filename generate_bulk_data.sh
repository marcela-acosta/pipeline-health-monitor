#!/bin/bash

for i in {1..200}
do
  gcloud pubsub topics publish search-events --message="{\"search_id\":\"S$i\",\"customer_id\":\"C$i\",\"search_date\":\"2026-04-22T09:00:00\",\"origin_city\":\"Queretaro\",\"destination_city\":\"Cancun\",\"destination_country\":\"Mexico\",\"travel_start_date\":\"2026-05-01\",\"travel_end_date\":\"2026-05-07\",\"number_of_guests\":$((RANDOM%5+1)),\"device_type\":\"mobile\",\"created_at\":\"2026-04-22T09:00:00\",\"updated_at\":\"2026-04-22T09:01:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish booking-events --message="{\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"booking_date\":\"2026-04-22\",\"travel_start_date\":\"2026-05-01\",\"travel_end_date\":\"2026-05-07\",\"booking_status\":\"confirmed\",\"total_amount\":$((RANDOM%2000+500)),\"currency\":\"USD\",\"destination_city\":\"Cancun\",\"destination_country\":\"Mexico\",\"channel\":\"web\",\"created_at\":\"2026-04-22T10:00:00\",\"updated_at\":\"2026-04-22T10:05:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish payment-events --message="{\"payment_id\":\"P$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"payment_date\":\"2026-04-22T10:15:00\",\"payment_method\":\"card\",\"payment_status\":\"paid\",\"amount\":$((RANDOM%2000+500)),\"currency\":\"USD\",\"transaction_reference\":\"TXN$i\",\"updated_at\":\"2026-04-22T10:16:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish hotel-events --message="{\"hotel_id\":\"H$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"hotel_name\":\"Ocean Resort\",\"city\":\"Cancun\",\"country\":\"Mexico\",\"check_in_date\":\"2026-05-01\",\"check_out_date\":\"2026-05-07\",\"room_type\":\"deluxe\",\"number_of_nights\":6,\"total_room_amount\":$((RANDOM%1500+300)),\"currency\":\"USD\",\"created_at\":\"2026-04-22T09:05:00\",\"updated_at\":\"2026-04-22T09:06:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish flight-events --message="{\"flight_id\":\"F$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"airline\":\"Aeromexico\",\"flight_number\":\"AM$i\",\"departure_city\":\"Mexico City\",\"arrival_city\":\"Cancun\",\"departure_datetime\":\"2026-05-01T08:00:00\",\"arrival_datetime\":\"2026-05-01T10:20:00\",\"ticket_class\":\"economy\",\"ticket_amount\":$((RANDOM%800+200)),\"currency\":\"USD\",\"created_at\":\"2026-04-22T09:10:00\",\"updated_at\":\"2026-04-22T09:11:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish review-events --message="{\"review_id\":\"R$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"review_date\":\"2026-05-08\",\"rating\":$((RANDOM%5+1)),\"review_title\":\"Good\",\"review_comment\":\"Nice trip\",\"service_category\":\"travel\",\"created_at\":\"2026-05-08T12:00:00\",\"updated_at\":\"2026-05-08T12:05:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish support-events --message="{\"ticket_id\":\"T$i\",\"customer_id\":\"C$i\",\"booking_id\":\"B$i\",\"created_date\":\"2026-04-22T13:00:00\",\"closed_date\":\"2026-04-22T15:30:00\",\"ticket_status\":\"closed\",\"priority\":\"medium\",\"issue_category\":\"payment\",\"assigned_agent\":\"Agent$i\",\"resolution_time_hours\":$((RANDOM%5+1)),\"created_at\":\"2026-04-22T13:00:00\",\"updated_at\":\"2026-04-22T15:30:00\"}" >/dev/null 2>&1 &

  gcloud pubsub topics publish marketing-events --message="{\"campaign_id\":\"M$i\",\"customer_id\":\"C$i\",\"event_date\":\"2026-04-22T08:30:00\",\"campaign_name\":\"Campaign$i\",\"channel\":\"email\",\"event_type\":\"opened\",\"device_type\":\"mobile\",\"country\":\"Mexico\",\"city\":\"Queretaro\",\"created_at\":\"2026-04-22T08:30:00\",\"updated_at\":\"2026-04-22T08:31:00\"}" >/dev/null 2>&1 &
done

echo "Bulk data sent"
