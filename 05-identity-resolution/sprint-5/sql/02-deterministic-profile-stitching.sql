-- Sprint 5 / Day 3
-- Deterministic golden profile and lineage views.
-- Run after 00-identity-foundation.sql and 01-normalized-source-fixtures.sql.

create or replace view golden_profile as
select
    n.canonical_customer_id as customer_id,
    max(case when n.source_system = 'salesforce'
              and n.source_entity = 'contact' then n.first_name end) as first_name,
    max(case when n.source_system = 'salesforce'
              and n.source_entity = 'contact' then n.last_name end) as last_name,
    max(case when n.email is not null then n.email end) as email,
    max(case when n.phone is not null then n.phone end) as phone,
    min(n.event_at) as profile_created_at,
    max(coalesce(n.source_updated_at, n.event_at)) as profile_updated_at,
    max(case when n.source_system = 'woocommerce' then true else false end) as has_woocommerce,
    max(case when n.source_system = 'offline_store' then true else false end) as has_offline_store,
    max(case when n.source_system in ('trendcart','marketplace') then true else false end) as has_marketplace,
    max(case when n.source_system = 'salesforce' then true else false end) as has_salesforce
from normalized_source_records n
where n.canonical_customer_id is not null
group by n.canonical_customer_id;

create or replace view profile_lineage as
select
    n.canonical_customer_id as customer_id,
    n.source_system,
    n.source_entity,
    n.source_record_id,
    coalesce(n.canonical_customer_id, x.customer_id) as resolved_customer_id,
    case
      when n.canonical_customer_id is not null then 'exact_governed_id'
      when x.customer_id is not null then x.match_method
      else 'unmatched'
    end as match_method,
    case
      when n.canonical_customer_id is not null or x.customer_id is not null then 1.000
      else 0.000
    end as confidence
from normalized_source_records n
left join identity_crosswalk x
  on x.source_system = n.source_system
 and x.source_entity = n.source_entity
 and x.source_record_id = n.source_record_id
where n.canonical_customer_id is not null
   or x.customer_id is not null;

-- One row per canonical customer.
select customer_id, count(*) as profile_row_count
from golden_profile
group by customer_id
having count(*) <> 1;

-- A source record must never belong to more than one customer.
select source_system, source_entity, source_record_id,
       count(distinct resolved_customer_id) as customer_count
from profile_lineage
group by source_system, source_entity, source_record_id
having count(distinct resolved_customer_id) > 1;

-- Expected positive-path assertion for the controlled customer.
select
    customer_id,
    has_marketplace,
    has_salesforce,
    profile_created_at,
    profile_updated_at
from golden_profile
where customer_id = 'TZ-CUST-006';

-- Expected lineage for Salesforce service context.
select source_system, source_entity, source_record_id, resolved_customer_id
from profile_lineage
where source_system = 'salesforce'
  and source_record_id = '00001026';

-- No anonymous, walk-in or ambiguous record should be in the golden profile.
select n.source_system, n.source_record_id
from normalized_source_records n
left join golden_profile g
  on g.customer_id = n.canonical_customer_id
where n.canonical_customer_id is null
  and g.customer_id is not null;
