-- Sprint 6 / Day 6
-- Measurement views for activation operations and outcomes.

create table if not exists activation_outcome_events (
    activation_id varchar(128) not null,
    customer_id varchar(64) not null,
    event_type varchar(128) not null,
    event_at timestamp not null,
    order_value decimal(12,2),
    primary key (activation_id, customer_id, event_type, event_at)
);

create table if not exists activation_measurement_snapshot (
    activation_id varchar(128) primary key,
    audience_name varchar(255) not null,
    audience_version varchar(64) not null,
    destination varchar(128) not null,
    evaluated_at timestamp not null,
    eligible_count integer not null,
    blocked_count integer not null,
    attempted_count integer not null,
    accepted_count integer not null,
    failed_count integer not null,
    holdout_count integer not null default 0
);

create or replace view activation_kpis as
select
    s.activation_id,
    s.audience_name,
    s.destination,
    s.eligible_count,
    s.blocked_count,
    s.attempted_count,
    s.accepted_count,
    s.failed_count,
    case when s.eligible_count = 0 then 0
         else s.eligible_count::decimal / nullif(s.eligible_count + s.blocked_count,0)
    end as eligibility_rate,
    case when s.attempted_count = 0 then 0
         else s.accepted_count::decimal / s.attempted_count
    end as delivery_acceptance_rate,
    case when s.eligible_count = 0 then 0
         else s.blocked_count::decimal / (s.eligible_count + s.blocked_count)
    end as blocked_rate,
    s.holdout_count
from activation_measurement_snapshot s;

create or replace view activation_outcomes as
select
    s.activation_id,
    s.audience_name,
    s.destination,
    count(distinct e.customer_id) as customers_with_outcome,
    coalesce(sum(e.order_value),0) as attributed_order_value
from activation_measurement_snapshot s
left join activation_outcome_events e
  on e.activation_id = s.activation_id
group by s.activation_id, s.audience_name, s.destination;

-- The outcome denominator remains the eligible population, not accepted payloads.
create or replace view activation_business_metrics as
select
    k.activation_id,
    k.audience_name,
    k.destination,
    k.eligibility_rate,
    k.delivery_acceptance_rate,
    o.customers_with_outcome,
    o.attributed_order_value,
    case when k.eligible_count = 0 then 0
         else o.customers_with_outcome::decimal / k.eligible_count
    end as audience_to_outcome_rate
from activation_kpis k
join activation_outcomes o
  on o.activation_id = k.activation_id;
