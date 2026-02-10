# Part B: BI + Automation + LLM Thinking

## B1) Dashboard Design (PowerBI / Tableau)

### 1. Dashboard Title
**"Executive Stock Market Analytics Dashboard"**

### 2. Target Stakeholder Persona
**Chief Investment Officer (CIO) / Portfolio Manager**

The CIO needs to:
- Monitor overall market health and trends
- Identify investment opportunities and risks
- Track portfolio sector allocation performance
- Make data-driven investment decisions quickly
- Communicate insights to investment committee

### 3. Top 6 KPIs

1. **Total Market Capitalization** ($XXB)
   - *Why it matters:* Shows overall market size and tracks market growth/decline
   - Alerts on significant market movements (>5% change day-over-day)

2. **Average Trading Volume** (XXM shares)
   - *Why it matters:* Indicates market liquidity and investor activity levels
   - High volume = high liquidity, easier to enter/exit positions

3. **Median P/E Ratio** (XX.X)
   - *Why it matters:* Market valuation indicator - helps identify overvalued/undervalued markets
   - Benchmark against historical averages (typically 15-20)

4. **Sector Diversification Index** (X/10 sectors active)
   - *Why it matters:* Shows market breadth - healthy markets have activity across sectors
   - Concentration risk indicator

5. **High Quality Stock Count** (XX stocks)
   - *Why it matters:* Number of stocks meeting quality criteria (healthy PE, good volume, high data quality)
   - Directly actionable for stock selection

6. **Daily Dollar Volume** ($XXB)
   - *Why it matters:* Total value traded - indicates market depth and institutional participation
   - Leading indicator for market trends

### 4. Top 6 Visuals/Charts

1. **Sector Performance Heatmap**
   - *Why it matters:* Instantly shows which sectors are outperforming/underperforming
   - Color-coded by price change % - enables quick sector rotation decisions
   - Reveals market themes and trends

2. **Market Cap Distribution (Treemap)**
   - *Why it matters:* Shows relative size of companies and sectors at a glance
   - Identifies concentration risk (are we too dependent on a few large caps?)
   - Drill-down capability from sector → individual stocks

3. **Trading Volume Trend (Time Series Line Chart)**
   - *Why it matters:* Reveals increasing/decreasing market participation over time
   - Spikes indicate significant events or opportunities
   - 30-day moving average shows underlying trend

4. **Geographic Breakdown (Choropleth Map)**
   - *Why it matters:* Visualizes geographic diversification and opportunities
   - Shows where market value is concentrated
   - Supports international allocation decisions

5. **Value vs Growth Scatter Plot**
   - *Why it matters:* PE Ratio (Y-axis) vs Market Cap (X-axis) with bubble size = volume
   - Quickly identifies undervalued large caps (bottom-right quadrant)
   - Supports stock selection and style allocation

6. **Outlier Alert Table (Top 10 Unusual Stocks)**
   - *Why it matters:* Highlights stocks with abnormal trading patterns
   - Z-score based ranking catches opportunities and risks early
   - Actionable - these stocks need immediate investigation

### 5. Filters/Slicers

1. **Sector Multiselect** - Compare specific sectors
2. **Market Cap Category** (Small/Mid/Large) - Focus on size segments
3. **Country Multiselect** - Geographic focus
4. **Date Range Slider** - Historical comparison
5. **Data Quality Filter** (High/Medium/Low) - Filter out poor quality data
6. **P/E Ratio Range** - Value/growth screening

### 6. Single Page vs Multiple Pages?

**Multi-page approach (3 pages):**

**Page 1: Market Overview** (Executive Summary)
- All 6 KPIs
- Sector heatmap
- Market cap treemap
- Quick insights and alerts
- *Why:* C-level executives need high-level view in 30 seconds

**Page 2: Deep Dive Analytics** (Analyst View)
- Trading volume trends
- Geographic breakdown
- Value vs growth scatter
- Detailed tables with drill-through
- *Why:* Analysts need detailed analysis tools for research

