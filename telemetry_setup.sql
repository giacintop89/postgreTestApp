-- telemetry_setup.sql
CREATE SCHEMA IF NOT EXISTS telemetry;

CREATE TABLE IF NOT EXISTS telemetry.records (
  id           BIGSERIAL PRIMARY KEY,
  ts           TIMESTAMPTZ NOT NULL DEFAULT now(),
  device_id    TEXT        NOT NULL,
  site         TEXT        NOT NULL,
  metric       TEXT        NOT NULL,
  value_num    DOUBLE PRECISION,
  value_text   TEXT,
  status       SMALLINT    NOT NULL DEFAULT 0,
  payload      JSONB       NOT NULL DEFAULT '{}'::jsonb
);

-- Indici utili per query tipiche
CREATE INDEX IF NOT EXISTS ix_records_ts        ON telemetry.records (ts DESC);
CREATE INDEX IF NOT EXISTS ix_records_device_ts ON telemetry.records (device_id, ts DESC);
CREATE INDEX IF NOT EXISTS ix_records_metric_ts ON telemetry.records (metric, ts DESC);
CREATE INDEX IF NOT EXISTS ix_records_payload   ON telemetry.records USING GIN (payload);