# WooCommerce Real-Time Source Implementation

## Overview

Sprint 1 established WooCommerce as the first operational source in the Trend Zone customer data platform portfolio. Customer behaviour and transaction data now flows in real time from the ecommerce site to Twilio Segment through Google Tag Manager.

## Source environment — Trend Zone website

[Trend Zone](https://trendzone.prabirbera.com/) is a functional WordPress and WooCommerce fashion store created as the first-party test environment for this portfolio. It supports product browsing, simple and variable products, cart management, checkout, test orders, and customer login.

These real browser interactions generate the ecommerce and identity signals used by the implementation. GTM4WP publishes the WooCommerce events to the data layer, after which GTM translates them into the Segment tracking model.

All catalogue, order and customer information used for testing is non-production data.

## Business objective

The implementation provides a reliable behavioural and transactional foundation for:

- Understanding the ecommerce conversion journey
- Connecting anonymous browsing to known customers
- Building unified customer profiles
- Creating behavioural audiences
- Supporting abandoned-cart and conversion use cases
- Activating customer data in downstream destinations

## Architecture

```text
WordPress / WooCommerce
        ↓
GTM4WP ecommerce dataLayer
        ↓
Google Tag Manager
        ↓
Segment Analytics.js
        ↓
Twilio Segment
```

### Component responsibilities

| Component | Responsibility |
|---|---|
| WooCommerce | Product catalogue, cart, checkout, orders and customer accounts |
| GTM4WP | Publishes GA4-style ecommerce events and product data to the data layer |
| Google Tag Manager | Reads event payloads, applies mappings and controls tag execution |
| Segment Analytics.js | Sends Page, Track and Identify calls |
| Twilio Segment | Receives, validates and associates customer events |

## Implemented customer journey

| Website action | Data layer event | Segment call |
|---|---|---|
| Customer views a product | `view_item` | `Product Viewed` |
| Customer adds a product | `add_to_cart` | `Product Added` |
| Customer opens the cart | `view_cart` | `Cart Viewed` |
| Customer removes a product | `remove_from_cart` | `Product Removed` |
| Customer starts checkout | `begin_checkout` | `Checkout Started` |
| Customer completes an order | `purchase` | `Order Completed` |
| Customer signs in | `user_identified` | Segment Identify |

## GTM implementation pattern

Segment Analytics.js is initialized once per page. Each ecommerce tag listens to a dedicated Custom Event trigger and sends the current event payload to Segment.

Trigger display names use the `CE -` prefix, while the Event name field contains only the raw data-layer event name. For example:

| Trigger name | Event name |
|---|---|
| `CE - add_to_cart` | `add_to_cart` |
| `CE - remove_from_cart` | `remove_from_cart` |
| `CE - view_cart` | `view_cart` |
| `CE - begin_checkout` | `begin_checkout` |
| `CE - purchase` | `purchase` |

## Product data model

The common product schema includes:

```text
product_id
name
sku
price
quantity
category
stock_status
google_business_vertical
variant
parent_product_id
```

`variant` and `parent_product_id` are included when the item is a WooCommerce variation. Cart, checkout and order events contain a `products` array so multi-product journeys retain item-level context.

## Identity behaviour

Segment manages the anonymous identifier for visitors. After authentication, the WooCommerce customer ID is passed as the Segment `userId`, while permitted customer attributes are sent as Identify traits.

This connects pre-login behaviour with the known customer without unnecessarily copying customer PII into every ecommerce event.

See [Identity Implementation](../05-identity-resolution/identity-implementation.md) for the detailed identity design.

## Data-quality controls

- Analytics.js initializes once per page.
- Ecommerce tags fire once per matching event.
- Event-specific values are used instead of stale page-level arrays.
- IDs and SKUs are represented as strings in Segment.
- Monetary values and quantities remain numeric.
- Product arrays are cleared between ecommerce events.
- Purchase values reconcile with item price multiplied by quantity.
- Refreshing the order-received page does not create a duplicate Order Completed event.

## Reusable setup guide

For the complete setup sequence, screenshot plan, validation layers and troubleshooting decision table, see the [Sprint 1 WooCommerce-to-Segment Implementation Runbook](woocommerce/sprint-1-implementation-runbook.md).

## Outcome

The WooCommerce source is implemented, published and validated end to end. It now provides a reusable real-time data foundation for the later Customer 360, audience and activation phases of the portfolio.
