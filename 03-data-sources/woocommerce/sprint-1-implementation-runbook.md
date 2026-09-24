# Sprint 1 Runbook — WooCommerce to Twilio Segment Through GTM

## Purpose

This runbook documents the implemented Trend Zone real-time ecommerce integration:

```text
WooCommerce → GTM4WP dataLayer → Google Tag Manager → Segment Analytics.js → Twilio Segment
```

It is written as a reusable implementation reference for future projects. The Trend Zone examples use fictional portfolio data; replace every environment-specific name, identifier and URL before using the procedure elsewhere.

## Implemented outcome

The completed Sprint 1 implementation captures the anonymous-to-known ecommerce journey through Page, Track and Identify calls.

| GTM4WP/dataLayer signal | Segment call | Segment event or purpose |
|---|---|---|
| Page lifecycle | Page | Page context |
| `view_item` | Track | `Product Viewed` |
| `add_to_cart` | Track | `Product Added` |
| `remove_from_cart` | Track | `Product Removed` |
| `view_cart` | Track | `Cart Viewed` |
| `begin_checkout` | Track | `Checkout Started` |
| `purchase` | Track | `Order Completed` |
| `user_identified` | Identify | Connect Segment-managed anonymous activity to a stable `userId` |

## How to use the screenshot placeholders

Every required screenshot has a permanent identifier such as `S1-01`. When supplying an image later, name it with the same identifier—for example, `S1-01.png`.

The final repository location will be:

```text
assets/evidence/sprint-1/runbook/S1-01.png
```

Each placeholder states exactly what the image should prove. Crop screenshots to the relevant interface and redact Write Keys, container IDs where necessary, cookies, credentials and any real customer information.

---

## 1. Confirm access and prerequisites

### Objective

Confirm that implementation and validation can be completed without creating duplicate tags or losing access midway.

### Required access

- WordPress administrator access
- WooCommerce administrator access
- Google Tag Manager container edit and publish access
- Twilio Segment workspace access
- Browser developer tools
- A fictional or authorized test customer and test order

### Pre-implementation checks

1. Record the environment and website being tested.
2. Confirm which GTM container is installed on the website.
3. Confirm whether Segment Analytics.js is already installed.
4. Confirm that only one Segment source Write Key is intended for the website.
5. Confirm that a rollback version exists in GTM.
6. Define a test plan before publishing.

> **Screenshot S1-01 — WordPress and WooCommerce environment**  
> Capture the WordPress dashboard with WooCommerce visible and the site/environment identifiable. Do not expose admin email addresses or unrelated plugins.  
> `<<PLACEHOLDER: S1-01.png>>`

### Expected result

The correct site, GTM container and Segment source are identified, and no second Segment installation is created accidentally.

---

## 2. Install and configure GTM4WP

### Objective

Expose WooCommerce ecommerce activity through a structured browser `dataLayer` that GTM can consume.

### Procedure

1. In WordPress, open **Plugins → Add New**.
2. Install and activate **GTM4WP — A Google Tag Manager plugin for WordPress**.
3. Open the plugin settings.
4. Configure the intended GTM container.
5. Enable the WooCommerce integration and its enhanced ecommerce/data-layer capability.
6. Save the configuration.
7. Avoid installing another GTM or Segment plugin that sends the same events.

> **Screenshot S1-02 — GTM4WP installed and active**  
> Capture the WordPress Plugins screen with GTM4WP shown as active.  
> `<<PLACEHOLDER: S1-02.png>>`

> **Screenshot S1-03 — GTM4WP WooCommerce settings**  
> Capture only the settings that enable WooCommerce ecommerce data-layer events. Redact the GTM container ID if desired.  
> `<<PLACEHOLDER: S1-03.png>>`

### Validation

Open a product page and run this in the browser console:

```javascript
window.dataLayer
```

Search the returned objects for `view_item` and inspect `ecommerce.items`.

> **Screenshot S1-04 — Product-page dataLayer event**  
> Capture the `view_item` event expanded in developer tools, including `ecommerce.items[0]`.  
> `<<PLACEHOLDER: S1-04.png>>`

### Expected result

