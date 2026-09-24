# Day 2 — Normalized Source Fixtures

## Outcome

Day 2 converts source-specific records into a common staging shape. Normalization does not merge customers. It preserves source lineage while making the fields comparable for Day 3 identity resolution.

## Common staging contract

Every normalized source view exposes:

| Field | Purpose |
|---|---|
| `source_system` | Originating platform |
| `source_entity` | Source object |
| `source_record_id` | Immutable native record ID |
| `source_customer_id` | Native customer identifier, when available |
| `canonical_customer_id` | Governed ID only when the source explicitly provides one |
| `anonymous_id` | Temporary browser or anonymous identifier |
| `email` | Synthetic/test email where present |
| `phone` | Synthetic/test phone where present |
| `first_name`, `last_name` | Source attributes |
| `event_type` | Activity type, when applicable |
| `event_at` | Activity timestamp |
| `source_updated_at` | Source modification timestamp |
| `raw_payload_ref` | Reference to the source record or fixture |

## Source normalization rules

### WooCommerce

- Keep the WooCommerce customer ID and order ID separate.
- Carry `anonymousId` until an explicit Identify event supplies the canonical ID.
- Treat order activity as activity, not as a new customer.
- Do not use email alone to create a merge.

### TrendCart

- Preserve the marketplace customer and order IDs.
- Apply the approved `TC-CUST-006 → TZ-CUST-006` crosswalk only when the fixture contains that exact relationship.
- Keep marketplace-only and anonymous orders unlinked.

### Salesforce

- Normalize Contact and Case as separate entities.
- Contact `Trend_Zone_Customer_ID__c` is the governed customer key.
- Case `Trend_Zone_Customer_ID__c` associates service activity with a customer.
- Salesforce Contact ID and Case Number remain lineage fields, not canonical IDs.

### Offline retail

- Preserve the POS transaction and loyalty/customer ID.
- Add a canonical ID only through an approved crosswalk.
- Unidentified walk-in transactions remain aggregate activity.

## Day 2 fixtures

The reference SQL contains one positive path for `TZ-CUST-006`, one anonymous marketplace record, one guest transaction and one deliberately ambiguous record. The negative examples are important: a Customer 360 process is trustworthy only when it can explain why records were not merged.

## Acceptance criteria

- All four source shapes expose the common staging fields.
- Source IDs remain intact.
- Canonical IDs appear only when explicitly governed.
- Anonymous, guest and ambiguous rows remain eligible for review rather than being forced into a profile.
- The normalized output is ready for deterministic crosswalk joins on Day 3.

## Next step

Day 3 will use the normalized views and the Day 1 crosswalk to build the golden profile and test one-to-one source-record assignment.
