class User < ActiveRecord::Base
  include Iry

  belongs_to :user, optional: true

  unique_constraint :unique_text
  check_constraint :unique_text
end