The product page produces a `view_item` event with product information. Use the observed payload—not assumptions—to determine all GTM variable paths.

---

## 3. Inspect the data-layer contract

### Objective

Document the actual input schema before creating GTM variables and tags.

### Procedure

Using GTM Preview and browser developer tools, inspect these interactions individually:

1. View a product.
2. Add the product to the cart.
3. Remove a product from the cart.
4. Open the cart.
5. Begin checkout.
6. Complete a test purchase.
7. Log in with a test customer.

For every event, record:

- data-layer event name
- location of the product array
- order and value fields
- customer fields
- data types
- fields that may be null

> **Screenshot S1-05 — Ecommerce events in GTM Preview**  
> Capture the Preview event timeline showing the relevant WooCommerce events in their observed order.  
> `<<PLACEHOLDER: S1-05.png>>`

> **Screenshot S1-06 — Purchase dataLayer payload**  
> Capture the expanded `purchase` object with transaction ID, value, currency and product lines. Use fictional test data.  
> `<<PLACEHOLDER: S1-06.png>>`

### Important rule

Do not blindly copy a variable path from another WooCommerce website. GTM4WP versions, WooCommerce configuration and product types can change the payload shape.

---

## 4. Create reusable GTM Data Layer Variables

### Objective

Convert the observed `ecommerce.items[0]` values into reusable GTM variables.

### Implemented product variables

| GTM variable | Example data-layer path | Expected type |
|---|---|---|
| `DLV - Product ID` | `ecommerce.items.0.item_id` | String or number normalized by tag |
| `DLV - Product Name` | `ecommerce.items.0.item_name` | String |
| `DLV - Product SKU` | `ecommerce.items.0.sku` | String |
| `DLV - Product Price` | `ecommerce.items.0.price` | Number |
| `DLV - Product Stock Status` | `ecommerce.items.0.stockstatus` | String |
| `DLV - Google Business Vertical` | `ecommerce.items.0.google_business_vertical` | String |
| `DLV - Product Category` | `ecommerce.items.0.item_category` | String |
| `DLV - Product Quantity` | `ecommerce.items.0.quantity` | Number |
| `DLV - ecommerce.items` | `ecommerce.items` | Array |

The paths above document the implemented Trend Zone payload. Confirm them again before reusing the guide on a live website.

### Procedure

1. Open **GTM → Variables → New**.
2. Select **Data Layer Variable**.
3. Enter the verified path.
4. Use Data Layer Version 2 unless the project requires otherwise.
5. Apply the established naming convention.
6. Save and verify the value in Preview mode.

Do not recreate the same product variables for every event when the source path is unchanged.

> **Screenshot S1-07 — Product Data Layer Variables**  
> Capture the GTM Variables list showing the reusable product variables.  
> `<<PLACEHOLDER: S1-07.png>>`

> **Screenshot S1-08 — Variable values in Preview**  
> Capture the Variables tab for `view_item`, showing the eight variables populated with the selected product.  
> `<<PLACEHOLDER: S1-08.png>>`

### Expected result

Every variable returns the expected value and type before it is used in a Segment call.

---

## 5. Create GTM Custom Event triggers

### Objective

Fire each Segment tag only for its corresponding data-layer event.

| Trigger name | Event name | Segment tag |
|---|---|---|
| `CE - view_item` | `view_item` | `SEG - Product Viewed` |
| `CE - add_to_cart` | `add_to_cart` | `SEG - Product Added` |
| `CE - remove_from_cart` | `remove_from_cart` | `SEG - Product Removed` |
| `CE - view_cart` | `view_cart` | `SEG - Cart Viewed` |
| `CE - begin_checkout` | `begin_checkout` | `SEG - Checkout Started` |
| `CE - purchase` | `purchase` | `SEG - Order Completed` |
| `CE - user_identified` | `user_identified` | `SEG - User Identify` |

### Procedure

1. Open **GTM → Triggers → New**.
2. Select **Custom Event**.
3. Enter the exact event name.
4. Configure the trigger for that event only.
5. Save it using the `CE -` naming convention.

The product array is tag data, not a trigger. Do not connect `DLV - ecommerce.items` to a trigger unless an explicit business rule requires it.

