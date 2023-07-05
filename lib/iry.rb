require_relative "iry/version"
require_relative "iry/callbacks"

module Iry
  class Error < StandardError
  end

  def self.included(klass)
    klass.class_eval do
      around_save(Iry::Callbacks)
    end
  end
end
