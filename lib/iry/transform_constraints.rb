module Iry
  # Implementation of {Iry} methods, helps ensuring the main module focus on
  # documentation
  module TransformConstraints
    extend self

    # @param model [Handlers::Model]
    # @yield
    # @return [nil, Handlers::Model]
    def handle_constraints(model, &block)
      handle_constraints!(model, &block)
    rescue StatementInvalid
      return nil
    end

    # @param model [Handlers::Model]
    # @yield
    # @return [Handlers::Model]
    def handle_constraints!(model, &block)
      # Allows checking if Iry has been activated (handling).
      # Number is used to support nested handle_constraints!
      Thread.current[:iry] ||= 0
      Thread.current[:iry] += 1

      nested_constraints!(model, &block)
    rescue StatementInvalid => err
      # Imports errors from "nested" models back into the parent, to ensure
      # `errors` is populated and the record is considered invalid

      # Skip if error has been added to the same object being handled
      if err.record.object_id == model.object_id
        raise
      end

      # Adds the error only if it hasn't been added already
      already_imported = model
        .errors
        .each
        .lazy
        .select { |ae| ae.respond_to?(:inner_error) }
        .map { |ae| ae.inner_error }
        .include?(err.error)
      if !already_imported
        model.errors.import(err.error)
      end

      raise
    ensure
      # "Pop" handle_constraints! usage, when 0, no constraint handling should
      # happen
      Thread.current[:iry] -= 1
    end

    # Tracks constraints of models saved as a consequence of saving another
    # model. This usually represents a situation of model using
    # `accepts_nested_attributes_for`
    # @param model [Handlers::Model]
    # @yield
    # @return [Handlers::Model]
    # @private
    def nested_constraints!(model, &block)
      raise ArgumentError, "Block required" if block.nil?

      block.()

      return model
    rescue ActiveRecord::StatementInvalid => err
      # Exit immediately if Iry hasn't been activated
      if Thread.current[:iry].nil? || Thread.current[:iry] == 0
        raise
      end

      # Exception might be an unknown constraint that is not handled by Iry
      # yet. If that's the case, Null handler will ensure that everything
      # proceeds as if Iry wasn't involved
      handler = Handlers::Null
      case
      when Handlers::PG.handle?(err)
        handler = Handlers::PG
      when Handlers::Sqlite.handle?(err)
        handler = Handlers::Sqlite
      end

      model_error = handler.handle(err, model)

      # This constraint is not handled by Iry and should raise normally
      if model_error.nil?
        raise
      end

      raise(
        StatementInvalid.new(
          err.message,
          sql: err.sql,
          binds: err.binds,
          record: model,
          error: model_error
        )
      )
    end

    # @param model [Handlers::Model]
    # @return [Boolean]
    def save(model, ...)
      success = nil
      constraint_model = handle_constraints(model) { success = model.save(...) }

      if constraint_model
        return success
      end

      return false
    end

    # @param model [Handlers::Model]
    # @return [true]
    # @raise [ConstraintViolation]
    # @raise [ActiveRecord::RecordInvalid]
    def save!(model, ...)
      constraint_model = handle_constraints(model) { model.save!(...) }

      if constraint_model
        return true
      end

      raise ConstraintViolation.new(model)
    end

    # @param model [Handlers::Model]
    # @return [Handlers::Model]
    def destroy(model)
      constraint_result = handle_constraints(model) { model.destroy }

      if constraint_result.nil?
        return false
      end

      return constraint_result
    end
  end
end
