# Day 6 — Activation Measurement Framework

## Outcome

Day 6 defines how to measure whether an activation is technically healthy, audience-relevant and commercially useful. Delivery success alone is not treated as business success.

## Measurement layers

| Layer | Question | Example metrics |
|---|---|---|
| Data quality | Is the audience trustworthy? | Deterministic-match rate, review-queue rate, duplicate rate |
| Eligibility | Can profiles legally and operationally activate? | Consent-eligible rate, suppression rate, deletion-block rate |
| Delivery | Did the destination receive the audience? | Accepted rate, rejected rate, retry rate, latency |
| Engagement | Did customers respond? | Delivered, opened, clicked, viewed |
| Business outcome | Did the activation influence behavior? | Purchase rate, repeat purchase, service resolution |
| Economics | Is the use case valuable? | Revenue per recipient, cost per conversion, incremental lift |

## Recommended KPI definitions

### Deterministic-match rate

Known profiles divided by all candidate records. A rising review queue may indicate source quality or crosswalk issues.

### Activation eligibility rate

Eligible profiles divided by audience-qualified profiles. Track by destination because consent requirements differ.

### Delivery acceptance rate

Accepted destination deliveries divided by attempted eligible deliveries. Exclude governance-blocked records from the transport denominator.

### Audience-to-outcome rate

Customers with the intended business outcome divided by eligible recipients, measured within a declared attribution window.

### Incremental lift

Difference between the treatment group outcome and a comparable holdout group. Do not claim lift from exposed-versus-unexposed comparisons without controlling for selection bias.

## Measurement contract

Every audience export should carry:

- Audience name and version
- Evaluation timestamp
- Destination
- Customer ID
- Eligibility status
- Consent snapshot
- Source snapshot reference
- Campaign or activation ID

## Attribution guardrails

- Define the conversion event before activation.
- Define the attribution window before reviewing results.
- Keep audience evaluation and delivery timestamps separate.
- Preserve a holdout or comparison design where possible.
- Report reach and outcome metrics separately.
- Do not treat an accepted payload as a conversion.

## Controlled example

For TZ-CUST-006, the portfolio can demonstrate profile eligibility, payload construction and delivery-contract logic. It must not invent open, click, conversion or revenue results without a real downstream campaign.

## Acceptance criteria

- Every activation has operational and business KPIs.
- Metric definitions include numerator, denominator and time window.
- Audience and delivery snapshots can be joined to outcome events.
- Holdout guidance is documented.
- The portfolio distinguishes validated implementation evidence from future campaign results.

## Next step

Day 7 will consolidate Sprint 6 into an operational runbook and portfolio handoff.
