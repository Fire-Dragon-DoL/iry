module Iry
  # Main function to kick-off **Iry** constraint-checking mechanism
  # If interested in adding support for other databases beside Postgres, modify this file.
  # @private
  module Callbacks
    extend self

    # @param model [Handlers::Model]
    # @yield
    # @return [void]
    def around_save(model)
      yield
    rescue ActiveRecord::StatementInvalid => err
      handler = Handlers::Null
      case
      when Handlers::PG.handle?(err)
        handler = Handlers::PG
      end

      is_handled = handler.handle(err, model)

      if !is_handled
        raise
      end
    end
  end
end
