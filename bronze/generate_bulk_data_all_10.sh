#!/bin/bash

for i in $(seq 1 100)
do
  gcloud pubsub topics publish customer-events --message="{\"customer_id\":\"C$i\",\"full_name\":\"Customer $i\",\"email\":\"customer$i@email.com\",\"phone\":\"442000$i\",\"country\":\"Mexico\",\"city\":\"Queretaro\",\"customer_segment\":\"premium\",\"loyalty_tier\":\"gold\",\"created_at\":\"2026-04-22T09:00:00\",\"updated_at\":\"2026-04-22T09:01:00\"}" >/dev/null

  gcloud pubsub topics publish booking-events --message="{\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"booking_date\":\"2026-04-22\",\"travel_start_date\":\"2026-05-01\",\"travel_end_date\":\"2026-05-07\",\"booking_status\":\"confirmed\",\"total_amount\":1000,\"currency\":\"USD\",\"destination_city\":\"Cancun\",\"destination_country\":\"Mexico\",\"channel\":\"web\",\"created_at\":\"2026-04-22T10:00:00\",\"updated_at\":\"2026-04-22T10:05:00\"}" >/dev/null

  gcloud pubsub topics publish payment-events --message="{\"payment_id\":\"P$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"payment_date\":\"2026-04-22T10:15:00\",\"payment_method\":\"card\",\"payment_status\":\"paid\",\"amount\":1000,\"currency\":\"USD\",\"transaction_reference\":\"TXN$i\",\"updated_at\":\"2026-04-22T10:16:00\"}" >/dev/null

  gcloud pubsub topics publish search-events --message="{\"search_id\":\"S$i\",\"customer_id\":\"C$i\",\"search_date\":\"2026-04-22T09:00:00\",\"origin_city\":\"Queretaro\",\"destination_city\":\"Cancun\",\"destination_country\":\"Mexico\",\"travel_start_date\":\"2026-05-01\",\"travel_end_date\":\"2026-05-07\",\"number_of_guests\":2,\"device_type\":\"mobile\",\"created_at\":\"2026-04-22T09:00:00\",\"updated_at\":\"2026-04-22T09:01:00\"}" >/dev/null

  gcloud pubsub topics publish hotel-events --message="{\"hotel_id\":\"H$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"hotel_name\":\"Ocean Resort\",\"city\":\"Cancun\",\"country\":\"Mexico\",\"check_in_date\":\"2026-05-01\",\"check_out_date\":\"2026-05-07\",\"room_type\":\"deluxe\",\"number_of_nights\":6,\"total_room_amount\":900,\"currency\":\"USD\",\"created_at\":\"2026-04-22T09:05:00\",\"updated_at\":\"2026-04-22T09:06:00\"}" >/dev/null

  gcloud pubsub topics publish flight-events --message="{\"flight_id\":\"F$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"airline\":\"Aeromexico\",\"flight_number\":\"AM$i\",\"departure_city\":\"Mexico City\",\"arrival_city\":\"Cancun\",\"departure_datetime\":\"2026-05-01T08:00:00\",\"arrival_datetime\":\"2026-05-01T10:20:00\",\"ticket_class\":\"economy\",\"ticket_amount\":350,\"currency\":\"USD\",\"created_at\":\"2026-04-22T09:10:00\",\"updated_at\":\"2026-04-22T09:11:00\"}" >/dev/null

  gcloud pubsub topics publish cancellation-events --message="{\"cancellation_id\":\"X$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"cancellation_date\":\"2026-04-23T11:00:00\",\"cancellation_reason\":\"customer_request\",\"refund_status\":\"approved\",\"refund_amount\":500,\"currency\":\"USD\",\"created_at\":\"2026-04-23T11:00:00\",\"updated_at\":\"2026-04-23T11:10:00\"}" >/dev/null

  gcloud pubsub topics publish review-events --message="{\"review_id\":\"R$i\",\"booking_id\":\"B$i\",\"customer_id\":\"C$i\",\"review_date\":\"2026-05-08\",\"rating\":5,\"review_title\":\"Good experience\",\"review_comment\":\"The trip was smooth\",\"service_category\":\"travel\",\"created_at\":\"2026-05-08T12:00:00\",\"updated_at\":\"2026-05-08T12:05:00\"}" >/dev/null

  gcloud pubsub topics publish support-events --message="{\"ticket_id\":\"T$i\",\"customer_id\":\"C$i\",\"booking_id\":\"B$i\",\"created_date\":\"2026-04-22T13:00:00\",\"closed_date\":\"2026-04-22T15:30:00\",\"ticket_status\":\"closed\",\"priority\":\"medium\",\"issue_category\":\"payment_question\",\"assigned_agent\":\"Agent $i\",\"resolution_time_hours\":2.5,\"created_at\":\"2026-04-22T13:00:00\",\"updated_at\":\"2026-04-22T15:30:00\"}" >/dev/null

  gcloud pubsub topics publish marketing-events --message="{\"campaign_id\":\"M$i\",\"customer_id\":\"C$i\",\"event_date\":\"2026-04-22T08:30:00\",\"campaign_name\":\"Summer Travel Deals\",\"channel\":\"email\",\"event_type\":\"opened\",\"device_type\":\"mobile\",\"country\":\"Mexico\",\"city\":\"Queretaro\",\"created_at\":\"2026-04-22T08:30:00\",\"updated_at\":\"2026-04-22T08:31:00\"}" >/dev/null

  echo "Sent batch $i"
  sleep 0.05
done

echo "Bulk data for all 10 tables sent correctly"
