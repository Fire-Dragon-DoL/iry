module Iry
  module Handlers
    # PostgreSQL handler through `pg` gem
    # @private
    module PG
      extend self

      # @return [Regexp]
      REGEX = %r{
        (?:
          unique\sconstraint|
          check\sconstraint|
          exclusion\sconstraint|
          foreign\skey\sconstraint
        )
        \s"([^"]+)"
      }x

      # When true, the handler is able to handle this exception, representing a constraint error in PostgreSQL.
      # This method must ensure not to raise exception in case the postgresql adapter is missing and as such, the
      # postgres constant is undefined
      # @param err [ActiveRecord::StatementInvalid]
      # @return [Boolean]
      def handle?(err)
        return false if !Object.const_defined?("::PG::Error")
        return false if !err.cause.is_a?(::PG::Error)

        return true if err.cause.is_a?(::PG::UniqueViolation)
        return true if err.cause.is_a?(::PG::CheckViolation)
        return true if err.cause.is_a?(::PG::ExclusionViolation)
        return true if err.cause.is_a?(::PG::ForeignKeyViolation)

        return false
      end

      # Appends constraint errors as model errors
      # @param err [ActiveRecord::StatementInvalid]
      # @param model [Model] should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      # @return [nil, ActiveModel::Error] if handled constraint, returns the
      #   error attached to the model. If constraint wasn't handled or handling
      #   failed, `nil` is returned
      def handle(err, model)
        pgerr = err.cause
        constraint_name_msg = pgerr.result.error_field(::PG::Constants::PG_DIAG_MESSAGE_PRIMARY)
        match = REGEX.match(constraint_name_msg)
        constraint_name = match[1]
        constraint = model.class.constraints[constraint_name]
        if constraint.nil?
          return nil
        end

        return constraint.apply(model)
      end
    end
  end
end
