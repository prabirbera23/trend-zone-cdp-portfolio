# Day 2 — Consent, Suppression and Deletion Rules

## Outcome

Day 2 adds an activation eligibility layer between audience membership and destination delivery. A profile may qualify for an audience but still be blocked from activation because consent is missing, a suppression applies or a deletion request is pending.

## Eligibility model

Activation eligibility is evaluated per destination, not globally.

| Check | Description |
|---|---|
| Identity quality | Profile must have a deterministic canonical ID |
| Audience qualification | Profile must meet the audience rule |
| Consent | Destination-specific marketing or service permission is present |
| Suppression | No global, campaign, channel or service suppression applies |
| Deletion state | No pending or completed deletion request blocks delivery |
| Freshness | Audience evaluation is within the permitted window |
| Lineage | Qualification and source evidence remain available |

## Consent categories

- marketing_email — promotional email and lifecycle campaigns
- marketing_push — mobile or web push messaging
- service_communication — operational service follow-up
- analytics_processing — measurement and product analytics
- personalization — onsite or in-product personalization

Service communication may have a different legal basis from marketing communication. The destination contract must not treat them as interchangeable.

## Suppression precedence

1. Deletion or erasure request
2. Global do-not-contact request
3. Destination or channel suppression
4. Service-case promotional suppression
5. Campaign-level exclusion
6. Audience qualification

A higher-priority block always overrides audience membership.

## Salesforce service-case rule

An unresolved Salesforce Case may permit service follow-up while suppressing promotional messaging. Case 00001026 is therefore a service-context signal, not automatic marketing eligibility.

## Day 2 acceptance criteria

- Eligibility is evaluated separately for each destination.
- Missing consent blocks marketing activation.
- Deletion and global suppression override all audience membership.
- Service communication and marketing communication are evaluated independently.
- Every blocked record has a reason code.
- Consent and suppression changes are auditable.

## Next step

Day 3 will define destination-specific field mappings and payload contracts for eligible profiles.
