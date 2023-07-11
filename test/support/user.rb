class User < ActiveRecord::Base
  include Iry

  belongs_to :user, optional: true
  belongs_to :friend_user, optional: true

  has_many(
    :friend_users,
    class_name: "User",
    foreign_key: "friend_user_id"
  )

  accepts_nested_attributes_for :friend_users

  unique_constraint :unique_text
  check_constraint :unique_text
  exclusion_constraint :exclude_text
  foreign_key_constraint :user_id
  foreign_key_constraint :friend_user_id, error_key: :friend_user

  validates :free_text, allow_blank: true, format: {with: /\A(?:-|[a-zA-Z0-9])*\z/}

  after_save :retrieve_user

  def retrieve_user
    # Explicitly attempts to execute SQL code right after a constraint error
    # this should cause some unexpected behavior unless handled properly
    User.first
  end
end