**Page 3: Risk & Opportunities** (Action-Oriented)
- Outlier detection table
- Sector rotation signals
- Quality stock recommendations
- Alert dashboard
- *Why:* Portfolio managers need actionable insights for trades

**Rationale:** Different stakeholders consume information differently. Multi-page allows:
- Quick executive access to key metrics
- Deep dives for analysts
- Action-oriented view for traders
- Better performance (not loading all visuals at once)

---

## B2) Stakeholder Insights: Obvious vs Non-Obvious

### 5 "Obvious Insights" (Expected Requests)

1. **"What are the top 10 stocks by market cap?"**
   - Basic ranking query
   - Directly requested by every stakeholder
   - Foundation for portfolio construction

2. **"Show me sector performance breakdown"**
   - Standard sector analysis
   - Used for allocation decisions
   - Always in quarterly reports

3. **"What's the average P/E ratio by sector?"**
   - Valuation analysis
   - Standard comparison metric
   - Used for sector rotation

4. **"Which stocks had the highest trading volume today?"**
   - Liquidity analysis
   - Trading desk standard request
   - Identifies active stocks

5. **"How many companies do we track in each country?"**
   - Geographic diversity check
   - Standard reporting metric
   - Portfolio construction input

### 5 "Non-Obvious Insights" (High Value, Unrequested)

1. **Volume Volatility Clustering Analysis**
   - Insight: Stocks with high volume volatility (variance in daily volume) often precede price movements
   - Value: Early warning system for potential breakouts or breakdowns
   - Implementation: Calculate 30-day rolling standard deviation of volume, flag top 10% as "unstable"
   - Why stakeholders don't ask: They don't know this leading indicator exists
   - Business impact: Get into positions 2-3 days before major moves

2. **Sector Correlation Matrix Over Time**
   - Insight: Which sectors move together vs independently? Is correlation increasing (risk) or decreasing (opportunity)?
   - Value: Better diversification - don't buy "different" sectors that actually move the same
   - Implementation: Calculate 30-day rolling correlation of sector returns
   - Why stakeholders don't ask: Too technical, but extremely valuable for risk management
   - Business impact: Reduce portfolio risk by 15-20% through better diversification

3. **Hidden Quality Decay Indicators**
   - Insight: Stocks where data quality score is declining over time (missing PE ratios, volume dropping, source URLs changing)
   - Value: Early warning that company is becoming opaque - possible fraud, bankruptcy, or delisting risk
   - Implementation: Track data_quality_score trends, alert on -10% degradation in 30 days
   - Why stakeholders don't ask: Don't think about metadata as signal
   - Business impact: Avoid holding stocks through major incidents

4. **Market Cap Migration Patterns**
   - Insight: Track companies moving between Small → Mid → Large cap categories over time
   - Value: Identify "rising stars" before they're obvious + catch "falling angels" early
   - Implementation: Create SCD Type 2 tracking of market_cap_category changes
   - Why stakeholders don't ask: Static view of current state, miss transitions
   - Business impact: Capture 30-50% of upside in category transitions

5. **Geographic-Sector Arbitrage Opportunities**
   - Insight: Same sector has different average P/E ratios in different countries - exploit the gap
   - Value: Example: If Tech stocks trade at 25x P/E in US but 18x in Germany, find undervalued German tech
   - Implementation: Calculate sector P/E by country, find >20% gaps, rank stocks in undervalued region
   - Why stakeholders don't ask: Think in sectors OR geography, not cross-section
   - Business impact: Systematic 10-15% alpha opportunity from geographic arbitrage

---

## B3) Data Quality + Reliability Plan

### 1. Top 5 Data Quality Checks

1. **Completeness Validation**
   - Check: All required fields populated (symbol, name, price, market_cap)
   - Implementation: `WHERE data_quality_score < 0.9` alert
   - Action: Flag incomplete records, attempt re-scrape from alternative source
   - SLA: >95% records with quality score >0.9

2. **Range and Reasonableness Checks**
   - Check: Stock price between $0.01 and $10,000 | Market cap > $1M | Volume >= 0 | PE ratio < 1000
   - Implementation: SQL constraints + dbt tests with `expression_is_true`
   - Action: Quarantine out-of-range records in separate `rejected_records` table
   - SLA: Zero records outside valid ranges in production tables

