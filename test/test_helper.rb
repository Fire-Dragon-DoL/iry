ENV["RAILS_ENV"] = "test"
Bundler.require(:default, :development, :test)
require "securerandom"
require "iry"

ActiveRecord::Base.establish_connection(
  {
    adapter: "postgresql",
    encoding: "unicode",
    url: ENV.fetch("DATABASE_URL", "postgres://postgres@localhost:5432/iry_test"),
    pool: Integer(ENV.fetch("DATABASE_POOL", "5"))
  }
)

require_relative "support/user"
