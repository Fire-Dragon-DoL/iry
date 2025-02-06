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
    adapter: "postgresql",
    encoding: "unicode",
    url: ENV.fetch("DATABASE_URL", "postgres://postgres@localhost:5432/iry_test"),
    pool: Integer(ENV.fetch("DATABASE_POOL", "5"))
  }
)

require_relative "support/application_record"
require_relative "support/other_user"
require_relative "support/inheriting_user"
require_relative "support/user"
