module Iry
  module Constraint
    class ForeignKey
      # Infers the unique constraint name based on keys and table name
      # @param keys [<Symbol>]
      # @param table_name [String]
      # @return [String]
      def self.infer_name(keys, table_name)
        if keys.size > 1
          # PostgreSQL convention:
          return "#{table_name}_#{keys.join("_")}_fkey"
        end

        # Rails convention:
        column = keys.first
        id = "#{table_name}_#{column}_fk"
        hashed_id = OpenSSL::Digest::SHA256.hexdigest(id)[0..9]

        "fk_rails_#{hashed_id}"
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
        message: :required
      )
        @keys = keys
        @message = message
        @name = name
        @error_key = error_key
      end

      # @param model [Handlers::Model]
      # @return [ActiveModel::Error]
      def apply(model)
        model.errors.add(error_key, message)
      end
    end
  end
end
