#!/bin/bash

PROJECT_ID="pipeline-health-mon-2026"
DATASET="bronze"

cd ~/pipelines/bronze
source ~/beam-venv/bin/activate

# 1. Create topics
for topic in search-events hotel-events flight-events cancellation-events review-events support-events marketing-events
do
  gcloud pubsub topics create $topic --project=$PROJECT_ID 2>/dev/null || true
done

# 2. Create subscriptions
for topic in search-events hotel-events flight-events cancellation-events review-events support-events marketing-events
do
  gcloud pubsub subscriptions create ${topic}-sub \
    --topic=$topic \
    --project=$PROJECT_ID 2>/dev/null || true
done

# 3. Start pipelines

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/search-events-sub \
  --table $PROJECT_ID:$DATASET.search_events \
  --schema "search_id:STRING,customer_id:STRING,search_date:STRING,origin_city:STRING,destination_city:STRING,destination_country:STRING,travel_start_date:STRING,travel_end_date:STRING,number_of_guests:INTEGER,device_type:STRING,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > search_events.log 2>&1 &

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/hotel-events-sub \
  --table $PROJECT_ID:$DATASET.hotel_events \
  --schema "hotel_id:STRING,booking_id:STRING,customer_id:STRING,hotel_name:STRING,city:STRING,country:STRING,check_in_date:STRING,check_out_date:STRING,room_type:STRING,number_of_nights:INTEGER,total_room_amount:FLOAT64,currency:STRING,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > hotel_events.log 2>&1 &

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/flight-events-sub \
  --table $PROJECT_ID:$DATASET.flight_events \
  --schema "flight_id:STRING,booking_id:STRING,customer_id:STRING,airline:STRING,flight_number:STRING,departure_city:STRING,arrival_city:STRING,departure_datetime:STRING,arrival_datetime:STRING,ticket_class:STRING,ticket_amount:FLOAT64,currency:STRING,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > flight_events.log 2>&1 &

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/cancellation-events-sub \
  --table $PROJECT_ID:$DATASET.cancellation_events \
  --schema "cancellation_id:STRING,booking_id:STRING,customer_id:STRING,cancellation_date:STRING,cancellation_reason:STRING,refund_status:STRING,refund_amount:FLOAT64,currency:STRING,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > cancellation_events.log 2>&1 &

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/review-events-sub \
  --table $PROJECT_ID:$DATASET.review_events \
  --schema "review_id:STRING,booking_id:STRING,customer_id:STRING,review_date:STRING,rating:INTEGER,review_title:STRING,review_comment:STRING,service_category:STRING,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > review_events.log 2>&1 &

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/support-events-sub \
  --table $PROJECT_ID:$DATASET.support_events \
  --schema "ticket_id:STRING,customer_id:STRING,booking_id:STRING,created_date:STRING,closed_date:STRING,ticket_status:STRING,priority:STRING,issue_category:STRING,assigned_agent:STRING,resolution_time_hours:FLOAT64,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > support_events.log 2>&1 &

nohup python bronze_pipeline.py \
  --subscription projects/$PROJECT_ID/subscriptions/marketing-events-sub \
  --table $PROJECT_ID:$DATASET.marketing_events \
  --schema "campaign_id:STRING,customer_id:STRING,event_date:STRING,campaign_name:STRING,channel:STRING,event_type:STRING,device_type:STRING,country:STRING,city:STRING,created_at:STRING,updated_at:STRING,ingested_at:TIMESTAMP" \
  > marketing_events.log 2>&1 &

echo "7 missing pipelines started."
ps aux | grep bronze_pipeline.py | grep -v grep
