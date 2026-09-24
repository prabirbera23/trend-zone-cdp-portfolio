# Day 3 — Destination Field Mappings and Payload Contracts

## Outcome

Day 3 defines stable destination contracts for eligible audiences. The contract separates the canonical customer key, profile attributes, consent state, audience metadata and source lineage.

## Common activation envelope

Every destination payload should contain:

| Field | Purpose |
|---|---|
| customer_id | Canonical Trend Zone profile key |
| audience_name | Audience that qualified the profile |
| audience_version | Version of the audience definition |
| evaluated_at | Time the eligibility decision was made |
| qualification_reason | Explainable reason for membership |
| identity_quality | Deterministic identity classification |
| consent_snapshot | Destination-relevant consent state |
| source_lineage_ref | Reference to contributing source records |

## Braze profile contract

| Canonical field | Braze field | Treatment |
|---|---|---|
| customer_id | external_id | Stable profile key |
| first_name | first_name | Profile attribute |
| last_name | last_name | Profile attribute |
| email | email | Only when consent and data-quality rules permit |
| audience_name | audience_membership | Versioned audience attribute |
| evaluated_at | cdp_audience_evaluated_at | Timestamp |
| identity_quality | cdp_identity_quality | Governance attribute |
| qualification_reason | cdp_qualification_reason | Troubleshooting attribute |

Do not send Salesforce Case Number as the Braze external ID.

## CRM/service contract

| Canonical field | Service field | Treatment |
|---|---|---|
| customer_id | trend_zone_customer_id | Customer reference |
| Salesforce Case Number | case_number | Service context |
| has_salesforce_service_case | open_service_case | Operational flag |
| qualification_reason | cdp_reason | Explainability |
| evaluated_at | cdp_evaluated_at | Freshness |

## Analytics/warehouse contract

Keep the full activation envelope, including source system, source record ID, audience version and eligibility status. This supports reconciliation without exposing unnecessary profile attributes to downstream tools.

## Failure handling

- Reject payloads without customer_id.
- Reject payloads with blocked eligibility status.
- Quarantine unknown destination fields.
- Record destination response, retry count and last attempt.
- Never retry a deletion or suppression block as if it were a transport failure.

## Acceptance criteria

- Each destination has an explicit field mapping.
- Canonical ID and source lineage are separated.
- Audience version and qualification reason are preserved.
- Consent state is evaluated before payload creation.
- Rejected payloads have actionable error categories.

## Next step

Day 4 will test successful, rejected and retryable activation scenarios.