> **Screenshot S1-09 — `CE - view_item` trigger**  
> Capture the complete trigger configuration, including Custom Event type and event name.  
> `<<PLACEHOLDER: S1-09.png>>`

> **Screenshot S1-10 — Sprint 1 Custom Event triggers**  
> Capture the trigger list showing all seven implemented custom-event triggers.  
> `<<PLACEHOLDER: S1-10.png>>`

---

## 6. Create the Segment JavaScript source

### Objective

Create the website endpoint that receives Analytics.js Page, Track and Identify calls.

### Procedure

1. In Segment, open **Connections → Sources**.
2. Add a JavaScript/website source if one does not already exist.
3. Use a clear environment-aware name such as `Trend Zone Website - PROD`.
4. Copy the source Write Key securely.
5. Never place the Write Key in screenshots, documentation, tickets or public repositories.

> **Screenshot S1-11 — Segment website source overview**  
> Capture the source name, type and enabled status. Crop or redact all Write Key values.  
> `<<PLACEHOLDER: S1-11.png>>`

### Expected result

One intended Segment JavaScript source exists for the environment.

---

## 7. Load Segment Analytics.js through GTM

### Objective

Make `window.analytics` available before any ecommerce or identity tag runs.

### Procedure

1. Create the GTM tag `SEG - Analytics.js - Initialize`.
2. Use the current official Segment Analytics.js installation snippet for the source.
3. Insert the correct Write Key using a controlled GTM variable or approved secret-handling convention.
4. Use the **Initialization → All Pages** trigger.
5. Confirm that the initialization tag runs once per page.
6. Do not retain another active Analytics.js installation in the theme, header/footer plugin or second GTM tag.

> **Screenshot S1-12 — Analytics.js initialization tag**  
> Capture the GTM tag name, tag type and triggering section. Redact the Write Key and any sensitive code values.  
> `<<PLACEHOLDER: S1-12.png>>`

> **Screenshot S1-13 — Initialization trigger**  
> Capture the `Initialization → All Pages` trigger associated with the tag.  
> `<<PLACEHOLDER: S1-13.png>>`

### Validation

In the console, check:

```javascript
typeof window.analytics
```

Then send a controlled test call if permitted:

```javascript
window.analytics.track('Test Event');
```

> **Screenshot S1-14 — Analytics.js available in browser**  
> Capture the console result showing that `window.analytics` exists. Do not capture cookies or unrelated console data.  
> `<<PLACEHOLDER: S1-14.png>>`

### Expected result

Analytics.js loads before event tags and a controlled request reaches the intended Segment source.

---

## 8. Implement `Product Viewed` first

### Objective

Validate the complete integration pattern with one event before cloning it across the ecommerce journey.

### Minimal diagnostic tag

Begin with the smallest possible Custom HTML call:

```html
<script>
  if (window.analytics && typeof window.analytics.track === 'function') {
    window.analytics.track('Product Viewed');
  }
</script>
```

Attach `CE - view_item` and confirm delivery. Then add the validated product properties:

```html
<script>
  if (window.analytics && typeof window.analytics.track === 'function') {
    window.analytics.track('Product Viewed', {
      product_id: '{{DLV - Product ID}}',
      name: '{{DLV - Product Name}}',
      sku: '{{DLV - Product SKU}}',
      price: Number('{{DLV - Product Price}}'),
      stock_status: '{{DLV - Product Stock Status}}',
      google_business_vertical: '{{DLV - Google Business Vertical}}',
      category: '{{DLV - Product Category}}',
      quantity: Number('{{DLV - Product Quantity}}')
    });
  }
</script>
```

Validate numeric conversion against the real payload. Do not allow missing variables to silently become invalid numbers.

> **Screenshot S1-15 — Product Viewed tag configuration**  
> Capture the Custom HTML tag, associated trigger and visible property mappings. Ensure the screenshot contains no Write Key.  
> `<<PLACEHOLDER: S1-15.png>>`

> **Screenshot S1-16 — Product Viewed fired in GTM Preview**  
> Capture the `view_item` event with `SEG - Product Viewed` under Tags Fired.  
> `<<PLACEHOLDER: S1-16.png>>`

