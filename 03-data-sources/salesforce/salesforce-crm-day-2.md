# Salesforce CRM Source — Day 2

## Status

**Sprint 4, Day 2 — completed and validated.** A governed Trend Zone customer identifier was added to Salesforce, synthetic Contact and Case records were created, the new CRM fields were included in Segment Selective Sync, and an identity-safe Contact model was mapped to the Segment Profiles destination through a tested and enabled `Send Identify` action.

## Objective

Extend the Day 1 Salesforce connection from basic ingestion to an identity-safe CRM enrichment flow. The implementation needed to preserve the existing Trend Zone customer ID as the canonical Segment `userId` while retaining Salesforce record identifiers as source-system traits.

## Implemented flow

```text
Salesforce Contact
  Trend_Zone_Customer_ID__c = TZ-CUST-006
        ↓
Segment Salesforce CRM Source
        ↓
Salesforce Contact Profiles model
        ↓
Send Identify mapping
        ↓
Segment userId = TZ-CUST-006
```

## Salesforce data preparation

### Contact identity field

A custom Contact field was created to carry the governed cross-channel customer identifier.

| Configuration | Value |
|---|---|
| Label | Trend Zone Customer ID |
| API name | `Trend_Zone_Customer_ID__c` |
| Type | Text (50) |
| External ID | Enabled |
| Unique | Enabled |
| Case sensitivity | Case-insensitive |
| Segment role | Canonical `userId` |

### Synthetic Contact

A fictional Contact was created for implementation and QA.

| Field | Test value |
|---|---|
| Name | Aditi Sharma |
| Trend Zone Customer ID | `TZ-CUST-006` |
| Email | `aditi.sharma.tz006@example.com` |
| Title | Loyalty Customer |
| Lead Source | Web |
| Location | Kolkata, West Bengal, India |
| Languages | English, Bengali |

### Customer-service Case

A fictional service Case was linked to Aditi Sharma.

| Field | Test value |
|---|---|
| Case Number | `00001026` |
| Subject | Damaged item received — Order TZ-ORD-1006 |
| Status | New |
| Priority | Medium |
| Origin | Web |
| Reason | Breakdown |
| Trend Zone Customer ID | `TZ-CUST-006` |
| Trend Zone Order ID | `TZ-ORD-1006` |

The Case-level customer ID is exposed through the Contact relationship, allowing customer-service context to retain the same governed identity without treating the Salesforce Contact ID as the customer key.

## Segment Selective Sync

The Contact and Case custom fields were added to the Salesforce CRM source configuration.

| Collection | Added column | Normalized Segment column |
|---|---|---|
| Contact | `Trend_Zone_Customer_ID__c` | `trend_zone_customer_id_c` |
| Case | `Trend_Zone_Customer_ID__c` | `trend_zone_customer_id_c` |
| Case | `Trend_Zone_Order_ID__c` | `trend_zone_order_id_c` |

Default Salesforce sample Contacts and their associated sample Cases were removed from the test environment. The retained dataset contains the governed Contact `TZ-CUST-006` and Case `00001026`, giving the Segment model a deterministic test record.

## Authentication incident and recovery

A scheduled source run initially failed at 0 ms with an invalid-credentials/API-access message. Salesforce API access was confirmed on the System Administrator profile, and the Salesforce connection was re-authenticated in Segment.

Subsequent scheduled runs returned **Data Flowing**, confirming recovery. After narrowing the selected collections and columns, the validated source runs reported **48 synchronized records**.

## Contact data model

A model named **Salesforce Contact Profiles** was created and enabled.

| Model field | Purpose |
|---|---|
| `id` | Salesforce Contact record identifier |
| `trend_zone_customer_id_c` | Governed Trend Zone customer identity |
| `email` | Profile contact trait |
| `first_name` | Profile trait |
| `last_name` | Profile trait |
| `phone` | Profile trait |
| `account_id` | Optional Salesforce relationship context |
| `created_date` | Source record creation timestamp |
| `last_modified_date` | Source record update timestamp |

The Salesforce `Id` remains the model's row-level unique identifier for extraction. It is not used as the Segment `userId`.

## Identify mapping

The Contact model was connected to Segment Profiles using the **Send Identify** action.

| Segment destination field | Salesforce model field |
|---|---|
| User ID | `trend_zone_customer_id_c` |
| `traits.email` | `email` |
| `traits.first_name` | `first_name` |
| `traits.last_name` | `last_name` |
| `traits.phone` | `phone` |
| `traits.salesforce_contact_id` | `id` |
| `traits.salesforce_created_at` | `created_date` |
| `traits.salesforce_last_modified_at` | `last_modified_date` |
| Timestamp | `last_modified_date` |

`Anonymous ID` and `Group ID` were intentionally left blank. The Salesforce Contact ID is stored as a traceability trait rather than promoted to the canonical customer identity.

## Validation

The test record preview resolved Aditi Sharma and produced:

```json
{
  "userId": "TZ-CUST-006",
  "traits": {
    "email": "aditi.sharma.tz006@example.com",
    "first_name": "Aditi",
    "last_name": "Sharma",
    "phone": "",
    "salesforce_contact_id": "003g700000eYmCrAAK",
    "salesforce_created_at": "2026-09-16T19:51:50.000+0000",
    "salesforce_last_modified_at": "2026-09-16T19:51:50.000+0000"
  },
  "timestamp": "2026-09-16T19:51:50.000+0000"
}
```

The mapping test returned **Test succeeded**, after which the mapping was saved and enabled.

## Product judgment

The implementation separates three different identifier roles:

| Identifier | Role |
|---|---|
| `TZ-CUST-006` | Cross-channel customer identity and Segment `userId` |
| Salesforce Contact `Id` | CRM source-system identifier and profile trait |
| Salesforce model unique identifier | Row-level extraction and change tracking |

This prevents Salesforce from creating a parallel customer identity while preserving the CRM record key for governance and troubleshooting.

## Day 2 outcome

| Check | Result |
|---|---|
| Contact customer-ID field created | Passed |
| Synthetic Contact created | Passed — `TZ-CUST-006` |
| Synthetic Case created and linked | Passed — `00001026` |
| Case customer and order IDs available | Passed |
| Custom fields added to Selective Sync | Passed |
| Failed authentication recovered | Passed |
| Contact model created | Passed |
| Governed ID mapped to Segment User ID | Passed |
| Identify test | Passed |
| Mapping enabled | Passed |

## Next step — Day 3

Day 3 will extend the Salesforce implementation beyond Contact profile enrichment, define the treatment of Case data, and validate how customer-service context should be represented without turning operational Case records into profile traits indiscriminately.
