source "https://rubygems.org"

# Specify your gem's dependencies in iry.gemspec
gemspec

gem "activerecord", require: "active_record"

group :development do
  gem "sorbet", require: false
  gem "sord", require: false
  gem "steep", require: false
  gem "tapioca", require: false
  gem "webrick", require: false
end

group :test do
  gem "mutex_m" # remove once minitest adds this
  gem "minitest"
  gem "minitest-power_assert"
  gem "minitest-reporters"
  gem "pg"
  gem "sqlite3"
end

group :development, :test do
  gem "pry-byebug"
  gem "rake", ">= 13"
end
