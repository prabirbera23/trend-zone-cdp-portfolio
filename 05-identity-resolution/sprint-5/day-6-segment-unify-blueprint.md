# Day 6 — Segment Unify Implementation Blueprint

## Purpose

This runbook maps the validated Sprint 5 Customer 360 contract to a Segment Unify implementation. It is a configuration blueprint for a licensed Unify workspace; the portfolio workspace used for source and mapping validation does not expose the required profile-level Unify capability.

The blueprint is still useful because every mapping is anchored to the identity, traits and QA rules already defined in this sprint.

## 1. Confirm the source contract

Before configuring Unify, confirm that the source models expose:

- A governed customer identifier using the TZ-CUST-### format
- Source-native record IDs for lineage
- Contact and Case objects from Salesforce
- Marketplace and ecommerce activity
- Explicit anonymous-to-known Identify transitions
- Consent and activation eligibility flags where required

Do not begin profile unification from email or name similarity alone.

## 2. Configure the identity namespace

Create or select the canonical customer identity namespace:

| Setting | Value |
|---|---|
| Primary customer key | customer_id |
| Example value | TZ-CUST-006 |
| Anonymous key | anonymousId |
| Salesforce Contact ID | Lineage attribute only |
| Salesforce Case Number | Activity lineage only |
| Match policy | Deterministic governed ID and approved crosswalk |

The namespace must not treat Salesforce Contact ID or Case Number as the customer identity.

## 3. Map source attributes

Map source fields into the canonical profile:

| Source field | Profile field | Treatment |
|---|---|---|
| Salesforce Trend_Zone_Customer_ID__c | customer_id | Identity key |
| Salesforce FirstName | first_name | Profile attribute |
| Salesforce LastName | last_name | Profile attribute |
| Salesforce Email | email | Verified attribute |
| Salesforce Contact.Id | traits.salesforce_contact_id | Lineage trait |
| Salesforce Case.CaseNumber | traits.salesforce_case_number | Service activity lineage |
| TrendCart customer ID | traits.marketplace_customer_id | Lineage trait |
| WooCommerce user ID | traits.woocommerce_customer_id | Lineage trait |
| anonymousId | anonymousId | Anonymous identity |

## 4. Configure profile traits

Create computed or modeled traits for:

- has_salesforce_service_case
- has_marketplace_activity
- is_known_customer
- identity_quality
- last_activity_at
- has_woocommerce
- has_offline_store
- has_marketplace
- has_salesforce

Each trait must have a documented source and refresh expectation.

## 5. Configure audiences

Create audiences using the Day 4 definitions:

- Customers with unresolved service cases
- High-value customers
- Recent purchasers
- Marketplace customers
- Review-required identities

Review-required identities must not be activated as known-customer audiences.

## 6. Validate the profile

Use the controlled profile TZ-CUST-006:

1. Confirm one unified profile exists.
2. Confirm TrendCart and Salesforce source lineage is visible.
3. Confirm Salesforce Case 00001026 appears as service context.
4. Confirm anonymous marketplace activity is not attached without Identify or crosswalk evidence.
5. Confirm profile traits match the SQL reference output.
6. Confirm audience membership has a qualification reason.
7. Confirm reprocessing is idempotent.

## 7. Activation guardrails

Before sending an audience downstream:

- Require a known canonical customer ID.
- Exclude review-queue records.
- Apply consent and suppression policies.
- Preserve audience version and evaluation timestamp.
- Monitor profile merge, unmerge and rejected-record counts.
- Retain a source lineage reference for troubleshooting.

## 8. Rollback and review

If a mapping produces unexpected merges:

1. Pause downstream activation.
2. Capture the affected profile IDs and source records.
3. Disable the offending identity rule or crosswalk version.
4. Rebuild the affected profile set from the last approved snapshot.
5. Re-run Day 5 validation assertions.
6. Record the decision and new rule version.

## Implementation boundary

The Sprint 5 repository proves the identity contract, normalized inputs, deterministic stitching, traits and QA logic through controlled reference artifacts. It does not claim that a licensed Segment Unify workspace was activated. The steps above are the production implementation path derived from that validated contract.
