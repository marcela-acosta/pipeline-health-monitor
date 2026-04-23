from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id="dag_hello_world",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["test"],
) as dag:
    hello = BashOperator(
        task_id="hello",
        bash_command="echo hello",
    )