> **Screenshot S1-17 — Product Viewed in Segment**  
> Capture the allowed Track event and its normalized properties in the Segment Source Debugger.  
> `<<PLACEHOLDER: S1-17.png>>`

### Debugging lesson from Sprint 1

At one stage the GTM tag appeared under **Tags Fired**, but no `Product Viewed` Track call appeared in Segment. A manual console call succeeded, proving that Analytics.js and network communication were functioning. The investigation therefore focused on tag execution, initialization timing and variable substitution rather than rebuilding the Segment source.

Use this diagnostic sequence:

1. Confirm the data-layer event exists.
2. Confirm the trigger matches the exact event name.
3. Confirm the tag fires in GTM Preview.
4. Confirm `window.analytics.track` exists when the tag executes.
5. Test a minimal property-free Track call.
6. Inspect the browser Network tab.
7. Confirm the event in Segment Source Debugger.
8. Add properties only after the minimal call succeeds.

---

## 9. Extend the pattern across the cart journey

### Objective

Implement the remaining pre-purchase events while preserving the validated pattern.

### Events

- `Product Added`
- `Product Removed`
- `Cart Viewed`
- `Checkout Started`

### Procedure

For each event:

1. Inspect the actual data-layer object.
2. Reuse existing variables when their paths remain valid.
3. Create only the additional event-level variables required for totals, currency or product arrays.
4. Create the matching `CE -` trigger.
5. Create the matching `SEG -` Track tag.
6. Test one interaction in Preview mode.
7. Validate event name, property names, values and types in Segment.
8. Check that the interaction creates exactly one Track event.

For cart, checkout and order events, preserve the complete `products[]` array where the source provides multiple lines; do not reduce a multi-product order to `items[0]`.

> **Screenshot S1-18 — Cart-event GTM tags**  
> Capture the GTM Tags list showing Product Added, Product Removed, Cart Viewed and Checkout Started.  
> `<<PLACEHOLDER: S1-18.png>>`

> **Screenshot S1-19 — Cart journey in Segment**  
> Capture the Source Debugger timeline showing the pre-purchase events in a realistic sequence.  
> `<<PLACEHOLDER: S1-19.png>>`

---

## 10. Implement customer identification

### Objective

Connect Segment-managed anonymous browsing history to a stable authenticated customer ID.

### Identity rules

- Segment manages `anonymousId` automatically.
- WooCommerce customer ID is transformed into the stable Trend Zone `userId` contract.
- Email and phone are traits, not primary identifiers.
- Do not create a GTM `DLV - Anonymous ID` merely to duplicate Segment's work.
- Do not put Snowflake, marketplace or CRM identifiers into the website data layer.

### Target data-layer event

```javascript
window.dataLayer.push({
  event: 'user_identified',
  user: {
    customer_id: 'TZ_7',
    email: 'fictional.user@example.com',
    phone: '+910000000000'
  }
});
```

The project used fictional values. A live implementation must define when this event is emitted, apply consent requirements and prevent unnecessary exposure of PII in the browser.

### GTM variables

| Variable | Data-layer path |
|---|---|
| `DLV - Customer ID` | `user.customer_id` |
| `DLV - Customer Email` | `user.email` |
| `DLV - Customer Phone` | `user.phone` |

### Identify tag

```html
<script>
  if (window.analytics && typeof window.analytics.identify === 'function') {
    window.analytics.identify('{{DLV - Customer ID}}', {
      email: '{{DLV - Customer Email}}',
      phone: '{{DLV - Customer Phone}}'
    });
  }
</script>
```

Attach the `CE - user_identified` trigger and ensure the event fires once at the intended authentication point.

> **Screenshot S1-20 — Logged-in customer dataLayer**  
> Capture the fictional `user_identified` event with customer ID, email and phone visible. Never use real customer data.  
> `<<PLACEHOLDER: S1-20.png>>`

> **Screenshot S1-21 — Customer identity variables**  
> Capture the three identity variables and their populated Preview values.  
> `<<PLACEHOLDER: S1-21.png>>`

> **Screenshot S1-22 — Segment Identify GTM tag**  
> Capture the Identify tag and `CE - user_identified` trigger, with fictional values only.  
> `<<PLACEHOLDER: S1-22.png>>`

