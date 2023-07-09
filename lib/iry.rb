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
  # Raised when constraint errors have been violated and have been converted to
  # model errors
  class RecordInvalid < ActiveRecord::RecordInvalid
  end

  # @param klass [Module]
  # @return [void]
  # @private
  def self.included(klass)
    klass.class_eval do
      # From activesupport
      class_attribute(:constraints)
      self.constraints = {}
      extend(Iry::Macros)
    end
  end

  # Executes block and in case of constraints violations on `model`, block is
  # halted and errors are appended to `model`
  # @param model [Handlers::Model] model object for which constraints should be
  #   monitored and for which errors should be added to
  # @yield block must perform the save operation, usually with `save`
  # @return [nil, Handlers::Model] the `model` or `nil` if a  a constraint is
  #   violated
  def self.handle_constraints(model, &block)
    raise ArgumentError, "Block required" if block.nil?

    block.()

    return model
  rescue ActiveRecord::StatementInvalid => err
    handler = Handlers::Null
    case
    when Handlers::PG.handle?(err)
      handler = Handlers::PG
    end

    is_handled = handler.handle(err, model)

    if !is_handled
      raise
    end

    return nil
  end

  # Similar to {ActiveRecord::Base#save} but in case of constraint violations,
  # `false` is returned and `errors` are populated.
  # Aside from `model`, it takes the same arguments as
  # {ActiveRecord::Base#save}
  # @param model [Handlers::Model] model to save
  # @return [Boolean] `true` if successful
  def self.save(model, ...)
    success = nil
    constraint_model = handle_constraints(model) { success = model.save(...) }

    if constraint_model
      return success
    end

    return false
  end

  # Similar to {ActiveRecord::Base#save!} but in case of constraint violations,
  # it raises {RecordInvalid} and `errors` are populated.
  # Aside from `model`, it takes the same arguments as
  # {ActiveRecord::Base#save!}
  # @param model [Handlers::Model] model to save
  # @return [true]
  # @raise [RecordInvalid] {RecordInvalid} inherits from
  #   {ActiveRecord::RecordInvalid} but it's triggered only when a constraint
  #   violation happens
  # @raise [ActiveRecord::RecordInvalid] triggered when a validation error is
  #   raised, but not a constraint violation
  def self.save!(model, ...)
    constraint_model = handle_constraints(model) { model.save!(...) }

    if constraint_model
      return true
    end

    raise RecordInvalid.new(model)
  end
end
