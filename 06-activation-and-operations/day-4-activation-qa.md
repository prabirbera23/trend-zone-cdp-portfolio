# Day 4 — Activation QA

## Outcome

Day 4 defines test scenarios for the complete path from audience membership to destination delivery. The tests distinguish governance blocks from temporary technical failures.

## Test matrix

| Test | Scenario | Expected result | Category |
|---|---|---|---|
| A1 | TZ-CUST-006, deterministic identity and granted consent | Payload created and eligible | Positive |
| A2 | Missing marketing consent | Payload blocked with consent reason | Governance block |
| A3 | Active global suppression | Payload blocked with suppression reason | Governance block |
| A4 | Pending deletion request | Payload blocked before payload creation | Governance block |
| A5 | Anonymous-only audience member | Payload rejected for missing canonical ID | Data-quality block |
| A6 | Review-queue identity | No downstream payload | Governance block |
| A7 | Destination timeout | Retry according to policy, no duplicate audience decision | Technical retry |
| A8 | Unknown destination field | Quarantine payload and alert | Contract failure |
| A9 | Salesforce Case context | Service payload may pass; marketing payload follows consent/suppression | Conditional |
| A10 | Duplicate delivery attempt | Idempotency key prevents duplicate processing | Reliability |

## Idempotency

Use an idempotency key composed of:

destination + customer_id + audience_name + audience_version + evaluated_at

A retry may repeat transport delivery, but it must not create a new audience decision or bypass an eligibility block.

## Error categories

- governance_block — consent, suppression, deletion or identity failure
- contract_failure — missing or invalid destination field
- transient_transport_failure — timeout, rate limit or temporary destination outage
- permanent_destination_failure — rejected identity or invalid destination configuration

## Acceptance criteria

- Every positive case produces a valid payload.
- Every governance block produces no downstream payload.
- Retryable errors are distinguishable from permanent failures.
- Idempotency prevents duplicate delivery.
- Case context does not override marketing consent.
- QA results retain audience, customer, destination and reason metadata.

## Next step

Day 5 will define operational monitoring, drift detection and alerting.
