ENV["RAILS_ENV"] = "test"
Bundler.require(:default, :test)
Minitest::Reporters.use!(
  [
    Minitest::Reporters::DefaultReporter.new(
      color: true
    )
  ]
)

require "securerandom"
require "set"
require "iry"

ActiveRecord::Base.establish_connection(
  {
    adapter: "sqlite3",
    pool: Integer(ENV.fetch("DATABASE_POOL", "5")),
    timeout: 5000,
    database: "storage/test.sqlite3"
  }
)

require_relative "support/application_record"
require_relative "support/user"
