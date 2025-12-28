-- telemetry_seed.sql
-- Inserisce N record di telemetria finta negli ultimi 60 minuti
DO $$
DECLARE
  n integer := 10000; -- cambia qui la quantità
BEGIN
  INSERT INTO telemetry.records (ts, device_id, site, metric, value_num, status, payload)
  SELECT
    now() - (random() * interval '60 minutes') AS ts,
    'DEV-' || lpad(((1 + floor(random()*50))::int)::text, 4, '0') AS device_id,
    (ARRAY['MILANO','ROMA','TORINO','BOLOGNA'])[1 + floor(random()*4)] AS site,
    (ARRAY['temperature','vibration','motor_current','belt_speed','cpu_load'])[1 + floor(random()*5)] AS metric,
    -- value_num diverso per metrica (range realistici)
    CASE
      WHEN m = 'temperature'   THEN 15 + random()*40
      WHEN m = 'vibration'     THEN random()*8
      WHEN m = 'motor_current' THEN 1 + random()*30
      WHEN m = 'belt_speed'    THEN 0.1 + random()*3.0
      WHEN m = 'cpu_load'      THEN random()*100
      ELSE random()*10
    END AS value_num,
    CASE WHEN random() < 0.97 THEN 0 ELSE 2 END AS status, -- 3% warning/fault
    jsonb_build_object(
      'seq', (1000000 + floor(random()*9000000))::bigint,
      'fw', (ARRAY['1.0.3','1.1.0','1.2.2','2.0.1'])[1 + floor(random()*4)],
      'ip', format('10.%s.%s.%s',
                   (1 + floor(random()*254))::int,
                   (1 + floor(random()*254))::int,
                   (1 + floor(random()*254))::int),
      'unit',
        CASE
          WHEN m='temperature' THEN 'C'
          WHEN m='vibration' THEN 'mm/s'
          WHEN m='motor_current' THEN 'A'
          WHEN m='belt_speed' THEN 'm/s'
          WHEN m='cpu_load' THEN '%'
          ELSE ''
        END,
      'meta', jsonb_build_object('line', (1 + floor(random()*6))::int, 'shift', (ARRAY['A','B','C'])[1 + floor(random()*3)])
    ) AS payload
  FROM (
    SELECT (ARRAY['temperature','vibration','motor_current','belt_speed','cpu_load'])[1 + floor(random()*5)] AS m
    FROM generate_series(1, n)
  ) s;
END $$;

-- Verifica rapida
SELECT
  count(*) AS total,
  min(ts)  AS oldest,
  max(ts)  AS newest
FROM telemetry.records;

-- Top metriche
SELECT metric, count(*) cnt
FROM telemetry.records
GROUP BY metric
ORDER BY cnt DESC;