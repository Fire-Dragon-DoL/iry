module Iry
  # Interface representing a constraint.
  # A constraint has a name and can apply errors to an object inheriting from {ActiveRecord::Base}
  # @abstract
  module Constraint
    # Sets validation errors on the model
    # @abstract
    # @param model [Handlers::Model]
    # @return [ActiveModel::Error]
    def apply(model)
    end

    # Name of the constraint to be caught from the database
    # @abstract
    # @return [String]
    def name
    end

    # Message to be attached as validation error to the model
    # (see Handlers::Model)
    # @abstract
    # @return [Symbol, String]
    def message
    end
  end
end
