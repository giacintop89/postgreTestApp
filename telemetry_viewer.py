import pandas as pd
import streamlit as st
from sqlalchemy import create_engine

# Connessione PostgreSQL
engine = create_engine(
    "postgresql+psycopg2://postgres:088914@localhost:5432/postgres"
)

st.title("Telemetry Viewer")

# Filtri
device = st.text_input("Device ID (es. DEV-0001)", "")
metric = st.selectbox(
    "Metric",
    ["all", "temperature", "vibration", "motor_current", "belt_speed", "cpu_load"]
)

query = """
SELECT ts, device_id, metric, value_num, status
FROM telemetry.records
WHERE ts > now() - interval '60 minutes'
"""

if device:
    query += f" AND device_id = '{device}'"
if metric != "all":
    query += f" AND metric = '{metric}'"

query += " ORDER BY ts DESC LIMIT 500"

df = pd.read_sql(query, engine)
# df.to_csv("C:\\Users\\UTENTE\\telemetry_snapshot.csv", index=False)

st.dataframe(df, use_container_width=True)

# Grafico
if not df.empty:
    st.line_chart(
        df.sort_values("ts").set_index("ts")["value_num"]
    )