import os
from datetime import datetime, timedelta, timezone

from google.cloud import compute_v1
from google.cloud import monitoring_v3

PROJECT_ID = os.environ["PROJECT_ID"]
ZONE = os.environ["ZONE"]
VM_NAME = os.environ["VM_NAME"]
IDLE_MINUTES = int(os.environ.get("IDLE_THRESHOLD_MINUTES", "60"))
CPU_THRESHOLD = float(os.environ.get("CPU_THRESHOLD_PERCENT", "5"))


def get_vm_status() -> str:
    client = compute_v1.InstancesClient()
    instance = client.get(project=PROJECT_ID, zone=ZONE, instance=VM_NAME)
    return instance.status  # RUNNING | TERMINATED | STOPPED | STAGING


def get_avg_cpu(minutes: int) -> float:
    client = monitoring_v3.MetricServiceClient()
    project_name = f"projects/{PROJECT_ID}"
    now = datetime.now(timezone.utc)

    interval = monitoring_v3.TimeInterval(
        end_time=now,
        start_time=now - timedelta(minutes=minutes),
    )

    results = client.list_time_series(
        request={
            "name": project_name,
            "filter": (
                f'metric.type="compute.googleapis.com/instance/cpu/utilization"'
                f' AND resource.labels.instance_name="{VM_NAME}"'
            ),
            "interval": interval,
            "view": monitoring_v3.ListTimeSeriesRequest.TimeSeriesView.FULL,
        }
    )

    values = [
        point.value.double_value * 100 for series in results for point in series.points
    ]

    return sum(values) / len(values) if values else 0.0


def stop_vm() -> None:
    client = compute_v1.InstancesClient()
    operation = client.stop(project=PROJECT_ID, zone=ZONE, instance=VM_NAME)
    print(f"Stop operation started: {operation.name}")


def main() -> None:
    print(f"[vm-idle-checker] VM={VM_NAME} project={PROJECT_ID} zone={ZONE}")

    status = get_vm_status()
    print(f"Status: {status}")

    if status != "RUNNING":
        print("VM is not running — nothing to do.")
        return

    avg_cpu = get_avg_cpu(IDLE_MINUTES)
    print(f"Avg CPU last {IDLE_MINUTES} min: {avg_cpu:.2f}%")

    if avg_cpu < CPU_THRESHOLD:
        print(f"CPU below {CPU_THRESHOLD}% for {IDLE_MINUTES} min → stopping VM.")
        stop_vm()
    else:
        print("VM is active — no action taken.")


if __name__ == "__main__":
    main()