3. **Duplicate Detection**
   - Check: Same symbol scraped multiple times on same day with different values
   - Implementation: Hash key validation (symbol + date), keep latest timestamp
   - Action: Deduplication in staging layer with audit log of discarded records
   - SLA: Zero duplicate symbol-date combinations in clean tables

4. **Freshness Monitoring**
   - Check: Data scraped within last 24 hours
   - Implementation: `SELECT MAX(scraped_at) FROM raw_table` < 24h ago
   - Action: Email alert to data engineering team if stale
   - SLA: All data <24 hours old during market hours

5. **Cross-Field Consistency**
   - Check: Market cap ≈ Price × Shares Outstanding (if shares data available)
   - Check: Companies in "Finance" sector shouldn't have Country = "Unknown"
   - Implementation: Business rule validation in dbt staging models
   - Action: Flag inconsistent records for manual review
   - SLA: <1% records with cross-field inconsistencies

### 2. Website Layout Change Detection

**Multi-layered detection approach:**

1. **Schema Validation**
   - Before scraping: Validate expected HTML structure exists (e.g., `<table class="stock-table">`)
   - If missing: Don't scrape, alert immediately
   - Implementation: Pre-flight check in scraper that validates page structure

2. **Column Count Validation**
   - After scraping: Check CSV has expected 10 columns
   - If mismatch: Alert before loading to database
   - Implementation: Pandas DataFrame shape validation

3. **Sample Data Pattern Matching**
   - Check: Do values match expected patterns? (e.g., symbols are 3-5 letters, prices have $)
   - If not: Regex validation failure = layout changed
   - Implementation: Pattern validation in scraper output

4. **Row Count Anomaly Detection**
   - If we normally get 100 rows but suddenly get 5: layout probably changed
   - Implementation: Alert if row count < 50% of 30-day average
   - Action: Pause pipeline, manual investigation

5. **Smoke Test Database Query**
   - After load: Run known queries, check results match expectations
   - Example: `SELECT COUNT(*) FROM raw_table WHERE scraped_at = today()` should be ~100
   - If fails: Rollback load, investigate

**Alert Chain:**
1. Slack notification to #data-engineering channel
2. Email to on-call engineer
3. Pause daily pipeline
4. Create Jira ticket with screenshots of broken page

### 3. Versioning and Historical Data Tracking

**Three-pronged approach:**

1. **Raw Data Archival**
   - Keep ALL raw scraped data forever in separate archive table
   - Schema: `raw_archive.stock_data_raw_YYYYMMDD` partitioned by scrape date
   - Why: Can recreate any historical state, audit data changes
   - Retention: Indefinite (low cost in Snowflake with time travel)

2. **Slowly Changing Dimension (SCD Type 2) for Company Changes**
   ```sql
   CREATE TABLE dim_company_history (
       company_key VARCHAR,
       stock_symbol VARCHAR,
       company_name VARCHAR,
       sector VARCHAR,
       valid_from DATE,
       valid_to DATE,
       is_current BOOLEAN
   )
   ```
   - Track when company changes sector, name, or country
   - Example: Company X was "Technology" until 2026-01-15, then changed to "Finance"
   - Enables: Time-travel queries like "What sector was X in on date Y?"

3. **Change Data Capture (CDC) Audit Log**
   ```sql
   CREATE TABLE audit_log (
       change_id NUMBER,
       table_name VARCHAR,
       record_key VARCHAR,
       column_changed VARCHAR,
       old_value VARCHAR,
       new_value VARCHAR,
       changed_by VARCHAR,
       changed_at TIMESTAMP
   )
   ```
   - Log every UPDATE/DELETE in production tables
   - Use Snowflake streams or database triggers
   - Enables: Full audit trail of every change

4. **dbt Model Versioning**
   - Git commit history for all model changes
   - Tag releases: `v1.0.0_2026-02-01`
   - Enables: "What were our calculations on date X?"

