module Iry
  module Constraint
    class Check
      # Infers the check constraint name based on key and table name
      # @param key [Symbol]
      # @param table_name [String]
      # @return [String]
      def self.infer_name(key, table_name)
        # PostgreSQL convention:
        # "#{table_name}_#{key}_check"
        # Rails convention
        id = "#{table_name}_#{key}_chk"
        hashed_id = OpenSSL::Digest::SHA256.hexdigest(id)[0..9]

        "chk_rails_#{hashed_id}"
      end

      # @return [Symbol]
      attr_accessor :key
      # @return [Symbol, String]
      attr_accessor :message
      # @return [String]
      attr_accessor :name

      # @param key [Symbol] key to apply error message for check constraint to
      # @param message [Symbol, String] the validation error message
      # @param name [String] constraint name
      def initialize(
        key,
        name:,
        message: :invalid
      )
        @key = key
        @message = message
        @name = name
      end

      # @param model [Handlers::Model]
      # @return [ActiveModel::Error]
      def apply(model)
        model.errors.add(key, message)
      end
    end
  end
end
