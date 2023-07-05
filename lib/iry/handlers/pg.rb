module Iry
  module Handlers
    module PG
      extend self

      UNIQUE_REGEX = /unique\sconstraint\s"(.+)"/
      UNIQUE_KEY_REGEX = /Key\s\((.+)\)\=/

      # When true, the handler is able to handle this exception, representing a constraint error in PostgreSQL.
      # This method must ensure not to raise exception in case the postgresql adapter is missing and as such, the
      # postgres constant is undefined
      # @param err [StandardError, ActiveRecord::StatementInvalid]
      # @return [Boolean]
      def handle?(err)
        return false if !err.is_a?(ActiveRecord::StatementInvalid)
        return false if !Object.const_defined?("::PG::Error")
        return false if !err.cause.is_a?(::PG::Error)
        return true
      end

      # Appends constraint errors as model errors
      # @param err [ActiveRecord::StatementInvalid]
      # @param model [ActiveRecord::Base]
      def handle(err, model)
        pgerr = err.cause
        constraint_name_msg = pgerr.result.error_field(::PG::Result::PG_DIAG_MESSAGE_PRIMARY)
        match = UNIQUE_REGEX.match(constraint_name_msg)
        constraint_name = match[1]

        column_msg = pgerr.result.error_field(::PG::Result::PG_DIAG_MESSAGE_DETAIL)
        match = UNIQUE_KEY_REGEX.match(column_msg)
        column = match[1].to_sym

        model.errors.add(column, :taken)
      end
    end
  end
end