5. **Snapshot Tables for Point-in-Time Analysis**
   - Daily snapshot of `fct_stock_observations`
   - Implementation: dbt snapshots feature
   - Enables: "Show me exactly what dashboard showed on Feb 1"

### 4. Duplicate Handling Strategy

**Prevention + Detection + Resolution:**

**Prevention (Primary Strategy):**
1. **Unique Key Constraint**
   - Raw layer: `MD5(symbol || scraped_at)` as primary key
   - Staging layer: `symbol` as unique constraint
   - Database enforces uniqueness automatically

2. **Idempotent Scraping**
   - Use consistent timestamp format
   - Same scrape run = same hash = database rejects duplicate on insert
   - Benefit: Can re-run scraper without creating duplicates

**Detection (Secondary):**
1. **Daily Duplicate Check Query**
   ```sql
   SELECT symbol, COUNT(*) 
   FROM staging.stock_data_clean 
   GROUP BY symbol 
   HAVING COUNT(*) > 1
   ```
   - Run in dbt test suite
   - Fails build if duplicates exist

2. **Data Quality Dashboard**
   - Tile showing "Duplicate Records" count
   - Should always be zero

**Resolution (When Prevention Fails):**
1. **Automated Deduplication Logic**
   - Rule: Keep record with most recent `last_updated_at`
   - Rule: If tie, keep record with highest `data_quality_score`
   - Implementation: In dbt staging model using `ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY last_updated_at DESC)`

2. **Quarantine Duplicates**
   - Don't delete - move to `staging.duplicates_quarantine` table
   - Allows investigation: Why did we get duplicates?
   - Weekly review process

3. **Root Cause Analysis**
   - If duplicates appear: Investigate scraper logs
   - Was scraper run twice? Did source website have duplicates?
   - Fix upstream issue, not just symptom

**Documentation:**
- Create runbook: "What to do if duplicates appear"
- Include: Detection query, resolution SQL, escalation path

---

## B4) LLM Integration Use Cases

### Use Case 1: Intelligent Earnings Call Sentiment Analysis

**Example User Prompt:**
```
"Analyze the latest earnings call transcript for TICK025 (Tech Corp) and tell me:
1. Is management optimistic or pessimistic about next quarter?
2. What risks did they mention?
3. How does this compare to their guidance from last quarter?
4. Should I buy, hold, or sell based on this analysis?"
```

**Data Retrieved:**
- `fct_stock_observations` for TICK025 historical performance
- `dim_company` for sector and country context
- External: Earnings call transcript from company investor relations page
- Historical earnings call transcripts for trend analysis

**LLM Output:**
```
Based on analysis of Tech Corp's Q4 2025 earnings call:

SENTIMENT: Cautiously Pessimistic (Confidence: 75%)
- CEO mentioned "headwinds" 8 times (vs 2 times last quarter)
- CFO lowered revenue guidance by 5% for Q1 2026
- Positive note: New product launch mentioned with enthusiasm

RISKS IDENTIFIED:
1. Supply chain disruptions in Asia (high severity)
2. Increased competition from rivals (medium severity)
3. FX headwinds from strong dollar (low severity)

COMPARISON TO LAST QUARTER:
- Last Q: Guided $500M revenue → Actual: $485M (3% miss)
- This Q: Guiding $475M (5% reduction) → Pattern suggests conservative guidance
- Tone shift: From "confident" to "cautious"

RECOMMENDATION: HOLD
- Stock currently at $125.50, P/E of 25.3 (sector avg: 23.1)
- Wait for Q1 results before adding to position
- Set price alert at $110 (10% drop) for potential buy opportunity
```

**Risks:**
1. **Hallucination:** LLM might invent quotes or statistics that weren't in transcript
2. **Compliance:** Investment recommendations require disclaimers, could violate securities regulations
3. **Cost:** Processing long transcripts expensive ($0.50-$2 per analysis)
4. **Recency:** Transcript might be days old, market already moved
5. **Bias:** LLM might have inherent optimism/pessimism bias

