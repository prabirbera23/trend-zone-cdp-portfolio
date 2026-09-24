-- Sprint 6 / Day 2
-- Consent, suppression and activation eligibility reference model.

create table if not exists customer_consent (
    customer_id varchar(64) not null,
    consent_type varchar(64) not null,
    consent_status varchar(32) not null,
    consent_source varchar(128),
    consented_at timestamp,
    withdrawn_at timestamp,
    primary key (customer_id, consent_type)
);

create table if not exists activation_suppression (
    customer_id varchar(64) not null,
    suppression_type varchar(64) not null,
    suppression_status varchar(32) not null,
    reason_code varchar(128) not null,
    effective_at timestamp not null,
    expires_at timestamp,
    primary key (customer_id, suppression_type)
);

create table if not exists deletion_requests (
    customer_id varchar(64) primary key,
    request_type varchar(32) not null,
    request_status varchar(32) not null,
    requested_at timestamp not null,
    completed_at timestamp
);

-- Fictional controlled consent and suppression examples.
create or replace view controlled_activation_controls as
select *
from (
    values
      ('TZ-CUST-006','marketing_email','granted','portfolio_fixture','2026-09-16 19:55:00'::timestamp,null),
      ('TZ-CUST-006','service_communication','granted','portfolio_fixture','2026-09-16 19:55:00'::timestamp,null)
) as t(customer_id, consent_type, consent_status, consent_source, consented_at, withdrawn_at);

create or replace view activation_eligibility as
select
    a.customer_id,
    a.audience_name,
    a.qualification_reason,
    case
      when g.customer_id is null then 'blocked_missing_profile'
      when exists (
        select 1 from deletion_requests d
        where d.customer_id = a.customer_id
          and d.request_status in ('pending','completed')
      ) then 'blocked_deletion_request'
      when exists (
        select 1 from activation_suppression s
        where s.customer_id = a.customer_id
          and s.suppression_status = 'active'
          and s.suppression_type in ('global','marketing')
      ) then 'blocked_suppression'
      when not exists (
        select 1 from controlled_activation_controls c
        where c.customer_id = a.customer_id
          and c.consent_type = 'marketing_email'
          and c.consent_status = 'granted'
      ) then 'blocked_missing_marketing_consent'
      else 'eligible_for_marketing_email'
    end as eligibility_status,
    current_timestamp as evaluated_at
from audience_membership a
left join golden_profile g
  on g.customer_id = a.customer_id;

create or replace view activation_blocks as
select *
from activation_eligibility
where eligibility_status like 'blocked_%';
