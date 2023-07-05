module Iry
  module Callbacks
    extend self

    # TODO: Auto index name
    # regexp = /unique\sconstraint\s"#{Regexp.escape(model.class.table_name)}_(.+)_key"/

    # @param model [ActiveRecord::Base]
    # @yield
    def around_save(model)
      yield
    rescue ActiveRecord::StatementInvalid => err
      case
      when Handlers::PG.handle?(err)
        Handlers::PG.handle(err, model)
      else
        raise
      end
    end
  end
end
