# typed: strong
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
#   fail_user = User.new(email: "user@example.com")
#   Iry.save(fail_user)
#   fail_user.errors.details.fetch(:email) #=> [{error: :taken}]
module Iry
  VERSION = T.let(File.read(File.expand_path("../../VERSION", __dir__)).strip.freeze, T.untyped)

  # Inherited from {ActiveRecord::RecordInvalid}, returns the model for
  # which the constraint violations have been detected
  sig { returns(Handlers::Model) }
  def record; end

  # _@param_ `klass`
  sig { params(klass: Module).void }
  def self.included(klass); end

  # Executes block and in case of constraints violations on `model`, block is
  # halted and errors are appended to `model`
  # 
  # _@param_ `model` — model object for which constraints should be monitored and for which errors should be added to
  # 
  # _@return_ — the `model` or `nil` if a  a constraint is
  # violated
  # 
  # Handle constraints for unique user
  # ```ruby
  # # The database schema has a unique constraint on email field
  # class User < ActiveRecord::Base
  #   include Iry
  # 
  #   unique_constraint :email
  # end
  # 
  # user = User.create!(email: "user@example.com")
  # fail_user = User.new(email: "user@example.com")
  # result = Iry.handle_constraints(fail_user) { fail_user.save }
  # result #=> nil
  # fail_user.errors.details.fetch(:email) #=> [{error: :taken}]
  # ```
  sig { params(model: Handlers::Model, block: T.untyped).void }
  def self.handle_constraints(model, &block); end

  # Executes block and in case of constraints violations on `model`, block is
  # halted, errors are appended to `model` and {StatementInvalid} is raised
  # 
  # _@param_ `model` — model object for which constraints should be monitored and for which errors should be added to
  # 
  # _@return_ — returns `model` parameter
  sig { params(model: Handlers::Model, block: T.untyped).returns(Handlers::Model) }
  def self.handle_constraints!(model, &block); end

  # Similar to {ActiveRecord::Base#save} but in case of constraint violations,
  # `false` is returned and `errors` are populated.
  # Aside from `model`, it takes the same arguments as
  # {ActiveRecord::Base#save}
  # 
  # _@param_ `model` — model to save
  # 
  # _@return_ — `true` if successful
  sig { params(model: Handlers::Model).returns(T::Boolean) }
  def self.save(model); end

  # Similar to {ActiveRecord::Base#save!} but in case of constraint violations,
  # it raises {ConstraintViolation} and `errors` are populated.
  # Aside from `model`, it takes the same arguments as
  # {ActiveRecord::Base#save!}
  # 
  # _@param_ `model` — model to save
  sig { params(model: Handlers::Model).returns(T::Boolean) }
  def self.save!(model); end

  # Similar to {ActiveRecord::Base#destroy} but in case of constraint
  # violations, `false` is returned and `errors` are populated.
  # 
  # _@param_ `model` — model to destroy
  # 
  # _@return_ — the destroyed model
  sig { params(model: Handlers::Model).returns(Handlers::Model) }
  def self.destroy(model); end

  # Included in all exceptions triggered by Iry, this allows to rescue any
  # gem-related exception by rescuing {Iry::Error}
  module Error
  end

  # Raised when constraints have been violated and have been converted to
  # model errors, on {ActiveRecord::Base#save!} calls, to simulate a behavior
  # similar to {ActiveRecord::RecordInvalid} when it's raised
  class ConstraintViolation < ActiveRecord::RecordInvalid
    include Iry::Error
  end

  # Raised when constraints errors happen and go through Iry, even if these
  # are not handled. This class inherits from {ActiveRecord::StatementInvalid}
  # to maximize compatibility with existing code
  class StatementInvalid < ActiveRecord::StatementInvalid
    include Iry::Error

    # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
    # sord omit - no YARD type given for "**kwargs", using untyped
    # _@param_ `message`
    # 
    # _@param_ `record`
    # 
    # _@param_ `error`
    sig do
      params(
        message: T.nilable(String),
        record: Handlers::Model,
        error: ActiveModel::Error,
        kwargs: T.untyped
      ).void
    end
    def initialize(message = nil, record:, error:, **kwargs); end

    # _@return_ — model affected by the constraint violation
    sig { returns(Handlers::Model) }
    attr_reader :record

    # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
    # _@return_ — error attached to the `record` for the
    # constraint violation
    sig { returns(ActiveModel::Error) }
    attr_reader :error
  end

  # Overrides private API method {ActiveRecord#create_or_update} to handle
  # constraints and attach errors to the including model
  module Patch
    # Takes attributes as named arguments
    # 
    # _@return_ — true if successful
    sig { returns(T::Boolean) }
    def create_or_update; end
  end

  # Class-level methods available to classes executing `include Iry`
  module Macros
    # Constraints by name
    sig { returns(T::Hash[String, Constraint]) }
    def constraints; end

    # Tracks check constraint for the given key and convert constraint errors into validation errors
    # 
    # _@param_ `key` — key to apply validation errors to
    # 
    # _@param_ `message` — the validation error message
    # 
    # _@param_ `name` — constraint name. If omitted, it will be inferred using table name + key
    sig { params(key: Symbol, name: T.nilable(String), message: T.any(Symbol, String)).void }
    def check_constraint(key, name: nil, message: :invalid); end

    # Tracks exclusion constraint for the given key and convert constraint errors into validation errors
    # 
    # _@param_ `key` — key to apply validation errors to
    # 
    # _@param_ `message` — the validation error message
    # 
    # _@param_ `name` — constraint name. If omitted, it will be inferred using table name + key
    sig { params(key: Symbol, name: T.nilable(String), message: T.any(Symbol, String)).void }
    def exclusion_constraint(key, name: nil, message: :taken); end

    # Tracks foreign key constraint for the given key (or keys) and convert constraint errors into validation errors
    # 
    # _@param_ `key_or_keys` — key or array of keys to track the foreign key constraint of
    # 
    # _@param_ `message` — the validation error message
    # 
    # _@param_ `name` — constraint name. If omitted, it will be inferred using table name + keys
    # 
    # _@param_ `error_key` — key to which the validation error will be applied to. If omitted, it will be applied to the first key
    sig do
      params(
        key_or_keys: T.any(Symbol, T::Array[Symbol]),
        name: T.nilable(String),
        message: T.any(Symbol, String),
        error_key: T.nilable(Symbol)
      ).void
    end
    def foreign_key_constraint(key_or_keys, name: nil, message: :required, error_key: nil); end

    # Tracks uniqueness constraint for the given key (or keys) and convert constraint errors into validation errors
    # 
    # _@param_ `key_or_keys` — key or array of keys to track the uniqueness constraint of
    # 
    # _@param_ `message` — the validation error message
    # 
    # _@param_ `name` — constraint name. If omitted, it will be inferred using table name + keys
    # 
    # _@param_ `error_key` — key to which the validation error will be applied to. If omitted, it will be applied to the first key
    sig do
      params(
        key_or_keys: T.any(Symbol, T::Array[Symbol]),
        name: T.nilable(String),
        message: T.any(Symbol, String),
        error_key: T.nilable(Symbol)
      ).void
    end
    def unique_constraint(key_or_keys, name: nil, message: :taken, error_key: nil); end
  end

  module Handlers
    # Interface for handlers of different database types
    # @abstract
    module Handler
      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # _@param_ `err` — possible constraint error to handle
      # 
      # _@return_ — true if this database handler is the correct one for this exception
      sig { params(err: ActiveRecord::StatementInvalid).returns(T::Boolean) }
      def handle?(err); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # _@param_ `err` — possible constraint error to handle
      # 
      # _@param_ `model`
      # 
      # _@return_ — `nil` if couldn't handle the error,
      # otherwise the {ActiveModel::Error} added to the model
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).void }
      def handle(err, model); end
    end

    # Interface of the model class. This class is usually inherits from {ActiveRecord::Base}
    # @abstract
    module ModelClass
      sig { returns(String) }
      def table_name; end

      sig { returns(T::Hash[String, Constraint]) }
      def constraints; end
    end

    # Interface of the model that should be used to handle constraints.
    # This object is an instance of {ActiveRecord::Base}
    # @abstract
    module Model
      # sord warn - ActiveModel::Errors wasn't able to be resolved to a constant in this project
      sig { returns(ActiveModel::Errors) }
      def errors; end

      sig { returns(ModelClass) }
      def class; end
    end

    # PostgreSQL handler through `pg` gem
    # @private
    module PG
      extend Iry::Handlers::PG
      REGEX = T.let(%r{
  (?:
    unique\sconstraint|
    check\sconstraint|
    exclusion\sconstraint|
    foreign\skey\sconstraint
  )
  \s"([^"]+)"
}x, T.untyped)

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # When true, the handler is able to handle this exception, representing a constraint error in PostgreSQL.
      # This method must ensure not to raise exception in case the postgresql adapter is missing and as such, the
      # postgres constant is undefined
      # 
      # _@param_ `err`
      sig { params(err: ActiveRecord::StatementInvalid).returns(T::Boolean) }
      def handle?(err); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # Appends constraint errors as model errors
      # 
      # _@param_ `err`
      # 
      # _@param_ `model` — should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      # 
      # _@return_ — if handled constraint, returns the
      # error attached to the model. If constraint wasn't handled or handling
      # failed, `nil` is returned
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).void }
      def handle(err, model); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # When true, the handler is able to handle this exception, representing a constraint error in PostgreSQL.
      # This method must ensure not to raise exception in case the postgresql adapter is missing and as such, the
      # postgres constant is undefined
      # 
      # _@param_ `err`
      sig { params(err: ActiveRecord::StatementInvalid).returns(T::Boolean) }
      def self.handle?(err); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # Appends constraint errors as model errors
      # 
      # _@param_ `err`
      # 
      # _@param_ `model` — should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      # 
      # _@return_ — if handled constraint, returns the
      # error attached to the model. If constraint wasn't handled or handling
      # failed, `nil` is returned
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).void }
      def self.handle(err, model); end
    end

    # Catch-all handler for unrecognized database adapters
    # @private
    module Null
      extend Iry::Handlers::Null

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # Returns always true, catching any unhandled database exception
      # 
      # _@param_ `err`
      sig { params(err: T.any(StandardError, ActiveRecord::StatementInvalid)).returns(T::Boolean) }
      def handle?(err); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # Return always false, failing to handle any constraint
      # 
      # _@param_ `err`
      # 
      # _@param_ `model` — should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).void }
      def handle(err, model); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # Returns always true, catching any unhandled database exception
      # 
      # _@param_ `err`
      sig { params(err: T.any(StandardError, ActiveRecord::StatementInvalid)).returns(T::Boolean) }
      def self.handle?(err); end

      # sord warn - ActiveRecord::StatementInvalid wasn't able to be resolved to a constant in this project
      # Return always false, failing to handle any constraint
      # 
      # _@param_ `err`
      # 
      # _@param_ `model` — should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).void }
      def self.handle(err, model); end
    end
  end

  # Main function to kick-off **Iry** constraint-checking mechanism
  # If interested in adding support for other databases beside Postgres, modify this file.
  # @private
  module Callbacks
    extend Iry::Callbacks

    # _@param_ `model`
    sig { params(model: Handlers::Model).void }
    def around_save(model); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).void }
    def self.around_save(model); end
  end

  # Interface representing a constraint.
  # A constraint has a name and can apply errors to an object inheriting from {ActiveRecord::Base}
  # @abstract
  module Constraint
    # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
    # Sets validation errors on the model
    # 
    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(ActiveModel::Error) }
    def apply(model); end

    # Name of the constraint to be caught from the database
    sig { returns(String) }
    def name; end

    # Message to be attached as validation error to the model
    # (see Handlers::Model)
    sig { returns(T.any(Symbol, String)) }
    def message; end

    class Check
      # Infers the check constraint name based on key and table name
      # 
      # _@param_ `key`
      # 
      # _@param_ `table_name`
      sig { params(key: Symbol, table_name: String).returns(String) }
      def self.infer_name(key, table_name); end

      # _@param_ `key` — key to apply error message for check constraint to
      # 
      # _@param_ `message` — the validation error message
      # 
      # _@param_ `name` — constraint name
      sig { params(key: Symbol, name: String, message: T.any(Symbol, String)).void }
      def initialize(key, name:, message: :invalid); end

      # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
      # _@param_ `model`
      sig { params(model: Handlers::Model).returns(ActiveModel::Error) }
      def apply(model); end

      sig { returns(Symbol) }
      attr_accessor :key

      sig { returns(T.any(Symbol, String)) }
      attr_accessor :message

      sig { returns(String) }
      attr_accessor :name
    end

    class Unique
      MAX_INFER_NAME_BYTE_SIZE = T.let(62, T.untyped)

      # Infers the unique constraint name based on keys and table name
      # 
      # _@param_ `keys`
      # 
      # _@param_ `table_name`
      sig { params(keys: T::Array[Symbol], table_name: String).returns(String) }
      def self.infer_name(keys, table_name); end

      # _@param_ `keys` — array of keys to track the uniqueness constraint of
      # 
      # _@param_ `message` — the validation error message
      # 
      # _@param_ `name` — constraint name
      # 
      # _@param_ `error_key` — key to which the validation error will be applied to
      sig do
        params(
          keys: T::Array[Symbol],
          name: String,
          error_key: Symbol,
          message: T.any(Symbol, String)
        ).void
      end
      def initialize(keys, name:, error_key:, message: :taken); end

      # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
      # _@param_ `model`
      sig { params(model: Handlers::Model).returns(ActiveModel::Error) }
      def apply(model); end

      sig { returns(T::Array[Symbol]) }
      attr_accessor :keys

      sig { returns(T.any(Symbol, String)) }
      attr_accessor :message

      sig { returns(String) }
      attr_accessor :name

      sig { returns(Symbol) }
      attr_accessor :error_key
    end

    class Exclusion
      # Infers the exclusion constraint name based on key and table name
      # 
      # _@param_ `key`
      # 
      # _@param_ `table_name`
      sig { params(key: Symbol, table_name: String).returns(String) }
      def self.infer_name(key, table_name); end

      # _@param_ `key` — key to apply error message for exclusion constraint to
      # 
      # _@param_ `message` — the validation error message
      # 
      # _@param_ `name` — constraint name
      sig { params(key: Symbol, name: String, message: T.any(Symbol, String)).void }
      def initialize(key, name:, message: :taken); end

      # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
      # _@param_ `model`
      sig { params(model: Handlers::Model).returns(ActiveModel::Error) }
      def apply(model); end

      sig { returns(Symbol) }
      attr_accessor :key

      sig { returns(T.any(Symbol, String)) }
      attr_accessor :message

      sig { returns(String) }
      attr_accessor :name
    end

    class ForeignKey
      # Infers the unique constraint name based on keys and table name
      # 
      # _@param_ `keys`
      # 
      # _@param_ `table_name`
      sig { params(keys: T::Array[Symbol], table_name: String).returns(String) }
      def self.infer_name(keys, table_name); end

      # _@param_ `keys` — array of keys to track the uniqueness constraint of
      # 
      # _@param_ `message` — the validation error message
      # 
      # _@param_ `name` — constraint name
      # 
      # _@param_ `error_key` — key to which the validation error will be applied to
      sig do
        params(
          keys: T::Array[Symbol],
          name: String,
          error_key: Symbol,
          message: T.any(Symbol, String)
        ).void
      end
      def initialize(keys, name:, error_key:, message: :required); end

      # sord warn - ActiveModel::Error wasn't able to be resolved to a constant in this project
      # _@param_ `model`
      sig { params(model: Handlers::Model).returns(ActiveModel::Error) }
      def apply(model); end

      sig { returns(T::Array[Symbol]) }
      attr_accessor :keys

      sig { returns(T.any(Symbol, String)) }
      attr_accessor :message

      sig { returns(String) }
      attr_accessor :name

      sig { returns(Symbol) }
      attr_accessor :error_key
    end
  end

  # Implementation of {Iry} methods, helps ensuring the main module focus on
  # documentation
  module TransformConstraints
    extend Iry::TransformConstraints

    # _@param_ `model`
    sig { params(model: Handlers::Model, block: T.untyped).void }
    def handle_constraints(model, &block); end

    # _@param_ `model`
    sig { params(model: Handlers::Model, block: T.untyped).returns(Handlers::Model) }
    def handle_constraints!(model, &block); end

    # Tracks constraints of models saved as a consequence of saving another
    # model. This usually represents a situation of model using
    # `accepts_nested_attributes_for`
    # 
    # _@param_ `model`
    sig { params(model: Handlers::Model, block: T.untyped).returns(Handlers::Model) }
    def nested_constraints!(model, &block); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(T::Boolean) }
    def save(model); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(T::Boolean) }
    def save!(model); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(Handlers::Model) }
    def destroy(model); end

    # _@param_ `model`
    sig { params(model: Handlers::Model, block: T.untyped).void }
    def self.handle_constraints(model, &block); end

    # _@param_ `model`
    sig { params(model: Handlers::Model, block: T.untyped).returns(Handlers::Model) }
    def self.handle_constraints!(model, &block); end

    # Tracks constraints of models saved as a consequence of saving another
    # model. This usually represents a situation of model using
    # `accepts_nested_attributes_for`
    # 
    # _@param_ `model`
    sig { params(model: Handlers::Model, block: T.untyped).returns(Handlers::Model) }
    def self.nested_constraints!(model, &block); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(T::Boolean) }
    def self.save(model); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(T::Boolean) }
    def self.save!(model); end

    # _@param_ `model`
    sig { params(model: Handlers::Model).returns(Handlers::Model) }
    def self.destroy(model); end
  end
end
