# Trend Zone Snowflake Reproducible Dataset

This package recreates the fictional offline-store dataset used in the Trend Zone Segment CDP portfolio. It contains executable Snowflake SQL, portable CSV exports and a separate Excel reference workbook.

## Reference workbook

[Download the formatted Excel workbook](reference/trend-zone-snowflake-dataset.xlsx) for a human-readable version of the five raw tables, field-level data dictionary, expected results, data-quality controls and SQL execution index.

## Dataset

| Object | Rows | Purpose |
|---|---:|---|
| RAW.CUSTOMERS | 35 | Five validated cross-channel and 30 simulated offline-only customers |
| RAW.STORES | 2 | Fictional physical stores |
| RAW.PRODUCTS | 9 | Product catalogue across four categories |
| RAW.OFFLINE_ORDERS | 50 | 35 known-customer and 15 guest transactions |
| RAW.OFFLINE_ORDER_ITEMS | 63 | Product-level order lines |

Total offline revenue is INR 111,242.30. All records are synthetic and intended only for education and portfolio demonstration.

## Execution order

1. Run `sql/01-setup.sql`.
2. Run `sql/02-create-raw-tables.sql`.
3. Run `sql/03-load-seed-data.sql`.
4. Run `sql/04-create-analytics-views.sql`.
5. Run `sql/05-data-quality-checks.sql`; all seven checks should return zero.
6. Run `sql/06-validation-queries.sql` and compare the results below.
7. Run `sql/07-configure-segment-reverse-etl-access.sql` to create the restricted role, service user and Segment state-schema permissions; assign the environment-specific RSA public key separately.

## Expected results

| Population | Orders | Revenue (INR) |
|---|---:|---:|
| CROSS_CHANNEL_VALIDATED | 5 | 11,722.20 |
| OFFLINE_ONLY_SIMULATED | 30 | 66,305.70 |
| GUEST_UNIDENTIFIED | 15 | 33,214.40 |
| **Total** | **50** | **111,242.30** |

| Analytical view | Rows |
|---|---:|
| ANALYTICS.SEGMENT_OFFLINE_ORDERS | 35 |
| ANALYTICS.SEGMENT_CUSTOMER_TRAITS | 35 |
| ANALYTICS.OFFLINE_GUEST_ORDERS | 15 |

## Reverse ETL implementation guide

Use the [Secure Snowflake-to-Segment Reverse ETL Tutorial](secure-reverse-etl-tutorial.md) for the complete key-pair workflow, Snowflake service-user permissions, Segment source and model configuration, free-plan workaround, Identify mapping, validation and production key-rotation guidance.

## Validated Reverse ETL outcome

The package was executed and validated against Segment Reverse ETL:

| Flow | Result |
|---|---|
| Customer traits | 5 scheduled Identify calls received |
| Known-customer offline orders | 35 records extracted and 100% loaded |
| Guest orders | 15 retained for aggregate analysis and excluded from known-profile activation |
| Data-quality checks | All seven checks returned zero |

See [Sprint 2 Snowflake Reverse ETL QA](../../07-testing-and-validation/sprint-2-snowflake-reverse-etl-qa.md) for evidence and acceptance results.

## Privacy and reuse

The names, contact details, stores, products and transactions are fictional. No Snowflake credentials, private keys, Segment write keys or production customer data are included. See the repository license before reuse.
