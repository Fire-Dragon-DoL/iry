create extension if not exists "pgcrypto";
create extension if not exists "btree_gist";

create table if not exists users (
	id uuid primary key default gen_random_uuid(),
  unique_text text not null default gen_random_uuid()::text,
  exclude_text text not null default gen_random_uuid()::text,
	user_id uuid,
  untracked_text text not null default gen_random_uuid()::text,
  free_text text not null default '',
	friend_user_id uuid,
	created_at timestamp(6) not null,
	updated_at timestamp(6) not null,
	-- acts similar to unique constraint
	exclude using gist (exclude_text with =)
);

create unique index if not exists
	index_users_on_unique_text on users(unique_text);
create unique index if not exists
	index_users_on_untracked_text on users(untracked_text);
alter table users
	add constraint chk_rails_15df0d7772 check (unique_text != 'invalid');
alter table users
	add constraint fk_rails_6d0b8b3c2f
		foreign key (user_id) references users(id);
alter table users
	add constraint fk_rails_d3f200176b
		foreign key (friend_user_id) references users(id);
