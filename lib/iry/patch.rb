module Iry
  # Overrides private API method {ActiveRecord#create_or_update} to handle
  # constraints and attach errors to the including model
  module Patch
    # Takes attributes as named arguments
    # @return [Boolean] true if successful
    def create_or_update(...)
      result = false
      Iry.handle_constraints!(self) { result = super }
      result
    end
  end
end
