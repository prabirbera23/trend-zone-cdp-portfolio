-- Sprint 5 / Day 5
-- QA assertions for deterministic identity, traits and audiences.

-- P1/P2/P3: the controlled customer must have one profile and Salesforce service context.
select
    case when count(*) = 1 then 'PASS' else 'FAIL' end as p1_profile_cardinality,
    case when bool_or(has_marketplace) then 'PASS' else 'FAIL' end as p1_marketplace_presence,
    case when bool_or(has_salesforce) then 'PASS' else 'FAIL' end as p2_salesforce_presence
from golden_profile
where customer_id = 'TZ-CUST-006';

select
    case when count(*) = 1 then 'PASS' else 'FAIL' end as p3_case_lineage
from profile_lineage
where source_system = 'salesforce'
  and source_entity = 'case'
  and source_record_id = '00001026'
  and resolved_customer_id = 'TZ-CUST-006';

-- N1/N2: anonymous and walk-in records must not resolve to a golden profile.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as n1_n2_unintended_lineage
from identity_exceptions e
join profile_lineage p
  on p.source_system = e.source_system
 and p.source_entity = e.source_entity
 and p.source_record_id = e.source_record_id
where e.exception_reason in ('anonymous_without_identify','guest_or_walk_in');

-- N3: cancelled or returned activity cannot create recent-purchaser membership.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as n3_cancelled_returned_excluded
from audience_membership a
join customer_activity_summary s
  on s.customer_id = a.customer_id
where a.audience_name = 'Recent purchasers'
  and s.has_cancelled_or_returned_order = 1;

-- A1: attribute-only records must remain in the review set.
select
    case when count(*) >= 1 then 'PASS' else 'FAIL' end as a1_attribute_similarity_reviewed
from review_required_identities
where exception_reason = 'attribute_similarity_only';

-- A2: source records assigned to multiple profiles must be detectable.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as a2_no_duplicate_assignments
from (
    select source_system, source_entity, source_record_id
    from profile_lineage
    group by source_system, source_entity, source_record_id
    having count(distinct resolved_customer_id) > 1
) duplicates;

-- Every active audience row must have a reason and a deterministic profile.
select
    case
      when count(*) = 0 then 'PASS'
      else 'FAIL'
    end as audience_explainability
from audience_membership a
left join golden_profile g on g.customer_id = a.customer_id
where g.customer_id is null
   or a.qualification_reason is null
   or trim(a.qualification_reason) = '';
