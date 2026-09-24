# Sprint 6 — Activation and Operational Readiness

## Objective

Move from a validated Customer 360 foundation to governed activation design. Sprint 6 defines how approved audiences are sent to downstream destinations, how consent and suppression are enforced, and how activation quality is monitored.

This sprint documents production-oriented activation patterns. It does not claim that paid downstream destinations were connected or that live campaigns were launched.

## Delivery plan

| Day | Focus | Deliverable | Status |
|---|---|---|---|
| 1 | Activation strategy | Use-case and destination matrix | **Complete — Day 1 defined** |
| 2 | Consent and suppression | Eligibility, consent and exclusion rules | **Complete — controls defined** |
| 3 | Destination contracts | Field mappings and payload contracts | **Complete — contracts defined** |
| 4 | Activation QA | Positive, negative and failure scenarios | **Complete — QA matrix defined** |
| 5 | Monitoring | Sync health, drift and alerting design | **Complete — monitoring model defined** |
| 6 | Measurement | Audience and campaign measurement framework | **Complete — measurement model defined** |
| 7 | Handoff | Operational runbook and portfolio summary | **Complete — operational handoff documented** |

## Guardrail

Only deterministic, consent-eligible and non-suppressed profiles may enter an activation audience. Review-queue records, anonymous-only records and ambiguous identities remain excluded.

See [Day 1 — Activation Matrix](day-1-activation-matrix.md), [Day 2 — Consent and Suppression](day-2-consent-suppression.md), [Day 3 — Destination Contracts](day-3-destination-contracts.md), [Day 4 — Activation QA](day-4-activation-qa.md), [Day 5 — Monitoring and Alerting](day-5-monitoring-and-alerting.md), [Day 6 — Measurement Framework](day-6-measurement-framework.md), and [Day 7 — Operational Handoff](day-7-operational-handoff.md).

## Sprint outcome

Sprint 6 is complete as a documented activation and operational-readiness blueprint. It connects the Customer 360 reference implementation to governed activation decisions, measurable outcomes and an operating handoff. Licensed Segment Unify access and live paid-destination activation remain explicitly outside the evidence claim.