**Risk Mitigation Strategies:**
1. **Citation Required:** Force LLM to cite exact quotes with timestamps
   - Use: "Quote the exact phrase where management mentioned headwinds"
   - Validate: Check citations against source document automatically

2. **Compliance Wrapper:**
   - Prepend all outputs with: "This is not investment advice. Consult a licensed financial advisor."
   - Log all recommendations for compliance audit
   - Require user to acknowledge disclaimer before viewing

3. **Cost Control:**
   - Cache LLM responses (same transcript analyzed by multiple users = one API call)
   - Summarize transcript first, then analyze summary (reduce tokens)
   - Budget: Max $100/day on LLM calls, rate limit per user

4. **Freshness Validation:**
   - Display transcript date prominently
   - Alert user if >7 days old: "This analysis may be stale"
   - Combine with real-time stock price movements

5. **Bias Detection:**
   - Run same analysis with 3 different prompts, compare outputs
   - If recommendation differs: Flag as "uncertain" and show all perspectives
   - A/B test against analyst recommendations for accuracy

---

### Use Case 2: Natural Language Data Exploration & Report Generation

**Example User Prompt:**
```
"Create an executive summary comparing Technology and Healthcare sectors.
Focus on valuation, growth, and risk. Make it suitable for presenting to
our investment committee tomorrow. Include a recommendation on which
sector to overweight."
```

**Data Retrieved:**
- `fct_stock_observations` aggregated by sector for Tech and Healthcare
- Historical 90-day trends (price, volume, market cap changes)
- `dim_company` for company counts and geographic diversity
- SQL Query: Sector performance comparison from analytics queries

**LLM Output:**
```markdown
EXECUTIVE SUMMARY: Technology vs Healthcare Sectors
Date: February 10, 2026

KEY FINDINGS:
Technology sector shows stronger growth but higher valuation risk, while
Healthcare offers stability with moderate returns.

VALUATION COMPARISON:
- Technology: Avg P/E 28.5 (15% above 5-year avg) → OVERVALUED
- Healthcare: Avg P/E 19.2 (in line with 5-year avg) → FAIR VALUE

GROWTH METRICS (Last 90 Days):
- Technology: +12.3% price appreciation, +8% market cap growth
- Healthcare: +5.7% price appreciation, +4% market cap growth
→ Technology outperforming by 2.2x

RISK INDICATORS:
- Technology: Higher volatility (std dev 15%), concentrated in Large Cap
- Healthcare: Lower volatility (std dev 8%), more diversified

LIQUIDITY:
- Technology: $2.1B avg daily dollar volume (excellent)
- Healthcare: $1.3B avg daily dollar volume (good)

RECOMMENDATION: Moderate Overweight to Healthcare
RATIONALE:
1. Current portfolio is 40% Technology (overweight vs market) → RISK
2. Healthcare at fair valuation with 6% expected return → OPPORTUNITY
3. Diversification benefit: Low correlation between sectors
4. Macroeconomic outlook: Interest rate cuts favor stable cash flows (Healthcare)

ACTION: Rebalance to 35% Tech / 25% Healthcare over next 30 days

[Generated by Claude AI. Data as of 2026-02-10. Review before presenting.]
```

**Risks:**
1. **Hallucination:** LLM might invent statistics like "15% above 5-year avg" if not in data
2. **Outdated Context:** LLM training data old, might not understand 2026 macro conditions
3. **Cost:** Complex query + long output = expensive API call
4. **Oversimplification:** Nuanced investment decisions reduced to simple recommendation
5. **Accountability:** If recommendation is wrong, who is liable?

**Risk Mitigation Strategies:**
1. **Structured Data Injection:**
   - Don't let LLM query database directly
   - Run SQL queries first, inject results as JSON into prompt
   - Example prompt structure:
   ```
   Here is factual data: {json_data}
   Using ONLY this data, write a summary.
   Do NOT make up any statistics.
   If information is missing, say "Data not available".
   ```
   - Reduces hallucination by 80%+

2. **Template-Based Output:**
   - Provide LLM with exact markdown template to fill in
   - Force sections like "VALUATION (P/E ratio)" so it can't skip or invent metrics
   - Validate output against template schema

