create extension if not exists "pgcrypto";
create extension if not exists "btree_gist";

create table if not exists users (
	id uuid primary key default gen_random_uuid(),
  unique_text text unique not null default gen_random_uuid()::text check (unique_text != 'invalid'),
  exclude_text text not null default gen_random_uuid()::text,
	user_id uuid references users (id),
  untracked_text text unique not null default gen_random_uuid()::text,
	friend_user_id uuid references users (id),
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null,
	-- acts similar to unique constraint
	exclude using gist (exclude_text with =)
);
