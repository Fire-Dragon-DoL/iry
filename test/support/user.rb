class User < ActiveRecord::Base
  include Iry

  belongs_to :user, optional: true
  belongs_to :friend_user, optional: true

  unique_constraint :unique_text
  check_constraint :unique_text
  exclusion_constraint :exclude_text
  foreign_key_constraint :user_id
  foreign_key_constraint :friend_user_id, error_key: :friend_user
end