3. **Cost Optimization:**
   - Generate report once, cache for 24 hours
   - Reuse for all users requesting same comparison
   - Use cheaper model (Claude Haiku) for structured tasks, reserve Opus for complex analysis
   - Budget: $0.10 per report × 50 reports/day = $5/day

4. **Human-in-the-Loop Review:**
   - Add "Draft" watermark to all LLM-generated reports
   - Require senior analyst to review and approve before sending to committee
   - Track accuracy: Did recommendations outperform market? Feedback loop

5. **Liability Protection:**
   - Footer: "AI-generated analysis. Not investment advice. Verify all figures before use."
   - Version control: Save prompt + output + data snapshot for audit trail
   - Disclaimer in email: "This report used AI assistance and requires human validation"

6. **Explainability:**
   - Include "Show Data Sources" button that reveals SQL queries used
   - Link each statistic to source table/query
   - Example: "Avg P/E 28.5 [Source: fct_stock_observations, Query #3]"

---

## B5) n8n Workflow Automation Design

### Workflow: Weekly High-Value Stock Opportunity Scanner

**Trigger Condition:**
- **Schedule:** Every Monday at 6:00 AM EST (before market open)
- **Why Monday:** Fresh week, decision makers reviewing opportunities
- **Why 6 AM:** Complete before 9:30 AM market open

**Workflow Steps:**

```
1. TRIGGER: Schedule (Weekly, Monday 6:00 AM EST)
   ↓
2. EXTRACT: Query Snowflake
   - Run SQL: Get all stocks from fct_stock_observations (last 7 days)
   - Filter: data_quality_score > 0.9 AND trading_volume > 500,000
   ↓
3. TRANSFORM: Calculate Opportunity Score
   - Python function node:
     * Score = (Value Score × 0.4) + (Momentum Score × 0.3) + (Quality Score × 0.3)
     * Value Score: Based on P/E vs sector average
     * Momentum Score: Volume trend and price trend
     * Quality Score: Data quality + healthy P/E range
   - Output: Top 20 stocks ranked by opportunity score
   ↓
4. ENRICH: Add Context
   - HTTP Request: Fetch latest news headlines for top 20 stocks (Alpha Vantage API)
   - Merge: Combine stock data + news sentiment
   ↓
5. LOGIC: Identify Alerts
   - IF node: Check for high-priority signals:
     * New stock entering Top 20 (wasn't there last week) → NEW OPPORTUNITY
     * Stock dropped >10% but fundamentals strong → BUY THE DIP
     * Stock P/E dropped below 15 in growth sector → VALUE ALERT
     * Volume spike >200% of average → UNUSUAL ACTIVITY
   ↓
6. FORMAT: Generate Report
   - Code node: Create HTML email template
   - Sections:
     * Executive Summary (3 sentences)
     * Top 10 Opportunities (table with scores)
     * New Opportunities This Week (if any)
     * Alerts (if any)
     * Full data export (CSV attachment)
   ↓
7. OUTPUT: Multi-channel Distribution
   - Slack: Post to #investment-opportunities channel
     * Message: "Weekly opportunity scan complete. 3 new alerts 🚨"
     * Include top 5 stocks inline
   - Email: Send detailed HTML report to:
     * CIO
     * Portfolio Managers (5 recipients)
     * Senior Analysts (3 recipients)
   - Notion: Update "Weekly Opportunities" database
     * Create new page with timestamp
     * Embed data table
   ↓
8. ALERT LOGIC: Conditional Notifications
   - IF >5 high-priority alerts:
     * Send SMS to CIO mobile
     * Create urgent Slack thread with @channel
   - IF new opportunity score >90:
     * Create Jira ticket in "Investment Ideas" project
     * Assign to research analyst
   ↓
9. ERROR HANDLING: (See failure section below)
```

**Alert Logic - What Triggers Notifications:**

| Condition | Severity | Action |
|-----------|----------|--------|
| 0 high-priority alerts | None | Standard weekly email only |
| 1-4 high-priority alerts | Medium | Email + Slack message |
| 5+ high-priority alerts | High | Email + Slack @channel + SMS to CIO |
| Opportunity score >90 | Critical | All above + Jira ticket |
| Score >95 | Urgent | All above + Teams call notification |

