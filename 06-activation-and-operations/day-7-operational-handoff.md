# Sprint 6 Day 7 — Operational Handoff

## Purpose

Day 7 converts the Sprint 6 activation design into a repeatable operating handoff. The handoff explains how an approved audience moves from Customer 360 evaluation to destination delivery, how failures are handled, and how outcomes are reviewed.

This is a production-oriented operating blueprint for the Trend Zone portfolio. It does not claim live paid-destination activation or licensed Segment Unify access.

## Sprint 6 outcome

The sprint now provides a complete activation control loop:

1. Select a business use case and destination.
2. Apply consent, suppression and identity-eligibility rules.
3. Build the destination payload from the approved contract.
4. Run positive, negative, retry and idempotency checks.
5. Monitor freshness, audience volume, delivery and failure signals.
6. Measure activation and downstream outcomes.
7. Pause, investigate or roll back when a guardrail is breached.

## Operational runbook

### 1. Pre-activation checks

- Confirm the source data and identity crosswalk are within freshness thresholds.
- Confirm the audience definition has an owner, purpose and expected volume.
- Apply consent, deletion, suppression and anonymous-profile exclusions.
- Review identity exceptions and hold ambiguous profiles in the review queue.
- Record the activation window, destination, audience version and expected record count.

### 2. Audience and payload preparation

- Materialize the approved audience snapshot.
- Resolve the canonical customer identifier and destination-specific identifiers.
- Generate the payload using the destination contract in [Day 3](day-3-destination-contracts.md).
- Add an activation run ID and audience version for traceability.
- Validate required fields, data types, timestamps and idempotency keys.

### 3. Delivery and monitoring

- Send only records that passed eligibility and suppression checks.
- Track extracted, eligible, suppressed, delivered, rejected and retried counts.
- Compare delivered volume with the expected audience range.
- Monitor source freshness, destination health, latency and error rate.
- Open an incident when a critical threshold or privacy control fails.

### 4. Incident response

| Signal | Immediate action | Recovery decision |
|---|---|---|
| Consent or deletion failure | Stop the activation and quarantine the run | Rebuild the audience after the control is fixed |
| Unexpected audience spike or drop | Pause delivery and compare against the prior snapshot | Resume only after the data owner approves the variance |
| Destination rejection | Capture error payloads and isolate invalid records | Correct the contract or data, then retry idempotently |
| Duplicate delivery risk | Stop retries and preserve the run ID | Replay only records with a confirmed idempotency key |
| Source freshness breach | Hold the audience as stale | Resume after the source passes freshness checks |

Rollback means pausing the affected activation, preventing further sends, preserving the run evidence and rebuilding from a corrected audience snapshot. It does not silently delete historical measurement records.

### 5. Post-activation review

- Reconcile audience size against delivery totals.
- Review suppression and rejection reasons.
- Confirm no privacy or deletion-control exceptions remain open.
- Compare engagement and business outcomes with the agreed baseline or holdout.
- Record decisions, incidents, follow-up actions and the next review date.

## Ownership and cadence

| Activity | Primary owner | Supporting owner | Cadence |
|---|---|---|---|
| Identity and source quality | Data/identity owner | Source owner | Before each run; weekly review |
| Consent and suppression | Privacy or data-governance owner | Activation owner | Before each run |
| Payload and destination delivery | Activation owner | Destination owner | Each activation |
| Incident triage and rollback | Activation owner | Data and privacy owners | As needed |
| Outcome measurement | Marketing or campaign owner | Analytics owner | After each campaign; monthly trend review |
| Contract and runbook review | Product owner | All domain owners | Monthly or after a material change |

## Sprint 6 definition of done

Sprint 6 is complete when:

- Each activation use case has a destination and data contract.
- Consent, suppression and identity rules are explicit.
- Positive, negative, retry and idempotency cases are documented.
- Freshness, volume, delivery and failure monitoring is defined.
- Audience and business outcome measures are defined.
- The operating handoff identifies owners, cadence, incident actions and rollback.
- The remaining platform limitations are visible and not represented as live evidence.

## Portfolio walkthrough

Use this sequence when presenting the work:

**Problem → Decision → Implementation → Control → Outcome**

- **Problem:** customer data is distributed across ecommerce, offline, marketplace and CRM systems.
- **Decision:** establish a canonical customer ID and activate only deterministic, consent-eligible profiles.
- **Implementation:** standardize source records, build Customer 360 reference logic, define destination contracts and QA controls.
- **Control:** add suppression, monitoring, idempotency, incident response and rollback.
- **Outcome:** produce an activation-ready operating model that can be mapped to licensed Segment capabilities and downstream destinations.

## Final status

Sprint 6 delivered an activation and operational-readiness blueprint for the validated Customer 360 reference implementation. The next phase is final review: consolidate the end-to-end story, verify links and evidence, and prepare the recruiter/interview walkthrough.
