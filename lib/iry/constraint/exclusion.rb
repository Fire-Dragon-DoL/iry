module Iry
  module Constraint
    class Exclusion
      # Infers the exclusion constraint name based on key and table name
      # @param key [Symbol]
      # @param table_name [String]
      # @return [String]
      def self.infer_name(key, table_name)
        "#{table_name}_#{key}_excl"
      end

      # @return [Symbol]
      attr_accessor :key
      # @return [Symbol, String]
      attr_accessor :message
      # @return [String]
      attr_accessor :name

      # @param key [Symbol] key to apply error message for exclusion constraint to
      # @param message [Symbol, String] the validation error message
      # @param name [String] constraint name
      def initialize(
        key,
        message: :taken,
        name:
      )
        @key = key
        @message = message
        @name = name
      end

      # @param model [Handlers::Model]
      # @return [void]
      def apply(model)
        model.errors.add(key, message)
      end
    end
  end
end
