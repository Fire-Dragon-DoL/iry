require_relative "iry/version"
require_relative "iry/handlers"
require_relative "iry/handlers/null"
require_relative "iry/handlers/pg"
require_relative "iry/callbacks"
require_relative "iry/macros"
require_relative "iry/constraint"
require_relative "iry/constraint/check"
require_relative "iry/constraint/exclusion"
require_relative "iry/constraint/unique"

module Iry
  def self.included(klass)
    klass.class_eval do
      extend(Iry::Macros)
      around_save(Iry::Callbacks)
    end
  end
end
