-- Sprint 5 / Day 4
-- Computed traits and audience qualification.
-- Run after the Day 3 golden profile and lineage views.

create or replace view customer_traits as
select
    g.customer_id,
    (g.customer_id is not null) as is_known_customer,
    g.has_woocommerce,
    g.has_offline_store,
    g.has_marketplace,
    g.has_salesforce,
    exists (
      select 1
      from normalized_source_records n
      where n.canonical_customer_id = g.customer_id
        and n.source_system = 'salesforce'
        and n.source_entity = 'case'
        and n.event_type = 'Case Opened'
    ) as has_salesforce_service_case,
    max(n.event_at) as last_activity_at,
    case
      when g.customer_id is not null then 'deterministic'
      else 'unresolved'
    end as identity_quality
from golden_profile g
left join normalized_source_records n
  on n.canonical_customer_id = g.customer_id
group by
    g.customer_id,
    g.is_known_customer,
    g.has_woocommerce,
    g.has_offline_store,
    g.has_marketplace,
    g.has_salesforce;

-- Use a parameter table so audience thresholds are visible and change-controlled.
create or replace view audience_parameters as
select
    cast(100.00 as decimal(12,2)) as high_value_threshold,
    cast(30 as integer) as recent_purchase_days;

-- Controlled value/order activity for audience examples.
create or replace view customer_activity_summary as
select
    n.canonical_customer_id as customer_id,
    sum(case when n.event_type = 'Order Completed' then 150.00 else 0.00 end) as completed_order_value,
    max(case when n.event_type = 'Order Completed' then n.event_at end) as last_completed_order_at,
    max(case when n.event_type = 'Order Completed' then 1 else 0 end) as has_completed_order,
    max(case when n.event_type in ('Order Cancelled','Order Returned') then 1 else 0 end) as has_cancelled_or_returned_order
from normalized_source_records n
where n.canonical_customer_id is not null
group by n.canonical_customer_id;

create or replace view audience_membership as
select
    t.customer_id,
    'Customers with unresolved service cases' as audience_name,
    'Linked Salesforce Case is open' as qualification_reason
from customer_traits t
where t.is_known_customer
  and t.has_salesforce_service_case

union all

select
    a.customer_id,
    'High-value customers' as audience_name,
    'Completed order value meets configured threshold' as qualification_reason
from customer_activity_summary a
cross join audience_parameters p
where a.customer_id is not null
  and a.completed_order_value >= p.high_value_threshold

union all

select
    a.customer_id,
    'Recent purchasers' as audience_name,
    'Completed order within configured lookback window' as qualification_reason
from customer_activity_summary a
cross join audience_parameters p
where a.customer_id is not null
  and a.has_completed_order = 1
  and a.has_cancelled_or_returned_order = 0
  and a.last_completed_order_at >= current_timestamp - (p.recent_purchase_days || ' days')::interval

union all

select
    t.customer_id,
    'Marketplace customers' as audience_name,
    'Deterministic marketplace activity is present' as qualification_reason
from customer_traits t
where t.is_known_customer
  and t.has_marketplace;

-- Review queue is intentionally separate from activation audiences.
create or replace view review_required_identities as
select
    source_system,
    source_entity,
    source_record_id,
    exception_reason,
    'Do not activate as a known customer' as handling
from identity_exceptions;
