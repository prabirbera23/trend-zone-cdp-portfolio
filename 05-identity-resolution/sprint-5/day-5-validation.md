# Day 5 — Identity and Audience Validation

## Outcome

Day 5 defines the QA gate for the Customer 360 simulation. The tests verify both what should resolve and what must not resolve.

## Test matrix

| Test | Scenario | Expected result |
|---|---|---|
| P1 | TrendCart customer and order for TZ-CUST-006 | Resolves to one canonical profile |
| P2 | Salesforce Contact for TZ-CUST-006 | Resolves through governed customer ID |
| P3 | Salesforce Case 00001026 | Attaches as service activity to TZ-CUST-006 |
| P4 | WooCommerce Identify with explicit canonical ID | Resolves to TZ-CUST-006 |
| N1 | Anonymous marketplace order | Remains outside known-customer profile |
| N2 | Walk-in offline transaction | Remains outside known-customer profile |
| N3 | Cancelled or returned activity | Does not qualify as a recent purchaser |
| A1 | Shared email or name without governed ID | Enters review queue; no automatic merge |
| A2 | One source record mapped to two customers | Fails integrity check and is quarantined |

## Validation principles

- A passing test means the rule produced the expected result, not merely that a row exists.
- Negative tests are first-class acceptance criteria.
- Every activated audience member must have a qualification reason.
- Every deterministic link must retain source lineage.
- A rerun against the same snapshot must be repeatable.

## Evidence boundary

This repository contains reference SQL and controlled fixtures for the validation logic. Segment Unify profile-level validation is represented as a documented configuration step because the portfolio workspace does not expose the required Unify feature tier.

## Day 5 exit criteria

- Positive-path assertions return the expected known profile.
- Negative-path assertions return zero unintended profile assignments.
- Ambiguous mappings appear in the review queue.
- Duplicate source-to-customer assignments are detected.
- Trait and audience outputs remain explainable to source records.
- Any failed assertion is documented before proceeding to Day 6.

## Next step

Day 6 will document the equivalent Segment Unify configuration and the mapping from this validated contract to production implementation steps.
