# PostgreSQL Telemetry Demo

Minimal toolkit to stand up a telemetry table in PostgreSQL, seed it with fake data, and explore it with a Streamlit viewer.

## Contents
- `telemetry_setup.sql` — creates the `telemetry` schema, `records` table, and indexes.
- `telemetry_seed.sql` — inserts a configurable batch of synthetic records from the last 60 minutes.
- `telemetry_viewer.py` — Streamlit app that lists recent records and plots numeric values.

## Prerequisites
- PostgreSQL running locally and accessible to the user in the connection string.
- Python 3.9+ with `pip` available.

## Setup
1) Create schema and table:
```bash
psql -U postgres -d postgres -f telemetry_setup.sql
```

2) Seed fake data (defaults to 10,000 rows; change `n` in the script to adjust):
```bash
psql -U postgres -d postgres -f telemetry_seed.sql
```

3) Install Python dependencies (example with a virtualenv):
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install streamlit pandas sqlalchemy psycopg2-binary
```

## Run the viewer
The Streamlit app queries the last 60 minutes of data and supports filtering by device ID and metric.

```bash
streamlit run telemetry_viewer.py
```

## Connection settings
`telemetry_viewer.py` uses the connection string `postgresql+psycopg2://postgres:088914@localhost:5432/postgres`. Update this string to match your local credentials or set up a role/password that matches it before running the app.

## Table layout
- `ts` (timestamptz), `device_id` (text), `site` (text), `metric` (text), `value_num` (double precision), `value_text` (text), `status` (smallint), `payload` (jsonb, default `{}`).
- Useful indexes: descending `ts`, `(device_id, ts)`, `(metric, ts)`, and a GIN index on `payload`.

## Seeding details
The seed script spreads timestamps across the last 60 minutes, generates up to 50 devices, picks metrics from temperature, vibration, motor current, belt speed, and CPU load, assigns realistic numeric ranges, and adds a small percentage of warning/fault statuses. It also returns quick counts at the end for verification.
