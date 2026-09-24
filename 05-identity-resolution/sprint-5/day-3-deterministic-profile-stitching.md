# Day 3 — Deterministic Profile Stitching

## Outcome

Day 3 turns the normalized source records into a reproducible golden profile. The stitching process is deliberately deterministic: it uses governed canonical IDs and approved crosswalks, not fuzzy similarity.

## Stitching sequence

1. Read the normalized source records.
2. Select records with an explicit canonical ID.
3. Join those records to the Day 1 identity crosswalk.
4. Aggregate profile attributes using documented survivorship rules.
5. Attach all contributing source records as lineage.
6. Keep records without deterministic evidence in the review queue.

## Survivorship rules

| Attribute | Rule |
|---|---|
| Canonical ID | Exact governed value only |
| Name | Prefer a non-null Salesforce Contact value, then the latest non-null source value |
| Email | Prefer a verified governed value; do not infer or concatenate values |
| Phone | Prefer a verified governed value; otherwise remain null |
| Profile created time | Minimum trusted source timestamp |
| Profile updated time | Maximum contributing source timestamp |
| Source presence | True when at least one active crosswalk row exists |
| Service context | Attach Salesforce Case activity; do not treat Case ID as a person key |

## Expected result

The controlled TZ-CUST-006 profile resolves:

- TrendCart customer and order
- Salesforce Contact 003g700000eYmCrAAK
- Salesforce Case 00001026
- WooCommerce Identify record when its explicit canonical ID is present

The anonymous marketplace order, walk-in transaction and ambiguous shared-email record remain outside the golden profile.

## Quality checks

The SQL provides checks for:

- One canonical profile row per customer
- No source record linked to more than one customer
- No profile created from attribute similarity alone
- All deterministic links having confidence 1.000
- Exceptions remaining visible for review

## Acceptance criteria

- TZ-CUST-006 produces exactly one golden profile.
- Every contributing record has a source-system lineage row.
- Salesforce Case 00001026 is activity context, not a new customer.
- Anonymous, guest and ambiguous rows do not enter the profile.
- Re-running the query produces the same profile and lineage.

## Next step

Day 4 will calculate reusable traits and audience eligibility from the golden profile and its linked activity.
