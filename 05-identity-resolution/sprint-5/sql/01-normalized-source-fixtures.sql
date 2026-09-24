-- Sprint 5 / Day 2
-- Normalized source fixtures. Values are fictional and intentionally limited.

create or replace view normalized_source_records as
select
    source_system,
    source_entity,
    source_record_id,
    source_customer_id,
    canonical_customer_id,
    anonymous_id,
    email,
    phone,
    first_name,
    last_name,
    event_type,
    event_at,
    source_updated_at,
    raw_payload_ref
from (
    values
      ('trendcart','customer','TC-CUST-006','TC-CUST-006','TZ-CUST-006',null,
       'aditi.sharma.tz006@example.com',null,'Aditi','Sharma',null,
       timestamp '2026-09-16 19:51:50',timestamp '2026-09-16 20:56:11','trendcart.customer.TC-CUST-006'),
      ('trendcart','order','TC-ORD-1006','TC-CUST-006','TZ-CUST-006',null,
       'aditi.sharma.tz006@example.com',null,'Aditi','Sharma','Order Completed',
       timestamp '2026-09-16 20:30:00',timestamp '2026-09-16 20:30:00','trendcart.order.TC-ORD-1006'),
      ('salesforce','contact','003g700000eYmCrAAK',null,'TZ-CUST-006',null,
       'aditi.sharma.tz006@example.com',null,'Aditi','Sharma',null,
       timestamp '2026-09-16 19:51:50',timestamp '2026-09-16 19:51:50','salesforce.contact.003g700000eYmCrAAK'),
      ('salesforce','case','00001026',null,'TZ-CUST-006',null,
       null,null,null,null,'Case Opened',
       timestamp '2026-09-16 20:19:22',timestamp '2026-09-16 20:56:11','salesforce.case.00001026'),
      ('woocommerce','identify','WC-ID-006',null,'TZ-CUST-006','anon-web-006',
       'aditi.sharma.tz006@example.com',null,'Aditi','Sharma','Identify',
       timestamp '2026-09-16 19:55:00',timestamp '2026-09-16 19:55:00','woocommerce.identify.WC-ID-006'),
      ('marketplace','order','TC-ORD-ANON-001',null,null,'anon-marketplace-001',
       null,null,null,null,'Order Completed',
       timestamp '2026-09-16 21:00:00',timestamp '2026-09-16 21:00:00','trendcart.order.TC-ORD-ANON-001'),
      ('offline_store','transaction','POS-1007','WALK-IN-1007',null,null,
       null,null,null,null,'Purchase',
       timestamp '2026-09-16 21:10:00',timestamp '2026-09-16 21:10:00','offline.transaction.POS-1007'),
      ('woocommerce','customer','WC-AMB-001',null,null,null,
       'shared@example.com',null,'Aditi','Sharma','Customer Updated',
       timestamp '2026-09-16 21:20:00',timestamp '2026-09-16 21:20:00','woocommerce.customer.WC-AMB-001')
) as t(
    source_system, source_entity, source_record_id, source_customer_id,
    canonical_customer_id, anonymous_id, email, phone, first_name, last_name,
    event_type, event_at, source_updated_at, raw_payload_ref
);

-- Records that are safe for deterministic stitching.
create or replace view deterministic_identity_candidates as
select *
from normalized_source_records
where canonical_customer_id is not null;

-- Records that must remain separate until additional evidence exists.
create or replace view identity_exceptions as
select *,
       case
         when canonical_customer_id is null and anonymous_id is not null
           then 'anonymous_without_identify'
         when canonical_customer_id is null and source_customer_id like 'WALK-IN-%'
           then 'guest_or_walk_in'
         when canonical_customer_id is null and email is not null
           then 'attribute_similarity_only'
         else 'unclassified'
       end as exception_reason
from normalized_source_records
where canonical_customer_id is null;
