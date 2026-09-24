# Day 1 — Canonical Identity Contract

## Outcome

Day 1 defines the rules that every Sprint 5 transformation must follow. The canonical key is `customer_id`, using the production-style format `TZ-CUST-###`. Source-native identifiers are retained for lineage and are never silently promoted to the canonical key.

Earlier controlled examples such as `TZ_123` and `TZ_5` remain valid historical test values. They must be normalized through an explicit crosswalk if reused; they are not rewritten in place.

## Canonical customer profile

| Field | Type | Purpose |
|---|---|---|
| `customer_id` | string | Stable Trend Zone canonical customer identifier |
| `first_name` | string | Best governed first name |
| `last_name` | string | Best governed last name |
| `email` | string | Synthetic or consented email in the portfolio dataset |
| `phone` | string | Synthetic or consented phone in the portfolio dataset |
| `profile_created_at` | timestamp | Earliest trusted first-seen timestamp |
| `profile_updated_at` | timestamp | Latest contributing source update |
| `has_woocommerce` | boolean | WooCommerce identity or activity is present |
| `has_offline_store` | boolean | Offline identity or activity is present |
| `has_marketplace` | boolean | TrendCart activity is present |
| `has_salesforce` | boolean | Salesforce Contact or Case context is present |

The canonical profile contains resolved customer attributes. Source IDs and match evidence live in the identity crosswalk so the profile remains compact and auditable.

## Identity crosswalk

| Field | Type | Purpose |
|---|---|---|
| `customer_id` | string | Canonical customer identifier |
| `source_system` | string | `woocommerce`, `offline_store`, `trendcart` or `salesforce` |
| `source_entity` | string | Source object, such as customer, order, contact or case |
| `source_record_id` | string | Native record identifier |
| `id_type` | string | Identifier type used for the match |
| `match_method` | string | Rule that created the link |
| `confidence` | decimal | Deterministic confidence, normally `1.00` |
| `first_seen_at` | timestamp | First observation of the link |
| `last_seen_at` | timestamp | Latest observation of the link |
| `active` | boolean | Whether the relationship remains current |

A unique constraint on `(source_system, source_entity, source_record_id)` prevents one source record from being assigned to multiple customers.

## Source identity crosswalk

| Source | Source identifier | Canonical use | Rule |
|---|---|---|---|
| WooCommerce | `customer_id` | Direct canonical candidate | Accept only governed values or an approved crosswalk |
| Web behaviour | `anonymousId` | Temporary browser identity | Link only after an observed Identify transition |
| Offline retail | loyalty/customer ID | Crosswalk input | Link only through an explicit store-to-customer mapping |
| TrendCart | marketplace customer ID | Crosswalk input | Known `TC-CUST-006` maps to `TZ-CUST-006`; marketplace-only users remain separate |
| Salesforce Contact | `Trend_Zone_Customer_ID__c` | Direct canonical candidate | Use the governed custom field; retain Salesforce Contact ID as lineage |
| Salesforce Case | `Trend_Zone_Customer_ID__c` | Activity association | Attach Case context to the matching profile; Case ID is not a person key |

## Match precedence

1. **Exact canonical ID** — accept an exact governed `TZ-CUST-###` value.
2. **Approved crosswalk** — accept a version-controlled source-to-customer mapping.
3. **Observed Identify transition** — connect `anonymousId` to `customer_id` only when the Identify event explicitly contains both.
4. **No deterministic evidence** — keep the record separate or unmatched.

Email, phone, name and postal address may support data-quality review, but do not automatically merge profiles in this sprint.

## Safety rules

- Never force a guest order into a known customer profile.
- Never merge two profiles from name similarity.
- Never use Salesforce Case ID as a customer identifier.
- Never discard the source record ID or match method.
- Quarantine conflicting or many-to-many mappings for review.
- Use only fictional or safely transformed portfolio data.

## Controlled test case: TZ-CUST-006

The positive-path test expects these governed relationships:

| System | Entity | Expected relationship |
|---|---|---|
| Trend Zone | Canonical customer | `TZ-CUST-006` |
| TrendCart | Customer/order | Explicit crosswalk to `TZ-CUST-006` |
| Salesforce | Contact | `Trend_Zone_Customer_ID__c = TZ-CUST-006` |
| Salesforce | Case `00001026` | Service activity associated with `TZ-CUST-006` |
| WooCommerce | Customer/activity | Included only when its controlled fixture carries the canonical ID |
| Offline retail | Customer/transaction | Included only when an approved crosswalk exists |

## Acceptance criteria

- Exactly one canonical profile is produced for `TZ-CUST-006`.
- Every contributing source record has one explainable crosswalk row.
- Unmatched and ambiguous records remain outside the canonical profile.
- Re-running the logic produces the same result.
- Source timestamps and identifiers remain traceable.
- Negative tests confirm that email-only, phone-only and name-only similarity do not merge profiles.

## Next step

Day 2 creates normalized source fixtures and views that conform to this contract before any stitching logic is written.
