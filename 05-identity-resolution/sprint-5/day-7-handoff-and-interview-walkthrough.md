# Day 7 — Sprint 5 Handoff and Interview Walkthrough

## Sprint outcome

Sprint 5 established a governed Customer 360 reference implementation across WooCommerce, offline retail, TrendCart and Salesforce CRM.

The implementation is organized as a transparent sequence:

1. Canonical identity contract
2. Normalized source fixtures
3. Deterministic golden-profile stitching
4. Computed traits and audience eligibility
5. Positive, negative and ambiguity validation
6. Segment Unify implementation blueprint

## What is implemented

- Canonical customer identifier: TZ-CUST-###
- Source identity crosswalk and lineage model
- Deterministic profile stitching
- Salesforce Contact and Case context handling
- Anonymous, guest and ambiguous-record exclusions
- Computed profile traits
- Explainable audience membership
- QA assertions for merge safety and audience integrity
- Step-by-step Unify configuration blueprint

## What is intentionally not claimed

- A licensed Segment Unify workspace was not activated in the portfolio workspace.
- Profile Explorer validation is not presented as evidence.
- No probabilistic PII matching is claimed.
- No real marketplace, production Salesforce or customer PII integration is claimed.
- Audience activation to downstream production destinations is documented as the next implementation step, not as completed evidence.

## Interview walkthrough

### 1. Start with the problem

“Customer records existed in multiple source systems, but a source-level sync does not automatically create a trustworthy Customer 360. The risk is merging the wrong people or activating incomplete identities.”

### 2. Explain the design decision

“I introduced a canonical Trend Zone customer ID and an auditable source crosswalk. Source-native IDs remain available for lineage, while only governed IDs and approved mappings can resolve a profile.”

### 3. Explain the merge boundary

“I deliberately did not merge on name, email or phone alone. Anonymous, guest and ambiguous records remain separate until an explicit Identify transition or approved crosswalk exists.”

### 4. Use TZ-CUST-006 as the positive path

“TZ-CUST-006 connects the controlled TrendCart customer, Salesforce Contact and Case 00001026. The Case contributes service context, but its Case Number is never used as the customer identity.”

### 5. Explain the quality gate

“The validation suite tests positive matches, negative exclusions, duplicate assignments, audience explainability and review-queue handling. A CDP implementation is not complete just because records appear in a destination.”

### 6. Explain the Unify boundary

“The repository contains the validated data model and a production-oriented Segment Unify runbook. Workspace-level profile validation depends on the licensed Unify capability, so I document that as the next activation step rather than presenting it as executed evidence.”

## Portfolio narrative

**Problem → Decision → Implementation → Outcome**

| Stage | Sprint 5 story |
|---|---|
| Problem | Customer context was distributed across ecommerce, marketplace, offline and CRM sources |
| Decision | Use a governed canonical ID and deterministic crosswalk |
| Implementation | Normalize, stitch, calculate traits and validate with controlled SQL |
| Outcome | A repeatable Customer 360 foundation with safe activation boundaries |

## Sprint 5 acceptance statement

Sprint 5 is complete as a reference implementation and production-oriented design package. The remaining operational step is to configure and validate the blueprint in a licensed Segment Unify workspace, then connect approved audiences to downstream destinations.

## Handoff checklist

- [x] Day 1 identity contract
- [x] Day 2 normalized source fixtures
- [x] Day 3 deterministic golden profile
- [x] Day 4 traits and audiences
- [x] Day 5 validation assertions
- [x] Day 6 Segment Unify blueprint
- [x] Day 7 portfolio and interview handoff
