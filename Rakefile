require "bundler/setup"

require "bundler/gem_tasks"
require "minitest/test_task"

# Minitest::TestTask.create(:test) do |t|
#   t.libs << "test"
#   t.libs << "lib"
#   t.test_prelude = "require \"test/test_helper\""
#   t.warning = false
#   t.test_globs = ["test/**/*_test.rb"]
# end
Minitest::TestTask.create(:"test:pg") do |t|
  t.libs << "test/pg"
  t.libs << "lib"
  t.test_prelude = "require \"test/pg/test_helper\""
  t.warning = false
  t.test_globs = ["test/pg/**/*_test.rb"]
end
Minitest::TestTask.create(:"test:sqlite") do |t|
  t.libs << "test/sqlite"
  t.libs << "lib"
  t.test_prelude = "require \"test/sqlite/test_helper\""
  t.warning = false
  t.test_globs = ["test/sqlite/**/*_test.rb"]
end

task(default: [:"test:pg", :"test:sqlite"])
