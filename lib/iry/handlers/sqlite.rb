module Iry
  module Handlers
    # Sqlite handler through `sqlite3` gem
    # @private
    module Sqlite
      extend self

      # @return [Regexp]
      REGEX = %r{
        (?:
          UNIQUE\sconstraint|
          CHECK\sconstraint
        )
        \sfailed(.+)?
      }x

      REGEX_CONSTRAINT_TYPE = /(UNIQUE|CHECK)\sconstraint/x

      # @return [Regexp]
      REGEX_CONSTRAINT_NAME = /(?:\:\sindex\s\'|\:\s)([^']+)\'?(?:\s\(\d+\))?$/x

      # When true, the handler is able to handle this exception, representing a constraint error in Sqlite.
      # This method must ensure not to raise exception in case the sqlite adapter is missing and as such, the
      # sqlite constant is undefined
      # @param err [ActiveRecord::StatementInvalid]
      # @return [Boolean]
      def handle?(err)
        return false if !Object.const_defined?("::SQLite3::ConstraintException")

        return true if err.cause.is_a?(::SQLite3::ConstraintException)

        return false
      end

      # Appends constraint errors as model errors
      # @param err [ActiveRecord::StatementInvalid]
      # @param model [Model] should inherit {ActiveRecord::Base} and`include Iry` to match the interface
      # @return [nil, ActiveModel::Error] if handled constraint, returns the
      #   error attached to the model. If constraint wasn't handled or handling
      #   failed, `nil` is returned
      def handle(err, model)
        sqliterr = err.cause
        constraint_name_msg = sqliterr.message
        constraint_type_match = REGEX_CONSTRAINT_TYPE.match(constraint_name_msg)
        if constraint_type_match.nil?
          return nil
        end

        constraint_type = constraint_type_match[1]
        match_constraint = REGEX.match(constraint_name_msg)
        if match_constraint.nil?
          return nil
        end

        match = REGEX_CONSTRAINT_NAME.match(match_constraint[1])
        if match.nil?
          return nil
        end

        constraint_name = nil
        case constraint_type
        in "UNIQUE"
          columns = match[1].
            split(", ").
            map { |full_col| full_col.delete_prefix("#{model.class.table_name}.") }
          constraint_name = Constraint::Unique.infer_name(
            columns,
            model.class.table_name
          )
        in "CHECK"
          constraint_name = match[1]
        else
          return nil
        end

        constraint = model.class.constraints[constraint_name]
        if constraint.nil?
          return nil
        end

        return constraint.apply(model)
      end
    end
  end
end
