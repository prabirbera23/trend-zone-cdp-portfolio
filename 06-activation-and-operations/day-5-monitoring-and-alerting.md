# Day 5 — Activation Monitoring and Alerting

## Outcome

Day 5 defines the operational controls needed to detect failed deliveries, audience drift and stale source data before they affect customer communication.

## Monitoring domains

| Domain | Signal | Example alert |
|---|---|---|
| Delivery health | Accepted, rejected, failed and retrying deliveries | Failure rate exceeds 5% |
| Governance blocks | Consent, suppression and deletion blocks | Blocks rise unexpectedly after a source change |
| Audience drift | Membership change versus prior evaluation | Membership changes by more than 30% |
| Source freshness | Latest source update timestamp | Salesforce sync is stale beyond SLA |
| Contract quality | Missing required fields or unknown fields | Payload contract failure detected |
| Idempotency | Duplicate delivery keys | Duplicate key observed |
| Data quality | Unmatched, ambiguous or conflicting records | Review queue exceeds threshold |

## Suggested service levels

- Real-time web activity: monitor within minutes
- Salesforce scheduled sync: monitor against the configured sync window
- Audience evaluation: complete before the downstream campaign cutoff
- Activation delivery: retry transient failures with a bounded policy
- Review queue: review before the next audience activation window

These are starting thresholds; production teams should confirm them with campaign owners and platform owners.

## Alert severity

- Critical — deletion or suppression bypass risk, duplicate delivery or broad identity conflict
- High — destination outage, large failure spike or stale source
- Medium — audience drift, review-queue growth or contract warnings
- Informational — normal sync completion or expected audience change

## Operational response

1. Confirm the alert and identify affected destination/audience.
2. Pause activation if governance or duplicate-delivery risk exists.
3. Compare current and prior audience snapshots.
4. Inspect source freshness and contract failures.
5. Retry only transient transport errors.
6. Re-run Day 4 QA after remediation.
7. Record the incident, decision and resulting rule change.

## Acceptance criteria

- Every activation has measurable health signals.
- Alert severity reflects customer and compliance risk.
- Audience drift is compared with a prior snapshot.
- Stale-source alerts identify the affected source.
- Governance failures pause activation rather than retrying indefinitely.
- Incident response produces an auditable record.

## Next step

Day 6 will define the measurement framework for audience delivery and business outcomes.
