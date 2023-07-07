require "active_record"

require_relative "iry/version"
require_relative "iry/handlers"
require_relative "iry/handlers/null"
require_relative "iry/handlers/pg"
require_relative "iry/callbacks"
require_relative "iry/macros"
require_relative "iry/constraint"
require_relative "iry/constraint/check"
require_relative "iry/constraint/exclusion"
require_relative "iry/constraint/foreign_key"
require_relative "iry/constraint/unique"

# Entrypoint of constraint validation, include in a class inheriting {ActiveRecord::Base} and the following class-level
# methods will be available:
# - {Macros#constraints}
# - {Macros#check_constraint}
# - {Macros#exclusion_constraint}
# - {Macros#foreign_key_constraint}
# - {Macros#unique_constraint}
#
# @example User unique constraint validation
#   # The database schema has a unique constraint on email field
#   class User < ActiveRecord::Base
#     include Iry
#
#     unique_constraint :email
#   end
#
#   user = User.create!(email: "user@example.com")
#   fail_user = User.create(email: "user@example.com")
#   fail_user.errors.details.fetch(:email) #=> [{error: :taken}]
module Iry
  # @param klass [Module]
  # @return [void]
  # @private
  def self.included(klass)
    klass.class_eval do
      extend(Iry::Macros)
      around_save(Iry::Callbacks)
    end
  end
end
