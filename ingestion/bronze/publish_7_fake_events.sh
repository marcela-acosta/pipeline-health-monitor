#!/bin/bash

gcloud pubsub topics publish search-events --message='{"search_id":"S001","customer_id":"C001","search_date":"2026-04-22T09:00:00","origin_city":"Queretaro","destination_city":"Cancun","destination_country":"Mexico","travel_start_date":"2026-05-01","travel_end_date":"2026-05-07","number_of_guests":2,"device_type":"mobile","created_at":"2026-04-22T09:00:00","updated_at":"2026-04-22T09:01:00"}'

gcloud pubsub topics publish hotel-events --message='{"hotel_id":"H001","booking_id":"B001","customer_id":"C001","hotel_name":"Ocean View Resort","city":"Cancun","country":"Mexico","check_in_date":"2026-05-01","check_out_date":"2026-05-07","room_type":"deluxe","number_of_nights":6,"total_room_amount":900.50,"currency":"USD","created_at":"2026-04-22T09:05:00","updated_at":"2026-04-22T09:06:00"}'

gcloud pubsub topics publish flight-events --message='{"flight_id":"F001","booking_id":"B001","customer_id":"C001","airline":"Aeromexico","flight_number":"AM245","departure_city":"Mexico City","arrival_city":"Cancun","departure_datetime":"2026-05-01T08:00:00","arrival_datetime":"2026-05-01T10:20:00","ticket_class":"economy","ticket_amount":350.25,"currency":"USD","created_at":"2026-04-22T09:10:00","updated_at":"2026-04-22T09:11:00"}'

gcloud pubsub topics publish cancellation-events --message='{"cancellation_id":"X001","booking_id":"B002","customer_id":"C002","cancellation_date":"2026-04-22T11:00:00","cancellation_reason":"customer_request","refund_status":"approved","refund_amount":500.00,"currency":"USD","created_at":"2026-04-22T11:00:00","updated_at":"2026-04-22T11:10:00"}'

gcloud pubsub topics publish review-events --message='{"review_id":"R001","booking_id":"B001","customer_id":"C001","review_date":"2026-05-08","rating":5,"review_title":"Excellent experience","review_comment":"The trip was smooth and the service was great","service_category":"travel_package","created_at":"2026-05-08T12:00:00","updated_at":"2026-05-08T12:05:00"}'

gcloud pubsub topics publish support-events --message='{"ticket_id":"T001","customer_id":"C001","booking_id":"B001","created_date":"2026-04-22T13:00:00","closed_date":"2026-04-22T15:30:00","ticket_status":"closed","priority":"medium","issue_category":"payment_question","assigned_agent":"Laura Smith","resolution_time_hours":2.5,"created_at":"2026-04-22T13:00:00","updated_at":"2026-04-22T15:30:00"}'

gcloud pubsub topics publish marketing-events --message='{"campaign_id":"M001","customer_id":"C001","event_date":"2026-04-22T08:30:00","campaign_name":"Summer Travel Deals","channel":"email","event_type":"opened","device_type":"mobile","country":"Mexico","city":"Queretaro","created_at":"2026-04-22T08:30:00","updated_at":"2026-04-22T08:31:00"}'

echo "Fake events published."
