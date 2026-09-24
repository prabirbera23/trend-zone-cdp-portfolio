# Sprint 5 — Customer 360 and Identity Resolution

## Objective

Build a reproducible Customer 360 from the governed identifiers already established across WooCommerce, offline retail, the TrendCart marketplace simulation and Salesforce CRM.

This sprint implements profile stitching, computed traits and audience qualification in transparent reference logic, then documents how the same identity contract is configured in Segment Unify. It does not claim that a licensed Segment Unify workspace was provisioned or activated.

## Why this sprint exists

The earlier sprints proved that each source can deliver useful customer or activity data. Sprint 5 answers the harder questions:

- Which records belong to the same customer?
- Which identifiers are authoritative?
- What must remain anonymous or unmatched?
- How can every merge be explained and reproduced?
- Which customer traits and audiences can downstream teams trust?

## Delivery plan

| Day | Focus | Deliverable | Status |
|---|---|---|---|
| 1 | Identity contract | Canonical profile schema, crosswalk model and deterministic matching rules | **Complete** |
| 2 | Source normalization | Comparable source views and controlled test fixtures | **Complete — normalized fixtures defined** |
| 3 | Profile stitching | Golden-profile and identity-crosswalk reference SQL | **Complete — deterministic profile views defined** |
| 4 | Traits and audiences | Computed traits and audience qualification logic | **Complete — traits and audience views defined** |
| 5 | Validation | Positive, negative and ambiguous-match QA tests | **Complete — validation assertions defined** |
| 6 | Segment Unify blueprint | Step-by-step configuration mapped to the validated contract | **Complete — implementation blueprint documented** |
| 7 | Portfolio handoff | Architecture summary, limitations and interview walkthrough | **Complete — Sprint 5 handoff documented** |

## Target customer journey

The primary deterministic test subject remains `TZ-CUST-006`. Its governed identifier can connect known WooCommerce activity, the TrendCart marketplace order and Salesforce Contact/Case context. A source participates only when an explicit identifier or approved crosswalk exists.

## Definition of done

Sprint 5 is complete when:

1. Every source identifier is mapped to a documented canonical identifier or deliberately remains unmatched.
2. A reproducible process produces one canonical row per known customer.
3. Source lineage survives every merge.
4. Guest and marketplace-only records are not forced into known profiles.
5. Computed traits and audience membership can be traced to source records.
6. Positive, negative and ambiguous-match tests pass.
7. The Segment Unify runbook describes the equivalent implementation without presenting unexecuted steps as evidence.

## Current status

**Complete — reference implementation and Unify blueprint documented.**

See [Day 1 — Identity Contract](day-1-identity-contract.md), [Day 2 — Normalized Source Fixtures](day-2-normalized-source-fixtures.md) and [Day 3 — Deterministic Profile Stitching](day-3-deterministic-profile-stitching.md) and [Day 4 — Traits and Audiences](day-4-traits-and-audiences.md) and [Day 5 — Validation](day-5-validation.md) and [Day 6 — Segment Unify Blueprint](day-6-segment-unify-blueprint.md) and [Day 7 — Handoff and Interview Walkthrough](day-7-handoff-and-interview-walkthrough.md).
