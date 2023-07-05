module Iry
  module Callbacks
    extend self

    UNIQUE_REGEX = /unique\sconstraint\s"(.+)"/
    UNIQUE_KEY_REGEX = /Key\s\((.+)\)\=/
    # TODO: Auto index name
    # regexp = /unique\sconstraint\s"#{Regexp.escape(model.class.table_name)}_(.+)_key"/

    def around_save(model)
      yield
    rescue ActiveRecord::RecordNotUnique => err
      pgerr = err.cause
      constraint_name_msg = pgerr.result.error_field(PG::Result::PG_DIAG_MESSAGE_PRIMARY)
      match = UNIQUE_REGEX.match(constraint_name_msg)
      constraint_name = match[1]

      column_msg = pgerr.result.error_field(PG::Result::PG_DIAG_MESSAGE_DETAIL)
      match = UNIQUE_KEY_REGEX.match(column_msg)
      column = match[1].to_sym

      model.errors.add(column, :not_unique)
    end
  end
end
