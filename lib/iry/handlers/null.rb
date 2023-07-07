module Iry
  module Handlers
    # Catch-all handler for unrecognized database adapters
    # @private
    module Null
      extend self

      # Returns always true, catching any unhandled database exception
      # @param err [StandardError, ActiveRecord::StatementInvalid]
      # @return [Boolean]
      def handle?(err)
        return true
      end

      # Return always false, failing to handle any constraint
      # @param err [ActiveRecord::StatementInvalid]
      # @param model [Model] should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      # @return [Boolean]
      def handle(err, model)
        return false
      end
    end
  end
end
