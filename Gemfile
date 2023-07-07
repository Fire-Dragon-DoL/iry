source "https://rubygems.org"

# Specify your gem's dependencies in iry.gemspec
gemspec

gem "activerecord", require: "active_record"
gem "pry-byebug"
gem "sord", require: false
gem "webrick", require: false

group :development do
  gem "sorbet", require: false
  gem "steep", require: false
  gem "tapioca", require: false
end

group :test do
  gem "pg"
  gem "minitest"
  gem "minitest-power_assert"
end

group :development, :test do
  gem "rake", ">= 13"
end
