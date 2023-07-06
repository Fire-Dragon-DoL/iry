module Iry
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