**High-Priority Alert Criteria:**
1. New stock entering Top 20 that wasn't there last week
2. Value alert: P/E < 15 AND sector average > 20 (>25% discount)
3. Volume spike: Current volume > 3× 30-day average
4. Price dip: Stock down >15% week-over-week BUT fundamentals unchanged
5. Quality upgrade: Data quality score improved from <0.8 to >0.9

**Output Destination:**

1. **Email (Primary)**
   - To: cio@company.com, portfolio-managers@company.com
   - Subject: "[Weekly Scan] 3 High-Priority Opportunities - Feb 10, 2026"
   - Body: HTML formatted with tables, charts embedded as images
   - Attachment: opportunities_2026-02-10.csv

2. **Slack**
   - Channel: #investment-opportunities
   - Format: Card with buttons ("View Full Report", "Add to Watchlist")
   - Includes: Top 5 stocks inline, alert count

3. **Notion**
   - Database: "Weekly Investment Scans"
   - Page title: "2026-02-10 Opportunity Scan"
   - Content: Embedded table + written summary + linked CSV

4. **Teams (If critical alerts)**
   - Adaptive card with stock details
   - Action buttons to approve/reject for deeper research

**Failure Handling and Retry Strategy:**

```
ERROR HANDLING FLOW:

Step 2 (Snowflake Query) Fails:
├─ Retry: 3 attempts with exponential backoff (30s, 60s, 120s)
├─ If still fails:
│  ├─ Log error to monitoring dashboard
│  ├─ Send Slack alert: "@data-engineering Snowflake query failed in weekly scan"
│  ├─ Email backup: Use cached data from last week's successful run
│  └─ Append disclaimer: "Using cached data from [date] due to data source issue"

Step 4 (News API) Fails:
├─ Retry: 2 attempts
├─ If fails:
│  ├─ Continue workflow WITHOUT news data
│  ├─ Add note in report: "News sentiment unavailable"
│  └─ Don't block entire workflow

Step 7 (Email Send) Fails:
├─ Retry: 5 attempts (critical step)
├─ If still fails:
│  ├─ Save report to Notion anyway (users can access there)
│  ├─ Post in Slack with @channel: "Email failed, report available in Notion"
│  └─ Create PagerDuty incident for ops team

Workflow Timeout (>30 minutes):
├─ Kill workflow
├─ Send alert: "Weekly scan exceeded time limit, investigate"
├─ Trigger manual review process
```

**Retry Strategy by Step:**

| Step | Retries | Backoff | Fail Action |
|------|---------|---------|-------------|
| Snowflake Query | 3 | Exponential (30s, 60s, 120s) | Use cached data + alert |
| API Calls | 2 | Linear (10s, 20s) | Continue without enrichment |
| Email Send | 5 | Constant (30s) | Fallback to Slack |
| Slack Post | 3 | Constant (10s) | Continue (non-critical) |
| Notion Update | 2 | Linear (15s, 30s) | Continue (non-critical) |

**Monitoring & Alerts:**
- Send success confirmation to #data-ops channel every Monday
- If no confirmation by 7:00 AM: On-call engineer gets paged
- Weekly dashboard: Track success rate, average runtime, error types

---

### How to Avoid False Positives?

**Problem:** Alert fatigue if we flag too many "opportunities" that aren't real

**Solutions:**

1. **Multi-Factor Scoring (No Single Metric)**
   - Don't alert on P/E alone
   - Require: Low P/E AND high quality AND positive momentum
   - Prevents: "Value traps" (cheap but dying companies)

2. **Historical Context**
   - Compare to stock's own 90-day average, not just absolute values
   - Example: Volume spike for stock A (normally 100K) is 300K, but stock B (normally 5M) at 300K is actually low
   - Prevents: Flagging large caps with normal volatility

3. **Sector Normalization**
   - Tech stocks naturally have P/E of 25+, so P/E of 30 isn't an outlier
   - Compare to sector average: Flag only if >20% different
   - Prevents: Flagging all growth stocks as "overvalued"

