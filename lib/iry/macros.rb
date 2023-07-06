module Iry
  module Macros
    # Constraints by name
    # @return [{String => Constraint}]
    def constraints
      @constraints ||= {}
    end

    # Tracks uniqueness constraint for the given key (or keys) and convert constraint errors into validation errors
    # @param key_or_keys [Symbol, <Symbol>] key or array of keys to track the uniqueness constraint of
    # @param message [Symbol, String] the validation error message
    # @param name [nil, String] constraint name. If omitted, it will be inferred using table name + keys
    # @param error_key [nil, Symbol] key to which the validation error will be applied to
    # @return [void]
    def unique_constraint(
      key_or_keys,
      message: :taken,
      name: nil,
      error_key: nil
    )
      keys = Array(key_or_keys)
      name ||= Constraint::Unique.infer_name(keys, table_name)
      error_key = keys.first

      if constraints.key?(name)
        raise ArgumentError, "Constraint already exists"
      end

      constraints[name] = Constraint::Unique.new(
        keys,
        message: message,
        name: name,
        error_key: error_key
      )
    end

    # Tracks check constraint for the given key and convert constraint errors into validation errors
    # @param key [Symbol] key to apply validation errors to
    # @param message [Symbol, String] the validation error message
    # @param name [nil, String] constraint name. If omitted, it will be inferred using table name + key
    # @return [void]
    def check_constraint(
      key,
      message: :invalid,
      name: nil
    )
      name ||= Constraint::Check.infer_name(key, table_name)

      if constraints.key?(name)
        raise ArgumentError, "Constraint already exists"
      end

      constraints[name] = Constraint::Check.new(
        key,
        message: message,
        name: name
      )
    end

    # Tracks exclusion constraint for the given key and convert constraint errors into validation errors
    # @param key [Symbol] key to apply validation errors to
    # @param message [Symbol, String] the validation error message
    # @param name [nil, String] constraint name. If omitted, it will be inferred using table name + key
    # @return [void]
    def exclusion_constraint(
      key,
      message: :taken,
      name: nil
    )
      name ||= Constraint::Exclusion.infer_name(key, table_name)

      if constraints.key?(name)
        raise ArgumentError, "Constraint already exists"
      end

      constraints[name] = Constraint::Exclusion.new(
        key,
        message: message,
        name: name
      )
    end
  end
end
