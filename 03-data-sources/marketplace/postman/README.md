# TrendCart Direct Segment Simulation

This Postman Collection v2.1 sends four fictional TrendCart marketplace scenarios directly to a dedicated Segment HTTP API source.

## Import and configure

1. Import `trendcart-direct-segment-simulation.postman_collection.json`.
2. Create or select the private environment `TrendCart Marketplace — Development`.
3. Add the variables below.

| Variable | Value |
|---|---|
| `segment_track_url` | `https://api.segment.io/v1/track` |
| `segment_write_key` | The dedicated Segment HTTP API source Write Key |

Mark `segment_write_key` as sensitive/secret. Do not export or commit its value.

## Requests

| Request | Event | Identity |
|---|---|---|
| 01 — Known Customer Order | Marketplace Order Completed | `userId` |
| 02 — Marketplace-Only Customer Order | Marketplace Order Completed | Namespaced `anonymousId` |
| 03 — Cancelled Marketplace Order | Marketplace Order Cancelled | `userId` |
| 04 — Returned Marketplace Order | Marketplace Order Returned | `userId` |

Each request uses Basic Auth with `{{segment_write_key}}` as the username and a blank password.

## Validation

Each request verifies that Segment returns HTTP `200` and `{"success":true}`. Run the requests through Collection Runner in numerical order. The validated baseline is four requests, eight passing assertions and zero errors.

## Disclosure

TrendCart and all records are fictional. Postman represents a simulated marketplace/partner API; this collection does not claim a live integration with a real marketplace.
