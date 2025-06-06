module Iry
  module Constraint
    class Unique
      MAX_INFER_NAME_BYTE_SIZE = 62

      # Infers the unique constraint name based on keys and table name
      # @param keys [<Symbol>]
      # @param table_name [String]
      # @return [String]
      def self.infer_name(keys, table_name)
        # PostgreSQL convention:
        # "#{table_name}_#{keys.join("_")}_key"

        # Rails convention:
        # index_trip_hikers_on_trip_id_and_hiker_card_id
        # index_TABLENAME_on_COLUMN1_and_COLUMN2
        name = "index_#{table_name}_on_#{keys.join("_and_")}"
        if name.bytesize <= MAX_INFER_NAME_BYTE_SIZE
          return name
        end

        digest = OpenSSL::Digest::SHA256.hexdigest(name)[0..9]
        hashed_id = "_#{digest}"
        name = "idx_on_#{keys.join("_")}"

        short_limit = MAX_INFER_NAME_BYTE_SIZE - hashed_id.bytesize
        short_name = name.mb_chars.limit(short_limit).to_s

        "#{short_name}#{hashed_id}"
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
      # @return [ActiveModel::Error]
      def apply(model)
        model.errors.add(error_key, message)
      end
    end
  end
end
