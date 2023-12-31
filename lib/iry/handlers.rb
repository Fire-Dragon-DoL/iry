module Iry
  module Handlers
    # Interface for handlers of different database types
    # @abstract
    module Handler
      # @abstract
      # @param err [ActiveRecord::StatementInvalid] possible constraint error to handle
      # @return [Boolean] true if this database handler is the correct one for this exception
      def handle?(err)
      end

      # @abstract
      # @param err [ActiveRecord::StatementInvalid] possible constraint error to handle
      # @param model [Model]
      # @return [nil, ActiveModel::Error] `nil` if couldn't handle the error,
      #   otherwise the {ActiveModel::Error} added to the model
      def handle(err, model)
      end
    end

    # Interface of the model class. This class is usually inherits from {ActiveRecord::Base}
    # @abstract
    module ModelClass
      # @abstract
      # @return [String]
      def table_name
      end

      # @abstract
      # @return [{String => Constraint}]
      def constraints
      end
    end

    # Interface of the model that should be used to handle constraints.
    # This object is an instance of {ActiveRecord::Base}
    # @abstract
    module Model
      # @abstract
      # @return [ActiveModel::Errors]
      def errors
      end

      # @!method class
      #   @abstract
      #   @return [ModelClass]
    end
  end
end