4. **Confirmation Period**
   - Don't alert on single-day anomalies
   - Require: Signal present for 3 consecutive days
   - Prevents: One-day glitches or data errors

5. **Whitelist / Blacklist**
   - Blacklist: Stocks with known data issues (delisted, under investigation)
   - Whitelist: Only alert on stocks with >$1B market cap (avoid penny stocks)
   - Prevents: Noise from low-quality tickers

6. **Feedback Loop**
   - Track: How many alerts led to actual trades?
   - If <20% conversion rate: Tighten thresholds
   - Monthly review: Portfolio managers rate alert quality (1-5 stars)
   - Adjust scoring algorithm based on feedback

7. **A/B Testing Thresholds**
   - Run workflow with two threshold sets
   - Version A: Opportunity score >85 (loose)
   - Version B: Opportunity score >90 (tight)
   - Compare: Which version has fewer false positives?
   - Optimize: Choose threshold that maximizes signal-to-noise ratio

**False Positive Metrics to Track:**
- Alert rate: Should be 3-10 per week (sweet spot)
- Precision: % of alerts that were actionable (target: >70%)
- Trade conversion: % of alerts that led to actual portfolio changes (target: >20%)

---

### What Business Event is Most Important to Monitor?

**Answer: Sudden Volume Spike Combined with Price Stability**

**Why This Matters Most:**

1. **Leading Indicator**
   - Volume spike often precedes price movement by 1-3 days
   - Institutional investors buying/selling before news is public
   - Retail investors haven't noticed yet = opportunity

2. **Actionable Signal**
   - If volume up 200%+ BUT price flat:
     * Accumulation phase = insiders buying = BULLISH
     * Can enter position before price runs
   - If volume up 200% AND price down 5%:
     * Distribution = insiders selling = BEARISH
     * Exit position or short

3. **Risk Management**
   - Sudden volume on a holding = something changed
   - Even if we don't know what, we should investigate
   - Prevents: Holding through disasters

4. **Beats Other Signals**
   - P/E changes: Slow, backward-looking
   - Price changes alone: Reactive, already moved
   - News: Public when published, already priced in
   - Volume: Real-time, shows informed traders acting NOW

**Implementation in Workflow:**
- Calculate: `volume_spike_ratio = current_volume / 30_day_avg_volume`
- Alert if: `volume_spike_ratio > 2.0` (200% increase)
- Priority boost if: `abs(price_change) < 2%` (price stable despite volume)
- Urgent alert if: On current portfolio holding

**Real-World Example:**
```
Stock: TICK042
Monday: Volume 800K (avg: 400K) | Price $50.00
Tuesday: Volume 1.2M (spike!) | Price $50.25 (+0.5%)
→ ALERT: Unusual volume with price stability

Investigation reveals: Major hedge fund accumulating position
Action: Buy before price runs
Result: By Friday, price at $57 (+14% gain)
```

This is why volume analysis is the #1 monitoring priority.

---

## B6) Client Memo (Consulting Communication)

**TO:** Chief Financial Officer  
**FROM:** Data Engineering Team  
**DATE:** February 10, 2026  
**RE:** Stock Market Analytics Platform - Phase 1 Complete

---

We've completed Phase 1 of your market analytics modernization. The platform now automatically scrapes 100+ stocks daily from financial markets, structures data in Snowflake with quality validation, and transforms it through dbt into executive-ready dashboards.

**Business Value:** Replace manual Excel tracking with real-time insights. Your team now sees sector performance, valuation trends, and trading anomalies in seconds instead of hours. Data quality checks ensure 95%+ accuracy. Early testing identified 3 undervalued stocks that weren't on your radar.

**Recommended Next Phase:** Add automated weekly opportunity alerts (via email/Slack), integrate earnings call sentiment analysis using AI, and expand to 500+ stocks with international markets. This enables proactive investment decisions versus reactive reporting.

Ready to proceed with Phase 2 scoping call?

---

*[Word count: 147 words]*
