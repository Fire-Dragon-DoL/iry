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
#   fail_user = User.create(email: "user@example.com")
#   fail_user.errors.details.fetch(:email) #=> [{error: :taken}]
module Iry
  VERSION = T.let(File.read(File.expand_path("../../VERSION", __dir__)).strip.freeze, T.untyped)

  # _@param_ `klass`
  sig { params(klass: Module).void }
  def self.included(klass); end

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
      # _@return_ — true if this database handler handled the constraint error
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).returns(T::Boolean) }
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
  \s"(.+)"
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
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).returns(T::Boolean) }
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
      sig { params(err: ActiveRecord::StatementInvalid, model: Model).returns(T::Boolean) }
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
    # Sets validation errors on the model
    # 
    # _@param_ `model`
    sig { params(model: Handlers::Model).void }
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

      # _@param_ `model`
      sig { params(model: Handlers::Model).void }
      def apply(model); end

      sig { returns(Symbol) }
      attr_accessor :key

      sig { returns(T.any(Symbol, String)) }
      attr_accessor :message

      sig { returns(String) }
      attr_accessor :name
    end

    class Unique
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

      # _@param_ `model`
      sig { params(model: Handlers::Model).void }
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

      # _@param_ `model`
      sig { params(model: Handlers::Model).void }
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

      # _@param_ `model`
      sig { params(model: Handlers::Model).void }
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
end
