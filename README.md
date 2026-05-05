# SaaS Financial Metrics: NRR Data Pipeline

**Live Dashboard:** [https://public.tableau.com/app/profile/dennis.ho2795/viz/SaaS_Financial_Metrics_NRR_Architecture/Dashboard1]

## Project Overview
This project demonstrates an end-to-end data engineering pipeline designed to calculate and visualize Net Revenue Retention (NRR) from raw, transactional CRM data. It mimics the architecture required to transition a SaaS company from basic spreadsheet reporting to automated, database-driven financial analytics.

## Architecture & Tech Stack
1. **Data Generation (R):** A custom script utilizing `dplyr` and `lubridate` to generate realistic, relational CRM data (`sf_accounts` and `sf_opportunities`), simulating a 2-year SaaS lifecycle with New Business, Expansion, Contraction, and Churn events.
2. **ETL & Data Modeling (PostgreSQL / DBeaver):** Raw transactional data is ingested into a PostgreSQL database. Complex SQL window functions (`OVER PARTITION BY`) and aggregations are used to transform event-level data into a normalized, monthly financial ledger.
3. **Visualization (Tableau):** The transformed data layer feeds into an executive-facing Tableau dashboard, highlighting the rolling 12-month NRR trend and MRR component waterfall.

## The SQL Transformation Logic
The core of this pipeline is a PostgreSQL script that calculates the running starting MRR to accurately derive the Net Revenue Retention percentage. 

*Key SQL techniques used:*
* Common Table Expressions (CTEs) for modularity.
* `DATE_TRUNC` for time-series aggregation.
* `COALESCE` and Window Functions (`ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING`) to calculate dynamic running totals across billing periods.

## Business Value
This architecture eliminates manual data wrangling in Excel, providing leadership with a mathematically validated, real-time look at expansion versus churn, ensuring that the "Source of Truth" lives in the database layer, not the presentation layer.
