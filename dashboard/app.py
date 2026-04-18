import os
import pandas as pd
import streamlit as st

# Toggle: set USE_MOCK=false once gold.pipeline_by_stage exists in BigQuery
USE_MOCK = os.environ.get("USE_MOCK", "true").lower() == "true"

# Funnel stages in pipeline order (top → bottom)
STAGE_ORDER = [
    "Prospección",
    "Calificado",
    "Propuesta",
    "Negociación",
    "Ganado",
    "Perdido",
]


def get_mock_data() -> pd.DataFrame:
    # Realistic funnel shape: volume decreases toward the bottom
    return pd.DataFrame(
        {
            "stage": STAGE_ORDER,
            "total_opportunities": [120, 85, 52, 30, 18, 22],
            "total_value": [980000, 712000, 445000, 268000, 195000, 134000],
        }
    )


@st.cache_data(ttl=60)  # refresh every 60 seconds
def get_pipeline_by_stage() -> pd.DataFrame:
    if USE_MOCK:
        return get_mock_data()

    from google.cloud import bigquery  # imported here so mock mode needs no GCP auth

    project_id = os.environ.get("GCP_PROJECT", "pipeline-health-mon-2026")
    client = bigquery.Client()
    query = f"SELECT * FROM `{project_id}.gold.pipeline_by_stage`"
    df = client.query(query).to_dataframe()

    # Enforce stage order even if BigQuery returns rows in arbitrary order
    df["stage"] = pd.Categorical(df["stage"], categories=STAGE_ORDER, ordered=True)
    return df.sort_values("stage").reset_index(drop=True)


# ── Page config ───────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="Pipeline Health Monitor",
    page_icon="🟢",
    layout="wide",
)

st.title("Pipeline Health Monitor 🟢 EN VIVO")

if USE_MOCK:
    st.info("Running with mock data — connect BigQuery by setting USE_MOCK=false")

# ── Load data ─────────────────────────────────────────────────────────────────
df = get_pipeline_by_stage()

# ── KPI summary row ───────────────────────────────────────────────────────────
col1, col2, col3 = st.columns(3)
col1.metric("Total Opportunities", f"{df['total_opportunities'].sum():,}")
col2.metric("Total Pipeline Value", f"${df['total_value'].sum():,.0f}")
col3.metric(
    "Win Rate",
    f"{df.loc[df['stage'] == 'Ganado', 'total_opportunities'].sum() / df['total_opportunities'].sum() * 100:.1f}%",
)

st.divider()

# ── Charts ────────────────────────────────────────────────────────────────────
left, right = st.columns(2)

with left:
    st.subheader("Opportunities by Stage")
    st.bar_chart(df.set_index("stage")["total_opportunities"])

with right:
    st.subheader("Pipeline Value by Stage ($)")
    st.bar_chart(df.set_index("stage")["total_value"])

# ── Detail table ──────────────────────────────────────────────────────────────
st.subheader("Stage Breakdown")
st.dataframe(
    df.style.format({"total_value": "${:,.0f}", "total_opportunities": "{:,}"}),
    use_container_width=True,
    hide_index=True,
)
