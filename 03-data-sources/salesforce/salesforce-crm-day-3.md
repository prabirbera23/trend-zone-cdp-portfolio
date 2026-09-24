# Salesforce CRM Source — Day 3

## Status

**Sprint 4, Day 3 — completed and validated.** The Salesforce Case collection was modelled in Segment, the retained service Case was verified end to end, and the available destination actions were evaluated against the intended customer-service event design.

## Objective

Extend the Salesforce implementation from Contact-profile enrichment to customer-service context while preserving the distinction between:

- **Profile attributes**, which describe a customer and belong in an Identify call.
- **Operational activities**, such as service Cases, which represent time-bound events and should be modelled as Track calls.

## Intended event design

The Case record was evaluated as a candidate for the following event:

```text
Customer Support Case Created
```

The proposed event contract was:

| Segment field | Salesforce Case field |
|---|---|
| User ID | `trend_zone_customer_id_c` |
| Event | Static value: `Customer Support Case Created` |
| `properties.case_id` | `id` |
| `properties.case_number` | `case_number` |
| `properties.order_id` | `trend_zone_order_id_c` |
| `properties.subject` | `subject` |
| `properties.status` | `status` |
| `properties.priority` | `priority` |
| `properties.origin` | `origin` |
| `properties.reason` | `reason` |
| `properties.type` | `type` |
| `properties.created_at` | `created_date` |
| `properties.closed_at` | `closed_date` |
| `properties.is_closed` | `is_closed` |
| Timestamp | `created_date` |

This contract remains the recommended representation if the event is later delivered through the Segment Tracking API.

## Case data model

A model named **Salesforce Customer Service Cases** was created from the Salesforce `Case` collection. Eighteen relevant columns were selected, including:

- `id`
- `case_number`
- `contact_id`
- `created_date`
- `last_modified_date`
- `closed_date`
- `is_closed`
- `subject`
- `description`
- `status`
- `priority`
- `origin`
- `reason`
- `type`
- `trend_zone_customer_id_c`
- `trend_zone_order_id_c`

## Validation record

The model preview returned the retained fictional Salesforce Case:

| Field | Validated value |
|---|---|
| Case Number | `00001026` |
| Customer ID | `TZ-CUST-006` |
| Order ID | `TZ-ORD-1006` |
| Contact ID | `003g700000eYmCrAAK` |
| Subject | Damaged item received — Order TZ-ORD-1006 |
| Status | New |
| Priority | Medium |
| Origin | Web |
| Reason | Breakdown |
| Type | Blank |
| Closed Date | Blank |
| Is Closed | False/open |
| Salesforce Case ID | `500g7000028eTVVAA2` |

The empty Closed Date and open-state value are consistent with a newly created Case whose status is `New`.

## Destination-action assessment

Two destination patterns were evaluated:

| Destination | Source compatibility | Action exposed for this model | Decision |
|---|---|---|---|
| Segment Connections | Reverse ETL warehouse sources | Not compatible with the Salesforce cloud-app source | Rejected |
| Segment Profiles | Compatible with Salesforce cloud-app objects | Send Identify only | Not used for Case activity |

Although Segment Profiles supports multiple actions in other source combinations, the actual Salesforce Case mapping workflow exposed only **Send Identify**.

## Architecture decision

The Case model was **not** mapped through Send Identify.

An Identify call updates durable traits about a person. A service Case is an operational activity with its own identifier, timestamp and lifecycle. Mapping Case fields as profile traits would:

- Collapse an activity into the customer's current profile state.
- Allow a later Case to overwrite an earlier Case.
- Remove the natural event history needed for behavioural analysis.
- Blur the boundary between customer identity and customer-service activity.

Stopping the mapping was therefore an intentional data-modelling decision rather than an incomplete configuration.

## Recommended production pattern

For event-level Case lifecycle data, use an event-producing integration such as:

```text
Salesforce Case create/update
        ↓
Salesforce Flow or Apex callout
        ↓
Segment HTTP Tracking API
        ↓
Track: Customer Support Case Created/Updated/Closed
```

The outbound integration should provide a stable `messageId`, use `TZ-CUST-006` as the governed `userId`, and preserve the Salesforce Case ID in event properties for traceability and deduplication.

## Day 3 outcome

| Check | Result |
|---|---|
| Salesforce Case collection modelled | Passed |
| Required Case fields selected | Passed |
| Case `00001026` visible in preview | Passed |
| Customer identity retained | Passed — `TZ-CUST-006` |
| Order relationship retained | Passed — `TZ-ORD-1006` |
| Case status and service context validated | Passed |
| Track-capable native mapping available | No |
| Identify mapping used as a workaround | No — intentionally rejected |
| Recommended event contract documented | Completed |
| Production integration pattern documented | Completed |

## Sprint 4 conclusion

Sprint 4 established a working Salesforce CRM source, governed Contact identity, tested Contact-to-Segment Identify mapping, and validated customer-service Case ingestion. It also demonstrated an important architecture boundary: profile enrichment and operational events require different Segment call types, and connector availability should not override the semantic data model.

The Salesforce integration is complete within the validated native-connector scope. A Salesforce Flow/Apex Tracking API integration is retained as a future extension rather than being represented as delivered functionality.