> **Screenshot S1-23 — Identify event in Segment**  
> Capture an allowed Identify event showing stable `userId` and traits. Redact or use fictional PII.  
> `<<PLACEHOLDER: S1-23.png>>`

### Expected result

The anonymous visitor retains Segment's anonymous identity before login, and the Identify call associates subsequent activity with the stable `userId`.

---

## 11. Implement `Order Completed`

### Objective

Send one normalized purchase event with stable transaction identity, financial values and every product line.

### Minimum contract

| Property | Rule |
|---|---|
| `order_id` | Stable WooCommerce order identifier |
| `revenue` | Final transaction revenue |
| `currency` | ISO currency code |
| `products[]` | All purchased lines with product ID, SKU, name, category, price and quantity |
| `userId` | Supplied through established Segment identity when customer is known |

### Procedure

1. Inspect the `purchase` data-layer payload on the confirmation page.
2. Map order ID, currency, revenue and the full items array.
3. Normalize property names to the tracking plan.
4. Attach the tag to `CE - purchase`.
5. Confirm the purchase tag fires once.
6. Refresh the confirmation page during testing and check whether the source can emit a duplicate purchase.
7. Validate financial values and product-line totals against WooCommerce.

> **Screenshot S1-24 — Order Completed tag and mappings**  
> Capture the GTM tag, `CE - purchase` trigger and order-property mappings.  
> `<<PLACEHOLDER: S1-24.png>>`

> **Screenshot S1-25 — Order Completed payload in Segment**  
> Capture the allowed event with order ID, revenue, currency, user identity and all product lines. Use fictional order data.  
> `<<PLACEHOLDER: S1-25.png>>`

---

## 12. Validate the integration end to end

### Test journey

Run one clean browser journey:

1. Start as an anonymous visitor.
2. Open a product page.
3. Add the product to cart.
4. View the cart.
5. Begin checkout.
6. Authenticate using a fictional test customer.
7. Complete a test order.
8. Review the event sequence in Segment.

### Validation layers

| Layer | What to verify |
|---|---|
| WooCommerce | The business interaction completed successfully |
| Browser data layer | Correct event and complete source payload |
| GTM Preview | Correct trigger, variables and exactly one fired tag |
| Browser Network | Segment request sent without blocking or script error |
| Segment Source Debugger | Correct Page/Track/Identify call allowed |
| Tracking plan | Names, properties, types and identity follow the contract |

> **Screenshot S1-26 — Complete GTM Preview journey**  
> Capture the event timeline and representative fired tags across the test journey.  
> `<<PLACEHOLDER: S1-26.png>>`

> **Screenshot S1-27 — Complete Segment event journey**  
> Capture the Source Debugger timeline showing Page, Track and Identify calls in the expected sequence.  
> `<<PLACEHOLDER: S1-27.png>>`

> **Screenshot S1-28 — Published GTM version**  
> Capture the published container version name and date after validation. Do not expose sensitive environment details.  
> `<<PLACEHOLDER: S1-28.png>>`

### Acceptance checklist

- [ ] Analytics.js initializes once before ecommerce tags.
- [ ] Page calls reach the correct Segment source.
- [ ] All six ecommerce Track events use approved names.
- [ ] Identify sends stable `userId` and approved traits.
- [ ] Segment retains its managed `anonymousId` behavior.
- [ ] Multi-product arrays retain all lines.
- [ ] Prices, quantities, revenue and currency have correct types.
- [ ] No event is duplicated during the normal journey.
- [ ] Segment shows the calls as allowed with no relevant violations.
- [ ] GTM version is published only after Preview validation.
- [ ] Screenshots contain only fictional data and no secrets.

---

## 13. Troubleshooting decision table

