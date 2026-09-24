-- Sprint 6 / Day 4
-- Activation QA assertions and delivery outcome model.

create table if not exists activation_delivery_log (
    delivery_id varchar(255) primary key,
    customer_id varchar(64) not null,
    audience_name varchar(255) not null,
    audience_version varchar(64) not null,
    destination varchar(128) not null,
    eligibility_status varchar(64) not null,
    delivery_status varchar(64) not null,
    error_category varchar(64),
    attempt_number integer not null default 1,
    idempotency_key varchar(512) not null unique,
    evaluated_at timestamp not null,
    delivered_at timestamp
);

-- A1: eligible records must have a destination-ready decision.
select
    case when count(*) >= 1 then 'PASS' else 'FAIL' end as a1_eligible_profile
from activation_eligibility
where customer_id = 'TZ-CUST-006'
  and eligibility_status = 'eligible_for_marketing_email';

-- A2-A4: governance blocks cannot be marked as deliverable.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as governance_blocks_not_deliverable
from activation_delivery_log
where eligibility_status like 'blocked_%'
  and delivery_status in ('delivered','accepted');

-- A5-A6: no activation row may exist without a canonical profile.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as no_noncanonical_delivery
from activation_delivery_log l
left join golden_profile g on g.customer_id = l.customer_id
where g.customer_id is null;

-- A7: retryable failures must have a bounded retry state.
select
    case
      when count(*) = 0 then 'PASS'
      when bool_and(attempt_number <= 5) then 'PASS'
      else 'FAIL'
    end as retry_bound_check
from activation_delivery_log
where error_category = 'transient_transport_failure';

-- A8: contract failures are quarantined.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as contract_failures_not_delivered
from activation_delivery_log
where error_category = 'contract_failure'
  and delivery_status in ('delivered','accepted');

-- A10: one idempotency key must not be processed more than once.
select
    case when count(*) = 0 then 'PASS' else 'FAIL' end as duplicate_idempotency_check
from (
    select idempotency_key
    from activation_delivery_log
    group by idempotency_key
    having count(*) > 1
) duplicates;
