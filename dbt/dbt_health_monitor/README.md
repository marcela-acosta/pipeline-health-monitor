# dbt_health_monitor

Starter dbt project for BigQuery using medallion architecture.

## Architecture

- `models/bronze`: raw-aligned ingestion layer
- `models/silver`: cleaned and standardized layer
- `models/gold`: business-ready marts and metrics

## BigQuery setup

1. Copy `profiles.yml.example` into your dbt profiles directory (`~/.dbt/profiles.yml`).
2. Replace placeholders with your GCP project, dataset, and service account path.
3. Install dependencies:

```bash
dbt deps
```

## Quick start

```bash
cd dbt/dbt_health_monitor
dbt debug
dbt build
```

## Included tests

- Generic tests in model schema files (`not_null`, `unique`, `accepted_values`)
- Package test (`dbt_utils.unique_combination_of_columns`)
- Singular SQL data tests in `tests/`