| Symptom | Likely layer | Checks |
|---|---|---|
| WooCommerce action occurs but no data-layer event | GTM4WP/WooCommerce | Plugin activation, WooCommerce integration, cache and payload support |
| Event exists but trigger does not fire | GTM | Exact event spelling, Preview container and trigger configuration |
| Trigger fires but tag does not | GTM | Exceptions, consent, tag sequencing and tag errors |
| Tag fires but Segment receives nothing | Analytics.js/browser | `window.analytics`, initialization timing, console errors, network requests, blockers and CSP |
| Minimal Track succeeds but enriched call fails | Mapping/type | Undefined variables, quoting, numeric conversion and malformed arrays |
| Segment receives duplicates | Multiple implementations | Duplicate GTM tags, theme scripts, plugins, repeated data-layer events or confirmation-page reload |
| Identify arrives without `userId` | Identity mapping | Customer-ID path, login timing and empty GTM variable |
| Purchase contains one product only | Array mapping | Replace first-item mapping with full normalized `products[]` transformation |

### Controlled debugging principle

Change one layer at a time. A GTM **Tags Fired** result proves that GTM attempted the tag; it does not prove that Segment received or accepted the call.

---

## 14. Production-readiness improvements

Before adapting this portfolio implementation to a live project:

- Confirm consent-management requirements and tag behavior by consent state.
- Use separate development, staging and production containers/sources.
- Define a formal tracking-plan approval process.
- Add automated schema enforcement or Protocols where licensed.
- Minimize PII and document its lawful purpose and retention.
- Establish monitoring for volume changes, blocked calls and violations.
- Define purchase deduplication and replay behavior.
- Validate variable paths after GTM4WP or WooCommerce upgrades.
- Use a controlled method for managing environment-specific Write Keys.
- Document rollback ownership and incident escalation.

---

## Screenshot register

Use this table when collecting the images. The identifier and filename must remain unchanged.

| ID | Filename | Evidence | Status |
|---|---|---|---|
| S1-01 | `S1-01.png` | WordPress/WooCommerce environment | Pending |
| S1-02 | `S1-02.png` | GTM4WP active | Pending |
| S1-03 | `S1-03.png` | GTM4WP WooCommerce settings | Pending |
| S1-04 | `S1-04.png` | `view_item` dataLayer payload | Pending |
| S1-05 | `S1-05.png` | Ecommerce events in GTM Preview | Pending |
| S1-06 | `S1-06.png` | Purchase dataLayer payload | Pending |
| S1-07 | `S1-07.png` | Product variable list | Pending |
| S1-08 | `S1-08.png` | Product variable values | Pending |
| S1-09 | `S1-09.png` | `CE - view_item` trigger | Pending |
| S1-10 | `S1-10.png` | Sprint 1 trigger list | Pending |
| S1-11 | `S1-11.png` | Segment website source | Pending |
| S1-12 | `S1-12.png` | Analytics.js initialization tag | Pending |
| S1-13 | `S1-13.png` | Initialization trigger | Pending |
| S1-14 | `S1-14.png` | Browser Analytics.js check | Pending |
| S1-15 | `S1-15.png` | Product Viewed tag | Pending |
| S1-16 | `S1-16.png` | Product Viewed fired in GTM | Pending |
| S1-17 | `S1-17.png` | Product Viewed in Segment | Pending |
| S1-18 | `S1-18.png` | Cart-event tag list | Pending |
| S1-19 | `S1-19.png` | Cart journey in Segment | Pending |
| S1-20 | `S1-20.png` | Customer identity dataLayer | Pending |
| S1-21 | `S1-21.png` | Identity variable values | Pending |
| S1-22 | `S1-22.png` | Identify GTM tag | Pending |
| S1-23 | `S1-23.png` | Identify event in Segment | Pending |
| S1-24 | `S1-24.png` | Order Completed mapping | Pending |
| S1-25 | `S1-25.png` | Order Completed in Segment | Pending |
| S1-26 | `S1-26.png` | Complete GTM Preview journey | Pending |
| S1-27 | `S1-27.png` | Complete Segment journey | Pending |
| S1-28 | `S1-28.png` | Published GTM version | Pending |

## Related project documents

- [WooCommerce Real-Time Implementation](../woocommerce-real-time-implementation.md)
- [Ecommerce Event Tracking Plan](../../04-data-design/event-tracking-plan.md)
- [Identity Implementation](../../05-identity-resolution/identity-implementation.md)
- [Sprint 1 End-to-End QA](../../07-testing-and-validation/sprint-1-end-to-end-qa.md)

