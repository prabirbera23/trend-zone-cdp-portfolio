-- Sprint 5 / Day 1
-- Canonical identity foundation for the portfolio simulation.

create table if not exists customer_profile (
    customer_id varchar(64) primary key,
    first_name varchar(128),
    last_name varchar(128),
    email varchar(320),
    phone varchar(64),
    profile_created_at timestamp,
    profile_updated_at timestamp,
    has_woocommerce boolean not null default false,
    has_offline_store boolean not null default false,
    has_marketplace boolean not null default false,
    has_salesforce boolean not null default false,
    constraint chk_customer_id_format
        check (customer_id like 'TZ-CUST-%')
);

create table if not exists identity_crosswalk (
    customer_id varchar(64) not null,
    source_system varchar(64) not null,
    source_entity varchar(64) not null,
    source_record_id varchar(255) not null,
    id_type varchar(64) not null,
    match_method varchar(128) not null,
    confidence decimal(4,3) not null,
    first_seen_at timestamp,
    last_seen_at timestamp,
    active boolean not null default true,
    primary key (source_system, source_entity, source_record_id),
    foreign key (customer_id) references customer_profile(customer_id),
    constraint chk_confidence
        check (confidence between 0 and 1)
);

-- Ambiguous records are reviewed instead of being forced into a profile.
create table if not exists identity_review_queue (
    source_system varchar(64) not null,
    source_entity varchar(64) not null,
    source_record_id varchar(255) not null,
    candidate_customer_id varchar(64),
    review_reason varchar(255) not null,
    review_status varchar(32) not null default 'pending',
    observed_at timestamp,
    primary key (source_system, source_entity, source_record_id)
);
