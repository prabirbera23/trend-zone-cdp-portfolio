# Day 4 — Computed Traits and Audience Eligibility

## Outcome

Day 4 defines reusable Customer 360 traits and the qualification logic for priority audiences. Traits are derived from normalized activity and the deterministic golden profile; they are not manually assigned.

## Trait categories

| Trait | Meaning | Evidence |
|---|---|---|
| `has_salesforce_service_case` | Customer has CRM service context | Salesforce Case linked through canonical ID |
| `has_marketplace_activity` | Customer has TrendCart activity | Marketplace customer or order linked through crosswalk |
| `is_known_customer` | Profile has a governed canonical ID | Golden profile exists |
| `identity_quality` | Identity confidence classification | Deterministic profile or unresolved exception |
| `last_activity_at` | Latest known source activity | Maximum contributing event timestamp |

## Audience rules

| Audience | Qualification | Exclusion |
|---|---|---|
| Customers with unresolved service cases | Known profile with an open service Case | Closed/resolved cases |
| High-value customers | Known profile above the controlled value threshold | Missing or untrusted customer identity |
| Recent purchasers | Known profile with a completed order in the lookback window | Cancelled or returned orders |
| Marketplace customers | Known profile with marketplace activity | Anonymous marketplace-only orders |
| Review-required identities | Any unresolved or ambiguous source record | Deterministically resolved records |

The value threshold and lookback window are configuration parameters, not hidden assumptions. The reference SQL uses a fictional threshold and a 30-day lookback for demonstration.

## Acceptance criteria

- Traits are calculated from source records, not typed into the profile.
- Every audience member has a qualification reason.
- Anonymous, guest and ambiguous records cannot qualify as known-customer audiences.
- Service-case audiences retain the Salesforce Case ID for operational follow-up.
- The same source snapshot produces the same trait and audience output.

## Next step

Day 5 will validate positive, negative and ambiguous scenarios against these rules.
