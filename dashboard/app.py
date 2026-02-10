"""
Stock Analytics Dashboard
Live Snowflake + dbt powered Streamlit application
"""

import streamlit as st
import pandas as pd
import plotly.express as px
from datetime import datetime
import snowflake.connector
import os
import snowflake.connector
# ============================================================================
# PAGE CONFIG
# ============================================================================

st.set_page_config(
    page_title="Stock Analytics Dashboard",
    page_icon="📈",
    layout="wide"
)

# ============================================================================
# CUSTOM STYLING
# ============================================================================

st.markdown("""
<style>
.main-header {
    font-size: 2.5rem;
    font-weight: bold;
    color: #1f77b4;
}
.sub-header {
    font-size: 1rem;
    color: #666;
}
.metric-card {
    background-color: #f0f2f6;
    padding: 20px;
    border-radius: 10px;
}
</style>
""", unsafe_allow_html=True)

# ============================================================================
# HEADER
# ============================================================================

st.markdown('<div class="main-header">📈 Stock Analytics Dashboard</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-header">Real-time Snowflake analytics powered by dbt</div>', unsafe_allow_html=True)
st.markdown("---")

# ============================================================================
# SNOWFLAKE CONNECTION
# ============================================================================

@st.cache_resource
def get_connection():
    return snowflake.connector.connect(
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
        database=os.environ["SNOWFLAKE_DATABASE"],
        schema=os.environ["SNOWFLAKE_SCHEMA"],
        role=os.environ["SNOWFLAKE_ROLE"],
    )

@st.cache_data(ttl=300)
def load_data():
    conn = get_connection()
    query = """
    SELECT 
        c.stock_symbol AS symbol,
        c.company_name,
        c.sector,
        c.country,
        f.market_cap_usd AS market_cap,
        f.stock_price_usd AS price,
        f.trading_volume AS volume,
        f.price_earnings_ratio AS pe_ratio,
        f.daily_dollar_volume
    FROM dim_company c
    JOIN fact_stock_observations f
      ON c.company_key = f.company_key
    WHERE f.observation_date = (
        SELECT MAX(observation_date) FROM fact_stock_observations
    )
    """
    return pd.read_sql(query, conn)

df_raw = load_data()
df_raw.columns = df_raw.columns.str.lower()


# ============================================================================
# SIDEBAR FILTERS
# ============================================================================

st.sidebar.header("🔍 Filter Options")

sectors = ["All"] + sorted(df_raw["sector"].dropna().unique())
selected_sector = st.sidebar.selectbox("Sector", sectors)

countries = ["All"] + sorted(df_raw["country"].dropna().unique())
selected_country = st.sidebar.selectbox("Country", countries)

market_cap_min = st.sidebar.number_input(
    "Minimum Market Cap (Millions USD)", 0.0, step=100.0
)

price_range = st.sidebar.slider(
    "Price Range",
    float(df_raw["price"].min()),
    float(df_raw["price"].max()),
    (float(df_raw["price"].min()), float(df_raw["price"].max()))
)

min_volume = st.sidebar.number_input(
    "Minimum Trading Volume", 0, step=100000
)

# ============================================================================
# APPLY FILTERS
# ============================================================================

df_filtered = df_raw.copy()

if selected_sector != "All":
    df_filtered = df_filtered[df_filtered["sector"] == selected_sector]

if selected_country != "All":
    df_filtered = df_filtered[df_filtered["country"] == selected_country]

df_filtered = df_filtered[df_filtered["market_cap"] >= market_cap_min * 1_000_000]

df_filtered = df_filtered[
    (df_filtered["price"] >= price_range[0]) &
    (df_filtered["price"] <= price_range[1])
]

df_filtered = df_filtered[df_filtered["volume"] >= min_volume]

if df_filtered.empty:
    st.warning("No results match your filters.")
    st.stop()

# ============================================================================
# KPI METRICS
# ============================================================================

st.subheader("📊 Key Metrics")

c1, c2, c3, c4 = st.columns(4)

with c1:
    st.metric("Total Stocks", len(df_filtered))

with c2:
    st.metric("Avg Price", f"${df_filtered['price'].mean():,.2f}")

with c3:
    st.metric(
        "Total Market Cap",
        f"${df_filtered['market_cap'].sum()/1e9:,.1f}B"
    )

with c4:
    st.metric(
        "Total Volume",
        f"{df_filtered['volume'].sum()/1e6:,.1f}M"
    )

st.markdown("---")

# ============================================================================
# VISUALS
# ============================================================================

tab1, tab2, tab3 = st.tabs(["📊 Sector", "🌍 Country", "💰 Price vs Cap"])

with tab1:
    sector_df = df_filtered.groupby("sector").agg(
        market_cap=("market_cap", "sum"),
        count=("symbol", "count")
    ).reset_index()

    fig1 = px.pie(
        sector_df,
        values="market_cap",
        names="sector",
        title="Market Cap by Sector"
    )
    st.plotly_chart(fig1, use_container_width=True)

with tab2:
    country_df = df_filtered.groupby("country").agg(
        market_cap=("market_cap", "sum")
    ).reset_index().sort_values("market_cap", ascending=False)

    fig2 = px.bar(
        country_df.head(10),
        x="country",
        y="market_cap",
        title="Top Countries by Market Cap"
    )
    st.plotly_chart(fig2, use_container_width=True)

with tab3:
    df_filtered = df_filtered.copy()
    df_filtered["market_cap_b"] = df_filtered["market_cap"] / 1e9

    fig3 = px.scatter(
        df_filtered,
        x="market_cap_b",
        y="price",
        color="sector",
        size="volume",
        hover_data=["symbol", "company_name"],
        title="Price vs Market Cap"
    )
    st.plotly_chart(fig3, use_container_width=True)

# ============================================================================
# DATA TABLE
# ============================================================================

st.subheader("📋 Top Stocks")

df_display = df_filtered[[
    "symbol", "company_name", "sector", "country",
    "price", "market_cap", "volume", "pe_ratio"
]].sort_values("market_cap", ascending=False)

st.dataframe(df_display.head(20), use_container_width=True)

# ============================================================================
# EXPORT
# ============================================================================

st.subheader("💾 Export")

csv = df_display.head(20).to_csv(index=False)

st.download_button(
    "Download CSV",
    csv,
    f"stocks_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
    "text/csv"
)

# ============================================================================
# AI SUMMARY (SIMULATED)
# ============================================================================

st.subheader("🤖 AI Summary")

if st.button("Generate Summary"):
    st.success(
        f"""
        Analyzed {len(df_filtered)} stocks.
        Largest sector: {df_filtered['sector'].value_counts().idxmax()}.
        Highest market cap: {df_filtered.iloc[0]['symbol']}.
        Average price: ${df_filtered['price'].mean():.2f}.
        """
    )

# ============================================================================
# FOOTER
# ============================================================================

st.markdown("---")
st.caption(f"Updated {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} | Powered by Snowflake + dbt + Streamlit")

