-- Sprint 6 / Day 5
-- Monitoring views for activation operations.

create or replace view activation_delivery_health as
select
    destination,
    audience_name,
    count(*) as total_attempts,
    sum(case when delivery_status in ('delivered','accepted') then 1 else 0 end) as successful_attempts,
    sum(case when delivery_status in ('failed','rejected') then 1 else 0 end) as failed_attempts,
    sum(case when error_category = 'transient_transport_failure' then 1 else 0 end) as retryable_attempts,
    sum(case when eligibility_status like 'blocked_%' then 1 else 0 end) as governance_blocks,
    max(evaluated_at) as latest_evaluation_at
from activation_delivery_log
group by destination, audience_name;

create or replace view activation_alerts as
select
    destination,
    audience_name,
    case
      when governance_blocks > 0 then 'critical'
      when failed_attempts > 0
       and failed_attempts::decimal / nullif(total_attempts,0) > 0.05 then 'high'
      when retryable_attempts > 0 then 'medium'
      else 'informational'
    end as severity,
    total_attempts,
    successful_attempts,
    failed_attempts,
    retryable_attempts,
    governance_blocks,
    latest_evaluation_at
from activation_delivery_health;

create table if not exists audience_evaluation_snapshot (
    audience_name varchar(255) not null,
    evaluation_date date not null,
    member_count integer not null,
    blocked_count integer not null default 0,
    source_snapshot_ref varchar(255),
    primary key (audience_name, evaluation_date)
);

create or replace view audience_drift as
select
    current_snapshot.audience_name,
    current_snapshot.evaluation_date as current_date,
    previous_snapshot.evaluation_date as previous_date,
    current_snapshot.member_count as current_members,
    previous_snapshot.member_count as previous_members,
    current_snapshot.member_count - previous_snapshot.member_count as member_delta,
    abs(current_snapshot.member_count - previous_snapshot.member_count)::decimal
      / nullif(previous_snapshot.member_count, 0) as relative_change
from audience_evaluation_snapshot current_snapshot
join audience_evaluation_snapshot previous_snapshot
  on previous_snapshot.audience_name = current_snapshot.audience_name
 and previous_snapshot.evaluation_date = current_snapshot.evaluation_date - 1;

create or replace view monitoring_exceptions as
select *
from activation_alerts
where severity in ('critical','high')
union all
select
    audience_name,
    'audience_evaluation' as destination,
    'medium' as severity,
    current_members as total_attempts,
    previous_members as successful_attempts,
    member_delta as failed_attempts,
    0 as retryable_attempts,
    0 as governance_blocks,
    current_date::timestamp as latest_evaluation_at
from audience_drift
where relative_change > 0.30;
