# Day 1 — Activation Use-Case and Destination Matrix

## Outcome

Day 1 connects the Sprint 5 audience definitions to practical business actions. The matrix separates the audience decision from the destination execution so each activation can be reviewed independently.

## Activation matrix

| Audience | Business action | Primary destination | Delivery pattern | Required identity |
|---|---|---|---|---|
| Recent purchasers | Post-purchase lifecycle messaging | Braze | Profile update or audience sync | Canonical customer ID plus consent |
| High-value customers | VIP retention and early-access journeys | Braze | Audience sync | Canonical customer ID plus marketing consent |
| Customers with unresolved service cases | Service follow-up or suppression from promotion | CRM/service workflow | Case-aware profile or suppression feed | Canonical customer ID and Case lineage |
| Marketplace customers | Cross-channel lifecycle analysis | Analytics/warehouse | Audience export or modeled table | Canonical customer ID |
| Review-required identities | Manual data-quality review | Internal review queue | No downstream activation | Source record and review reason |

## Destination principles

### Braze

Braze is the primary B2C activation destination for lifecycle audiences. The profile contract should carry the canonical customer ID, audience membership, evaluation timestamp, consent state and source lineage reference.

### CRM or service workflow

Service-case audiences should support operational follow-up and promotional suppression. A Salesforce Case Number is retained as context; it is not used as the customer identifier.

### Analytics or warehouse

Marketplace and Customer 360 audiences can be exported for measurement, analysis and future activation planning. This keeps analytical audiences separate from directly messageable audiences.

### Internal review queue

Ambiguous or unresolved identity records must never be activated. They should expose source system, source record ID, candidate customer, reason and review status.

## Activation eligibility

A profile may enter a downstream audience only when all are true:

- A canonical customer ID exists.
- Identity quality is deterministic.
- Required consent is present for the destination.
- The profile is not suppressed or deleted.
- The audience qualification reason is present.
- The evaluation timestamp is current.
- Source lineage can be retrieved for troubleshooting.

## Exclusion rules

Exclude:

- Anonymous-only profiles
- Guest or walk-in transactions without a crosswalk
- Attribute-only matches
- Conflicting source-to-customer assignments
- Missing consent
- Global suppression or deletion requests
- Profiles with stale or failed audience evaluation

## Example: TZ-CUST-006

TZ-CUST-006 can qualify for Recent purchasers or Marketplace customers when the audience query returns a current result and the required consent is present. Salesforce Case 00001026 may create service context or a promotional suppression condition; it does not independently qualify the customer for marketing communication.

## Day 1 acceptance criteria

- Each Sprint 5 audience has a defined business action.
- Each activation has a destination or an explicit no-activation route.
- Required identity and consent conditions are documented.
- Anonymous and review-required records are excluded.
- The matrix can be converted into destination field mappings on Day 3.

## Next step

Day 2 will formalize consent, suppression and deletion rules before any destination payload is designed.
