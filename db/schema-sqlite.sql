create table users (
	id integer primary key,
  unique_text text not null default CURRENT_TIMESTAMP,
  exclude_text text not null default CURRENT_TIMESTAMP,
	user_id integer,
  untracked_text text not null default CURRENT_TIMESTAMP,
  free_text text not null default '',
	friend_user_id integer,
	created_at datetime(6) not null,
	updated_at datetime(6) not null,

  constraint chk_rails_15df0d7772
    check (unique_text != 'invalid'),

  foreign key(user_id) references users(id),
  foreign key(friend_user_id) references users(id)
);

create unique index
	index_users_on_unique_text on users(unique_text);
create unique index
	index_users_on_untracked_text on users(untracked_text);

create unique index
	index_users_on_unique_text_and_untracked_text on users(unique_text, untracked_text);
