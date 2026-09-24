# Sprint 1 End-to-End Validation

## Scope

This document records the final QA of the WooCommerce → GTM → Twilio Segment implementation. Testing covered anonymous browsing, authenticated identity, cart behaviour, checkout and purchase completion.

## Test method

Every test followed the same verification chain:

```text
Website action
      ↓
WooCommerce / GTM4WP data layer
      ↓
GTM Preview event and tag execution
      ↓
Segment Source Debugger
      ↓
Payload and identity comparison
```

Testing used a controlled browser session so the same anonymous identifier could be followed through login and subsequent known-customer activity.

## Results

| Test | Expected outcome | Result |
|---|---|---|
| Product Viewed | Correct product reaches Segment once | Passed |
| Product Added | Correct product, quantity and value | Passed |
| Cart Viewed | Current cart appears in `products[]` | Passed |
| Product Removed | Only the removed item is reported | Passed |
| Stale-data check | Removed or previously viewed products do not persist | Passed |
| User Identify | Anonymous session connects to WooCommerce customer ID | Passed |
| Post-login tracking | Subsequent Track events contain the known `userId` | Passed |
| Checkout Started | Multi-product checkout payload and value reconcile | Passed |
| Order Completed | Order ID, totals and line items reconcile | Passed |
| Variable product | Variant and parent product ID are preserved | Passed |
| Purchase refresh | Same order ID does not generate a duplicate event | Passed |
| Published-container smoke test | Production events reach Segment without GTM Preview | Passed |

## Defect found and resolved

During QA, the trigger named `CE - add_to_cart` contained the incorrect Event name `CE - remove_from_cart`.

The trigger was corrected to:

```text
Trigger name: CE - add_to_cart
Event name:   add_to_cart
Tag:          SEG - Product Added
```

The Product Added flow was then retested successfully. The separate Product Removed trigger was verified against `remove_from_cart`.

## Payload reconciliation example

The final multi-product purchase contained:

| Product | Price | Quantity | Extended value |
|---|---:|---:|---:|
| Basic Gray Jeans | 150 | 1 | 150 |
| Boho Bangle Bracelet | 170 | 2 | 340 |
| **Total** |  |  | **490** |

Segment received `total`, `revenue` and `value` as 490 INR. The variable product retained its selected variant and parent-product identifier.

## Identity validation

The session began anonymously and Segment assigned an `anonymousId`. After the WooCommerce customer logged in:

- One Identify call was received.
- A stable WooCommerce-derived `userId` was present.
- The anonymous identifier remained connected to the session.
- Subsequent ecommerce events were associated with the known user.
- No undefined or duplicate Identify calls were observed.

## Purchase deduplication

After the initial Order Completed event was received, the order-received page was refreshed. Segment did not receive a second Order Completed event for the same order ID.

## Production verification

After the validated GTM workspace was published, a smoke test was completed without GTM Preview. Product Viewed, Product Added and Cart Viewed reached the Segment production source as expected.

## Final decision

**Sprint 1 QA status: Passed**

The WooCommerce real-time source is suitable for use as the validated foundation for the next portfolio phases. Screenshots and implementation evidence can be added separately under the repository assets when prepared.
