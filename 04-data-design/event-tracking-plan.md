# Cross-Channel Event Tracking Plan

## Purpose

This tracking plan defines the governed event contracts for the implemented WooCommerce, Snowflake and simulated TrendCart marketplace sources.

## Event taxonomy

| Data layer event | Segment method | Segment event | Business meaning | Status |
|---|---|---|---|---|
| `user_identified` | Identify | Not applicable | Connects an authenticated WooCommerce customer to prior anonymous activity | Validated |
| `view_item` | Track | `Product Viewed` | Customer viewed a product detail page | Validated |
| `add_to_cart` | Track | `Product Added` | Customer added a product and quantity to the cart | Validated |
| `remove_from_cart` | Track | `Product Removed` | Customer removed a product and quantity from the cart | Validated |
| `view_cart` | Track | `Cart Viewed` | Customer viewed the current cart contents | Validated |
| `begin_checkout` | Track | `Checkout Started` | Customer entered the checkout journey | Validated |
| `purchase` | Track | `Order Completed` | Customer successfully completed an online order | Validated |
| Snowflake modeled row | Track | `Offline Order Completed` | Known customer completed an offline-store order | Validated |
| Simulated created-order request | Track | `Marketplace Order Completed` | Marketplace order successfully created | Implemented — Sprint 3 |
| Simulated cancelled-order request | Track | `Marketplace Order Cancelled` | Marketplace order cancelled | Implemented — Sprint 3 |
| Simulated returned-order request | Track | `Marketplace Order Returned` | Marketplace order returned | Implemented — Sprint 3 |

## Identity contract

| Field | Source | Rule |
|---|---|---|
| `anonymousId` | Segment Analytics.js | Managed by Segment and maintained across the anonymous session |
| `userId` | WooCommerce customer ID | Added after successful identification |
| Email | WooCommerce customer profile | Sent as an Identify trait |
| Phone | WooCommerce customer profile | Sent as an Identify trait when available |

PII belongs in the Identify call and is not unnecessarily duplicated in ecommerce Track events.

## Standard product object

| Property | Type | Required | Description |
|---|---|---:|---|
| `product_id` | String | Yes | WooCommerce product or variation ID |
| `name` | String | Yes | Product display name |
| `sku` | String | Yes | Product SKU; product ID is used where the test catalogue has no separate SKU |
| `price` | Number | Yes | Unit price |
| `quantity` | Number | Yes | Quantity represented by the event |
| `category` | String | Yes | Primary product category |
| `stock_status` | String | Yes | WooCommerce availability status |
| `google_business_vertical` | String | Yes | Business classification; `retail` for this implementation |
| `variant` | String | Conditional | Selected variation such as colour |
| `parent_product_id` | String | Conditional | Parent ID for a variable product |

## Product Viewed, Added and Removed

These single-product events use the standard product fields and the following commerce properties:

| Property | Type | Rule |
|---|---|---|
| `currency` | String | ISO currency code; `INR` in the test implementation |
| `value` | Number | Unit price multiplied by event quantity |
| `quantity` | Number | Defaults to 1 for Product Viewed when the source event omits quantity |

## Cart Viewed and Checkout Started

| Property | Type | Required | Rule |
|---|---|---:|---|
| `currency` | String | Yes | Cart currency |
| `value` | Number | Yes | Current cart or checkout subtotal |
| `products` | Array | Yes | Current line items using the standard product object |

The products array must represent only the current cart or checkout state. Previously viewed or removed products must not persist.

## Order Completed

| Property | Type | Required | Rule |
|---|---|---:|---|
| `order_id` | String | Yes | Unique WooCommerce order number |
| `total` | Number | Yes | Final order total |
| `revenue` | Number | Yes | Revenue value used by the implementation |
| `value` | Number | Yes | Purchase value |
| `currency` | String | Yes | Order currency |
| `tax` | Number | Yes | Tax amount; zero is valid |
| `shipping` | Number | Yes | Shipping amount; zero is valid |
| `coupon` | String | No | Applied coupon or empty value |
| `products` | Array | Yes | Purchased line items |

## Offline Order Completed

Emitted by the Snowflake known-customer order model through Reverse ETL.

| Field | Contract |
|---|---|
| `userId` | Stable known-customer identifier |
| `timestamp` | Source order occurrence time normalized to UTC |
| `event` | `Offline Order Completed` |
| `properties.transaction_id` | Stable business transaction identifier |
| `properties.currency` | ISO currency code |
| `properties.subtotal`, `discount`, `tax`, `revenue` | Numeric order values that reconcile |
| `properties.products[]` | Product ID, SKU, name, category, quantity, price and line total |
| `anonymousId` | Not mapped because the offline order has no browser-session identity |

The mapping uses **Added records** so a completed order is normally sent once when first discovered. The Reverse ETL model uses `MESSAGE_ID` as its checkpoint identifier, but this destination generated the Tracking API `messageId`; production replay protection should therefore use a deterministic message ID where supported or downstream idempotency based on `transaction_id`.

## Planned Marketplace Event Contract

Sprint 3 used Postman to send four simulated TrendCart marketplace Track calls directly to a dedicated Segment HTTP API source. Known-customer events use the governed Trend Zone `userId`; marketplace-only events use a namespaced `anonymousId`.

| Field | Planned contract |
|---|---|
| `messageId` | Deterministic source `event_id` for traceability and duplicate control |
| `timestamp` | Original marketplace occurrence time normalized to UTC |
| `userId` | Used only when a deterministic Trend Zone customer crosswalk exists |
| `anonymousId` | Namespaced stable marketplace reference for marketplace-only shoppers |
| `properties.marketplace` | `trendcart` |
| `properties.marketplace_order_id` | Stable source order identifier |
| Monetary properties | Numeric values that reconcile to the source order |
| `properties.products[]` | Governed product ID, SKU, name, category, quantity and price fields |

A marketplace reference must not automatically become the Trend Zone `userId`. Invalid, unauthenticated, unsupported or duplicate requests must not produce duplicate customer events.

## Naming and type standards

- Segment event names use title case and past-tense business language.
- Data-layer events retain the GA4-style snake_case names produced by the source.
- IDs and SKUs are stored as strings in Segment.
- Price, value, quantity, tax, shipping and revenue are numeric.
- Optional variation properties are omitted when they do not apply.
- Event names and property names remain stable after publication.

## Acceptance criteria

An event is accepted only when:

1. The correct website action produces the expected data-layer event.
2. The mapped GTM tag fires once.
3. Segment receives the correct call type and event name.
4. Required properties are present with the correct types.
5. Product and monetary values match WooCommerce.
6. The customer identity state is correct.
7. No stale products or duplicate purchase events are observed.
