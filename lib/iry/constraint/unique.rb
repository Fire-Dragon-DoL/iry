module Iry
  module Constraint
    class Unique
      # Infers the unique constraint name based on keys and table name
      # @param keys [<Symbol>]
      # @param table_name [String]
      # @return [String]
      def self.infer_name(keys, table_name)
        "#{table_name}_#{keys.join("_")}_key"
      end

      # @return [<Symbol>]
      attr_accessor :keys
      # @return [Symbol, String]
      attr_accessor :message
      # @return [String]
      attr_accessor :name
      # @return [Symbol]
      attr_accessor :error_key

      # @param keys [<Symbol>] array of keys to track the uniqueness constraint of
      # @param message [Symbol, String] the validation error message
      # @param name [String] constraint name
      # @param error_key [Symbol] key to which the validation error will be applied to
      def initialize(
        keys,
        name:,
        error_key:,
        message: :taken
      )
        @keys = keys
        @message = message
        @name = name
        @error_key = error_key
      end

      # @param model [Handlers::Model]
      # @return [void]
      def apply(model)
        model.errors.add(error_key, message)
      end
    end
  end
end
