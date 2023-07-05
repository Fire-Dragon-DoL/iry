create extension if not exists "pgcrypto";

create table users (
	id uuid primary key default gen_random_uuid(),
  unique_text text unique not null default '' check (unique_text != 'invalid'),
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null
);
