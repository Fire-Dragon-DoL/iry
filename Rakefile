require "bundler/setup"

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_prelude = "require \"test/test_helper\""
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end

task(default: :test)
